# Property-Based Testing

Automatically generate random test cases, shrink failures to minimal 
counterexamples, and report failing values with full assertion output.

## Overview

Property-based testing is fundamentally different from example-based testing. 
Standard assertions check properties on data provided by the test author. 
Property-based testing inverts this concept: the test author describes what 
must be true, and XCTestKit generates random values automatically, searching 
for a case that invalidates the property.

When a failing value is found, XCTestKit shrinks it to the smallest value that 
still fails (the minimal counterexample), then reports it along with the full 
assertion failure output, including structural diffs, expression capture, 
and formatting preferences.

Value generation is controlled by a seed for deterministic replay, and by a 
size parameter that starts small (for example, zero, empty arrays, and short 
strings) and grows across iterations to explore progressively larger values.

Types used with property-based evaluators conform to the ``Arbitrary`` protocol, 
which defines how to generate random values and optionally how to shrink them.

### Targeted Testing

Targeted property-based testing guides generation toward values that maximize 
a numeric target. While standard property-based testing generates a new value 
on each iteration, targeted testing maintains a pool of high-target values 
and either generates a new value (exploration) or selects and mutates a pooled 
value (exploitation) on each iteration.

Over many iterations, the targeting process converges toward values that 
maximize the target metric, testing edge cases and worst-case behavior that 
random generation alone is unlikely to reach.

### Stateful Testing

Stateful testing extends property-based testing to systems with mutable state. 
Rather than testing individual values against a property, stateful testing 
generates random sequences of commands and executes them against both a 
simplified model and the real system, verifying consistency at each step.

Commands conform to the ``Stateful`` protocol, which defines how to generate 
random commands, execute them against the model and system, and advance the 
model independently. Optional preconditions filter commands based on the model 
state, and optional postconditions verify system behavior after each command 
is executed.

When a failing command sequence is found, it is shrunk to the minimal 
counterexample in two phases: removal shrinking removes unnecessary commands, 
and argument shrinking reduces individual command parameters.

## Topics

### Evaluating Properties Synchronously

- ``XCTKForAll(examples:message:fileID:file:line:column:options:_:)-7wpbg``
- ``XCTKForAll(using:examples:message:fileID:file:line:column:options:_:)-58b``
- ``XCTKForAll(where:examples:message:fileID:file:line:column:options:_:)-6zkzo``
- ``XCTKForAll(using:where:examples:message:fileID:file:line:column:options:_:)-4ef8a``

### Evaluating Properties Asynchronously

- ``XCTKForAll(examples:message:fileID:file:line:column:options:_:)-8pmfo``
- ``XCTKForAll(using:examples:message:fileID:file:line:column:options:_:)-2ig2c``
- ``XCTKForAll(where:examples:message:fileID:file:line:column:options:_:)-4n2q8``
- ``XCTKForAll(using:where:examples:message:fileID:file:line:column:options:_:)-2q3hf``

### Evaluating Properties Statefully

- ``XCTKStateful(_:model:system:command:fileID:file:line:column:options:invariant:)``
- ``Stateful``
- ``Stateful()``
- ``Weight(_:)``

### Targeting Properties

- ``XCTKTarget(_:)``

### Classifying Properties

- ``XCTKAssume(_:)``
- ``XCTKClassify(_:when:)``
- ``XCTKCover(_:_:when:)``
- ``XCTKLabel(_:)``
- ``XCTKCollect(_:)``
- ``XCTKTabulate(_:_:)``
- ``XCTKCoverTable(_:_:)``

### Generating Values

- ``Arbitrary``
- ``Arbitrary()``
- ``Generator``
- ``GenerationContext``

### Configuration

- ``PropertyOptions``
- ``PropertyDiagnostics``
- ``CommandStatistics``
