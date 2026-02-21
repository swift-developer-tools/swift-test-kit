# Property-Based Testing

Automatically generate random test cases, shrink failures to minimal 
counterexamples, and report failing values with full assertion output.

## Overview

Property-based testing is fundamentally different from example-based testing. 
Standard assertions check properties on data provided by the test author. 
Property-based testing inverts this concept: the test author describes what 
must be true, and SwiftTestKit generates random values automatically, searching 
for a case that invalidates the property.

When a failing value is found, SwiftTestKit shrinks it to the smallest value 
that still fails (the minimal counterexample), then reports it along with the 
full assertion failure output, including structural diffs, expression capture, 
and formatting preferences.

Value generation is controlled by a seed for deterministic replay, and by a 
size parameter that starts small (for example, zero, empty arrays, and short 
strings) and grows across iterations to explore progressively larger values.

### Assertion Interception

SwiftTestKit assertions used inside a property body are automatically 
intercepted rather than reported directly to Swift Testing. This allows 
SwiftTestKit to re-run the property body during shrinking without producing 
intermediate test failures. After shrinking completes, a single failure is 
reported containing the minimal counterexample and the intercepted assertion 
output.

- Important: Native Swift Testing assertions are not intercepted by 
SwiftTestKit. If a native Swift Testing assertion fails inside a property body, 
it bypasses shrinking and produces an immediate test failure. Use only 
SwiftTestKit assertions inside property bodies.

## Topics

### Evaluating Properties Synchronously

- ``STKForAll(_:fileID:file:line:column:options:_:)-9km1j``
- ``STKForAll(using:message:fileID:file:line:column:options:_:)-6h5i2``
- ``STKForAll(where:message:fileID:file:line:column:options:_:)-4zfpt``
- ``STKForAll(using:where:message:fileID:file:line:column:options:_:)-3v160``

### Evaluating Properties Asynchronously

- ``STKForAll(_:fileID:file:line:column:options:_:)-7d8k8``
- ``STKForAll(using:message:fileID:file:line:column:options:_:)-4hzb4``
- ``STKForAll(where:message:fileID:file:line:column:options:_:)-7oehd``
- ``STKForAll(using:where:message:fileID:file:line:column:options:_:)-5uhb2``

### Classifying Properties

- ``STKAssume(_:)``
- ``STKClassify(_:when:)``
- ``STKCover(_:_:when:)``
- ``STKLabel(_:)``
- ``STKCollect(_:)``
- ``STKTabulate(_:_:)``
- ``STKCoverTable(_:_:)``

### Generating Values

- ``Arbitrary``
- ``Arbitrary()``
- ``Generator``
- ``GenerationContext``
