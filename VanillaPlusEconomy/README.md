# Vanilla+ Economy Extension

Rusted Warfare mod that adds two balanced late-game economy tiers and lets Builders refit into Combat Engineers.

## Changes

### Fabricators

- T3 -> T4: $8000, 80s, 3000 HP, +22 credits, $22100 total cost.
- T4 -> T5: $12000, 110s, 4000 HP, +34 credits, $34100 total cost.

### Extractors

- T3 Overclocked -> T4: $8000, 80s, 1200 HP, +45 credits, $22100 total cost.
- T4 -> T5: $12000, 110s, 1400 HP, +68 credits, $34100 total cost.
- Reinforced Extractors are unchanged.
- Downgrade refunds: T3 Overclocked $4000, T4 $8000, T5 $14000.

### Builders

- Builder -> Combat Engineer: $3000, 30s.
- Total cost stays fair: $500 Builder + $3000 refit = $3500 Combat Engineer.
- Combat Engineer stats are unchanged.

## Install

### `.rwmod`

1. Open Rusted Warfare.
2. Go to `Mods`.
3. Import `VanillaPlusEconomy.rwmod`.
4. Enable `Vanilla+ Economy Extension`.
5. Save and reload mod data.

### Manual

Copy the `VanillaPlusEconomy` folder into:

```text
Rusted Warfare/mods/units/
```

On this Mac Steam install:

```text
/Users/parmesh/Library/Application Support/Steam/steamapps/common/Rusted Warfare/mods/units/
```

Then enable it in `Mods` and reload mod data.

## Compatibility

This mod replaces:

- `builder`
- `fabricatorT3`
- `extractorT3_overclocked`

Do not use it with another mod that replaces those same units unless you are intentionally testing load order.

## Tested

Tested on Rusted Warfare 1.15 with the game unit loader. Both the folder mod and the `.rwmod` package load 7 custom units successfully.
