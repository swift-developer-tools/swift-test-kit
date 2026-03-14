# Custom Diffs

Customize structural comparison and rendering when computing diffs.

## Overview

Types that conform to ``CustomDiffRepresentable`` can control which properties 
are recursed into when computing diffs. This is useful for excluding properties 
that are irrelevant to logical equality, such as timestamps and large data 
blobs that would produce noisy output.

Types that conform to ``CustomDiffStringConvertible`` can control how a value 
appears in structural diffs. This is useful for types with verbose or unclear 
default string representation.

Both protocols may be adopted independently.

## Topics

### Structural Comparison

- ``CustomDiffRepresentable``
- ``DiffRepresentation``

### Rendering

- ``CustomDiffStringConvertible``
