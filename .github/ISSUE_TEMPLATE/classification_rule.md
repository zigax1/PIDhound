---
name: Classification rule
about: PIDhound doesn't recognize a process / tool you use
title: 'classify: <tool name>'
labels: classification
assignees: ''
---

## The process

What tool / command is PIDhound missing or misclassifying?

## Sample shape

Output of `ps -axo pid,ppid,command | grep -i <tool>` so we can see the actual argv shape:

```
<paste output>
```

## What group it should go in

One of: claude-code, mcp-server, ai-assistant, playwright, test-runner, dev-server, docker, listening-port, other.

## Why it matters

Optional. Quick note on when this tool tends to go stale / orphan / leak, so the right state tags apply.
