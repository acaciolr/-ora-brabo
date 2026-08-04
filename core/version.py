"""
core/version.py
Single source of truth for the ORA BRABO version and ASCII banner.
Imported by app.py (--version / window title) and the connection dialog.
Keep in sync with the `version` field in pyproject.toml.
"""
from __future__ import annotations

__version__ = "1.3.3"

# ASCII banner (figlet "standard" — reads "ORA BRABO").
BANNER_ART = r"""
   ___  ____    _    ____  ____    _    ____   ___
  / _ \|  _ \  / \  | __ )|  _ \  / \  | __ ) / _ \
 | | | | |_) |/ _ \ |  _ \| |_) |/ _ \ |  _ \| | | |
 | |_| |  _ </ ___ \| |_) |  _ </ ___ \| |_) | |_| |
  \___/|_| \_/_/   \_\____/|_| \_/_/   \_\____/ \___/
"""
