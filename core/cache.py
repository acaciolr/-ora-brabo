"""
core/cache.py
In-memory metrics cache with TTL and history ring-buffer for charts.
"""

from __future__ import annotations

import time
from collections import deque
from dataclasses import dataclass, field
from threading import RLock
from typing import Any, Deque


@dataclass
class CacheEntry:
    value: Any
    timestamp: float
    ttl: float = 10.0

    @property
    def is_expired(self) -> bool:
        return time.monotonic() - self.timestamp > self.ttl


class MetricsCache:
    """
    Thread-safe cache for collector output.
    Each key stores the latest value + a ring-buffer of history
    for graph rendering.
    """

    HISTORY_SIZE = 120  # 120 data points per metric

    def __init__(self) -> None:
        self._lock = RLock()
        self._data: dict[str, CacheEntry] = {}
        self._history: dict[str, Deque] = {}

    # ------------------------------------------------------------------
    # Write
    # ------------------------------------------------------------------

    def set(self, key: str, value: Any, ttl: float = 10.0) -> None:
        with self._lock:
            self._data[key] = CacheEntry(value=value, timestamp=time.monotonic(), ttl=ttl)
            if key not in self._history:
                self._history[key] = deque(maxlen=self.HISTORY_SIZE)
            self._history[key].append((time.monotonic(), value))

    # ------------------------------------------------------------------
    # Read
    # ------------------------------------------------------------------

    def get(self, key: str, default: Any = None) -> Any:
        with self._lock:
            entry = self._data.get(key)
            if entry is None or entry.is_expired:
                return default
            return entry.value

    def get_history(self, key: str) -> list[tuple[float, Any]]:
        with self._lock:
            return list(self._history.get(key, []))

    def get_history_values(self, key: str) -> list[Any]:
        return [v for _, v in self.get_history(key)]

    def is_fresh(self, key: str) -> bool:
        with self._lock:
            entry = self._data.get(key)
            return entry is not None and not entry.is_expired

    def keys(self) -> list[str]:
        with self._lock:
            return list(self._data.keys())

    def clear(self, key: str | None = None) -> None:
        with self._lock:
            if key:
                self._data.pop(key, None)
                self._history.pop(key, None)
            else:
                self._data.clear()
                self._history.clear()
