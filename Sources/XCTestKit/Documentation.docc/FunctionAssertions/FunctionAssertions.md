# Function Assertions

Assert that certain conditions are satisfied during code execution, and record 
test failures with configurable diff output.

## Overview

XCTestKit assertions mirror the XCTest assertion API. General usage patterns 
and testing workflows are the same. See 
[XCTest documentation](https://developer.apple.com/documentation/xctest) for 
instructions on how to write and run tests.

The primary difference between XCTestKit and XCTest is the diff output produced 
by ``XCTKAssertEqual(_:_:_:file:line:options:)-func``. When the given values 
are not equal, XCTestKit computes a structural diff and formats it as a 
path-based summary, providing clear and actionable insight into where the 
values differ. Other assertions do not produce diffs, since they assert 
conditions where a diff is not meaningful (for example, 
``XCTKAssertTrue(_:_:file:line:options:)-func`` asserts a binary condition).

## Topics

### Articles

- <doc:BooleanFunctionAssertions>
- <doc:NilFunctionAssertions>
- <doc:EqualityFunctionAssertions>
- <doc:ComparableFunctionAssertions>
- <doc:ErrorFunctionAssertions>
- <doc:FailFunctionAssertions>
