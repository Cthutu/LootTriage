# LootTriage — BetterBags fork

Fork of [Krelock/LootTriage](https://github.com/Krelock/LootTriage), adding an optional BetterBags integration. Developed against BetterBags v0.9.1 on WoW Forever.

LootTriage listens for BetterBags item and bag updates, draws one set of markers on the item decoration, and handles keep-item clicks on the interaction button. Grid and list rows share the same tooltip markers. Bank, virtual, empty, and static preview items are excluded.

For merged stacks, the icon shows the lowest numbered highlighted physical stack it represents. The tooltip gives that stack's quantity and bag/slot location. Use BetterBags' **Show Bags** before deleting: clicking a merged icon can pick up a different physical stack. Other highlighted stacks in the same icon become individually visible in Show Bags.

LootTriage's corner sorting still applies only to Blizzard's bags. BetterBags controls its own category layout. Without BetterBags, LootTriage retains its existing bag handling.

## Local testing

Copy the `.lua` files and `LootTriage.toc` from this checkout into the installed `Interface/AddOns/LootTriage` folder. Back up the installed files first. Restart WoW after the first installation because the TOC now loads `BetterBags.lua`; subsequent Lua edits can be tested with `/reload`.

1. Open BetterBags and use `/lt` to select **Always** highlighting or run the highlight preview.
2. Confirm each candidate has one glow/rank. Alt-left-click an item to toggle its keep star, then check its tooltip.
3. Switch categories, views and themes; close/reopen bags and move an item. Confirm markers follow their items and disappear from empty slots.
4. Enable merged stacks with differently sized stacks of the same item. Check the rank and physical quantity in the tooltip, then use Show Bags to locate the candidate.
5. Check list rows, bank items and the item browser. Bank and preview items must not get deletion markers or keep-click handling.
6. With full bags, open loot containing a more valuable item and confirm its coin agrees with the bag candidate rank.
7. Disable BetterBags and reload to check the ordinary bag highlights and keep clicks.

The integration does not delete items automatically.
