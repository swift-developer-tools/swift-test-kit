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

- ``XCTKForAll(_:fileID:file:line:column:options:_:)-8p99k``
- ``XCTKForAll(using:message:fileID:file:line:column:options:_:)-1n6rn``
- ``XCTKForAll(where:message:fileID:file:line:column:options:_:)-4xj6q``
- ``XCTKForAll(using:where:message:fileID:file:line:column:options:_:)-3lyy4``

### Evaluating Properties Asynchronously

- ``XCTKForAll(_:fileID:file:line:column:options:_:)-80308``
- ``XCTKForAll(using:message:fileID:file:line:column:options:_:)-75slc``
- ``XCTKForAll(where:message:fileID:file:line:column:options:_:)-7u936``
- ``XCTKForAll(using:where:message:fileID:file:line:column:options:_:)-39qo7``

### Evaluating Properties Statefully

- ``XCTKStateful(_:model:system:command:fileID:file:line:column:options:invariant:)``
- ``Stateful``
- ``Stateful()``
- ``Weight(_:)``

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
