# Macro Assertions

Assert that certain conditions are satisfied during code execution, and record 
test failures with configurable diff output.

## Overview

Macro assertions capture the literal source text of expressions for use in 
failure output. For boolean macro assertions, compound expressions using `&&` 
and `||` are decomposed to show the value of each sub-expression and identify 
which caused the assertion failure, respecting short-circuit evaluation so only 
evaluated operands appear in the output. Other macro assertions capture the 
expression text without decomposition. 

Macro assertions are particularly useful when testing complex expressions or 
reviewing CI/CD logs without immediate access to the source code.

## Topics

### Articles

- <doc:BooleanMacroAssertions>
- <doc:NilMacroAssertions>
- <doc:EqualityMacroAssertions>
- <doc:ComparableMacroAssertions>
- <doc:PredicateMacroAssertions>
- <doc:ErrorMacroAssertions>
- <doc:FailMacroAssertions>
