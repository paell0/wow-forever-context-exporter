# Your first report

[Main README](../README.md) · [Interface languages](LOCALIZATION.md)

You can use ForeverContext without configuring anything. It prepares text for you to paste into an AI of your choice. The AI is outside WoW; the addon does not send the report or provide an AI service.

## Ask for advice

1. Outside combat, click the minimap button or type `/fcontext`.
2. Leave **Overview** selected. You can enter a goal, such as “I play solo and want help with my next talent points.” The goal is optional.
3. Click **1. Prepare text**, then **2. Select text**.
4. Press **Ctrl+C**, open your AI, and press **Ctrl+V**. Send the pasted report with your question.

The report is normally prepared when the window opens. Prepare it again after changing your goal, gear or settings. Selecting the text does not copy it to your system clipboard: **Ctrl+C** performs that step. Report labels stay English; game names and your own text keep their original language.

## Optional tools

Choose **More tools** only when you want to do one of these tasks. Each button has an explanation in the addon.

| Button | Use it when… |
| --- | --- |
| **Compare two items** | You have two items and want to ask the AI which one suits your character. |
| **Use an AI plan** | Your AI has returned a plan and you want to check and track its tasks. |
| **See items in my bags** | You want to browse carried items and choose some to compare or keep. |
| **Tell the AI what to keep** | You want the AI to know that an item is reserved, and why. This does not lock it in game. |
| **Note an item's origin** | You want to save your own referenced notes about where an item comes from. This is not a loot search engine. |
| **Save a talent build** | You want to save your current talents for an activity, share them or compare builds with AI. |

Only one tool is shown at a time. Closing a tool returns to the report you came from without generating a new snapshot. If a saved change makes that report outdated, prepare the text again before copying. Combat closes the addon windows.

## Compare two items

1. Open **More tools → Compare two items** and open your bags.
2. Drag your first item onto **1. First item**, and your second onto **2. Second item**. You can also paste a full item link into each field; pressing Enter is not required before preparing the comparison.
3. Read the next-step message. **3. Prepare comparison** becomes available when both references are valid.
4. Click it, then select and copy the report into your AI as above.

This prepares the question and character context. It does not equip an item, decide for you, or contact the AI. **Start again** clears both selected items.

## Follow an AI plan

1. First give your report to the AI and ask for a plan for ForeverContext. The report contains the supported plan-format instructions.
2. Open **More tools → Use an AI plan**. Paste the AI reply or just its plan block into the dark text box. **Try an example** fills in a draft if you want to learn the controls first.
3. Click **2. Check the plan** and read the tasks below.
4. Choose **3. Use this plan** only if you want those tasks to replace your current plan.

The importer can find one `FCPLAN/1` block inside a Markdown-fenced AI reply. Plain plan blocks also work. If the reply contains more than one plan, paste only your chosen block. Incomplete fences, malformed tasks and oversized input are rejected; pasted content is never executed. Previewing, trying an example or editing the text does not replace your saved plan.

The window expands when it has tasks to show. Automatic tasks update from your character's current state. Tick only manual tasks yourself. Unknown data means that the task cannot be checked, not that it failed. Use **Review with AI** to prepare a progress report later. [Full plan format and limits](PROGRESS-PLAN.md).

## Change a setting

**Settings** starts with three simple choices: interface language, optional carried-bag context and spoiler preferences. Defaults already include normal character information, and opening Settings never resets earlier custom choices.

Use **Choose report details** only if you want the individual category switches or the source-observation helper. **Back to settings** returns to the simple view. **Restore defaults** explicitly resets report-category/spoiler/helper choices, retaining your language and saved plans, notes and profiles. **Prepare text** returns to the report and includes the selected settings.

The [complete tool guide](COMMUNITY-TOOLS.md) covers source provenance, profiles, bags, preservation preferences and the limits of spoiler filtering. You do not need these extra features to export a useful first report.
