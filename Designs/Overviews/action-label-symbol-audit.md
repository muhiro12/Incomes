# Action Label and Symbol Audit

## Scope and decision

- Issue: [#416](https://github.com/muhiro12/Incomes/issues/416).
- Reviewed source: `ca62e220e253c24820d299f5ce8805e58aac2ff6` on `develop`.
- Date: 2026-11-12.
- Selected direction: make copying primary in the Item content entry and use
  the merge symbol for duplicate-tag resolution. The selected changes are
  implemented; publication remains separate.

Keep most action titles and symbols. The bounded changes distinguish Item
content copying from Item duplication and represent duplicate-tag resolution
with a merge symbol. These are clarity improvements, not a broad UI redesign.

The existing vocabulary from [product vocabulary](../Architecture/product-vocabulary.md)
and the action ordering from [ADR 0009](../Decisions/0009-contextual-actions-and-entity-context.md)
remain applicable. Issues #395 and #347 are closed as completed; this assessment
does not repeat their broad terminology or native-UI work.

## Selected changes

| Placement | Previous | Selected | Reason and boundary |
| --- | --- | --- | --- |
| Item detail action list and Item-row context menus | `Copy or Share Content` / `doc.on.doc` | `Copy Content…` / `clipboard` | The neighboring `Duplicate` uses `document.on.document`; the two symbols visibly have the same stacked-page silhouette in the captured iPhone detail screen. Copying is the primary context. A clipboard distinguishes the entry from duplication. The ellipsis and localized accessibility hint explain that review precedes copying or sharing. |
| Duplicate-tag row context menu | `Resolve` / `checkmark.seal` | Keep title; use `arrow.triangle.merge` | Resolution searches for matching tags and merges their relationships. The existing comparison toolbar already uses the merge symbol. A seal/checkmark suggests validation or completion rather than the impending mutation. Preserve the destructive role, divider, confirmation and selected-group scope. |

The Item content entry keeps the existing review-before-copy flow. Its title is
`Copy Content…` (`内容をコピー…` in Japanese), and its accessibility hint says
`Review content before copying or sharing.` The review screen keeps both Copy
Content and Share Content. Copy Content uses the same `clipboard` symbol;
Share Content retains `square.and.arrow.up`. The generic copy-text component's
default remains unchanged for name and other copy actions.

The plain clipboard conveys the copy destination while remaining distinct from
the adjacent duplication symbol. Avoid `doc.on.clipboard`, whose native image
meaning is Paste. The entry opens the review screen and does not write to
the clipboard immediately.

Keep `Resolve` and `Merge` as distinct labels for now: the first finds matching
duplicates for a selected group, while the comparison screen operates on its
selected tags. Renaming both to Merge would require reviewing scope and all
confirmation wording; it is not needed for the symbol improvement.

Changed implementation locations:

- [ShareItemContentButton](../../Incomes/Sources/Features/Item/Detail/ShareItemContentButton.swift):
  shared by `ItemView` and `ItemContextMenuActions`.
- [ItemContentShareView](../../Incomes/Sources/Features/Item/Detail/ItemContentShareView.swift):
  the actual Copy Content control uses the clipboard symbol too.
- [DuplicateTagRow](../../Incomes/Sources/Features/Tag/Views/DuplicateTagRow.swift):
  the contextual Resolve action only.

Callbacks, drafts, navigation routes, mutation scope, saved identifiers,
entitlements, confirmations, disabled states and cancellation behavior are unchanged.

## Placement inventory

The table covers relevant app-owned shared actions and their consumers, including
related local controls. It is a source inventory; runtime coverage is separately
recorded below. Component previews are not evidence of their surrounding screens.

| Action/component | Placements and neighboring actions | Decision |
| --- | --- | --- |
| `CreateItemButton` / `CreateItemToolbarContent` | Main sidebar and content toolbar; search results; year charts; month, content and category item lists; monthly summary toolbar; both empty-year presentations. Neighbors include Settings, Search, ledger switching, monthly summary and category Rename. | Keep `Create` / `square.and.pencil`. These neighbors have different symbols. No adjacent second generic creation action justifies replacing it with `plus` or forcing text. Preserve content-only prominent styling and native toolbar adaptation. |
| `CreateItemTip` | Tip attached to the shared creation button | Keep the matching compose symbol. Revisit only if the shared creation symbol changes. |
| `ShowItemButton` | Item-row context menu; row tap also opens detail | Keep `Show` / `doc.text.magnifyingglass`, with `Show Item Details` accessibility label and opening hint. A short menu title is sufficient within the Item context. |
| `EditItemButton` | Item detail list and Item-row context menus | Keep `Edit` / `pencil`. The selected Item supplies object context; a new object-badged variant offers no demonstrated benefit. |
| `DuplicateItemButton` | Item detail list and Item-row context menus | Keep `Duplicate` / `document.on.document`. It already describes object duplication; preserve the hint that a copied form opens. The neighboring content entry now uses a clipboard. |
| `ShareItemContentButton` | Item detail list and Item-row context menus | Use `Copy Content…` / `clipboard`, including Japanese `内容をコピー…`, as selected above. |
| `RecalculateItemButton` | Item-row context menu | Keep `Recalculate` / `arrow.triangle.2.circlepath`; no new object-specific composite. |
| `DeleteItemButton` | Item detail list and Item-row context menus; row edit/swipe deletion is separately wired | Keep `Delete` / `trash`, destructive semantics, confirmation and accessibility hint. Do not use a slashed object to mean deletion. |
| `ItemFormToolbarContent` | Create, edit, duplicate and proposal-derived forms | Keep Cancel / `xmark`; Create / `square.and.pencil`; Save / `checkmark`. Preserve mode-specific title, validation disabling, submit hint, recurrence/scope review and draft cancellation. |
| `SuggestionButton` and repeat-month controls | Keyboard suggestion strip and repeat picker | Keep content/month text. These select concrete values; adding action glyphs would compete with the values. |
| Category Rename and `CategoryRenameToolbarContent` | Category-list toolbar next to Item creation; rename sheet | Keep Rename / `pencil` and Cancel/Save symbols. Pencil and square-with-pencil distinguish rename from new Item. |
| `DuplicateTagRow` | Duplicate-tag list context menu, alongside Open and Copy Name | Use the accepted Resolve merge symbol above. Open / `arrow.right.circle` and Copy Name / `doc.on.doc` remain appropriate. |
| `DuplicateTagSectionHeader` | Per-type duplicate-tag section heading | Keep textual `Resolve All`. Scope comes from the section; preserve the explicit All qualifier and destructive role. Do not replace it with an unlabeled merge glyph. |
| `DuplicateTagView` / `DuplicateTagColumnHeader` | Comparison toolbar and column headers | Keep Merge / `arrow.triangle.merge`, Delete / `trash`, Close, selection disabling and confirmations. The column supplies the deletion target. |
| Orphan-tag controls | Row context menu, orphan detail and cleanup-list toolbar | Keep Open / `arrow.right.circle`, Copy Name / `doc.on.doc`, Delete and Cleanup All / `trash`. Do not imply merge for unused-tag deletion. |
| `MainNavigationYearContextMenu`, `HomeSummaryButton`, `HomeMonthRowButton` | Year/sidebar, summary and month context menus | Keep Show Summary / `chart.bar`, View Month / `calendar`, Duplicate Year Items / `square.on.square`, link actions and Delete / `trash`. Preserve year scope in the duplication title. |
| Yearly-duplication proposal controls | Inline adaptive horizontal/vertical actions and row context menu | Keep Edit / `pencil` and Create / `plus.circle`. Edit opens a draft; Create executes the proposal. Distinct symbols and hints already preserve this difference. |
| `CopyTextContextMenuButton`, `CopyURLContextMenuButton` | Item text review; search filter, tag-maintenance and proposal menus; Item/month/year link menus | Keep the default copy text/name / `doc.on.doc` and copy link / `link`; Item content copying explicitly selects `clipboard`. Text-copy actions do copy immediately, unlike the content-review entry above. |
| `ItemContentShareView` | Text review form with Copy Content and Share Content; Done toolbar | Use `clipboard` for Copy Content; keep `square.and.arrow.up` and Done / `checkmark`; these are the actual copy/share operations. |
| `DataExportButton` | Export form and export-current-data precaution inside import flow | Keep `square.and.arrow.up` and the existing contextual titles. Preserve preparation spinner, disabling and export-priority confirmation. |
| Import entry and confirmation | Choose file row, difference review, Import/Replace data confirmation, choose-another-file/result rows | Keep Choose file / `doc.badge.plus` and explicit textual Import/Replace data. No neighboring creation control makes the file symbol ambiguous. Preserve destructive replacement semantics; do not collapse both modes into a generic icon. |
| Ledger controls | Main ledger menu/toolbar, management form, rename form and unassigned-items flow | Keep `books.vertical`, Manage Ledgers / `slider.horizontal.3`, Create Ledger / `plus`, textual Rename and assignment controls. Ledger creation is a named form action, not adjacent to Item creation. No need to invent a book-plus composite. |
| Input Assistance | Item form entry; photo/camera source rows; Cancel/Done/Processing toolbar | Keep `text.badge.plus`, `photo.on.rectangle`, `camera`, `xmark`, `checkmark` and the progress indicator. Processing has explicit status text and accessibility semantics. |
| `CloseButton` / `CloseButtonLabel` | Item/settings/debug/maintenance/subscription/chart sheets and yearly-duplication promotion dismissal | Keep the localized Close label and icon presentation; preserve the pre-iOS-26 visual fallback. This shared control represents dismissal everywhere. |
| Search/filter actions | Search toolbar, empty result refinement, category/content filter menus and amount-search action | Keep `magnifyingglass` and `line.3.horizontal.decrease.circle`; names and filter values remain readable context. |

The Item context menu is shared through `ListItemButton` across list consumers,
including tag comparison. A change to its shared button must therefore be checked
in the menu as well as the Item detail list.

Watch and Widgets do not consume these Item mutation buttons. The source scan
found Watch's separate Settings control and development-only deletion surface;
their icons do not need changes as part of this change. Companion runtime
rendering is outside this assessment.

## Explicit presentation exceptions

The app has no `.labelStyle(.titleOnly)` use in the reviewed source. Existing
explicit styles have placement-specific reasons:

- `CloseButtonLabel`: icon-only dismissal in toolbars and a compact promotion
  header; localized label is retained for accessibility.
- `LedgerSelectionMenu`: title and icon in the content presentation so the
  selected ledger remains visible; icon-only toolbar variant exposes the current
  ledger through its accessibility value.
- Photo Library and Camera: title and icon on full-width source-selection rows,
  allowing people to read the acquisition method.
- Processing: title and progress indicator together to describe why Done is
  unavailable, with a processing-state accessibility label.

Text-only alert/confirmation actions, value suggestions, and scope-sensitive
form actions are justified local controls. They are not a reason to strip titles
or icons from reusable semantic buttons.

## Symbol and localization evidence

Checked Apple's installed SF Symbols 27.0 `name_availability.plist` and its
release mapping, rather than treating a successful string reference as proof:

| Symbol | First iOS release | Decision |
| --- | --- | --- |
| `clipboard` | 16.0 | Selected content-entry and copy symbol; no fallback needed for iOS 18 baseline |
| `arrow.triangle.merge` | 14.0 | Selected Resolve symbol; no fallback needed for iOS 18 baseline |
| `document.on.document` | 18.0 | Existing duplication symbol is supported at the baseline |
| `doc.on.doc`, `square.and.arrow.up`, `checkmark.seal` | 13.0 | Existing comparison symbols |
| `square.and.pencil`, `pencil`, `text.badge.plus`, `plus.circle`, `link` | 13.0 | Retained actions |
| `doc.badge.plus`, `books.vertical` | 14.0 | Retained import/ledger symbols |

A comparison image was rendered using actual native `NSImage` system symbols,
including adjacent Item actions. That artifact compares glyphs; it is not an
iOS application screenshot or evidence of iOS layout behavior.

The reviewed Create/Edit/Duplicate/Show/Delete/Recalculate, content-copy/share,
link-copy/share, Resolve/Resolve All/Merge, Choose file/Create Ledger and
Cancel/Save/Close keys contain translated entries for English, Japanese,
Spanish, French and Simplified Chinese. The new Copy Content… title and review hint are translated for all five locales.
The retired Copy or Share Content key had one literal caller, now updated, and
was removed. Existing unrelated entries are preserved. Catalog coverage is not
proof of truncation behavior or spoken VoiceOver quality.

## Baseline verification

The Item detail Preview was attempted with Japanese localization using the
selected Xcode integration. It failed with a `PreviewsFoundationHost`
`TaskTimeoutError`; no trustworthy Preview screenshot was returned. This is a
tool/preview-pipeline gap, not evidence of a product defect.

Direct Preview coverage: 0 captured, 1 failed. The six other selected screen
definitions (main navigation, Item form navigation, duplicate-tag list and
comparison, import and export) were not attempted after the pipeline timeout.
Isolated button/row previews were excluded because the surrounding placement is
the subject of this assessment. This is not a whole-repository Preview census.

A separate live run captured five current-app screens on iPhone 18 Pro,
iOS 27.2, portrait, Japanese, using the Incomes scheme and the existing DEBUG
sample-like data. These captures are not a reproduction of the failed Preview's
exact fixture and are not counted as successful Preview captures.

| Live screen | Observed result |
| --- | --- |
| Main navigation | Settings, Search and Create remain distinguishable. |
| Month list | Monthly Summary (`sparkles`) and Create (`square.and.pencil`) remain distinguishable. |
| Expanded Item detail | Duplicate and Copy or Share Content visibly share the stacked-page silhouette; their Japanese titles are fully readable. Edit and Delete remain distinct. |
| Item content review | Opens a review screen before any copying; Copy Content and Share Content are separate, distinguishable actions. |
| Create form | Cancel and Create remain distinguishable; Create is disabled with incomplete input. The empty form was cancelled. |

Native build/install/run succeeded. The returned latest build log reported no
warnings or errors. Runtime logs did contain Simulator AI-availability,
unpaired-Watch, Store-product-query, WebKit/accessibility and animation
monitoring diagnostics. No crash or missing icon was observed in the five
reviewed screens; this is not a claim of warning-free runtime behavior.

Transient blank/stale captures were discarded after fresh screenshots and
hierarchies agreed. The interaction session was ended, the task-owned app run
was stopped, and the original Xcode scheme/destination selection was restored
and read back. Xcode-generated catalog extraction changes were inspected and
reverted; no app implementation or translation change is part of this audit.

Unverified runtime placements include Item context menus, duplicate-tag
maintenance, import/export, iPad/regular width, older supported OS versions,
other locales, Dynamic Type and spoken VoiceOver. The tag-symbol decision is
based on source behavior and native glyph comparison, not a captured
tag-maintenance screen. Accessibility labels and hints were reviewed in source,
and the live hierarchy was inspected; neither establishes VoiceOver acceptance.

## Implementation verification

The three Swift view changes preserve the existing callbacks and presentation
flow. Verification completed:

- SwiftLint formatting and the repository rule checks passed.
- The new title and accessibility hint passed translation-patch validation for
  all five supported locales; existing unrelated translations are unchanged.
- Native build/install/run succeeded for the final `clipboard` implementation.
  The returned build log contained no warnings or errors.
- Japanese iPhone detail and content-review screenshots show the final clipboard
  icon, readable copy labels and the retained Share Content action. The hierarchy
  identifies the image as Clipboard, rather than Paste, and preserves the button
  labels. No clipping, overlap or missing symbol was observed there.
- The Item context menu's shortened title was inspected during the preceding
  build. That capture used the intermediate paper-on-clipboard symbol, so it is
  not final-icon evidence; the shared menu code now uses `clipboard`.
- Sessions and task-owned runs were closed, and Xcode selection was restored and
  read back. Build-generated catalog churn was removed while retaining the
  intended translation changes.

Duplicate-tag runtime presentation, final-icon context-menu capture, other
locales/widths, older OS rendering, and spoken VoiceOver remain unverified.
Runtime logs contain system WebKit/accessibility/animation diagnostics; no crash
was observed in the reviewed interactions. Copying, sharing and merging were not
executed during this visual check. No domain logic changed, so additional
behavior tests are not warranted for these labels and symbols.

The requested work does not itself close #416 or authorize publication.

## Official guidance

- [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons):
  use recognizable actions and concise labels; text is appropriate when it
  communicates the action more clearly.
- [SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols):
  individual symbols have OS-specific availability; inspect their rendering in
  the actual contexts where they appear.

The selected changes are app-specific clarity improvements, not claims that
Apple mandates those exact symbol names.
