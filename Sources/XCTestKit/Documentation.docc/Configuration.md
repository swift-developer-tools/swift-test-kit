# Configuration

Configurable testing options.

## Overview

XCTestKit may be configured at the global or assertion level. Options passed 
to individual assertions take precedence over global options.

### Global Configuration

Use ``TestConfiguration`` to set options that apply to all assertions by 
default.

```swift
TestConfiguration.global.diffEnabled                = true
TestConfiguration.global.formatOptions.maxDiffs     = 5
```

### Assertion Configuration

Pass options directly to any assertion to override global options for that 
function call, or subclass ``XCTKCase`` to define reusable options for a test 
class.

```swift
final class TestClass: XCTKCase
{
    override var options: TestOptions
    {
        var opts = super.options
        opts.formatOptions.maxDiffs = 5
        return opts
    }
    
    func testWithGlobalOptions()
    {
        /// Pass no options to use the global options.
        XCTKAssertEqual(expected, actual)
    }
    
    func testWithClassOptions()
    {
        /// Pass class-level options to override the global options.
        XCTKAssertEqual(expected, actual, options: self.options)
    }
    
    func testWithCustomOptions()
    {
        let options = TestOptions(formatOptions: .init(maxDiffs: 10))

        /// Pass assertion-level options to override the global options.
        XCTKAssertEqual(expected, actual, options: options)
    }
}
```

## Topics

- ``XCTKCase``
- ``TestConfiguration``
- ``TestOptions``
- ``DiffOptions``
- ``FormatOptions``
- ``PropertyOptions``
