"""
widgets/charts.py
Visual helpers: sparklines, progress bars, metric tiles for Rich renderables.
Also provides Graph(Static) — a Dolphie-style plotext time-series widget.
"""
from __future__ import annotations

import contextlib
import math
from rich.text import Text
from rich.table import Table
from rich.panel import Panel
from rich.columns import Columns
from textual.widgets import Static

import plotext as plt

# Unicode block chars for sparklines (index 0=empty, 8=full)
_SPARK = " ▁▂▃▄▅▆▇█"


# ---------------------------------------------------------------------------
# Dolphie-style plotext Graph widget
# ---------------------------------------------------------------------------

class Graph(Static):
    """
    Textual Static widget that renders a time-series line chart using plotext.
    Mirrors Dolphie's Graph(Static) pattern: plt.build() → Text.from_ansi() → update().

    Usage:
        graph = Graph("CPU Load %", color=(84, 239, 174), unit="%", id="g-cpu")
        graph.update_data([3.2, 4.1, 5.0, ...])
    """

    DEFAULT_CSS = """
    Graph {
        height: 12;
        background: #0a0e1b;
        border: solid #384c7a;
        padding: 0;
    }
    """

    def __init__(
        self,
        label: str,
        color: tuple[int, int, int] = (68, 180, 255),
        unit: str = "",
        fmt_fn=None,
        **kwargs,
    ) -> None:
        super().__init__("", **kwargs)
        self.label = label
        self.color = color            # RGB tuple for plotext
        self.unit = unit              # suffix for y-axis labels
        self.fmt_fn = fmt_fn          # optional formatter: (float) -> str
        self._values: list[float] = []

    # ── Lifecycle ──────────────────────────────────────────────────────────

    def on_resize(self) -> None:
        """Re-render on terminal resize (same as Dolphie)."""
        self._draw()

    # ── Public API ─────────────────────────────────────────────────────────

    def update_data(self, values: list[float]) -> None:
        """Push new data and re-render."""
        self._values = list(values)
        self._draw()

    # ── Internal render ────────────────────────────────────────────────────

    def _draw(self) -> None:
        w = self.size.width
        h = self.size.height
        if not self._values or w < 8 or h < 4:
            return

        try:
            plt.clf()
            # Background + axes (dark theme matching Dolphie)
            plt.canvas_color((10, 14, 27))
            plt.axes_color((10, 14, 27))
            plt.ticks_color((133, 159, 213))
            plt.plotsize(w, h)

            y = self._values[-w:]
            x = list(range(len(y)))

            plt.plot(x, y, marker="braille", label=self.label, color=self.color)

            # Y-axis ticks
            max_y = max(y) if y else 1.0
            max_y = max_y if max_y > 0 else 1.0
            n_ticks = 4
            y_ticks = [i * max_y / n_ticks for i in range(n_ticks + 1)]

            if self.fmt_fn:
                y_labels = [self.fmt_fn(v) for v in y_ticks]
            else:
                # Auto-format: use .0f for large values, .2f for small
                if max_y >= 100:
                    y_labels = [f"{v:.0f}{self.unit}" for v in y_ticks]
                elif max_y >= 10:
                    y_labels = [f"{v:.1f}{self.unit}" for v in y_ticks]
                else:
                    y_labels = [f"{v:.2f}{self.unit}" for v in y_ticks]

            plt.yticks(y_ticks, y_labels)
            plt.xticks([])  # No x-axis labels (time-series rolling window)

            with contextlib.suppress(OSError, Exception):
                self.update(Text.from_ansi(plt.build()))

        except Exception:
            pass


# ---------------------------------------------------------------------------
# Lightweight Rich helpers (used in Static-based panels)
# ---------------------------------------------------------------------------

def sparkline(values: list[float], width: int = 30, color: str = "cyan") -> Text:
    """Render a Unicode sparkline from a list of floats."""
    if not values:
        return Text("─" * width, style="dim")
    recent = list(values)[-width:]
    mn, mx = min(recent), max(recent)
    rng = mx - mn if mx != mn else 1
    chars = [_SPARK[min(8, int((v - mn) / rng * 8))] for v in recent]
    pad = width - len(chars)
    result = Text(" " * pad, style="dim")
    result.append("".join(chars), style=color)
    return result


def pct_bar(pct: float, width: int = 20, show_pct: bool = True) -> Text:
    """Render a color-coded percentage bar."""
    pct = min(max(float(pct or 0), 0), 100)
    filled = int(pct / 100 * width)
    bar = "█" * filled + "░" * (width - filled)
    color = "green" if pct < 70 else ("yellow" if pct < 85 else "red")
    suffix = f" {pct:5.1f}%" if show_pct else ""
    return Text(f"{bar}{suffix}", style=color)


def color_for_pct(pct: float) -> str:
    """Return Rich color name based on percentage threshold."""
    if pct >= 85:
        return "bold red"
    if pct >= 70:
        return "bold yellow"
    return "bold green"


def fmt(val, decimals: int = 1, suffix: str = "") -> str:
    """Format a numeric value, returning N/A for None."""
    if val is None:
        return "N/A"
    try:
        return f"{float(val):,.{decimals}f}{suffix}"
    except (TypeError, ValueError):
        return str(val)


def metric_row(label: str, value: str, label_color: str = "cyan", value_color: str = "white") -> Text:
    """Single label: value line."""
    t = Text()
    t.append(f"{label:<18}", style=label_color)
    t.append(value, style=value_color)
    return t


def spark_row(label: str, values: list[float], width: int = 28, color: str = "cyan") -> Text:
    """Label + Unicode sparkline on one line (used where Graph widget isn't practical)."""
    t = Text()
    t.append(f"{label:<10}", style="dim")
    t.append_text(sparkline(values, width, color))
    return t


def wait_bar(event: str, time_s: float, max_time: float, wait_class: str, bar_width: int = 20) -> Text:
    """One wait event row with inline bar."""
    CLASS_COLORS = {
        "User I/O": "cyan", "Commit": "yellow", "Concurrency": "magenta",
        "Application": "red", "System I/O": "blue", "Network": "green",
        "Cluster": "bright_magenta", "Idle": "dim",
    }
    pct = (time_s / max_time * 100) if max_time > 0 else 0
    filled = int(pct / 100 * bar_width)
    bar = "█" * filled + "░" * (bar_width - filled)
    cls_color = CLASS_COLORS.get(wait_class, "white")
    t = Text()
    t.append(f" {event:<42}", style="white")
    t.append(f"{time_s:7.1f}s  ", style="yellow")
    t.append(bar, style=cls_color)
    t.append(f"  {wait_class}", style=f"dim {cls_color}")
    return t
