//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// A representation of memory, in bytes.
public struct ByteCount:
    AdditiveArithmetic, Comparable, CustomStringConvertible,
    Equatable, Hashable, Sendable
{
    /// The byte count.
    public let rawValue: UInt64
    
    
    
    // MARK: - Initialize
    
    /// Initializes a ``ByteCount`` instance from the given byte count.
    /// - Parameter rawValue: The byte count.
    private init(
        rawValue: UInt64
    )
    {
        self.rawValue = rawValue
    }
    
    
    
    /// Creates a ``ByteCount`` instance from the given value and scale.
    /// - Parameters:
    ///   - value: The value to scale.
    ///   - scale: The amount by which to scale.
    /// - Returns: A ``ByteCount`` instance representing the given value and
    /// scale.
    private static func makeByteCount<T>(
        _ value : T,
        scale   : ByteCountScale
    ) -> ByteCount where T : BinaryInteger
    {
        return ByteCount(rawValue: scaled(value, by: scale))
    }
    
    
    
    /// Creates a ``ByteCount`` instance from the given value and scale.
    /// - Parameters:
    ///   - value: The value to scale.
    ///   - scale: The amount by which to scale.
    /// - Returns: A ``ByteCount`` instance representing the given value and
    /// scale.
    private static func makeByteCount(
        _ value : Double,
        scale   : ByteCountScale
    ) -> ByteCount
    {
        return ByteCount(rawValue: scaled(value, by: scale))
    }
    
    
    
    // MARK: - Bytes
    
    /// Creates a ``ByteCount`` instance from the given number of bytes.
    /// - Parameter bytes: The number of bytes.
    /// - Returns: A ``ByteCount`` instance representing the given number of
    /// bytes.
    public static func bytes<T>(
        _ bytes: T
    ) -> ByteCount where T : BinaryInteger
    {
        return makeByteCount(bytes, scale: .bytes)
    }
    
    
    
    // MARK: - Kilobytes
    
    /// Creates a ``ByteCount`` instance from the given number of kilobytes.
    /// - Parameter kilobytes: The number of kilobytes.
    /// - Returns: A ``ByteCount`` instance representing the given number of
    /// kilobytes.
    public static func kilobytes<T>(
        _ kilobytes: T
    ) -> ByteCount where T : BinaryInteger
    {
        return makeByteCount(kilobytes, scale: .kilobytes)
    }
    
    
    
    /// Creates a ``ByteCount`` instance from the given number of kilobytes.
    /// - Parameter kilobytes: The number of kilobytes.
    /// - Returns: A ``ByteCount`` instance representing the given number of
    /// kilobytes.
    public static func kilobytes(
        _ kilobytes: Double
    ) -> ByteCount
    {
        return makeByteCount(kilobytes, scale: .kilobytes)
    }
    
    
    
    
    // MARK: - Megabytes
    
    /// Creates a ``ByteCount`` instance from the given number of megabytes.
    /// - Parameter megabytes: The number of megabytes.
    /// - Returns: A ``ByteCount`` instance representing the given number of
    /// megabytes.
    public static func megabytes<T>(
        _ megabytes: T
    ) -> ByteCount where T : BinaryInteger
    {
        return makeByteCount(megabytes, scale: .megabytes)
    }
    
    
    
    /// Creates a ``ByteCount`` instance from the given number of megabytes.
    /// - Parameter megabytes: The number of megabytes.
    /// - Returns: A ``ByteCount`` instance representing the given number of
    /// megabytes.
    public static func megabytes(
        _ megabytes: Double
    ) -> ByteCount
    {
        return makeByteCount(megabytes, scale: .megabytes)
    }
    
    
    
    
    // MARK: - Gigabytes
    
    /// Creates a ``ByteCount`` instance from the given number of gigabytes.
    /// - Parameter gigabytes: The number of gigabytes.
    /// - Returns: A ``ByteCount`` instance representing the given number of
    /// gigabytes.
    public static func gigabytes<T>(
        _ gigabytes: T
    ) -> ByteCount where T : BinaryInteger
    {
        return makeByteCount(gigabytes, scale: .gigabytes)
    }
    
    
    
    /// Creates a ``ByteCount`` instance from the given number of gigabytes.
    /// - Parameter gigabytes: The number of gigabytes.
    /// - Returns: A ``ByteCount`` instance representing the given number of
    /// gigabytes.
    public static func gigabytes(
        _ gigabytes: Double
    ) -> ByteCount
    {
        return makeByteCount(gigabytes, scale: .gigabytes)
    }
    
    
    
    // MARK: - Scale
    
    /// Byte count scales.
    private enum ByteCountScale: UInt64
    {
        case bytes      = 1
        case kilobytes  = 1_024
        case megabytes  = 1_048_576
        case gigabytes  = 1_073_741_824
    }
    
    
    
    /// Scales the given value by the specified amount.
    ///
    /// - Precondition: `value` must not be negative.
    /// - Precondition: The ``ByteCount`` instance must not overflow.
    ///
    /// - Parameters:
    ///   - value: The value to scale.
    ///   - scale: The amount by which to scale.
    /// - Returns: The scaled value.
    private static func scaled<T>(
        _   value   : T,
        by  scale   : ByteCountScale
    ) -> UInt64 where T : BinaryInteger
    {
        precondition(
            value >= 0,
            "ByteCount must not be negative"
        )
        
        guard let base = UInt64(exactly: value)
        else
        {
            preconditionFailure("ByteCount overflow")
        }
        
        let (result, overflow)
            = base.multipliedReportingOverflow(by: scale.rawValue)
        
        precondition(
            !overflow,
            "ByteCount overflow"
        )
        
        return result
    }
    
    
    
    /// Scales the given value by the specified amount.
    ///
    /// - Precondition: `value` must be finite and must not be negative.
    /// - Precondition: The ``ByteCount`` instance must not overflow.
    ///
    /// - Parameters:
    ///   - value: The value to scale.
    ///   - scale: The amount by which to scale.
    /// - Returns: The scaled value.
    private static func scaled(
        _   value   : Double,
        by  scale   : ByteCountScale
    ) -> UInt64
    {
        precondition(
            value >= 0
            && value.isFinite,
            "ByteCount must be finite and must not be negative"
        )
        
        let scaledValue: Double = value * Double(scale.rawValue)
        
        precondition(
            scaledValue <= Double(UInt64.max),
            "ByteCount overflow"
        )
        
        return UInt64(scaledValue)
    }
    
    
    
    // MARK: - Conformance
    
    /// Checks whether the first value is less than the second value.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: A value to compare.
    /// - Returns: Whether the first value is less than the second value.
    public static func < (
        lhs : ByteCount,
        rhs : ByteCount
    ) -> Bool
    {
        return lhs.rawValue < rhs.rawValue
    }
    
    
    
    /// A textual representation of this instance.
    public var description: String
    {
        return rawValue.readableBytes
    }
    
    
    
    /// Zero bytes.
    public static var zero: ByteCount
    {
        return ByteCount(rawValue: 0)
    }
    
    
    
    /// Computes the sum of the given values.
    ///
    /// - Precondition: The sum of the given values must not overflow.
    ///
    /// - Parameters:
    ///   - lhs: The first value.
    ///   - rhs: The second value.
    /// - Returns: The sum of the given values.
    public static func + (
        lhs : ByteCount,
        rhs : ByteCount
    ) -> ByteCount
    {
        let (result, overflow): (UInt64, Bool)
            = lhs.rawValue.addingReportingOverflow(rhs.rawValue)
        
        precondition(
            !overflow,
            "ByteCount overflow"
        )
        
        return ByteCount(rawValue: result)
    }
    
    
    
    /// Computes the difference of the given values.
    ///
    /// - Precondition: `lhs` must be greater than or equal to `rhs`.
    ///
    /// - Parameters:
    ///   - lhs: The first value.
    ///   - rhs: The second value.
    /// - Returns: The difference of the given values.
    public static func - (
        lhs : ByteCount,
        rhs : ByteCount
    ) -> ByteCount
    {
        precondition(
            lhs.rawValue >= rhs.rawValue,
            "ByteCount underflow"
        )
        
        return ByteCount(rawValue: lhs.rawValue - rhs.rawValue)
    }
    
    
    
    /// Computes the product of the given values.
    ///
    /// - Precondition: `rhs` must not be negative.
    /// - Precondition: The product of the given values must not overflow.
    ///
    /// - Parameters:
    ///   - lhs: The byte count.
    ///   - rhs: The scalar.
    /// - Returns: The product of the given values.
    public static func * (
        lhs : ByteCount,
        rhs : Int
    ) -> ByteCount
    {
        precondition(
            rhs >= 0,
            "rhs must not be negative"
        )
        
        let (result, overflow): (UInt64, Bool)
            = lhs.rawValue.multipliedReportingOverflow(by: UInt64(rhs))
        
        precondition(
            !overflow,
            "ByteCount overflow"
        )
        
        return ByteCount(rawValue: result)
    }
    
    
    
    /// Computes the product of the given values.
    ///
    /// - Precondition: `lhs` must not be negative.
    /// - Precondition: The product of the given values must not overflow.
    ///
    /// - Parameters:
    ///   - lhs: The scalar.
    ///   - rhs: The byte count.
    /// - Returns: The product of the given values.
    public static func * (
        lhs : Int,
        rhs : ByteCount
    ) -> ByteCount
    {
        precondition(
            lhs >= 0,
            "lhs must not be negative"
        )
        
        return rhs * lhs
    }
    
    
    
    /// Computes the product of the given values and assigns the result to
    /// the given byte count.
    ///
    /// - Precondition: `rhs` must not be negative.
    /// - Precondition: The product of the given values must not overflow.
    ///
    /// - Parameters:
    ///   - lhs: The byte count.
    ///   - rhs: The scalar.
    public static func *= (
        lhs : inout ByteCount,
        rhs : Int
    )
    {
        lhs = lhs * rhs
    }
    
    
    
    /// Computes the quotient of the given values.
    ///
    /// - Precondition: `rhs` must be positive.
    ///
    /// - Parameters:
    ///   - lhs: The numerator.
    ///   - rhs: The denominator.
    /// - Returns: The quotient of the given values.
    public static func / (
        lhs : ByteCount,
        rhs : Int
    ) -> ByteCount
    {
        precondition(
            rhs > 0,
            "ByteCount division by zero or negative value"
        )
        
        return ByteCount(rawValue: lhs.rawValue / UInt64(rhs))
    }
    
    
    
    /// Computes the quotient of the given values.
    ///
    /// - Precondition: `rhs` must be positive.
    ///
    /// - Parameters:
    ///   - lhs: The numerator.
    ///   - rhs: The denominator.
    /// - Returns: The quotient of the given values.
    public static func / (
        lhs : ByteCount,
        rhs : ByteCount
    ) -> Double
    {
        precondition(
            rhs.rawValue > 0,
            "ByteCount division by zero"
        )
        
        return Double(lhs.rawValue) / Double(rhs.rawValue)
    }
    
    
    
    /// Computes the quotient of the given values and assigns the result to
    /// the given byte count.
    ///
    /// - Precondition: `rhs` must be positive.
    ///
    /// - Parameters:
    ///   - lhs: The byte count.
    ///   - rhs: The scalar.
    public static func /= (
        lhs : inout ByteCount,
        rhs : Int
    )
    {
        lhs = lhs / rhs
    }
}
