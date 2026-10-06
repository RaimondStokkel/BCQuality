---
bc-version: [all]
domain: data-modeling
keywords: [job-queue, tableextension, flowfield, calcformula, cleanup, retry, buffer, business-invariant, authoritative-state]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Business state must have a domain owner

## Description

An AL table extension can add fields to an extensible standard table, but that capability does not establish that the table owns their business meaning. An `exist` FlowField over `Job Queue Entry`, an import buffer, or an integration log proves only that matching records exist; recalculating it cannot prove that a business obligation has been resolved. A technically correct calculation can therefore change a business result when an execution record is removed, recreated, or retried, with the underlying business facts unchanged.

## Best Practice

Functional entities own business meaning, invariants, and outcomes; technical entities own execution mechanics. This is a design recommendation grounded in AL's record and FlowField semantics, not a platform prohibition on extending standard tables.

- For added fields or changed state consumers, identify the authoritative business fact, its owner, and the owner's responsibility and lifecycle. Apply this to standard and custom tables, including changes with no schema change.
- Extend a standard table when the added data belongs to that entity's responsibility and lifecycle. Customer preferences can belong to Customer; a queue row's retry settings belong to execution. Use a separate entity when identity, invariants, or retention require one, rather than merely moving the same dependency to another table.
- Trace the writer, authoritative reader, and relevant deletion, retention, rebuild, retry, or cancellation path. With business facts unchanged, those technical operations must not resolve an obligation or replace a domain decision. Retaining a technical row indefinitely cannot repair a meaning mismatch.
- Keep stable domain references, correlation data, and replay-safe checkpoints on technical records when their loss or reconstruction preserves the business invariant and required recovery. Disposable caches are valid when consumers fall back to the domain authority. Implementation metadata on a business entity is valid when it enforces that entity's own invariant, such as a concurrency version.
- Allow execution to advance business state through a validated domain transition. A successful retry may complete the work; a transport acknowledgement alone establishes only its documented transport meaning.
- Require visible evidence of the authoritative consumer and the responsibility or lifecycle mismatch before reporting a defect. Missing context, a technical-sounding field name, or `tableextension` alone is insufficient. For existing data, account for migration and consumers before changing ownership.

See sample: [`business-state-must-have-a-domain-owner.good.al`](business-state-must-have-a-domain-owner.good.al). Customer owns the repair indicator; removing an inactive job leaves it intact, and validating the repaired email clears it.

## Anti Pattern

- A business indicator is an `exist` FlowField over error-bearing queue or staging records, and a visible cleanup path removes those records without repairing the underlying business data.
- A business consumer treats execution success, transport acceptance, or absence of a technical record as approval or resolution without the corresponding domain evidence.
- A retry or transmission failure overwrites an existing business decision with attempt state, losing the distinction between the decision and its delivery.

Identify the business fact, the authoritative read or write, the technical operation that changes its meaning or lifetime, and the resulting incorrect outcome. These are ownership defects even when the field is on a custom table or the only change is in a page, report, or codeunit consumer.

See sample: [`business-state-must-have-a-domain-owner.bad.al`](business-state-must-have-a-domain-owner.bad.al). Removing the last matching inactive job makes the customer repair indicator false while the customer's email remains empty.

## References

- [Table extension objects](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-table-ext-object)
- [FlowFields and the Exist calculation](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-flowfields)
- [Record.Delete](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-delete-method)
