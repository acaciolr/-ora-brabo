"""
collectors/base.py
Abstract base for all metric collectors.
"""

from __future__ import annotations

import logging
from abc import ABC, abstractmethod

from core.cache import MetricsCache
from core.connection_manager import ConnectionManager

log = logging.getLogger(__name__)


class BaseCollector(ABC):
    """All collectors inherit from this."""

    def __init__(
        self,
        conn_manager: ConnectionManager,
        cache: MetricsCache,
        interval: int = 5,
    ) -> None:
        self.conn = conn_manager
        self.cache = cache
        self.interval = interval
        self.log = logging.getLogger(self.__class__.__name__)

    @abstractmethod
    async def collect(self) -> None:
        """Run collection cycle and populate cache."""
        ...
