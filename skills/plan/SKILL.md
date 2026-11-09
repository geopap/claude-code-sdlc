---
name: plan
description: Turn a GitHub issue (or a short request) into a buildable spec with acceptance criteria, a risk tier and PR-sized slices, and post it on the issue. Use when starting any non-trivial change.
argument-hint: <issue-number | "request text">
allowed-tools: Bash(gh issue view *) Bash(gh issue list *) Bash(gh pr list *) Bash(git log *)
---

# /sdlc:plan

Input: `$ARGUMENTS`. This is an issue number, or free text describing the request.

## Context
- Repo: !`gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "(no GitHub remote)"`
- Project config: !`cat .claude/sdlc.json 2>/dev/null || echo "(missing: run /sdlc:setup first)"`

## Steps
1. If the input is a number, load it with `gh issue view <n> --comments`. If it's text, treat it as the request. You'll offer to create an issue at the end.
2. Delegate to the `sdlc:planner` subagent. Pass it the issue body and comments, the config, and the instruction to return the spec in its standard format.
3. Read the spec critically before you show it:
   - Is every AC testable?
   - Is each slice independently mergeable, and roughly 400 changed lines or fewer?
   - Does the risk tier match the paths it will touch?
   - Are there open questions that actually block the build?
4. Show the spec to the user. If there are blocking open questions, ask them now and stop.
5. Once the user approves (they may edit it):
   - Issue input: post it with `gh issue comment <n> --body-file <tmpfile>`, and add the label `risk:<tier>` (create the label if it's missing).
   - Text input: offer to create the issue with `gh issue create`, using the spec as the body.

Don't start building. The next step is `/sdlc:build <issue>` or `/sdlc:ship <issue>`.
