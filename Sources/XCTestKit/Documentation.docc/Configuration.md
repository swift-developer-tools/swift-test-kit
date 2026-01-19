# Configuration

Configurable testing options.

## Overview

XCTestKit may be configured at the global, class, or assertion level. Options 
passed to individual assertions have the highest priority, followed by class 
options, then global options.

Use ``XCTKConfig`` to customize the global configuration, or subclass 
``XCTKCase`` to override at the class level. Pass ``XCTKOptions`` directly to 
any assertion to override at the assertion level.

If no explicit configuration is provided at any level, the default 
configuration is used.

## Topics

### Setting Configuration

- ``XCTKConfig``
- ``XCTKCase``

### Option Types

- ``XCTKOptions``
- ``XCTKDiffOptions``
- ``XCTKFormatOptions``
