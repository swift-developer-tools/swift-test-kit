# Macro Assertions

Assert that certain conditions are satisfied during code execution, and record 
test failures with configurable diff output.

## Overview

XCTestKit assertions mirror the XCTest assertion API. General usage patterns 
and testing workflows are the same. See 
[XCTest documentation](https://developer.apple.com/documentation/xctest) for 
instructions on how to write and run tests.

The primary difference between XCTestKit and XCTest is the diff output produced 
by ``XCTKAssertEqual(_:_:_:file:line:options:)-macro``. When the given values 
are not equal, XCTestKit computes a structural diff and formats it as a 
path-based summary, providing clear and actionable insight into where the 
values differ. Other assertions do not produce diffs, since they assert 
conditions where a diff is not meaningful (for example, 
``XCTKAssertTrue(_:_:file:line:)-macro`` asserts a binary condition).

Additionally, macro assertions capture the literal source text of expressions 
for use in failure output. For boolean macro assertions, compound expressions 
using `&&` and `||` are decomposed to show the value of each sub-expression and 
identify which caused the assertion failure, respecting short-circuit 
evaluation so only evaluated operands appear in the output. Other macro 
assertions capture the expression text without decomposition. 

Macro assertions are particularly useful when testing complex expressions or 
reviewing CI/CD logs without immediate access to the source code.

## Topics

### Articles

- <doc:BooleanMacroAssertions>
- <doc:NilMacroAssertions>
- <doc:EqualityMacroAssertions>
- <doc:ComparableMacroAssertions>
- <doc:ErrorMacroAssertions>
- <doc:FailMacroAssertions>
