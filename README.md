# Vanilla+ Economy Extension

Rusted Warfare mod that adds balanced T4 Fabricators/Extractors, a Repair Bay upgrade, a Command Center Eng -> Combat Eng refit, and a small Honor Scout mobility upgrade.

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
- Extractor T4: $14000 upgrade from T3, $6000 from Overclocked T3, or $11000 from Reinforced T3, 1200 HP, +45 credits, $20100 total cost.
- Extractor timing is equal across T3 routes: direct T3 -> T4 takes 111.0s; Overclocked route takes 83.3s + 27.7s; Reinforced route takes 23.8s + 87.2s.
- T4 Extractors can downgrade only to Overclocked T3 with a $3000 refund.
- Repair Bay Upgrade: $2000, 55.6s, 1000 -> 1500 HP, 0.20 -> 0.30 repair/build assist, 230 -> 280 range, subtle gold-accent sprite. Upgraded bays use a self-only Reclaim action instead of target-reclaim: 16.3s, $2800 refund.
- Engineer: built from the Command Center for $500 with vanilla Builder stats and Mega Builder sprites.
- Eng -> Combat Eng: requires 2 Extractors of any type, costs $3500, takes 33.3s, locks the Engineer in place, and produces the standard Combat Engineer.
- Scout -> Honor Scout: $200, 11.1s, speed 1.0 -> 1.33, turn speed 2.4 -> 3.2.

## Source

- `VanillaPlusEconomy/` is the mod source folder.
- `VanillaPlusEconomy.rwmod` is the ready-to-import package.

## Release

Run `./scripts/release-workshop.sh --note "Your Workshop change note"` to rebuild the package, sync the local Rusted Warfare install, publish the Steam Workshop item, and verify the public Workshop metadata. Add `--remove-local-after-publish` when you want the local side-loaded copy removed after Workshop upload.

Tested on Rusted Warfare 1.15 with the game unit loader.
