# Vanilla+ Economy Extension

Rusted Warfare mod that adds one balanced T4 economy tier, a small Scout mobility upgrade, and a gated Builder refit.

Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3728251918

## Install

Use Steam Workshop, or import `VanillaPlusEconomy.rwmod` from this repo.

1. Open Rusted Warfare.
2. Go to `Mods`.
3. Import `VanillaPlusEconomy.rwmod`.
4. Enable `Vanilla+ Economy Extension`.
5. Save and reload mod data.

## Changes

- Fabricator T4: $11900 upgrade from T3, 121.0s, 3000 HP, +24 credits, $26000 total cost.
- Extractor T4: $14000 upgrade from T3 or $6000 from Overclocked T3, 1200 HP, +45 credits, $20100 total cost.
- Extractor timing is equal either way: T3 -> T4 takes 111.0s; T3 -> Overclocked -> T4 takes 83.3s + 27.7s.
- T4 Extractors can downgrade only to Overclocked T3 with a $3000 refund.
- Builder -> Combat Engineer: requires 2 Extractors of any type, costs $3500, takes 33.3s, and locks the Builder in place.
- Scout -> Honor Scout: $200, 11.1s, speed 1.0 -> 1.33, turn speed 2.4 -> 3.2.

## Source

- `VanillaPlusEconomy/` is the mod source folder.
- `VanillaPlusEconomy.rwmod` is the ready-to-import package.

Tested on Rusted Warfare 1.15 with the game unit loader.
