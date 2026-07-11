"""
widgets/explain_screen.py
Detail screen for SQL explain plan — pushed as modal, q to close.
Handles two data sources:
  • V$SQL_PLAN   → estimated plan  (cardinality, cost, bytes, predicates)
  • SQL Monitor  → runtime plan    (actual_rows, starts, elapsed, cpu, disk_reads)
"""
from __future__ import annotations

from textual.app import ComposeResult
from textual.screen import Screen
from textual.widgets import DataTable, Footer, Header, Static
from textual.binding import Binding
from textual.containers import Vertical
from rich.text import Text
from rich.panel import Panel


def _is_runtime_plan(plan_rows: list[dict]) -> bool:
    """Detect if plan rows contain runtime stats (SQL Monitor) vs. estimated (V$SQL_PLAN)."""
    return any(
        (r.get("actual_rows") or 0) > 0 or (r.get("starts") or 0) > 0
        for r in plan_rows
    )


class ExplainScreen(Screen):
    """Full-screen SQL detail view: text + execution plan."""

    BINDINGS = [
        Binding("q",      "dismiss", "Close", show=True),
        Binding("escape", "dismiss", "Close", show=False),
    ]

    def __init__(self, sql_id: str, sql_text: str, plan_rows: list[dict], **kwargs) -> None:
        super().__init__(**kwargs)
        self.sql_id    = sql_id
        self.sql_text  = sql_text
        self.plan_rows = plan_rows

    def compose(self) -> ComposeResult:
        yield Header(show_clock=False)
        with Vertical():
            yield Static(id="explain-sql")
            yield DataTable(id="explain-plan", show_cursor=False, zebra_stripes=True)
        yield Footer()

    def on_mount(self) -> None:
        self.title     = f"SQL Detail — {self.sql_id}"
        self.sub_title = "q to close"

        # SQL text panel
        sql_txt = Text()
        sql_txt.append(self.sql_text or "(no text available)", style="#e6edf3")
        self.query_one("#explain-sql", Static).update(
            Panel(sql_txt, title=f"[bold cyan]SQL ID: {self.sql_id}[/]",
                  border_style="cyan", padding=(0, 1))
        )

        dt: DataTable = self.query_one("#explain-plan")

        if not self.plan_rows:
            dt.add_columns("#", "Note")
            dt.add_row("—", "(no plan found — SQL may no longer be in shared pool)")
            return

        runtime = _is_runtime_plan(self.plan_rows)

        if runtime:
            # SQL Monitor plan: has execution stats
            dt.add_columns(
                "#", "Operation", "Object",
                "Est Rows", "Actual Rows", "Starts",
                "Elapsed(s)", "CPU(s)", "Disk Reads", "Status",
            )
            for r in self.plan_rows:
                pid    = r.get("plan_line_id", 0)
                depth  = int(r.get("depth", pid) or 0)
                indent = "  " * min(depth, 10)
                op     = str(r.get("operation", ""))
                obj    = str(r.get("object_name", "") or "")
                card   = int(r.get("cardinality", 0) or 0)
                actual = int(r.get("actual_rows", 0) or 0)
                starts = int(r.get("starts", 0) or 0)
                el     = float(r.get("elapsed_secs", 0) or 0)
                cpu    = float(r.get("cpu_secs", 0) or 0)
                disk   = int(r.get("disk_reads", 0) or 0)
                status = str(r.get("status", "") or "")
                status_c = "green" if status == "EXECUTING" else "dim"
                dt.add_row(
                    str(pid),
                    f"{indent}{op}",
                    obj,
                    f"{card:,}" if card else "—",
                    f"{actual:,}" if actual else "—",
                    f"{starts:,}" if starts else "—",
                    f"{el:,.1f}" if el else "—",
                    f"{cpu:,.1f}" if cpu else "—",
                    f"{disk:,}" if disk else "—",
                    Text(status, style=status_c) if status else Text(""),
                )
        else:
            # V$SQL_PLAN: estimated plan with predicates
            dt.add_columns(
                "#", "Operation", "Object",
                "Est Rows", "Cost", "Bytes",
                "Access Predicate", "Filter Predicate",
            )
            for r in self.plan_rows:
                pid    = r.get("plan_line_id", 0)
                depth  = int(r.get("depth", pid) or 0)
                indent = "  " * min(depth, 10)
                op     = str(r.get("operation", ""))
                obj    = str(r.get("object_name", "") or "")
                card   = int(r.get("cardinality", 0) or 0)
                cost   = int(r.get("cost", 0) or 0)
                byt    = int(r.get("bytes", 0) or 0)
                acc    = str(r.get("access_predicates", "") or "")
                fil    = str(r.get("filter_predicates", "") or "")
                # Color cost — high cost rows stand out
                cost_c = "red" if cost > 100000 else ("yellow" if cost > 10000 else "white")
                dt.add_row(
                    str(pid),
                    f"{indent}{op}",
                    obj,
                    f"{card:,}" if card else "—",
                    Text(f"{cost:,}", style=cost_c) if cost else Text("—", style="dim"),
                    f"{byt:,}" if byt else "—",
                    Text(acc[:60], style="dim yellow") if acc else Text(""),
                    Text(fil[:60], style="dim cyan") if fil else Text(""),
                )

    def action_dismiss(self) -> None:
        self.dismiss()
