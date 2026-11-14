## Graphify — `lib/` only

- For architecture, navigation, and code relationship questions, use `graphify query`, `graphify path`, or `graphify explain` first when the graph exists.
- Use only `lib/` source files. Never read, search, or modify files outside `lib/` without permission.
- Do not use an unscoped Graphify graph if it includes code outside `lib/`.
- Never run `graphify update .` for this project. Update Graphify only if its CLI supports restricting extraction to `lib/`.
- If the graph is missing, stale, or out of scope, inspect only relevant files inside `lib/`.
- Read source files only when needed. Avoid full reports, broad searches, and unrelated context.
- Make minimal changes. Preserve existing architecture and state management.
- If work requires files outside `lib/`, ask permission first.