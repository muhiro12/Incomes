# Product Vocabulary

## Purpose

Incomes describes each concept with one term across the app, App Intents,
App Shortcuts, widgets, Apple Watch, notifications, accessibility text, and
Store copy. This record lists the canonical English and Japanese terms, the
deliberate exceptions, and the audit that keeps them aligned.

Keep terms that are already clear and stable. Change copy for consistency or
precision, not for novelty.

## Canonical Terms

| English | Japanese | Meaning |
| --- | --- | --- |
| Item | 項目 | One dated record with income, outgo, content, and category |
| Income | 収入 | Money received by an item or period |
| Outgo | 支出 | Money spent by an item or period |
| Net income | 純収入 | Income minus outgo for an item or period |
| Income and Outgo | 収支 | The paired view of income and outgo |
| Balance | 残高 | The running total after an item |
| Content | 内容 | The item's description and its content tag |
| Category | カテゴリ | The grouping an item belongs to |
| Tag | タグ | Only on tag maintenance surfaces |
| Summary | サマリー | Monthly and yearly overviews |
| Upcoming | 今後の項目 | Items dated after today |
| Recent | 最近の項目 | Items dated up to today |
| Repeat | 繰り返し | Items created together across months |
| Duplicate | 複製 | Copy an item or a year's items |
| Yearly duplication | 年次複製 | The feature that proposes next year's items |
| Duplicate tags | 重複タグ | Tags with the same name and type |
| Sample data | サンプルデータ | Developer fixtures; see sample data profiles |
| Import / Export | 取り込み / 書き出し | Move an Incomes file in or out |

Rules that follow from the table:

- Do not use アイテム, 記録, or 収支 for an item.
- Do not use 純利益 or 収支 for net income; 収支 means only the paired
  income-and-outgo view.
- Do not use "spending", "expense", "entry", or "transaction" in English for
  items or outgo. "This entry" is acceptable only for the item form being
  edited.
- Spanish, French, and Simplified Chinese follow the English structure. Net
  income is "Ingreso neto", "Revenu net", and "净收入".

## Deliberate Exceptions

- Apple product and feature names keep Apple's wording: iCloud, Siri, Ask Siri,
  Shortcuts, Apple Watch, iPhone, widgets, notifications, and the Settings app.
- App Shortcuts phrase lists keep alternate phrasings, such as 記録 or 取引 in
  Japanese, so Siri can match natural requests. The first phrase of each list
  uses the canonical term.
- The monthly summary prompt is English guidance for the on-device model. It
  uses the same terms so generated summaries follow this vocabulary.
- "Contents" names the list of content tags on Apple Watch and in the export
  summary, where it means the set of item descriptions.

## Periodic Audit

Run this audit at each major release, or after a feature adds many strings:

1. Export English and Japanese values from every `.xcstrings` catalog, for
   example with a short script that prints the catalog, key, `en`, and `ja`
   columns.
2. Search the English column for non-canonical synonyms: "spending",
   "expense", "entry", "entries", "transaction", and "net result".
3. Search the Japanese column for アイテム, 純利益, カテゴリー, and 収支.
   Check that each 収支 means the paired income-and-outgo view.
4. Check that App Intents titles, widget and Watch strings, notification copy,
   and accessibility labels use the same terms as the app. Store
   descriptions and What's New live in App Store Connect; review them with
   the release tooling in `Tools/Release` during the same audit.
5. Validate every changed catalog for placeholders and locale coverage, and
   keep each catalog's existing key order so diffs stay reviewable.
6. Record any new deliberate exception in this document.
