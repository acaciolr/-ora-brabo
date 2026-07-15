"""
reports/generator.py
Builds a professional, multi-section PDF performance/health report from a
MetricsCache snapshot. Pure function of the cache — no live DB queries, so
it works identically against a demo session or a real (live) Oracle
connection, including RAC, Data Guard, and Exadata environments.

Synchronous / blocking (reportlab). Callers must run it off the asyncio
event loop, e.g. via `asyncio.to_thread(generate_report, cache, out_dir)`.
"""
from __future__ import annotations

import logging
from datetime import datetime
from pathlib import Path
from xml.sax.saxutils import escape as _xml_escape

from reportlab.graphics.charts.lineplots import LinePlot
from reportlab.graphics.shapes import Drawing, String
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.pdfgen import canvas as pdfcanvas
from reportlab.platypus import (
    BaseDocTemplate, Frame, PageBreak, PageTemplate, Paragraph,
    SimpleDocTemplate, Spacer, Table, TableStyle,
)
from reportlab.platypus.tableofcontents import TableOfContents

from core.cache import MetricsCache

log = logging.getLogger(__name__)

REPORTS_DIR = Path.home() / ".ora_brabo" / "reports"

_ACCENT = colors.HexColor("#1f6fb2")
_ACCENT_DARK = colors.HexColor("#14507f")
_RED    = colors.HexColor("#c0392b")
_YELLOW = colors.HexColor("#b8860b")
_GREEN  = colors.HexColor("#2e7d32")
_GREY_BG = colors.HexColor("#f5f7fa")
_GREY_LINE = colors.HexColor("#dfe3e8")
_SEV_COLORS = {"CRITICAL": _RED, "WARNING": _YELLOW, "INFO": colors.HexColor("#2472a4")}

_STYLES = getSampleStyleSheet()
_H1     = ParagraphStyle("ObH1", parent=_STYLES["Title"], textColor=colors.white, fontSize=19, leading=23)
_H2     = ParagraphStyle("ObH2", parent=_STYLES["Heading2"], textColor=_ACCENT_DARK, spaceBefore=16, spaceAfter=6,
                          borderColor=_ACCENT, borderWidth=0, leading=16)
_H3     = ParagraphStyle("ObH3", parent=_STYLES["Heading3"], textColor=_ACCENT, spaceBefore=8, spaceAfter=4)
_NORMAL = _STYLES["BodyText"]
_SMALL  = ParagraphStyle("ObSmall", parent=_STYLES["BodyText"], fontSize=8, textColor=colors.grey)
_NOTE   = ParagraphStyle("ObNote", parent=_STYLES["BodyText"], fontSize=7, textColor=colors.grey)
_CELL   = ParagraphStyle("ObCell", parent=_STYLES["BodyText"], fontSize=7, leading=9)
_TOC1   = ParagraphStyle("ObTOC1", parent=_STYLES["Normal"], fontName="Helvetica-Bold", fontSize=10.5,
                          leading=16, spaceBefore=4, textColor=colors.HexColor("#1a1a1a"))


# ---------------------------------------------------------------------------
# Small helpers — tolerate dict rows (demo mode) and dataclass rows (Finding),
# and tolerate the field-name drift between the real collectors and the demo
# mock data (e.g. ASM FRA in MB vs GB, RAC GC stats shape).
# ---------------------------------------------------------------------------

def _field(obj, name: str, default=None):
    if isinstance(obj, dict):
        return obj.get(name, default)
    return getattr(obj, name, default)


def _num(obj, name: str, default=0):
    v = _field(obj, name, default)
    return v if v is not None else default


def _pick_num(obj, *names, default=0):
    """Try several field-name variants in order — the demo mock and the real
    collectors sometimes disagree on naming (e.g. tablespaces: used_pct vs
    pct_used)."""
    for name in names:
        v = _field(obj, name)
        if v is not None:
            return v
    return default


def _txt(obj, name: str, default: str = "") -> str:
    v = _field(obj, name, default)
    return default if v is None else str(v)


def _fmt_dt(v) -> str:
    if isinstance(v, datetime):
        return v.strftime("%Y-%m-%d %H:%M")
    return str(v) if v is not None else ""


def _severity_str(sev) -> str:
    return str(getattr(sev, "value", sev)).upper()


def _pct_color(pct: float):
    if pct >= 85:
        return _RED
    if pct >= 70:
        return _YELLOW
    return _GREEN


def _hexcode(c) -> str:
    return "#%02x%02x%02x" % (int(c.red * 255), int(c.green * 255), int(c.blue * 255))


