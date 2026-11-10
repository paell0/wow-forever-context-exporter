# Progress plans, focused questions, and item comparison

[Back to the main README](../README.md)

## Follow the four-step loop

1. Open ForeverContext and select **Overview**, **Talent points**, **Gear advice**, or **Next session**. Enter your goal and generate a report.
2. Copy the text into your preferred AI. The report asks for an optional `FCPLAN/1` plan block at the end of the reply.
3. Click **Progress plan** in the addon. Paste only that plan block, click **Preview plan**, review the tasks, and click **Accept plan** if you want to follow it.
4. Play, then use **Review plan** or **Review with AI**. The next report contains the accepted tasks, current checks, and observed changes since the reference snapshot.

Only one ForeverContext window is visible at a time. Opening **Progress plan** or **Compare items** temporarily hides the report; closing the editor returns to the same report without regenerating it. Switching between editors keeps the report hidden. Background data retries pause so they cannot take focus from your input; if loading was interrupted, click **Generate / refresh** after returning. Editors opened directly while the report is closed do not open it when dismissed. Entering combat closes the windows without restoring the report.

Accepting or archiving a plan, or changing a manual checkbox, marks the restored report as outdated. Click **Generate / refresh** to include those changes; **Select all** stays disabled until the report is refreshed. Draft edits do not change accepted progress.

No network connection or AI model is provided by the addon. Copy reports and plan blocks manually. Importing a plan does not apply talents, equip items, spend gold, or perform gameplay actions.

## Automatic and manual checks

| Task | What completes it |
| --- | --- |
| `LEVEL` | Your current character level reaches the target. |
| `SKILL` | The queried skill's current rank reaches the target. Bonuses are not added to the rank. |
| `SLOT` | An item is equipped in the requested inventory slot. |
| `TALENT` | The active build reaches the target committed rank in that node, excluding bonus ranks. |
| `ITEM` | The requested item ID is currently equipped. Bag possession does not complete it. |
| `GOLD` | Your current gold balance reaches the target. This is not total gold earned. |
| `MANUAL` | You tick the checkbox yourself. |

Unknown, restricted, unlearned/unobserved, or unapplied data is labelled **UNKNOWN**, not automatically completed or failed. Automatic checks reflect the current state: removing an item or spending gold can make a goal pending again. Only manual tasks have editable checkboxes.

The plan window refreshes after relevant level, skill, gear, money, and talent events. You can also click **Refresh**. Unapplied talent changes are not counted as committed progress.

## Plan block format

```text
FCPLAN/1
TITLE|My next session
LEVEL|26|Reach level 26
SKILL|186|75|Reach Mining 75
SLOT|1|Equip a helmet
TALENT|104753|5|Reach committed rank 5 in this verified node
ITEM|12345|Equip this verified item ID
GOLD|10|Hold at least 10 gold
MANUAL|Complete a dungeon with friends
```

These are format examples, not recommendations for every class. Replace targets and IDs with appropriate, verified values. `TALENT` needs a **node ID**, not a spell or entry ID. Use `MANUAL` when an action or ID cannot be verified.

- One task per line, with `|` separating fields. Labels cannot contain `|`.
- Maximum 32 tasks, 240 bytes per label, and 24,000 bytes per imported block.
- Numeric IDs and targets must be positive integers. Gold targets use whole gold units.
- A fenced code block is accepted. Arbitrary prose, JSON, and Lua code are not evaluated or imported as tasks.
- Invalid input does not replace your plan. Previewing does not accept it.

**Inventory slot IDs:** 1 head, 2 neck, 3 shoulders, 4 shirt, 5 chest, 6 waist, 7 legs, 8 feet, 9 wrists, 10 hands, 11–12 rings, 13–14 trinkets, 15 back, 16 main hand, 17 off hand, 18 ranged/relic, 19 tabard.

## References and previous plans

Acceptance freezes a copy of the **most recently generated report's snapshot**, or a fresh snapshot if none exists. Accept a plan while that reference still matches the AI conversation you are following. The addon cannot know which conversation you pasted into.

New exports update the last-generated snapshot without changing the active plan's reference. Replacing or clearing a plan archives it; the two most recent archived plans are retained. Review exports include the most recent archived plan and its current task checks.

Snapshots record level, gold balance, equipped item IDs, readable skill ranks, and committed talent ranks. They do not preserve full old item tooltips, every historical talent decision, or combat performance. Unknown values are excluded from comparisons. Client-build changes are flagged for advice review.

## Compare two items

1. Click **Compare items** or type `/fcontext compare`.
2. Drag an item onto **Drop item A** and another onto **Drop item B**. Alternatively, paste a game item link into each field and press Enter.
3. Click **Compare with AI**. Copy the resulting report into your AI.

Full item links retain supplied enchant, gem, and variant fields. Numeric IDs are also accepted but explicitly marked as base references. Website URLs and spell links are rejected. Uncached item data is retried briefly and then marked pending if it remains unavailable.

The report contains both candidates and your current gear, talents, stats, goals, and plan context. Candidate tooltip set counts refer to the **current character**, not a simulated loadout after equipping that item. The AI must evaluate slot compatibility, weapon rules, and hypothetical set changes; the addon does not claim a computed winner or DPS simulation.

## Commands and storage

| Command | Action |
| --- | --- |
| `/fcontext` | Open the most recently selected report purpose. |
| `/fcontext overview` | General character report. |
| `/fcontext talents` | Next talent points. |
| `/fcontext gear` | Gear advice. |
| `/fcontext session` | Next play session. |
| `/fcontext review` | Review accepted and previous advice. |
| `/fcontext plan` | Preview, accept, and track a plan. |
| `/fcontext compare` | Choose two item candidates. |
| `/fcontext minimap` | Hide/show the minimap button. |

Plans, goals, candidate references, and snapshots are stored per character in `ForeverContextCharacterDB`. Existing account-level goal/options are used as initial defaults when migrating; future changes are separate per character. Minimap position/visibility remain in the account-level `ForeverContextDB`.

Player-entered goals, accepted task labels, and selected comparison references are included in the reports you choose to export. No account identifier is added to snapshots. AI advice and imported labels are player-supplied context, not verified game rules.
