# Before and after examples

Each example names the artifact, the main failure mode, the rewrite, and what was cut or kept. The first is a real pull request; the rest are constructed to show different failure modes. In every case the test is the same: can an engineer who has never seen the situation understand what was broken, why, and what changed, substantially faster after the rewrite, with nothing they need removed?

## 1. Pull request description: implementation before behavior

Source: [anthropics/anthropic-sdk-csharp #265](https://github.com/anthropics/anthropic-sdk-csharp/pull/265), reproduced verbatim.

### Before (about 560 words)

> Fixes #263.
>
> ## What was wrong
>
> In `Microsoft.Extensions.AI`, *require any tool* and *require one specific tool* are the **same type** — `RequiredChatToolMode` — differing only by a nullable `RequiredFunctionName`. Both adapters discriminated on the runtime type alone, so the name was dropped on the floor.
>
> ```csharp
> : toolMode is RequiredChatToolMode ? new ToolChoiceAny() { ... }
> ```
>
> Before / after, for `ChatToolMode.RequireSpecific("get_weather")` with two tools registered:
>
> ```jsonc
> // before -- byte-identical to ChatToolMode.RequireAny
> "tool_choice": { "type": "any" }
>
> // after
> "tool_choice": { "type": "tool", "name": "get_weather" }
> ```
>
> The call succeeded either way. No exception, no warning, no log line — the caller demanded one tool and the model was free to call any of the others. `RequiredChatToolMode.RequiredFunctionName`'s getter had zero occurrences anywhere in the shipped `Anthropic` assembly, across all three TFM groups.
>
> ## What changed
>
> One new arm in the `tool_choice` mapping in each of the two adapters, matching on the property rather than the type:
>
> ```csharp
> : toolMode is RequiredChatToolMode { RequiredFunctionName: { } name }
>     ? new ToolChoiceTool() { Name = name, DisableParallelToolUse = !options.AllowMultipleToolCalls }
> : toolMode is RequiredChatToolMode
>     ? new ToolChoiceAny() { ... }   // unchanged
> ```
>
> Applied to both copies per the "a fix usually needs applying to every copy" note in `CLAUDE.md`: `AnthropicClientExtensions` (stable, `ToolChoiceTool`) and `AnthropicBetaClientExtensions` (beta, `BetaToolChoiceTool`). Both surfaces had the defect.
>
> `DisableParallelToolUse` is carried over from the `ToolChoiceAny` arm unchanged, so `AllowMultipleToolCalls` keeps behaving identically on this path — including `null` staying `null` rather than becoming `false`.
>
> Behaviour change worth calling out: callers who passed `RequireSpecific` and were silently getting `"any"` will now get `"tool"`. That is the point of the fix, but it does mean a request that previously let the model choose will now force one tool.
>
> ## What gives confidence
>
> `GetResponseAsync_WithToolModeRequireSpecific`, added to `AnthropicClientExtensionsTestsBase` so it runs against **both** adapters. It registers two tools and asserts the exact wire request through `VerbatimHttpHandler`, whose `JsonNode.DeepEquals` comparison fails on an extra *or* missing member — so a `name` that goes missing, or one that appears somewhere unexpected, both fail rather than pass.
>
> - **Fails before:** 2 failed (one per adapter), both with `"tool_choice":{"type":"any"}` in the actual body.
> - **Passes after:** 2 passed.
> - No regressions: the 533 `AnthropicClient*` adapter tests pass, `./scripts/build` is clean (0 warnings, warnings-as-errors), `./scripts/lint` is clean.
>
> Not verified locally: the `net472` / `netstandard2.0` run, which needs Windows. The change is plain pattern matching with no TFM-sensitive API, so I would not expect a split, but CI is the source of truth there.
>
> ## Alternative considered
>
> Throwing on a `RequiredFunctionName` the adapter cannot honour would also be an improvement over discarding it, but the SDK can honour it, so mapping it is strictly better.
>
> ## Notes
>
> - Companion PR for #264 (union-typed schema nodes losing their type-specific keywords) touches the same file in a different region; they should merge in either order without conflicting.
> - Nothing to document outside this repo — this makes an already-documented `ChatOptions` knob work as its name says.

### After (about 300 words)

> Fixes #263.
>
> `ChatToolMode.RequireSpecific("get_weather")` was sent to Anthropic as `tool_choice: {"type": "any"}`, the same request `RequireAny` produces, so the model was free to call any registered tool instead of `get_weather`. The request succeeded, so nothing flagged the problem. With this fix the request is `{"type": "tool", "name": "get_weather"}`.
>
> ## Cause
>
> Both adapters chose `tool_choice` from the runtime type alone. In `Microsoft.Extensions.AI`, `RequireAny` and `RequireSpecific` are the same type, `RequiredChatToolMode`, differing only by a nullable `RequiredFunctionName`, so the name was never read:
>
> ```csharp
> : toolMode is RequiredChatToolMode ? new ToolChoiceAny() { ... }
> ```
>
> ## Change
>
> Both adapters, `AnthropicClientExtensions` (stable) and `AnthropicBetaClientExtensions` (beta, where the type is `BetaToolChoiceTool`), get one new arm ahead of the existing `ToolChoiceAny` arm:
>
> ```csharp
> : toolMode is RequiredChatToolMode { RequiredFunctionName: { } name }
>     ? new ToolChoiceTool() { Name = name, DisableParallelToolUse = !options.AllowMultipleToolCalls }
> ```
>
> `DisableParallelToolUse` is derived exactly as in the `ToolChoiceAny` arm, so `AllowMultipleToolCalls` behaves the same on this path, including a null value staying null.
>
> Existing callers of `RequireSpecific` will see a behavior change: requests that previously let the model choose now force one tool.
>
> ## Testing
>
> `GetResponseAsync_WithToolModeRequireSpecific` in `AnthropicClientExtensionsTestsBase` runs against both adapters. It registers two tools and asserts the full request body with a comparison that fails on any missing or extra member.
>
> - Before the fix: fails for both adapters with `"tool_choice":{"type":"any"}` in the body.
> - After: passes for both.
> - The full adapter suite, build, and lint pass.
>
> Not verified locally: `net472` and `netstandard2.0`, which need Windows. The change is plain pattern matching, so I don't expect a difference, but CI is the check.
>
> ## Notes
>
> #264 touches the same file in a different region. The two PRs should merge in either order without conflicts.

### Transformations

- **Behavior now leads.** The original opened with the framework's type design. A reader had to hold "same type, nullable property, discriminated on runtime type" in memory before learning what any of it caused. The rewrite opens with the wrong request and its consequence, then explains the representation.
- **The wire-format before/after became one sentence.** The comparison was already the clearest fact in the PR. It moved from the middle of the "what was wrong" section into the first paragraph.
- **The cause section opens with the defect, then the background, in one sentence before the code.** The adapters' type-only match is the bug; the framework's shared type is why that match loses information. The original had them in the opposite order, and the first draft of this rewrite did too.
- **The change section states its scope before the code.** A reviewer opening the diff wants to know it touches two adapters before reading the arm. The first draft put the scope after the code block.
- **Escalating restatement was collapsed.** "The call succeeded either way. No exception, no warning, no log line", the "byte-identical" comment, and the "zero occurrences across all three TFM groups" sentence all establish that the bug was silent. One clause does that.
- **The test section names the test, what it asserts, and the before/after result as a list.** The handler's class name, the JSON comparison API, the exact failure counts, warning counts, and the 533 figure are all inspectable in the diff and CI, and none change what a reviewer does. The three results stayed as bullets because they are parallel and scan faster than a sentence.
- **The behavior change stayed inside the change section.** A reader checking compatibility looks there, not in trailing notes.
- **The alternatives section was removed.** Throwing instead of mapping is not an alternative a reviewer would propose when the SDK can honor the request.
- **Section headings were kept.** This is a PR description; reviewers scan by section. The headings became plainer.
- **Metaphors and rhetorical constructions were replaced where they hid the literal fact.** "Dropped on the floor" became "never read the name". "Matching on the property rather than the type" was dropped because the code excerpt shows it.

### Deliberately removed

- The `CLAUDE.md` justification for applying the fix to both adapters. The reviewer needs to know both were fixed, not why the author knew to do it.
- "That is the point of the fix." The preceding sentence already made the point.
- "Nothing to document outside this repo." The absence of a documentation task is not information the reviewer acts on.
- The description of #264's content. The reader needs the conflict risk and the merge-order fact, not the other PR's subject.
- Exact test counts and the warnings-as-errors setting. CI reports them.
- The claim that `RequiredFunctionName`'s getter had no call sites in the shipped assembly. It is a second proof of a fact the wire comparison already shows, and a reviewer can confirm it with one search. This is a judgment call; a reviewer who wants proof that no other path consumed the name could reasonably ask for it back.

### Deliberately retained

- Both adapters had the defect and both were fixed. Dropping this would make a reviewer wonder whether the beta surface is still broken.
- `DisableParallelToolUse` uses the same derivation as the existing arm. This is the one implementation detail with a behavioral consequence a reviewer might probe.
- The behavior change for existing callers. It affects consumers, and it is the kind of note that belongs in a changelog.
- The Windows-only targets were not run locally. Removing an unverified-environment statement would turn a partial verification into an implied full one.
- The beta adapter's `BetaToolChoiceTool` type name and the null-stays-null clause. One code snippet stands for two changes, and without the name the snippet implies the copies are identical. The null clause is the one `bool?` subtlety a reviewer would pause on. Each costs a few words. A blind reader flagged both as the only substantive losses in an earlier draft.
- The clause that the test's comparison fails on any missing or extra member. It is the fact that backs "asserts the full request body"; without it the phrase is an unverified adjective.
- The merge-order note about #264. It is operationally useful to the maintainer merging both.

### Result

An engineer unfamiliar with the issue learns in the first sentence what was broken and what it caused, and in the next two sections why and what changed. In a blind comparison by a reader who had not seen the issue, the user-visible symptom arrived about three times sooner (roughly 35 words in versus 110), and no claim was strengthened or invented. The original required reading the whole first section to reach the same point, and the reader's model was of the type system, not of the wrong request.

## 2. Code review comment: defended instead of stated

Failure modes: preemptive defense, hedge stack, the point in the middle.

### Before

> Thanks for this. The overall direction here is solid, and I appreciate the thoroughness of the retry logic. One thing worth flagging, though it may well be intentional: `retryCount` is incremented before the `await`, which means that if the operation throws synchronously (which it can, since `client.Send` validates arguments eagerly), we will have consumed a retry slot without ever having actually attempted the request. In most cases this is harmless, since the argument validation failure is deterministic and retrying would not help anyway, but it does mean the error surfaced to the caller will be a `RetryExhaustedException` wrapping the `ArgumentException` rather than the `ArgumentException` itself, which could be confusing for callers trying to distinguish "you passed bad input" from "the network is down." Not a blocker, and happy to defer to you, but it might be worth either moving the increment after the `await`, or short-circuiting on synchronous throws. Either approach would work; the second is arguably more explicit about intent.

### After

> Bad arguments surface as `RetryExhaustedException` instead of `ArgumentException`. `client.Send` validates eagerly and throws synchronously, and `retryCount` is incremented before the `await`, so the validation failure burns every retry slot and the caller gets the wrapped exception. Moving the increment after the `await` fixes it. Not a blocker.

### Notes

The consequence the author cares about was the fourth clause of a nine-clause sentence. It is now the first sentence. The "harmless in most cases" hedge was removed because the next clause showed it is not harmless: the caller gets the wrong exception type. The two proposed fixes became one; the second was offered as a courtesy, not a preference. "Not a blocker" stayed because it tells the author what to do with the comment.

## 3. Slack project update: narrative instead of status

Failure modes: chronological narration, buried ask, background the channel knows.

### Before

> Hey team, quick update on the ingestion pipeline work. As you know, we have been migrating the batch importer over to the new streaming framework, which has been a larger lift than initially scoped due to some subtleties in how backpressure is handled between the Kafka consumer and the downstream transform stage. Over the past few days I have been digging into why the throughput numbers in staging were coming in lower than expected, and it turns out the transform stage was being throttled by a default buffer size that is tuned for much smaller payloads than ours. After adjusting that and re-running the load test, throughput is now roughly where we need it to be, though there is still some variance I want to characterize before calling it done. The other thing I wanted to raise is that the cutover date we discussed last week is looking tight given that the reconciliation job still needs to be adapted, so it would be great to get a sense of whether there is flexibility there or whether we should scope down the first release. Happy to discuss in standup or async, whichever works.

### After

> Ingestion pipeline: throughput in staging is now at target after fixing a buffer size in the transform stage. I still want to characterize the remaining variance before calling it done.
>
> The reconciliation job still needs adapting, so the cutover date from last week looks tight. Can we either move the date or ship the first release without reconciliation? I need a decision this week.

### Notes

The reader of this message needs to know the state and whether they must act. Both were at the end. The Kafka backpressure narrative and the debugging story were removed; anyone who needs them can ask. The ask was turned from "it would be great to get a sense of" into a question with two options and a deadline, because the original already implied both. Nothing was invented: the two options were the author's own.

## 4. Issue description: speculation before symptom

Failure modes: implementation before behavior, proposed fix ahead of reproduction, proof of diligence.

### Before

> I have been looking into the session handling code in `SessionMiddleware`, and I believe there may be an issue with how the sliding expiration is computed when the `Secure` cookie attribute is set and the request arrives over a plain HTTP connection, which can happen behind certain load balancer configurations that terminate TLS. From reading the code, `RefreshExpiry` is called unconditionally, but `Response.Cookies.Append` will silently skip writing a `Secure` cookie on a non-HTTPS request, so the refreshed expiry never reaches the client. I have traced through this fairly carefully and I am reasonably confident in the analysis, though I have not yet confirmed it with a packet capture. I think the correct fix is probably to either honor `X-Forwarded-Proto` when deciding whether the request is secure, or to log a warning when a `Secure` cookie is dropped, or both. I can put together a PR if this seems right.

### After

> Sessions expire after the initial timeout even though the user is active, when the app runs behind a TLS-terminating load balancer.
>
> Expected: each request extends the session by the sliding expiration window.
> Actual: the session expires at the original time.
>
> Setup: `Secure` cookie attribute enabled, app receives plain HTTP from the load balancer, `X-Forwarded-Proto: https` is present.
>
> Probable cause, from reading the code and not yet confirmed with a capture: `RefreshExpiry` runs, but `Response.Cookies.Append` skips `Secure` cookies on non-HTTPS requests, so the refreshed cookie never reaches the client. Honoring `X-Forwarded-Proto` in the secure check would fix it. I can open a PR.

### Notes

The original never stated the user-visible symptom; the reader had to derive "sessions expire early" from the mechanism. The rewrite leads with it and gives the expected/actual pair a maintainer needs. The "reasonably confident, traced carefully" language became a single explicit label, "not yet confirmed with a capture", which is the same fact without the appeal. The warning-log option was dropped as a fix because it does not fix the symptom; it could return as a separate suggestion if wanted.

## 5. Design document section: abstraction before example, and what to keep

Failure modes: abstraction first, framework vocabulary before behavior. This example is longer after the rewrite than a summary would be, because a design doc is supposed to carry the detail. The edit reorders and keeps the qualifications.

### Before

> ### Invalidation model
>
> The cache invalidation strategy adopts a generational, tag-scoped model in which each cache entry is associated with one or more invalidation tags, and each tag maintains a monotonically increasing generation counter persisted in the shared coordination store. At read time, the entry's recorded tag generations are compared against the current generations; any divergence is treated as a miss. This approach decouples invalidation from entry enumeration, which is significant because the enumeration cost of a scan-and-delete approach grows linearly with cache size, whereas generation comparison is O(tags) per read. It should be noted that because tag generations reside in the coordination store, a loss of that store's state results in a global invalidation event, which, while not ideal, is considered acceptable given our consistency requirements and is in any case strictly safer than the alternative failure mode of serving stale data.

### After

> ### Invalidation model
>
> When a product's price changes, every cached page that showed that price must be dropped, and nothing else should be. We do this with tags and generation counters rather than by scanning the cache.
>
> Each cache entry records the tags it depends on, such as `product:123` and `category:shoes`, and the generation number of each tag at the time it was written. Each tag has a generation counter in Redis. Invalidating a tag increments its counter. On read, the entry's recorded generations are compared with the current ones, and any mismatch is a miss.
>
> This keeps invalidation cost independent of cache size. A scan-and-delete approach costs time proportional to the number of entries; this costs one comparison per tag on each read.
>
> Because the counters live in Redis, losing Redis state invalidates the whole cache at once. That is acceptable for our consistency requirements, and it fails toward misses rather than stale data.

### Notes

The first sentence is now a concrete case the reader can picture. The mechanism follows at one altitude, then the reason for choosing it, then the failure mode. The failure mode was kept in full because it is a real operational property; only the "it should be noted that" and "while not ideal" framing were removed. "Coordination store" became the actual store's name, which the source document identified elsewhere; if it had not, the rewrite would keep the generic term rather than guess.

## 6. Release notes: drama instead of impact

Failure modes: dramatic restatement, internal mechanics, breaking change buried.

### Before

> ## v3.2.0
>
> This release represents a significant step forward in the robustness of the connection layer. We have completely reworked the way retries are orchestrated, moving from an ad hoc, per-call approach to a unified, policy-driven model that gives you fine-grained control over backoff, jitter, and circuit breaking. No more scattered retry loops. No more surprising timeouts. Just predictable, configurable behavior. As part of this work, the `retryOnTimeout` option has been superseded by the new `RetryPolicy` object; the old option continues to be accepted but now emits a deprecation warning and will be removed in v4. We have also fixed a long-standing issue where connection pools could, under specific and rare circumstances involving concurrent disposal, leak a socket, and improved the clarity of several error messages.

### After

> ## v3.2.0
>
> **Deprecated:** `retryOnTimeout` is replaced by `RetryPolicy`. The old option still works but logs a deprecation warning and is removed in v4.
>
> **Added:** `RetryPolicy` configures backoff, jitter, and circuit breaking for all calls in one place.
>
> **Fixed:** a socket leak in connection pools when a pool was disposed while a connection was in use. Several error messages are clearer.

### Notes

A user reading release notes wants to know what they must change first. The deprecation was the fifth sentence; it is now the first line. "No more scattered retry loops. No more surprising timeouts. Just predictable, configurable behavior" carried no information the `RetryPolicy` line does not. "Specific and rare circumstances involving concurrent disposal" was replaced by the concrete condition it was describing; if the source had not been specific enough to name the condition, the rewrite would say "in some concurrent disposal cases" rather than invent one.

## 7. AI research summary: significance instead of finding

Failure modes: faux-profound framing, symmetrical claims, restated significance, hedge that hides the actual limit.

### Before

> This paper offers a compelling reframing of how we think about retrieval-augmented generation. Rather than treating retrieval as a preprocessing step, the authors position it as a first-class participant in the generation loop, which is not merely an architectural nicety but a fundamentally different way of allocating the model's attention budget. Their key insight, that retrieval quality and generation quality are not independent but deeply intertwined, leads to a training procedure in which the retriever is updated using signal from the generator's downstream loss. The results are striking: on three of the four benchmarks evaluated, the approach outperforms strong baselines by a meaningful margin, and on the fourth it is competitive. It is worth noting that the evaluation is limited to English-language corpora and relatively short documents, and the compute cost of joint training is non-trivial, but these caveats do not diminish the significance of the core contribution. For teams building RAG systems, this work suggests that the boundary between retrieval and generation may be far more porous than conventional architectures assume.

### After

> The paper trains the retriever using the generator's loss instead of training the two separately. On three of four benchmarks it beats the strong baselines by a meaningful margin; on the fourth it is competitive.
>
> Limits: English-only corpora, short documents, and joint training costs substantially more compute than the usual pipeline.
>
> For us: if we retrain our retriever, joint training is worth a trial on our English document set. It is not a drop-in change, and the paper gives no evidence for long documents.

### Notes

The finding is one sentence and the original took four to reach it. "Not merely an architectural nicety but a fundamentally different way" and "not independent but deeply intertwined" are contrasts against positions no reader held. The caveats were kept and promoted, because "these caveats do not diminish the significance" was the source's opinion, not a fact, and a reader evaluating the paper for their own long-document use case needs the limits more than the praise. The "for us" paragraph states only what the evidence supports and names what it does not cover.

## 8. When to leave it alone

> Retries now use exponential backoff starting at 200 ms, capped at 5 s, with full jitter. The previous fixed 1 s delay caused thundering-herd reconnects after a broker restart; see the incident notes linked in the ticket.

This paragraph leads with the change, gives the numbers a reader would verify, states the reason in one sentence, and points to the evidence. It contains a "now" contrast and a link, and it needs both. Do not edit text that already passes the test.
