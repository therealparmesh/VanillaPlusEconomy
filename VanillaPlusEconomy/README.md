# Vanilla+ Economy Extension

Rusted Warfare mod that adds balanced T4 Fabricators/Extractors, a Repair Bay upgrade, a Command Center Eng -> Combat Eng refit, and a small Honor Scout mobility upgrade.

Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3728251918

## Changes

### Fabricators

- T3 -> T4: $11900, 121.0s, 3000 HP, +24 credits, $26000 total cost.

### Extractors

- T3 -> T4: $14000, 111.0s, 1200 HP, +45 credits, $20100 total cost.
- T3 -> Overclocked -> T4: $8000 + $6000, 83.3s + 27.7s, 1200 HP, +45 credits, $20100 total cost.
- T3 -> Reinforced -> T4: $3000 + $11000, 23.8s + 87.2s, 1200 HP, +45 credits, $20100 total cost.
- Reinforced Extractors keep vanilla shield stats and count for the refit gate.
- T4 can only downgrade to Overclocked T3 and refunds $3000.

### Engineer

- Engineer: built from the Command Center for $500.
- Uses vanilla Builder stats, repair/build behavior, and build options.
- Uses Mega Builder sprites only; it does not use Mega Builder stats or weapons.
- Eng -> Combat Eng: requires 2 Extractors of any type, $3500, 33.3s.
- The Engineer cannot move while refitting.
- The result is the standard Combat Engineer with unchanged stats.
- There is no downgrade.

### Repair Bay

- Repair Bay Upgrade: $2000, 55.6s.
- HP increases from 1000 to 1500.
- Repair speed and build assist increase from 0.20 to 0.30.
- Repair and build-assist range increases from 230 to 280.
- The upgraded sprite has a subtle gold accent.
- Reclaim is unchanged and there is no downgrade.

### Scouts

- Scout -> Honor Scout: $200, 11.1s.
- Speed increases from 1.0 to 1.33.
- Turn speed increases from 2.4 to 3.2.
- HP, damage, range, sight, acceleration, and deceleration are unchanged.

## Install

Subscribe on Steam Workshop, or import `VanillaPlusEconomy.rwmod` from Rusted Warfare's `Mods` screen.

## Compatibility

This mod replaces:

- `scout`
- `extractorT1`
- `extractorT2`
- `extractorT3`
- `extractorT3_overclocked`
- `extractorT3_reinforced`
- `fabricatorT3`
- `repairBay`

This mod also adds:

- `vpe_engineer`

Do not use it with another mod that replaces those same units unless you are intentionally testing load order.

## Tested

Tested on Rusted Warfare 1.15 with the game unit loader.
