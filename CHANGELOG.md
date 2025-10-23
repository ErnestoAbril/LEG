# Changelog

## 1.1.0+2 — 2025-09-11

- Budgets: fixed double-discount on saving expenses. Now remaining = assigned − consumed; assigned values are not decremented on save.
- Category Panel: totals accurate using cents; progress bars; order by remaining (desc); close button; smoother amount editing (format on blur) with rounding to cents.
- Formatting: unified parsing/formatting; global currency settings applied live; separators validated; integer-cents sums avoid rounding drift in totals.
- Persistence: budgets normalized to 2 decimals on load/save; gastos migrated to `montoCents` for canonical storage.
- Selection Dialog: shows current balance and original assigned per category.
- Historial: added legends for Pie and Bar charts (colors, %, amounts); totals computed from `montoCents`; legend visibility toggle persisted.
- Performance: reduced redundant chart recomputations; minor UI optimizations.
- Misc: fixed Problems panel warning; improved stability.

## 1.0.0+1 — Initial
- First cut of the app.
