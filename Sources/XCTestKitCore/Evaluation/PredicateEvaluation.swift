//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Iterates the given predicate over the given collection.
/// - Parameters:
///   - predicate: The predicate to call with each element of the collection.
///   - collection: The collection over which to iterate.
/// - Returns: Information about the iteration of the given predicate over the
/// given collection.
public func iteratePredicate<C>(
    _       predicate   : (C.Element) throws -> Bool,
    over    collection  : C
) -> PredicateIterationResult where C : Collection
{
    var matchedElements : [ElementResult]   = []
    var failedElements  : [ElementResult]   = []
    var errorElements   : [ElementResult]   = []
    
    for (index, element) in collection.enumerated()
    {
        do
        {
            let success: Bool = try predicate(element)
            
            let result = ElementResult(
                index:  index,
                value:  DiffValue(element),
                error:  nil
            )
            
            if success
            {
                matchedElements.append(result)
            }
            else
            {
                failedElements.append(result)
            }
        }
        catch
        {
            let result = ElementResult(
                index:  index,
                value:  DiffValue(element),
                error:  error.localizedDescription
            )
            
            errorElements.append(result)
        }
    }
    
    return PredicateIterationResult(
        matchedElements:    matchedElements,
        failedElements:     failedElements,
        errorElements:      errorElements
    )
}
