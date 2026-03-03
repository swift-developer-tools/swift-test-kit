//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Darwin
import Synchronization



/// Allocates memory that produces a deterministic increase in the physical
/// memory footprint.
///
/// Standard allocations through `Array` or `malloc()` may reuse pages that
/// are already in the process's physical memory footprint, producing no
/// measurable difference. This is less apparent when running a single test
/// in isolation, but prevalent when running tests repeatedly or as a group.
///
/// Use this to test performance tests that exceed the memory threshold.
/// Call `withExtendedLifetime(_:_:)` with the instance after the performance
/// call to prevent the compiler from destroying the instance before the
/// post-run memory measurement (the closure can be empty).
internal final class MemoryHolder: @unchecked Sendable
{
    /// The mapped pointers and the number of allocated bytes.
    ///
    /// An array is used to accumulate the mapped pointers so the physical
    /// memory footprint consistently rises between runs, while ensuring that
    /// all pointers are freed on deinitialization.
    private var mapped: [(pointer: UnsafeMutableRawPointer, bytes: Int)] = []
    
    
    
    /// Maps the given number of bytes into physical memory.
    ///
    /// This uses `mmap()` directly to bypass the any pre-allocated `malloc()`
    /// pool and ensure a deterministic increase in the physical memory
    /// footprint. All pages are touched to force physical allocation.
    ///
    /// - Parameter bytes: The number of bytes to map. The default value is
    /// `10_000_000`.
    @inline(never)
    internal func allocate(
        bytes: Int = 10_000_000
    )
    {
        let pointer: UnsafeMutableRawPointer? = mmap(
            nil,
            bytes,
            PROT_READ | PROT_WRITE,
            MAP_PRIVATE | MAP_ANON,
            -1,
            0
        )
        
        guard
            let pointer,
            pointer != UnsafeMutableRawPointer(bitPattern: -1)
        else
        {
            return
        }
        
        /// Touch every page to force physical allocation.
        memset(pointer, 1, bytes)
        
        self.mapped.append((pointer, bytes))
    }
    
    
    
    /// Deinitizializes the ``MemoryHolder`` instance.
    deinit
    {
        for (pointer, bytes) in mapped
        {
            munmap(pointer, bytes)
        }
    }
}