def _styled_table(header: list, rows: list[list], col_widths=None, font_size: int = 7) -> Table:
    t = Table([header] + rows, colWidths=col_widths, repeatRows=1)
    t.setStyle(TableStyle([
        ("BACKGROUND",      (0, 0), (-1, 0), _ACCENT),
        ("TEXTCOLOR",       (0, 0), (-1, 0), colors.white),
        ("FONTNAME",        (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE",        (0, 0), (-1, -1), font_size),
        ("GRID",            (0, 0), (-1, -1), 0.3, colors.HexColor("#cccccc")),
        ("ROWBACKGROUNDS",  (0, 1), (-1, -1), [colors.white, colors.HexColor("#f2f2f2")]),
        ("VALIGN",          (0, 0), (-1, -1), "TOP"),
        ("TOPPADDING",      (0, 0), (-1, -1), 3),
        ("BOTTOMPADDING",   (0, 0), (-1, -1), 3),
    ]))
    return t


def _line_chart(values: list, title: str, color=_ACCENT, width: int = 220, height: int = 95):
    values = [float(v) for v in values if isinstance(v, (int, float))]
    if len(values) < 2:
        return None
    try:
        d = Drawing(width, height)
        chart = LinePlot()
        chart.x = 30
        chart.y = 16
        chart.width = width - 42
        chart.height = height - 30
        chart.data = [list(enumerate(values))]
        chart.lines[0].strokeColor = color
        chart.lines[0].strokeWidth = 1.2
        chart.joinedLines = 1
        vmin, vmax = min(values), max(values)
        if vmin == vmax:
            vmax = vmin + 1
        pad = (vmax - vmin) * 0.15 or 1
        chart.yValueAxis.valueMin = max(0, vmin - pad)
        chart.yValueAxis.valueMax = vmax + pad
        chart.yValueAxis.labels.fontSize = 6
        chart.xValueAxis.labels.fontSize = 6
        chart.xValueAxis.valueMin = 0
        chart.xValueAxis.valueMax = max(len(values) - 1, 1)
        d.add(chart)
        d.add(String(width / 2, height - 8, title, textAnchor="middle", fontSize=8, fillColor=colors.black))
        return d
    except Exception:
        log.warning("Chart render failed for %r", title, exc_info=True)
        return None


def _kpi_card(label: str, value: str, color_hex: str = "#1f6fb2") -> Table:
    p_label = Paragraph(f'<font size=7 color="#6b7280">{_xml_escape(label).upper()}</font>', _NORMAL)
    p_value = Paragraph(f'<font size=15 color="{color_hex}"><b>{_xml_escape(str(value))}</b></font>', _NORMAL)
    card = Table([[p_label], [p_value]], colWidths=[4.1 * cm])
    card.setStyle(TableStyle([
        ("BACKGROUND",    (0, 0), (-1, -1), _GREY_BG),
        ("BOX",           (0, 0), (-1, -1), 0.6, _GREY_LINE),
        ("TOPPADDING",    (0, 0), (-1, 0), 6),
        ("BOTTOMPADDING", (0, 0), (-1, 0), 1),
        ("TOPPADDING",    (0, 1), (-1, 1), 0),
        ("BOTTOMPADDING", (0, 1), (-1, 1), 8),
        ("LEFTPADDING",   (0, 0), (-1, -1), 8),
        ("RIGHTPADDING",  (0, 0), (-1, -1), 8),
    ]))
    return card


def _kpi_row(cards: list) -> Table:
    row = Table([cards], colWidths=[4.3 * cm] * len(cards))
    row.setStyle(TableStyle([("VALIGN", (0, 0), (-1, -1), "TOP")]))
    return row


def _overall_status(cache: MetricsCache):
    findings = cache.get("advisor.findings", []) or []
    crit = sum(1 for f in findings if _severity_str(_field(f, "severity", "INFO")) == "CRITICAL")
    warn = sum(1 for f in findings if _severity_str(_field(f, "severity", "INFO")) == "WARNING")
    blockers = len(cache.get("locks.blockers", []) or [])
    if crit > 0:
        return "ATTENTION REQUIRED", _RED, crit, warn, blockers
    if warn > 0 or blockers > 0:
        return "MINOR ISSUES", _YELLOW, crit, warn, blockers
    return "HEALTHY", _GREEN, crit, warn, blockers


# ---------------------------------------------------------------------------
# Cover page
# ---------------------------------------------------------------------------

def _build_cover(cache: MetricsCache) -> list:
    db_info = cache.get("health.db_info", {}) or {}
    now = datetime.now()
    startup = _field(db_info, "startup_time")
    uptime = "N/A"
    if isinstance(startup, datetime):
        delta = now - startup
        uptime = f"{delta.days}d {delta.seconds // 3600}h {(delta.seconds % 3600) // 60}m"

    status_label, status_color, crit, warn, blockers = _overall_status(cache)

    cpu         = cache.get("health.cpu_load", 0) or 0
    total_sess  = cache.get("health.total_sessions", 0) or 0
    active_sess = cache.get("health.active_sessions", 0) or 0
    sga         = cache.get("health.sga_mb", 0) or 0
    pga         = cache.get("health.pga_mb", 0) or 0
    ts_list     = cache.get("awr.tablespaces", []) or []
    avg_ts_pct  = (sum(_pick_num(t, "used_pct", "pct_used") for t in ts_list) / len(ts_list)) if ts_list else 0.0

    banner = Table([[Paragraph(
        "ORA BRABO &mdash; Database Performance &amp; Health Report", _H1)]], colWidths=[18 * cm])
    banner.setStyle(TableStyle([
        ("BACKGROUND",    (0, 0), (-1, -1), _ACCENT_DARK),
        ("TOPPADDING",    (0, 0), (-1, -1), 16),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 16),
        ("LEFTPADDING",   (0, 0), (-1, -1), 16),
    ]))

    status_bar = Table([[Paragraph(
        f"Overall Status: <b>{status_label}</b> &mdash; {crit} critical, {warn} warning finding(s), "
        f"{blockers} blocking session(s)",
        ParagraphStyle("statusbar", parent=_NORMAL, textColor=colors.white, fontSize=10))]], colWidths=[18 * cm])
    status_bar.setStyle(TableStyle([
        ("BACKGROUND",    (0, 0), (-1, -1), status_color),
        ("TOPPADDING",    (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
        ("LEFTPADDING",   (0, 0), (-1, -1), 16),
    ]))

    id_rows = [
        ["Database",    _txt(db_info, "db_name", "N/A"),        "Role",      _txt(db_info, "database_role", "N/A")],
        ["Unique Name", _txt(db_info, "db_unique_name", "N/A"), "Version",   _txt(db_info, "version", "N/A")],
        ["Host",        _txt(db_info, "host_name", "N/A"),      "Instance",  _txt(db_info, "instance_name", "N/A")],
        ["Open Mode",   _txt(db_info, "open_mode", "N/A"),      "CDB",       _txt(db_info, "cdb", "N/A")],
        ["Log Mode",    _txt(db_info, "log_mode", "N/A"),       "Flashback", _txt(db_info, "flashback_on", "N/A")],
        ["Uptime",      uptime,                                 "Generated", now.strftime("%Y-%m-%d %H:%M:%S")],
    ]
    id_table = Table(id_rows, colWidths=[2.8 * cm, 6 * cm, 2.5 * cm, 6.5 * cm])
    id_table.setStyle(TableStyle([
        ("FONTSIZE",      (0, 0), (-1, -1), 8.5),
        ("FONTNAME",      (0, 0), (0, -1), "Helvetica-Bold"),
        ("FONTNAME",      (2, 0), (2, -1), "Helvetica-Bold"),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ("LINEBELOW",     (0, 0), (-1, -1), 0.3, _GREY_LINE),
    ]))

    cards_row1 = _kpi_row([
        _kpi_card("CPU Load", f"{float(cpu):.2f}"),
        _kpi_card("Active / Total Sessions", f"{active_sess} / {total_sess}"),
        _kpi_card("Uptime", uptime),
        _kpi_card("Blocking Sessions", str(blockers), "#c0392b" if blockers else "#2e7d32"),
    ])
    cards_row2 = _kpi_row([
        _kpi_card("Avg Tablespace Usage", f"{avg_ts_pct:.1f}%", _hexcode(_pct_color(avg_ts_pct))),
        _kpi_card("SGA (MB)", f"{float(sga):,.0f}"),
        _kpi_card("PGA (MB)", f"{float(pga):,.0f}"),
        _kpi_card("Critical / Warning", f"{crit} / {warn}",
                  "#c0392b" if crit else ("#b8860b" if warn else "#2e7d32")),
    ])

    return [
        banner, status_bar, Spacer(1, 16),
        id_table, Spacer(1, 16),
        cards_row1, Spacer(1, 8),
        cards_row2,
    ]


# ---------------------------------------------------------------------------
# Section builders — each returns a list of flowables (no leading heading —
# the orchestrator in generate_report() adds the numbered section heading).
# Sections tied to optional architecture (RAC/Data Guard/ASM/Exadata/ADDM)
# return [] to skip entirely when not applicable. Sections that are always
# relevant (Health, Waits, SQL, Tablespaces, Segments, Locks, RMAN) always
# return content, falling back to an explicit "no data" / "all clear" note.
# ---------------------------------------------------------------------------

def _build_summary(cache: MetricsCache) -> list:
    findings = cache.get("advisor.findings", []) or []
    if not findings:
        return [Paragraph("No advisor findings available.", _NORMAL)]

    story = []
    counts = {"CRITICAL": 0, "WARNING": 0, "INFO": 0}
    for f in findings:
        sev = _severity_str(_field(f, "severity", "INFO"))
        counts[sev] = counts.get(sev, 0) + 1
    story.append(Paragraph(
        f"<b>{counts['CRITICAL']}</b> critical, <b>{counts['WARNING']}</b> warning, "
        f"<b>{counts['INFO']}</b> info findings detected.", _NORMAL))
    story.append(Spacer(1, 6))

    important = [f for f in findings if _severity_str(_field(f, "severity", "INFO")) in ("CRITICAL", "WARNING")]
    if important:
        rows = []
        for f in important[:15]:
            detail = _xml_escape(_txt(f, "detail"))
            suggestion = _xml_escape(_txt(f, "suggestion"))
            body = detail
            if suggestion:
                body = f"{body}<br/><i>{suggestion}</i>" if body else f"<i>{suggestion}</i>"
            rows.append([
                _severity_str(_field(f, "severity", "INFO")),
                _txt(f, "category"),
                _xml_escape(_txt(f, "title")),
                Paragraph(body, _CELL),
            ])
        header = ["Sev", "Category", "Title", "Detail / Suggestion"]
        t = _styled_table(header, rows, col_widths=[1.8 * cm, 2.2 * cm, 4 * cm, 8 * cm])
        extra = []
        for i, f in enumerate(important[:15], start=1):
            sev = _severity_str(_field(f, "severity", "INFO"))
            extra.append(("TEXTCOLOR", (0, i), (0, i), _SEV_COLORS.get(sev, colors.black)))
            extra.append(("FONTNAME", (0, i), (0, i), "Helvetica-Bold"))
        t.setStyle(TableStyle(extra))
        story.append(t)
    return story


def _build_health(cache: MetricsCache) -> list:
    cpu         = cache.get("health.cpu_load", 0) or 0
    total_sess  = cache.get("health.total_sessions", 0) or 0
    active_sess = cache.get("health.active_sessions", 0) or 0
    sga         = cache.get("health.sga_mb", 0) or 0
    pga         = cache.get("health.pga_mb", 0) or 0
    mem         = cache.get("health.memory", {}) or {}
    rates       = cache.get("health.rates", {}) or {}

    snap_rows = [
        ["CPU Load",         f"{float(cpu):.2f}",                            "Total Sessions",   str(total_sess)],
        ["Active Sessions",  str(active_sess),                               "SGA (MB)",         f"{float(sga):,.0f}"],
        ["PGA (MB)",         f"{float(pga):,.0f}",                           "Free Mem (MB)",    f"{_num(mem, 'free_mb'):,.0f}"],
        ["Redo MB/s",        f"{_num(rates, 'redo_mb_per_sec'):.3f}",        "Logical Reads/s",  f"{_num(rates, 'logical_reads_per_sec'):,.0f}"],
        ["Physical Reads/s", f"{_num(rates, 'physical_reads_per_sec'):,.0f}","Hard Parses/s",     f"{_num(rates, 'hard_parses_per_sec'):,.0f}"],
        ["Commits/s",        f"{_num(rates, 'commits_per_sec'):,.0f}",       "Executes/s",       f"{_num(rates, 'executes_per_sec'):,.0f}"],
    ]
    t = Table(snap_rows, colWidths=[3.5 * cm, 3 * cm, 3.5 * cm, 3 * cm])
    t.setStyle(TableStyle([
        ("FONTSIZE", (0, 0), (-1, -1), 8),
        ("FONTNAME", (0, 0), (0, -1), "Helvetica-Bold"),
        ("FONTNAME", (2, 0), (2, -1), "Helvetica-Bold"),
        ("GRID",     (0, 0), (-1, -1), 0.25, _GREY_LINE),
    ]))
    story = [t, Spacer(1, 10)]

    cpu_hist   = cache.get_history_values("health.cpu_load") or []
    sess_hist  = cache.get_history_values("health.active_sessions") or []
    rates_hist = cache.get_history_values("health.rates") or []
    redo_hist  = [r.get("redo_mb_per_sec") for r in rates_hist if isinstance(r, dict) and isinstance(r.get("redo_mb_per_sec"), (int, float))]
    lread_hist = [r.get("logical_reads_per_sec") for r in rates_hist if isinstance(r, dict) and isinstance(r.get("logical_reads_per_sec"), (int, float))]

    charts = []
    for values, title in (
        (cpu_hist, "CPU Load — trend"),
        (sess_hist, "Active Sessions — trend"),
        (redo_hist, "Redo MB/s — trend"),
        (lread_hist, "Logical Reads/s — trend"),
    ):
        d = _line_chart(values, title)
        if d:
            charts.append(d)

    if charts:
        story.append(Paragraph("Trend based on in-memory sample history (not full AWR retention).", _NOTE))
        story.append(Spacer(1, 4))
        if len(charts) % 2:
            charts.append("")
        rows = [charts[i:i + 2] for i in range(0, len(charts), 2)]
        chart_table = Table(rows)
        chart_table.setStyle(TableStyle([("VALIGN", (0, 0), (-1, -1), "TOP")]))
        story.append(chart_table)
    else:
        story.append(Paragraph("Not enough history yet for trend charts.", _NORMAL))
    return story


def _build_locks(cache: MetricsCache) -> list:
    blockers = cache.get("locks.blockers", []) or []
    waiters = cache.get("locks.waiters", []) or []
    if not blockers and not waiters:
        return [Paragraph("No blocking sessions detected at time of report generation.",
                           ParagraphStyle("lockok", parent=_NORMAL, textColor=_GREEN))]

    story = [Paragraph(
        f"<b>{len(blockers)}</b> blocking session(s) detected at time of report generation.",
        ParagraphStyle("lockwarn", parent=_NORMAL, textColor=_RED))]
    story.append(Spacer(1, 4))
    if blockers:
        rows = [[
            str(_num(b, "sid")), _txt(b, "username"), _txt(b, "machine"),
            _txt(b, "program"), _txt(b, "lock_type"), str(_num(b, "ctime_secs")),
        ] for b in blockers[:15]]
        story.append(_styled_table(
            ["SID", "User", "Machine", "Program", "Lock Type", "Held (s)"], rows,
            col_widths=[1.8 * cm, 2.8 * cm, 3.5 * cm, 3.5 * cm, 2.5 * cm, 2 * cm]))

    if waiters:
        story.append(Spacer(1, 8))
        story.append(Paragraph(f"Waiting Sessions ({len(waiters)})", _H3))
        rows2 = [[
            str(_num(w, "waiter_sid")), _txt(w, "waiter_username"), _txt(w, "lock_type"),
        ] for w in waiters[:15]]
        story.append(_styled_table(["SID", "User", "Lock Type"], rows2, col_widths=[2 * cm, 4 * cm, 4 * cm]))
    return story


def _build_waits(cache: MetricsCache) -> list:
    story = []
    top = cache.get("waits.system_top", []) or []
    if top:
        rows = [[
            _txt(w, "event"), _txt(w, "wait_class"),
            f"{_num(w, 'total_waits'):,}", f"{_num(w, 'time_waited_sec'):,.1f}",
            f"{_num(w, 'avg_wait_ms'):,.2f}",
        ] for w in top[:10]]
        story.append(_styled_table(
            ["Event", "Class", "Waits", "Time (s)", "Avg (ms)"], rows,
            col_widths=[5 * cm, 3 * cm, 2.3 * cm, 2.5 * cm, 2.5 * cm]))
    else:
        story.append(Paragraph("No wait event data available.", _NORMAL))

    by_class = cache.get("waits.by_class", []) or []
    if by_class:
        rows2 = [[
            _txt(w, "wait_class"), str(_num(w, "session_count")), f"{_num(w, 'avg_wait_sec'):,.2f}",
        ] for w in by_class[:8]]
        story.append(Spacer(1, 6))
        story.append(_styled_table(["Wait Class", "Sessions", "Avg Wait (s)"], rows2,
                                    col_widths=[5 * cm, 3 * cm, 3 * cm]))

    awr_waits = cache.get("awr.top_waits", []) or []
    if awr_waits:
        story.append(Spacer(1, 8))
        story.append(Paragraph("Historical Top Waits (AWR)", _H3))
        rows3 = [[
            _txt(w, "event_name"), _txt(w, "wait_class"),
            f"{_num(w, 'total_waits'):,}", f"{_num(w, 'time_waited_secs'):,.1f}",
            f"{_num(w, 'avg_wait_ms'):,.2f}",
        ] for w in awr_waits[:10]]
        story.append(_styled_table(
            ["Event", "Class", "Waits", "Time (s)", "Avg (ms)"], rows3,
            col_widths=[5 * cm, 3 * cm, 2.3 * cm, 2.5 * cm, 2.5 * cm]))
    return story


def _build_sql(cache: MetricsCache) -> list:
    story = []
    top = cache.get("sql.top", []) or []
    if top:
        rows = [[
            _txt(r, "sql_id"), f"{_num(r, 'executions'):,}",
            f"{_num(r, 'cpu_sec'):,.2f}", f"{_num(r, 'elapsed_sec'):,.2f}",
            f"{_num(r, 'buffer_gets'):,}", _txt(r, "parsing_schema_name"),
        ] for r in top[:10]]
        story.append(_styled_table(
            ["SQL ID", "Exec", "CPU (s)", "Elapsed (s)", "Buffer Gets", "Schema"], rows,
            col_widths=[2.8 * cm, 1.8 * cm, 2.2 * cm, 2.5 * cm, 3 * cm, 2.7 * cm]))
    else:
        story.append(Paragraph("No SQL activity data available.", _NORMAL))

    awr_sql = cache.get("awr.top_sql", []) or []
    if awr_sql:
        story.append(Spacer(1, 8))
        story.append(Paragraph("Historical Top SQL (AWR)", _H3))
        rows2 = [[
            _txt(r, "sql_id"), f"{_num(r, 'elapsed_secs'):,.1f}", f"{_num(r, 'cpu_secs'):,.1f}",
            f"{_num(r, 'executions'):,}", f"{_num(r, 'buffer_gets'):,}",
            Paragraph(_xml_escape(_txt(r, "sql_text"))[:90], _CELL),
        ] for r in awr_sql[:10]]
        story.append(_styled_table(
            ["SQL ID", "Elapsed (s)", "CPU (s)", "Exec", "Buffer Gets", "SQL Text"], rows2,
            col_widths=[2.5 * cm, 2 * cm, 2 * cm, 1.8 * cm, 2.5 * cm, 4.2 * cm]))
    return story


def _build_tablespaces(cache: MetricsCache) -> list:
    ts = cache.get("awr.tablespaces", []) or []
    if not ts:
        return [Paragraph("No tablespace data available.", _NORMAL)]
    rows = [[
        _txt(t, "tablespace_name"), _txt(t, "status"),
        f"{_num(t, 'total_mb'):,.0f}", f"{_num(t, 'used_mb'):,.0f}",
        f"{_num(t, 'free_mb'):,.0f}", f"{_pick_num(t, 'used_pct', 'pct_used'):,.1f}",
    ] for t in ts[:30]]
    table = _styled_table(
        ["Tablespace", "Status", "Total (MB)", "Used (MB)", "Free (MB)", "Used %"], rows,
        col_widths=[4 * cm, 2 * cm, 2.3 * cm, 2.3 * cm, 2.3 * cm, 1.8 * cm])
    cmds = []
    for i, t in enumerate(ts[:30], start=1):
        pct = float(_pick_num(t, "used_pct", "pct_used"))
        cmds.append(("TEXTCOLOR", (5, i), (5, i), _pct_color(pct)))
        cmds.append(("FONTNAME", (5, i), (5, i), "Helvetica-Bold"))
    table.setStyle(TableStyle(cmds))
    return [table]


def _build_segments(cache: MetricsCache) -> list:
    story = []
    big = cache.get("obj.biggest_segments", []) or []
    if big:
        rows = [[
            _txt(s, "owner"), _txt(s, "segment_name"), _txt(s, "segment_type"),
            _txt(s, "tablespace_name"), f"{_num(s, 'size_mb'):,.1f}",
        ] for s in big[:15]]
        story.append(_styled_table(
            ["Owner", "Segment", "Type", "Tablespace", "Size (MB)"], rows,
            col_widths=[2.5 * cm, 3.5 * cm, 2 * cm, 2.5 * cm, 2.5 * cm]))
    else:
        story.append(Paragraph("No segment size data available.", _NORMAL))

    hot = cache.get("obj.top_segments", []) or []
    if hot:
        story.append(Spacer(1, 8))
        story.append(Paragraph("Segments Under Contention", _H3))
        rows2 = [[
            _txt(s, "owner"), _txt(s, "object_name"), _txt(s, "object_type"),
            _txt(s, "statistic_name"), f"{_num(s, 'value'):,}",
        ] for s in hot[:10]]
        story.append(_styled_table(
            ["Owner", "Segment", "Type", "Statistic", "Value"], rows2,
            col_widths=[2.5 * cm, 3.5 * cm, 2 * cm, 3 * cm, 2 * cm]))
    return story


def _dg_capacity_gb(d) -> tuple[float, float, float]:
    """Diskgroup capacity in GB — real collector reports GB directly,
    demo mock reports MB with a 'pct_used' key instead of 'used_pct'."""
    total_gb = _field(d, "total_gb")
    free_gb = _field(d, "free_gb")
    if total_gb is None:
        total_gb = _num(d, "total_mb") / 1024
    if free_gb is None:
        free_gb = _num(d, "free_mb") / 1024
    pct = _pick_num(d, "used_pct", "pct_used")
    return float(total_gb), float(free_gb), float(pct)


def _build_asm(cache: MetricsCache) -> list:
    dgs = cache.get("asm.diskgroups", []) or []
    if not dgs:
        return []
    rows = []
    for d in dgs[:15]:
        total_gb, free_gb, pct = _dg_capacity_gb(d)
        rows.append([
            _txt(d, "name"), _txt(d, "state"), _txt(d, "type"),
            f"{total_gb:,.1f}", f"{free_gb:,.1f}", f"{pct:,.1f}",
        ])
    story = [_styled_table(
        ["Diskgroup", "State", "Type", "Total (GB)", "Free (GB)", "Used %"], rows,
        col_widths=[3.5 * cm, 2 * cm, 2 * cm, 2.5 * cm, 2.5 * cm, 2 * cm])]

    fra = cache.get("asm.fra", {}) or {}
    if fra:
        story.append(Spacer(1, 8))
        # tolerate both GB (real collector) and MB (demo data) field naming
        if "fra_total_gb" in fra:
            total, used = _num(fra, "fra_total_gb"), _num(fra, "fra_used_gb")
        else:
            total, used = _num(fra, "total_mb") / 1024, _num(fra, "used_mb") / 1024
        pct = _num(fra, "used_pct")
        story.append(Paragraph(f"FRA usage: {used:,.1f}/{total:,.1f} GB ({pct:,.1f}%)", _NORMAL))
    return story


def _normalize_gc(gc) -> list[tuple]:
    """rac.gc_stats is dict{inst_id: stats} in production, list[dict] in demo mode."""
    if isinstance(gc, dict):
        return sorted(gc.items(), key=lambda kv: kv[0])
    if isinstance(gc, list):
        return sorted(((_num(r, "inst_id"), r) for r in gc), key=lambda kv: kv[0])
    return []


def _build_rac(cache: MetricsCache) -> list:
    if not cache.get("rac.detected", False):
        return []
    instances = cache.get("rac.instances", []) or []
    if not instances:
        return []

    rows = [[
        str(_num(i, "inst_id")), _txt(i, "instance_name"), _txt(i, "host_name"),
        _txt(i, "status"), str(_num(i, "total_sessions")), str(_num(i, "active_sessions")),
    ] for i in instances]
    story = [_styled_table(
        ["Inst", "Instance", "Host", "Status", "Sessions", "Active"], rows,
        col_widths=[1.5 * cm, 3 * cm, 4 * cm, 2 * cm, 2.3 * cm, 2 * cm])]

    gc_pairs = _normalize_gc(cache.get("rac.gc_stats", {}) or {})
    if gc_pairs:
        story.append(Spacer(1, 8))
        story.append(Paragraph("Global Cache (GC) Latency", _H3))
        rows2 = []
        for inst_id, stats in gc_pairs:
            cr_lat = _field(stats, "gc_cr_latency_ms")
            cr_lat = cr_lat if cr_lat is not None else _num(stats, "gc_latency_ms")
            cur_lat = _num(stats, "gc_cur_latency_ms")
            cr_blocks = _field(stats, "gc cr blocks received")
            cr_blocks = cr_blocks if cr_blocks is not None else _num(stats, "gc_cr_blocks_received")
            cur_blocks = _field(stats, "gc current blocks received")
            cur_blocks = cur_blocks if cur_blocks is not None else _num(stats, "gc_current_blocks_received")
            rows2.append([
                str(inst_id), f"{float(cr_lat or 0):,.3f}", f"{float(cur_lat or 0):,.3f}",
                f"{int(cr_blocks or 0):,}", f"{int(cur_blocks or 0):,}",
            ])
        story.append(_styled_table(
            ["Inst", "CR Latency (ms)", "Current Latency (ms)", "CR Blocks Rcvd", "Current Blocks Rcvd"], rows2,
            col_widths=[1.5 * cm, 3 * cm, 3.5 * cm, 3.3 * cm, 3.3 * cm]))

    ic = cache.get("rac.interconnect", []) or []
    if ic:
        story.append(Spacer(1, 8))
        story.append(Paragraph("Cluster Interconnect", _H3))
        rows3 = [[str(_num(x, "inst_id")), _txt(x, "name"), _txt(x, "ip_address")] for x in ic]
        story.append(_styled_table(["Inst", "Name", "IP Address"], rows3,
                                    col_widths=[1.5 * cm, 4 * cm, 5 * cm]))

    services = cache.get("rac.services", []) or []
    if services:
        story.append(Spacer(1, 8))
        story.append(Paragraph("Services", _H3))
        rows4 = [[
            _txt(s, "name"), _txt(s, "goal"), _txt(s, "svc_status"),
            _txt(s, "inst_id", "ANY") or "ANY",
        ] for s in services[:15]]
        story.append(_styled_table(["Service", "Goal", "Status", "Instance"], rows4,
                                    col_widths=[4 * cm, 2.5 * cm, 2.5 * cm, 2 * cm]))
    return story


def _build_dg(cache: MetricsCache) -> list:
    role = cache.get("dg.role", "") or ""
    stats = cache.get("dg.stats", {}) or {}
    standby = cache.get("dg.standby_processes", []) or cache.get("dg.rac_processes", []) or []
    if not role or (not stats and not standby):
        return []

    story = [Paragraph(
        f"Role: <b>{_xml_escape(role)}</b> &nbsp;&nbsp;|&nbsp;&nbsp; "
        f"Protection Mode: <b>{_xml_escape(cache.get('dg.protection_mode') or 'N/A')}</b>",
        _NORMAL)]
    story.append(Spacer(1, 6))

    if stats:
        rows = [[k, _txt(v, "value"), _txt(v, "unit")] for k, v in stats.items()]
        story.append(_styled_table(["Metric", "Value", "Unit"], rows, col_widths=[4 * cm, 6 * cm, 6 * cm]))

    if standby:
        story.append(Spacer(1, 8))
        story.append(Paragraph("Standby / Apply Processes", _H3))
        rows2 = [[
            _txt(p, "process"), _txt(p, "status"), str(_num(p, "sequence")),
            str(_num(p, "delay_mins")),
        ] for p in standby]
        story.append(_styled_table(["Process", "Status", "Sequence", "Delay (min)"], rows2,
                                    col_widths=[3 * cm, 4 * cm, 3 * cm, 3 * cm]))

    gap = cache.get("dg.archive_gap", None)
    if isinstance(gap, list) and gap:
        story.append(Spacer(1, 8))
        story.append(Paragraph("Archive Gap Detected", ParagraphStyle("dggap", parent=_H3, textColor=_RED)))
        rows3 = [[str(_num(g, "thread#")), str(_num(g, "low_seq")), str(_num(g, "high_seq"))] for g in gap]
        story.append(_styled_table(["Thread", "Low Seq", "High Seq"], rows3, col_widths=[3 * cm, 4 * cm, 4 * cm]))
    return story


def _build_exadata(cache: MetricsCache) -> list:
    if not cache.get("exa.detected", False):
        return []
    story = []
    ss = cache.get("exa.smart_scan", {}) or {}
    fc = cache.get("exa.flash_cache", {}) or {}
    cells = cache.get("exa.cells", []) or []

    if ss or fc:
        rows = [
            ["Smart Scan %",         f"{_num(ss, 'smart_scan_pct'):,.1f}%",    "Offload Efficiency", f"{_num(ss, 'offload_efficiency_pct'):,.1f}%"],
            ["Storage Index %",      f"{_num(ss, 'storage_index_pct'):,.1f}%", "Flash Cache Hit %",  f"{_num(fc, 'hit_pct'):,.1f}%"],
            ["Eligible for Offload", f"{_num(ss, 'eligible_gb'):,.1f} GB",     "Returned via IB",     f"{_num(ss, 'returned_gb'):,.1f} GB"],
        ]
        t = Table(rows, colWidths=[4 * cm, 3 * cm, 4.5 * cm, 3 * cm])
        t.setStyle(TableStyle([
            ("FONTSIZE", (0, 0), (-1, -1), 8),
            ("FONTNAME", (0, 0), (0, -1), "Helvetica-Bold"),
            ("FONTNAME", (2, 0), (2, -1), "Helvetica-Bold"),
            ("GRID",     (0, 0), (-1, -1), 0.25, _GREY_LINE),
        ]))
        story.append(t)
        story.append(Spacer(1, 8))

    if cells:
        story.append(Paragraph("Cell Servers", _H3))
        rows2 = [[
            _txt(c, "cell_name"), _txt(c, "ip_address"), _txt(c, "cell_status"), _txt(c, "cell_version"),
        ] for c in cells]
        story.append(_styled_table(["Cell", "IP Address", "Status", "Version"], rows2,
                                    col_widths=[3.5 * cm, 3.5 * cm, 2.5 * cm, 4.5 * cm]))
        story.append(Spacer(1, 8))

    cell_waits = cache.get("exa.cell_waits", []) or []
    if cell_waits:
        story.append(Paragraph("Top Cell Wait Events", _H3))
        rows3 = [[
            _txt(w, "event"), str(_num(w, "total_waits")),
            f"{_num(w, 'time_waited_secs'):,.1f}", f"{_num(w, 'avg_wait_ms'):,.2f}",
        ] for w in cell_waits[:10]]
        story.append(_styled_table(["Event", "Waits", "Time (s)", "Avg (ms)"], rows3,
                                    col_widths=[6 * cm, 2.5 * cm, 2.5 * cm, 2.5 * cm]))
        story.append(Spacer(1, 8))

    offload_sql = cache.get("exa.sql_offload", []) or []
    if offload_sql:
        story.append(Paragraph("Top SQL by Offload Efficiency", _H3))
        rows4 = [[
            _txt(s, "sql_id"), f"{_num(s, 'offload_pct'):,.1f}%",
            f"{_num(s, 'eligible_gb'):,.1f}", f"{_num(s, 'ib_gb'):,.1f}",
            _txt(s, "schema_name"),
        ] for s in offload_sql[:10]]
        story.append(_styled_table(["SQL ID", "Offload %", "Eligible GB", "IB GB", "Schema"], rows4,
                                    col_widths=[2.8 * cm, 2.3 * cm, 2.5 * cm, 2.3 * cm, 3 * cm]))
    return story


def _build_rman(cache: MetricsCache) -> list:
    history = cache.get("rman.history", []) or []
    backup_sets = cache.get("rman.backup_sets", []) or []
    if not history and not backup_sets:
        return [Paragraph(
            "No RMAN backup activity found in the last 7 days — verify backup configuration.",
            ParagraphStyle("rmanwarn0", parent=_NORMAL, textColor=_RED))]

    story = []
    if history:
        failed = [h for h in history if _txt(h, "status").upper() not in ("COMPLETED", "SUCCEEDED", "SUCCESS")]
        if failed:
            story.append(Paragraph(
                f"<b>{len(failed)}</b> RMAN job(s) did not complete successfully in the last 7 days.",
                ParagraphStyle("rmanwarn", parent=_NORMAL, textColor=_RED)))
            story.append(Spacer(1, 4))
        rows = [[
            _txt(h, "operation"), _txt(h, "input_type"), _txt(h, "status"),
            _fmt_dt(_field(h, "start_time")), _txt(h, "time_taken_display"),
            f"{_num(h, 'output_mb'):,.0f}",
        ] for h in history[:15]]
        table = _styled_table(
            ["Operation", "Type", "Status", "Start", "Duration", "Output (MB)"], rows,
            col_widths=[2.5 * cm, 3 * cm, 2.3 * cm, 3.5 * cm, 2.5 * cm, 2.5 * cm])
        cmds = []
        for i, h in enumerate(history[:15], start=1):
            if _txt(h, "status").upper() not in ("COMPLETED", "SUCCEEDED", "SUCCESS"):
                cmds.append(("TEXTCOLOR", (2, i), (2, i), _RED))
                cmds.append(("FONTNAME", (2, i), (2, i), "Helvetica-Bold"))
        table.setStyle(TableStyle(cmds))
        story.append(table)

    if backup_sets:
        story.append(Spacer(1, 8))
        story.append(Paragraph("Recent Backup Sets", _H3))
        rows2 = [[
            str(_num(b, "set_count")), _txt(b, "backup_type"), _txt(b, "device_type"),
            _fmt_dt(_field(b, "start_time")), f"{_num(b, 'size_mb'):,.0f}", _txt(b, "tag"),
        ] for b in backup_sets[:10]]
        story.append(_styled_table(
            ["Set#", "Type", "Device", "Start", "Size (MB)", "Tag"], rows2,
            col_widths=[1.8 * cm, 2.3 * cm, 2.5 * cm, 3.5 * cm, 2.5 * cm, 4 * cm]))
    return story


def _build_ops(cache: MetricsCache) -> list:
    jobs = cache.get("obj.scheduler_jobs", []) or []
    stale = cache.get("obj.stale_stats", []) or []
    if not jobs and not stale:
        return []

    story = []
    if jobs:
        failing = [j for j in jobs if _num(j, "failure_count") and _num(j, "failure_count") > 0]
        if failing:
            story.append(Paragraph(
                f"<b>{len(failing)}</b> scheduler job(s) with failures.",
                ParagraphStyle("jobwarn", parent=_NORMAL, textColor=_YELLOW)))
            story.append(Spacer(1, 4))
        rows = [[
            _txt(j, "owner"), _txt(j, "job_name"), _txt(j, "state"),
            str(_num(j, "run_count")), str(_num(j, "failure_count")),
        ] for j in jobs[:15]]
        story.append(_styled_table(
            ["Owner", "Job", "State", "Runs", "Failures"], rows,
            col_widths=[2.5 * cm, 4.5 * cm, 2.5 * cm, 2 * cm, 2 * cm]))

    if stale:
        story.append(Spacer(1, 8))
        story.append(Paragraph(f"Tables with Stale/Missing Statistics ({len(stale)})", _H3))
        rows2 = []
        for s in stale[:15]:
            days = _field(s, "days_since_analyze")
            rows2.append([
                _txt(s, "owner"), _txt(s, "table_name"),
                f"{float(days):,.0f}" if days is not None else "N/A",
                f"{_num(s, 'dml_since_analyze'):,}",
            ])
        story.append(_styled_table(
            ["Owner", "Table", "Days Since Analyze", "DML Since Analyze"], rows2,
            col_widths=[2.5 * cm, 4.5 * cm, 3.5 * cm, 3.5 * cm]))
    return story


def _build_addm(cache: MetricsCache) -> list:
    findings = cache.get("awr.addm_findings", []) or []
    if not findings:
        return []
    rows = [[
        _txt(f, "task_name"), _txt(f, "finding_name"), _txt(f, "type"),
        f"{_num(f, 'impact_absolute'):,.1f}",
        Paragraph(_xml_escape(_txt(f, "message"))[:200], _CELL),
    ] for f in findings[:15]]
    return [_styled_table(
        ["Task", "Finding", "Type", "Impact", "Message"], rows,
        col_widths=[2.3 * cm, 2.8 * cm, 2 * cm, 1.8 * cm, 6.6 * cm])]


# ---------------------------------------------------------------------------
# PDF rendering plumbing — numbered "Page X of Y" footer + a real, page-
# numbered Table of Contents (ReportLab's two-pass TOC recipe).
# ---------------------------------------------------------------------------

class _NumberedCanvas(pdfcanvas.Canvas):
    """Draws 'Page X of Y' by buffering pages and replaying them on save()."""

    def __init__(self, *args, **kwargs):
        pdfcanvas.Canvas.__init__(self, *args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self._draw_footer(num_pages)
            pdfcanvas.Canvas.showPage(self)
        pdfcanvas.Canvas.save(self)

    def _draw_footer(self, page_count: int) -> None:
        self.saveState()
        self.setFont("Helvetica", 7)
        self.setFillColor(colors.grey)
        self.drawString(1.5 * cm, 1 * cm, f"Generated by ORA BRABO — {datetime.now():%Y-%m-%d %H:%M:%S}")
        self.drawRightString(A4[0] - 1.5 * cm, 1 * cm, f"Page {self._pageNumber} of {page_count}")
        self.restoreState()


class _ReportDocTemplate(BaseDocTemplate):
    """Registers each numbered section heading as a Table of Contents entry."""

    def afterFlowable(self, flowable) -> None:
        if isinstance(flowable, Paragraph) and flowable.style.name == "ObH2":
            self.notify("TOCEntry", (0, flowable.getPlainText(), self.page))


def _render(story: list, path: Path, db_name: str) -> None:
    common_kwargs = dict(
        pagesize=A4,
        leftMargin=1.5 * cm, rightMargin=1.5 * cm, topMargin=1.5 * cm, bottomMargin=1.8 * cm,
        title=f"ORA BRABO Report - {db_name}",
    )
    try:
        doc = _ReportDocTemplate(str(path), **common_kwargs)
        frame = Frame(doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id="normal")
        doc.addPageTemplates([PageTemplate(id="normal", frames=[frame])])
        doc.multiBuild(story, canvasmaker=_NumberedCanvas)
    except Exception:
        log.warning("TOC-based report build failed, falling back to a simple single-pass layout", exc_info=True)
        doc = SimpleDocTemplate(str(path), **common_kwargs)
        doc.build(story, canvasmaker=_NumberedCanvas)


_SECTION_DEFS = (
    ("Executive Summary",           _build_summary),
    ("Health & Load",               _build_health),
    ("Locks & Blocking Sessions",   _build_locks),
    ("Top Wait Events",             _build_waits),
    ("Top SQL",                     _build_sql),
    ("Tablespaces & Capacity",      _build_tablespaces),
    ("Segments",                    _build_segments),
    ("ASM & Storage",               _build_asm),
    ("RAC Cluster",                 _build_rac),
    ("Data Guard",                  _build_dg),
    ("Exadata",                     _build_exadata),
    ("RMAN / Backup",               _build_rman),
    ("Scheduler Jobs & Statistics", _build_ops),
    ("ADDM Findings",               _build_addm),
)


def generate_report(cache: MetricsCache, output_dir: Path | None = None) -> Path:
    """Build a PDF report from the current cache snapshot and return its path."""
    output_dir = output_dir or REPORTS_DIR
    output_dir.mkdir(parents=True, exist_ok=True)

    db_info = cache.get("health.db_info", {}) or {}
    db_name = _txt(db_info, "db_name", "ORACLE")
    safe_name = "".join(c if c.isalnum() else "_" for c in db_name).strip("_") or "ORACLE"
    path = output_dir / f"{safe_name}_{datetime.now():%Y%m%d_%H%M%S}.pdf"

    story: list = []
    try:
        story.extend(_build_cover(cache))
    except Exception:
        log.warning("Report cover section failed", exc_info=True)

    toc = TableOfContents()
    toc.levelStyles = [_TOC1]
    story += [PageBreak(), Paragraph("Table of Contents", _H2), toc, PageBreak()]

    n = 1
    for title, builder in _SECTION_DEFS:
        try:
            content = builder(cache)
        except Exception:
            log.warning("Report section %r failed", title, exc_info=True)
            continue
        if not content:
            continue
        story.append(Paragraph(f"{n}. {_xml_escape(title)}", _H2))
        story.extend(content)
        story.append(Spacer(1, 6))
        n += 1

    _render(story, path, db_name)
    log.info("Report generated: %s", path)
    return path
