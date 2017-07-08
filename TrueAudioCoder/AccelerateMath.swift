//
//  AccelerateMath.swift
// Copyright (c) 2014–2015 Mattt Thompson (http://mattt.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Accelerate

// MARK: Sum
public func sum(_ x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_sve(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func sum(_ x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_sveD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Sum of Absolute Values
public func asum(_ x: [Float]) -> Float {
    return cblas_sasum(Int32(x.count), x, 1)
}

public func asum(_ x: [Double]) -> Double {
    return cblas_dasum(Int32(x.count), x, 1)
}

// MARK: Maximum
public func max(_ x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_maxv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func max(_ x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_maxvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Minimum
public func min(_ x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_minv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func min(_ x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_minvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Mean
public func mean(_ x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_meanv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func mean(_ x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_meanvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Mean Magnitude
public func meamg(_ x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_meamgv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func meamg(_ x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_meamgvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Mean Square Value
public func measq(_ x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_measqv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func measq(_ x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_measqvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Add
public func add(_ x: [Float], y: [Float]) -> [Float] {
    var results = [Float](y)
    cblas_saxpy(Int32(x.count), 1.0, x, 1, &results, 1)
    
    return results
}

public func add(_ x: [Double], y: [Double]) -> [Double] {
    var results = [Double](y)
    cblas_daxpy(Int32(x.count), 1.0, x, 1, &results, 1)
    
    return results
}

// MARK: Subtraction
public func sub(_ x: [Float], y: [Float]) -> [Float] {
    var results = [Float](y)
    catlas_saxpby(Int32(x.count), 1.0, x, 1, -1, &results, 1)
    
    return results
}

public func sub(_ x: [Double], y: [Double]) -> [Double] {
    var results = [Double](y)
    catlas_daxpby(Int32(x.count), 1.0, x, 1, -1, &results, 1)
    
    return results
}

// MARK: Multiply
public func mul(_ x: [Float], y: [Float]) -> [Float] {
    var results = [Float](repeating: 0.0, count: x.count)
    vDSP_vmul(x, 1, y, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

public func mul(_ x: [Double], y: [Double]) -> [Double] {
    var results = [Double](repeating: 0.0, count: x.count)
    vDSP_vmulD(x, 1, y, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

// MARK: Divide
public func div(_ x: [Float], y: [Float]) -> [Float] {
    var results = [Float](repeating: 0.0, count: x.count)
    vvdivf(&results, x, y, [Int32(x.count)])
    
    return results
}

public func div(_ x: [Double], y: [Double]) -> [Double] {
    var results = [Double](repeating: 0.0, count: x.count)
    vvdiv(&results, x, y, [Int32(x.count)])
    
    return results
}

// MARK: Modulo
public func mod(_ x: [Float], y: [Float]) -> [Float] {
    var results = [Float](repeating: 0.0, count: x.count)
    vvfmodf(&results, x, y, [Int32(x.count)])
    
    return results
}

public func mod(_ x: [Double], y: [Double]) -> [Double] {
    var results = [Double](repeating: 0.0, count: x.count)
    vvfmod(&results, x, y, [Int32(x.count)])
    
    return results
}

// MARK: Remainder
public func remainder(_ x: [Float], y: [Float]) -> [Float] {
    var results = [Float](repeating: 0.0, count: x.count)
    vvremainderf(&results, x, y, [Int32(x.count)])
    
    return results
}

public func remainder(_ x: [Double], y: [Double]) -> [Double] {
    var results = [Double](repeating: 0.0, count: x.count)
    vvremainder(&results, x, y, [Int32(x.count)])
    
    return results
}

// MARK: Square Root
public func sqrt(_ x: [Float]) -> [Float] {
    var results = [Float](repeating: 0.0, count: x.count)
    vvsqrtf(&results, x, [Int32(x.count)])
    
    return results
}

public func sqrt(_ x: [Double]) -> [Double] {
    var results = [Double](repeating: 0.0, count: x.count)
    vvsqrt(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Dot Product
public func dot(_ x: [Float], y: [Float]) -> Float {
    precondition(x.count == y.count, "Vectors must have equal count")
    
    var result: Float = 0.0
    vDSP_dotpr(x, 1, y, 1, &result, vDSP_Length(x.count))
    
    return result
}


public func dot(_ x: [Double], y: [Double]) -> Double {
    precondition(x.count == y.count, "Vectors must have equal count")
    
    var result: Double = 0.0
    vDSP_dotprD(x, 1, y, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Fast Fourier Transform
public func fft(_ input: [Float]) -> (magnitudes: [Float], phases: [Float]) {
    var real = [Float](input)
    var imaginary = [Float](repeating: 0.0, count: input.count)
    
    var window = [Float](repeating: 0.0, count: input.count)
    //vDSP_hann_window(&window, vDSP_Length(input.count), Int32(vDSP_HANN_DENORM));
    vDSP_blkman_window(&window, vDSP_Length(input.count), 0)
    //vDSP_vmul(&window, 1, &real, 1, &real, 1, vDSP_Length(input.count))
    
    var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)
    
    let length = vDSP_Length(floor(log2(Float(input.count))))
    let radix = FFTRadix(kFFTRadix2)
    let weights = vDSP_create_fftsetup(length, radix)
    vDSP_fft_zip(weights!, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
    
    var magnitudes = [Float](repeating: 0.0, count: input.count)
    vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
    
    //var normalizedMagnitudes = [Float](repeating: 0.0, count: input.count)
    //vDSP_vsmul(sqrt(magnitudes), 1, [2.0 / Float(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))
    
    var phases = [Float](repeating: 0.0, count: input.count)
    
    for i in 0 ..< input.count {
        phases[i] = atan2f(splitComplex.imagp[i], splitComplex.realp[i])
    }
    
    
    vDSP_destroy_fftsetup(weights)
    
    return (sqrt(magnitudes), phases)
}

public func hann_window(windowSize: Int) -> [Float] {
    var window = [Float](repeating: 0.0, count: windowSize)
    vDSP_hann_window(&window, vDSP_Length(windowSize), Int32(vDSP_HANN_DENORM))
    return window
}


// MARK: Fast Fourier Transform
public func inverse_fft(_ magnitudes: [Float], phases: [Float]) -> [Float] {
    var real = [Float](repeating: 0.0, count: magnitudes.count)
    var imaginary = [Float](repeating: 0.0, count: magnitudes.count)
    for i in 0 ..< magnitudes.count {
        real[i] = magnitudes[i] * cosf(phases[i])
        imaginary[i] = magnitudes[i] * sinf(phases[i])
    }
    
    var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)
    
    let length = vDSP_Length(floor(log2(Float(magnitudes.count))))
    let radix = FFTRadix(kFFTRadix2)
    let weights = vDSP_create_fftsetup(length, radix)
    vDSP_fft_zip(weights!, &splitComplex, 1, length, FFTDirection(FFT_INVERSE))
    
    //var outMagnitudes = [Float](repeating: 0.0, count: magnitudes.count)
    //vDSP_zvmags(&splitComplex, 1, &outMagnitudes, 1, vDSP_Length(magnitudes.count))
    
    //var normalizedMagnitudes = [Float](repeating: 0.0, count: magnitudes.count)
    vDSP_vsmul(splitComplex.realp, 1, [1.0 / Float(magnitudes.count)], splitComplex.realp, 1, vDSP_Length(magnitudes.count))
    
    var window = [Float](repeating: 0.0, count: magnitudes.count)
    vDSP_hann_window(&window, vDSP_Length(magnitudes.count), Int32(vDSP_HANN_DENORM));
    //vDSP_vmul(&window, 1, splitComplex.realp, 1, splitComplex.realp, 1, vDSP_Length(magnitudes.count))
    
    vDSP_destroy_fftsetup(weights)
    
    return Array(UnsafeBufferPointer(start: splitComplex.realp, count: magnitudes.count))
}

public func fft(_ input: [Double]) -> [Double] {
    var real = [Double](input)
    var imaginary = [Double](repeating: 0.0, count: input.count)
    var splitComplex = DSPDoubleSplitComplex(realp: &real, imagp: &imaginary)
    
    let length = vDSP_Length(floor(log2(Float(input.count))))
    let radix = FFTRadix(kFFTRadix2)
    let weights = vDSP_create_fftsetupD(length, radix)
    vDSP_fft_zipD(weights!, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
    
    var magnitudes = [Double](repeating: 0.0, count: input.count)
    vDSP_zvmagsD(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
    
    var normalizedMagnitudes = [Double](repeating: 0.0, count: input.count)
    vDSP_vsmulD(sqrt(magnitudes), 1, [2.0 / Double(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))
    
    vDSP_destroy_fftsetupD(weights)
    
    return normalizedMagnitudes
}
