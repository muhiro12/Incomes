# Released store fixture — 5.12

- Source: the `5.12` tag (`c7c57e01`), the preserved released 5.x baseline.
- Produced by compiling that tag's own `IncomesLibrary` and writing three items
  with a shared repeat ID, a shared category tag, and recalculated balances
  through its `Item.create` and `BalanceCalculator`.
- Written on the iPhone 18 Pro iOS 27.0 Simulator with Xcode 27.0 (27A266a),
  then closed so the store checkpointed its write-ahead log.
- Contents are synthetic. The store keeps its `-wal` and `-shm` sidecars so
  relocation is exercised with the complete file set.
- Not produced by the App Store build's own UI. A store written by the shipped
  binary would additionally cover data created through the released interface.
