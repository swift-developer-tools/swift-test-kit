# Property-Based Testing

Automatically generate random test cases, shrink failures to minimal 
counterexamples, and report failing inputs with full assertion output.

## Overview

Property-based testing is fundamentally different from example-based testing. 
Standard assertions check properties on data provided by the test author. 
Property-based testing inverts this concept: the test author describes what 
must be true, and XCTestKit generates random inputs automatically, searching 
for a case that invalidates the property.

When a failing input is found, XCTestKit shrinks it to the smallest value that 
still fails (the minimal counterexample), then reports it along with the full 
assertion failure output, including structural diffs, expression capture, 
and formatting preferences.

Value generation is controlled by a seed for deterministic replay, and by a 
size parameter that starts small (for example, zero, empty arrays, and short 
strings) and grows across iterations to explore progressively larger inputs.

### Assertion Interception

XCTestKit assertions used inside a property body are automatically intercepted 
rather than reported directly to XCTest. This allows XCTestKit to re-run the 
property body during shrinking without producing intermediate test failures. 
After shrinking completes, a single failure is reported containing the minimal 
counterexample and the intercepted assertion output.

- Important: Native XCTest assertions are not intercepted by XCTestKit. If a 
native XCTest assertion fails inside a property body, it bypasses shrinking and 
produces an immediate test failure. Use only XCTestKit assertions inside 
property bodies.

## Topics

### Evaluating Properties Synchronously

- ``XCTKForAll(_:file:line:options:_:)-4hrgl``
- ``XCTKForAll(using:message:file:line:options:_:)-9crvp``
- ``XCTKForAll(where:message:file:line:options:_:)-88ock``
- ``XCTKForAll(using:where:message:file:line:options:_:)-lfb``

### Evaluating Properties Asynchronously

- ``XCTKForAll(_:file:line:options:_:)-5aetq``
- ``XCTKForAll(using:message:file:line:options:_:)-128a0``
- ``XCTKForAll(where:message:file:line:options:_:)-64dm8``
- ``XCTKForAll(using:where:message:file:line:options:_:)-57tax``

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
