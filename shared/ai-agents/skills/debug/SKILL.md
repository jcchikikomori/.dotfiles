---
name: debug
description: Debug production issues, reproduce bugs, perform root cause analysis using 5 Whys method, and create test cases to verify fixes.
---

# Production Debugging Skill

**Use Case:** Investigating production issues, reproducing bugs from ticket information, and planning test cases.

## Core Debugging Workflow

### Phase 1: Understand & Reproduce
1. **Intake:** Gather error logs, user reports, and environment details (Browser, OS, Staging/Prod).
2. **Reproduce:** Replicate the exact conditions. Write failing test cases to prove the bug exists before touching any application code.
   - *If Frontend:* Look for race conditions in React hooks, stale closures, missing keys, or CORS.
   - *If Backend:* Look for N+1 queries, missing indexes, race conditions, or null reference errors.

### Phase 2: Root Cause Analysis (5 Whys)
Do not just patch the error. Determine *why* it happened.
- Why did the variable evaluate to null?
- Why did the database allow a null value?
- Why was validation missing?

### Phase 3: The Fix
- Write the application code to fix the root cause.
- Ensure the failing test written in Phase 1 now passes.
- Assess performance impact (e.g., does this require a slow database migration?).

### Output Format
When handling a debugging task, structure your response as follows:

```markdown
## 🔍 Debug Session

### Issue Summary
[Brief description of the bug]

### Root Cause Hypothesis
[Your technical explanation of what is breaking]

### Action Plan
1. [ ] Replicate via automated test
2. [ ] Apply application fix
3. [ ] Verify test passes
```