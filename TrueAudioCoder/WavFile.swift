//
//  WavFile.swift
//  TrueAudioCoder
//
//  Created by Alexander on 06.11.16.
//  Copyright © 2016 Alexander Kochupalov. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation
import Compression
/*
 0  - RIFF блок
 4  - длинна файла без RIFF блока
 
 
 8  - тип RIFF файла (может быть WAV,AVI,...)
 
 12 - fmt блок
 16 - длинна блока
 20 - формат WAV файла (1 - PCM, 2 - ADPCM,...)
 22 - количество каналов (1 - моно,2 - стерео)
 24 - частота оцифровки (8000,11025,22050,44100)
 28 - информация для буфера - скорость передачи байт в сек(частота оцифровки/количество байт для значения амплитуды)
 32 - количество байт для значения амплитуды
 34 - 8 бит или 16 бит
 
 36 - data блок
 40 - длинна блока
 */

class WavHeader {
    //RIFF block
    var rawHeaderData: NSMutableData = NSMutableData()
    var riff: String {
        get {
            return String.init(data: self.rawHeaderData.subdata(with: NSMakeRange(0, 4)), encoding: String.Encoding.ascii)!
        }
        set(newValue) {
            var convertedValue = newValue.data(using: String.Encoding.ascii)
            self.rawHeaderData.replaceBytes(in: NSMakeRange(0, 4), withBytes: &convertedValue)
        }
    }
    var fileLength: UInt {
        get {
            var tempInteger: UInt = 0
            rawHeaderData.getBytes(&tempInteger, range: NSMakeRange(4, 4))
            return tempInteger
        }
        set(newValue) {
            var copiedNewValue: UInt = newValue
            rawHeaderData.replaceBytes(in: NSMakeRange(4, 4), withBytes: &copiedNewValue)
        }
    }
    
    var riffType: String {
        get {
            return String.init(data: self.rawHeaderData.subdata(with: NSMakeRange(8, 4)), encoding: String.Encoding.ascii)!
        }
        set(newValue) {
            var convertedValue = newValue.data(using: String.Encoding.ascii)
            self.rawHeaderData.replaceBytes(in: NSMakeRange(8, 4), withBytes: &convertedValue)
        }
    }
    
    //FMT block
    var fmt: String {
        get {
            return String.init(data: self.rawHeaderData.subdata(with: NSMakeRange(12, 4)), encoding: String.Encoding.ascii)!
        }
        set(newValue) {
            var convertedValue = newValue.data(using: String.Encoding.ascii)
            self.rawHeaderData.replaceBytes(in: NSMakeRange(12, 4), withBytes: &convertedValue)
        }
    }
    var fmtLength: UInt {
        get {
            var tempInteger: UInt = 0
            rawHeaderData.getBytes(&tempInteger, range: NSMakeRange(16, 4))
            return tempInteger
        }
        set(newValue) {
            var copiedNewValue: UInt = newValue
            rawHeaderData.replaceBytes(in: NSMakeRange(16, 4), withBytes: &copiedNewValue)
        }
    }
    var wavFormat: UInt {
        get {
            var tempInteger: UInt = 0
            rawHeaderData.getBytes(&tempInteger, range: NSMakeRange(20, 2))
            return tempInteger
        }
        set(newValue) {
            var copiedNewValue: UInt = newValue
            rawHeaderData.replaceBytes(in: NSMakeRange(20, 2), withBytes: &copiedNewValue)
        }
    }
    var channelCount: UInt {
        get {
            var tempInteger: UInt = 0
            rawHeaderData.getBytes(&tempInteger, range: NSMakeRange(22, 2))
            return tempInteger
        }
        set(newValue) {
            var copiedNewValue: UInt = newValue
            rawHeaderData.replaceBytes(in: NSMakeRange(22, 2), withBytes: &copiedNewValue)
        }
    }
    var frequency: UInt {
        get {
            var tempInteger: UInt = 0
            rawHeaderData.getBytes(&tempInteger, range: NSMakeRange(24, 4))
            return tempInteger
        }
        set(newValue) {
            var copiedNewValue: UInt = newValue
            rawHeaderData.replaceBytes(in: NSMakeRange(24, 4), withBytes: &copiedNewValue)
        }
    }
    var byteRate: UInt {
        get {
            var tempInteger: UInt = 0
            rawHeaderData.getBytes(&tempInteger, range: NSMakeRange(28, 4))
            return tempInteger
        }
        set(newValue) {
            var copiedNewValue: UInt = newValue
            rawHeaderData.replaceBytes(in: NSMakeRange(28, 4), withBytes: &copiedNewValue)
        }
    }
    var sampleSize: UInt {
        get {
            var tempInteger: UInt = 0
            rawHeaderData.getBytes(&tempInteger, range: NSMakeRange(32, 2))
            return tempInteger
        }
        set(newValue) {
            var copiedNewValue: UInt = newValue
            rawHeaderData.replaceBytes(in: NSMakeRange(32, 2), withBytes: &copiedNewValue)
        }
    }
    var amplitudeSize: UInt {
        get {
            var tempInteger: UInt = 0
            rawHeaderData.getBytes(&tempInteger, range: NSMakeRange(34, 2))
            return tempInteger
        }
        set(newValue) {
            var copiedNewValue: UInt = newValue
            rawHeaderData.replaceBytes(in: NSMakeRange(34, 2), withBytes: &copiedNewValue)
        }
    }
    
    //DATA block
    var dataHead: String {
        get {
            return String.init(data: self.rawHeaderData.subdata(with: NSMakeRange(36, 4)), encoding: String.Encoding.ascii)!
        }
        set(newValue) {
            var convertedValue = newValue.data(using: String.Encoding.ascii)
            self.rawHeaderData.replaceBytes(in: NSMakeRange(36, 4), withBytes: &convertedValue)
        }
    }
    var dataLength: UInt {
        get {
            var tempInteger: UInt = 0
            rawHeaderData.getBytes(&tempInteger, range: NSMakeRange(40, 4))
            return tempInteger
        }
        set(newValue) {
            var copiedNewValue: UInt = newValue
            rawHeaderData.replaceBytes(in: NSMakeRange(40, 4), withBytes: &copiedNewValue)
        }
    }
    
    init(headerData: NSMutableData) {
        self.rawHeaderData = headerData
    }
    
}

class WavFile {
    var chunkSize: UInt = 2048          //размер в СЕМПЛАХ, 1 сэмпл = 2 канала по 2 байта
    var borderSize: Int = 70
    var wavHeader: WavHeader? = nil
    var sampleData: Data? = nil
    
    var fullTrack: NSData {
        get {
            let fullData = self.wavHeader!.rawHeaderData.mutableCopy() as! NSMutableData
            fullData.append(sampleData!)
            return fullData
        }
    }
    
    init (fileName: String) {
        let asset = NSDataAsset(name: fileName)
        let rawMusicData = asset!.data as NSData
        
        let rawHeader = rawMusicData.subdata(with: NSMakeRange(0, 44)) as NSData
        self.wavHeader = WavHeader(headerData: rawHeader.mutableCopy() as! NSMutableData)
        
        let rawAudio = rawMusicData.subdata(with: NSMakeRange(44, rawMusicData.length - 44))
        self.sampleData = rawAudio
        
        print("Header Size: \(self.wavHeader!.rawHeaderData.length)")
        print("Audio Size: \(self.sampleData!.count)")
    }
    
    init (fileUrl: URL) {
        //let asset = NSDataAsset(name: fileName)
        let rawMusicData = NSData(contentsOf: fileUrl)!
        
        let rawHeader = rawMusicData.subdata(with: NSMakeRange(0, 44)) as NSData
        self.wavHeader = WavHeader(headerData: rawHeader.mutableCopy() as! NSMutableData)
        
        let rawAudio = rawMusicData.subdata(with: NSMakeRange(44, rawMusicData.length - 44))
        self.sampleData = rawAudio
        
        print("Header Size: \(self.wavHeader!.rawHeaderData.length)")
        print("Audio Size: \(self.sampleData!.count)")
    }
    
    init (compressedData: Data) {
        var readedTotal: Int = 0
        var offset: Int = 44
        let headerData = compressedData.subdata(in: 0 ..< 44) as NSData
        self.wavHeader = WavHeader(headerData: headerData.mutableCopy() as! NSMutableData)
        
        self.sampleData = Data()
        
        (compressedData as NSData).getBytes(&readedTotal, range: NSMakeRange(offset, MemoryLayout<Int>.size))
        offset += MemoryLayout<Int>.size
        
        print("Read compressed data. Total: \(readedTotal) chunks")
        
        
        var prevLeftHalfChunk: [Float]? = nil
        var prevRightHalfChunk: [Float]? = nil
        
        let window = hann_window(windowSize: Int(self.chunkSize))
        
        for i in 0 ..< readedTotal - 1 {
            var leftChunkLength: Int = 0
            (compressedData as NSData).getBytes(&leftChunkLength, range: NSMakeRange(offset, MemoryLayout<Int>.size))
            offset += MemoryLayout<Int>.size
            
            let leftCompressedChunkData = compressedData.subdata(in: offset ..< (offset + leftChunkLength))
            
            offset += leftChunkLength
            
            let uncompressedLeftChunk = self.uncompressChunk(leftCompressedChunkData)
            
            var rightChunkLength: Int = 0
            (compressedData as NSData).getBytes(&rightChunkLength, range: NSMakeRange(offset, MemoryLayout<Int>.size))
            offset += MemoryLayout<Int>.size
            
            let rightCompressedChunkData = compressedData.subdata(in: offset ..< (offset + rightChunkLength))
            
            
            offset += rightChunkLength
            
            let uncompressedRightChunk = self.uncompressChunk(rightCompressedChunkData)
            
            //uncompressedLeftChunk.magnitudes.append(contentsOf: uncompressedLeftChunk.magnitudes.reversed())
            //uncompressedLeftChunk.phases.append(contentsOf: uncompressedLeftChunk.phases.reversed().map({return $0 * (-1.0)}))
            
            //uncompressedRightChunk.magnitudes.append(contentsOf: uncompressedRightChunk.magnitudes.reversed())
            //uncompressedRightChunk.phases.append(contentsOf: uncompressedRightChunk.phases.reversed().map({return $0 * (-1.0)}))
            
            var inverseLeftChunk: [Float] = inverse_fft(uncompressedLeftChunk.magnitudes, phases: uncompressedLeftChunk.phases)
            var inverseRightChunk: [Float] = inverse_fft(uncompressedRightChunk.magnitudes, phases: uncompressedRightChunk.phases)
            
            inverseLeftChunk = mul(inverseLeftChunk, y: window)
            inverseRightChunk = mul(inverseRightChunk, y: window)
            
            var newLeftChunk: [Float]
            var newRightChunk: [Float]
            
            if prevLeftHalfChunk == nil || prevRightHalfChunk == nil {
                newLeftChunk = Array(inverseLeftChunk[0 ..< Int(self.chunkSize / 2)])
                newRightChunk = Array(inverseRightChunk[0 ..< Int(self.chunkSize / 2)])
            }
            else {
                newLeftChunk = add(Array(inverseLeftChunk[0 ..< Int(self.chunkSize / 2)]), y: prevLeftHalfChunk!)
                newRightChunk = add(Array(inverseRightChunk[0 ..< Int(self.chunkSize / 2)]), y: prevRightHalfChunk!)
            }
            
            //self.replaceHalfChunk(chunkNumber: UInt(i), newChunkLeft: newLeftChunk, newChunkRight: newRightChunk)
            self.addHalfChunk(chunkNumber: UInt(i), newChunkLeft: newLeftChunk, newChunkRight: newRightChunk)
            
            prevLeftHalfChunk = Array(inverseLeftChunk[Int(self.chunkSize / 2) ..< Int(self.chunkSize)])
            prevRightHalfChunk = Array(inverseRightChunk[Int(self.chunkSize / 2) ..< Int(self.chunkSize)])
            
            print("Chunk \(i) replaced succefully")
        }
    }
    
    func readChunk(chunkNumber: UInt, channelNumber: Int = 0) -> [Float]? {
        let offset = chunkNumber * self.chunkSize * 4
        if offset > UInt(self.sampleData!.count) {
            return nil
        }
        
        let subData = self.sampleData! as NSData
        
        var outputArray = [Int16](repeating: 0, count: Int(self.chunkSize * 2))
        
        subData.getBytes(&outputArray, range: NSMakeRange(Int(offset), Int(self.chunkSize * 4)))
        
        return outputArray.enumerated().filter({(index, value) in index % 2 == channelNumber }).map({(index, value) in return Float(value)})
        
    }
    
    func readHalfChunk(chunkNumber: UInt, channelNumber: Int = 0) -> [Float]? {
        let offset = chunkNumber * self.chunkSize * 2 //перекрытие 50%
        if offset > UInt(self.sampleData!.count) {
            return nil
        }
        
        let subData = self.sampleData! as NSData
        
        var outputArray = [Int16](repeating: 0, count: Int(self.chunkSize * 2))
        
        subData.getBytes(&outputArray, range: NSMakeRange(Int(offset), Int(self.chunkSize * 4)))
        
        return outputArray.enumerated().filter({(index, value) in index % 2 == channelNumber }).map({(index, value) in return Float(value)})
        
    }
    
    func replaceChunk(chunkNumber: UInt, newChunkLeft: [Float], newChunkRight: [Float]) {
        var newChunk: [Int16] = []
        let offset = chunkNumber * self.chunkSize * 4
        
        for i in 0 ..< newChunkLeft.count {
            if Int(newChunkLeft[i]) < Int(Int16.min) {
                newChunk.append(Int16.min)
            }
            else if Int(newChunkLeft[i]) > Int(Int16.max) {
                newChunk.append(Int16.max)
            }
            else {
                newChunk.append(Int16(newChunkLeft[i]))
            }
            
            if Int(newChunkRight[i]) < Int(Int16.min) {
                newChunk.append(Int16.min)
            }
            else if Int(newChunkRight[i]) > Int(Int16.max) {
                newChunk.append(Int16.max)
            }
            else {
                newChunk.append(Int16(newChunkRight[i]))
            }
        }
        
        
        let newData = NSData(bytes: &newChunk, length: Int(self.chunkSize * 4))
        self.sampleData?.replaceSubrange(Int(offset) ..< Int(offset + self.chunkSize * 4), with: newData as Data)
    }
    
    func replaceHalfChunk(chunkNumber: UInt, newChunkLeft: [Float], newChunkRight: [Float]) {
        var newChunk: [Int16] = []
        let offset = chunkNumber * self.chunkSize * 2   //перекрытие 50%
        
        for i in 0 ..< newChunkLeft.count {
            if Int(newChunkLeft[i]) < Int(Int16.min) {
                newChunk.append(Int16.min)
            }
            else if Int(newChunkLeft[i]) > Int(Int16.max) {
                newChunk.append(Int16.max)
            }
            else {
                newChunk.append(Int16(newChunkLeft[i]))
            }
            
            if Int(newChunkRight[i]) < Int(Int16.min) {
                newChunk.append(Int16.min)
            }
            else if Int(newChunkRight[i]) > Int(Int16.max) {
                newChunk.append(Int16.max)
            }
            else {
                newChunk.append(Int16(newChunkRight[i]))
            }
        }
        
        
        let newData = NSData(bytes: &newChunk, length: Int(self.chunkSize * 2))
        self.sampleData?.replaceSubrange(Int(offset) ..< Int(offset + self.chunkSize * 2), with: newData as Data)
    }
    
    func addChunk(chunkNumber: UInt, newChunkLeft: [Float], newChunkRight: [Float]) {
        var newChunk: [Int16] = []
        
        for i in 0 ..< newChunkLeft.count {
            if Int(newChunkLeft[i]) < Int(Int16.min) {
                newChunk.append(Int16.min)
            }
            else if Int(newChunkLeft[i]) > Int(Int16.max) {
                newChunk.append(Int16.max)
            }
            else {
                newChunk.append(Int16(newChunkLeft[i]))
            }
            
            if Int(newChunkRight[i]) < Int(Int16.min) {
                newChunk.append(Int16.min)
            }
            else if Int(newChunkRight[i]) > Int(Int16.max) {
                newChunk.append(Int16.max)
            }
            else {
                newChunk.append(Int16(newChunkRight[i]))
            }
        }
        
        let newData = NSData(bytes: &newChunk, length: Int(self.chunkSize * 4))
        self.sampleData?.append(newData as Data)
    }
    
    func addHalfChunk(chunkNumber: UInt, newChunkLeft: [Float], newChunkRight: [Float]) {
        var newChunk: [Int16] = []
        
        for i in 0 ..< newChunkLeft.count {
            if Int(newChunkLeft[i]) < Int(Int16.min) {
                newChunk.append(Int16.min)
            }
            else if Int(newChunkLeft[i]) > Int(Int16.max) {
                newChunk.append(Int16.max)
            }
            else {
                newChunk.append(Int16(newChunkLeft[i]))
            }
            
            if Int(newChunkRight[i]) < Int(Int16.min) {
                newChunk.append(Int16.min)
            }
            else if Int(newChunkRight[i]) > Int(Int16.max) {
                newChunk.append(Int16.max)
            }
            else {
                newChunk.append(Int16(newChunkRight[i]))
            }
        }
        
        let newData = NSData(bytes: &newChunk, length: Int(self.chunkSize * 2))
        self.sampleData?.append(newData as Data)
    }
    
    func convertToInt16(_ floatValue: Float) -> Int16 {
        if Int(floatValue) < Int(Int16.min) {
            return Int16.min
        }
        else if Int(floatValue) > Int(Int16.max) {
            return Int16.max
        }
        else {
            return Int16(floatValue)
        }
    }
    
    func generateFilter() -> [Float] {
        var result: [Float] = []
        for i in 0 ..< self.chunkSize {
            if borders(Int(i)) {
                result.append(1.0)
            }
            else {
                result.append(0.0)
            }
        }
        return result
    }
    
    func generateAdaptiveFilter(inputMagnitudes: [Float]) -> [Float] {
        var result: [Float] = []
        let maxMagnitude = inputMagnitudes.max()!
        let maxIndex = inputMagnitudes.index(of: maxMagnitude)!
        
        let inLeftBorder = maxIndex < (inputMagnitudes.count / 2)
        
        var firstLeftBorder = 0
        var firstRightBorder = 0
        var secondLeftBorder = 0
        var secondRightBorder = 0
        
        if inLeftBorder {
            firstLeftBorder = maxIndex - self.borderSize > 0 ? maxIndex - self.borderSize : 0
            firstRightBorder = maxIndex + self.borderSize < Int(self.chunkSize / 2) ? maxIndex + self.borderSize : Int(self.chunkSize / 2)
        }
        else {
            firstLeftBorder = maxIndex - self.borderSize > Int(self.chunkSize / 2) ? maxIndex - self.borderSize : Int(self.chunkSize / 2)
            firstRightBorder = maxIndex + self.borderSize < Int(self.chunkSize) ? maxIndex + self.borderSize : Int(self.chunkSize)
        }
        
        secondLeftBorder = Int(self.chunkSize) - firstLeftBorder
        secondRightBorder = Int(self.chunkSize) - secondRightBorder
        
        for i in 0 ..< Int(self.chunkSize) {
            if (i >= firstLeftBorder && i <= firstRightBorder) || (i >= secondLeftBorder && i <= secondRightBorder) {
                result.append(1.0)
            }
            else {
                result.append(0.0)
            }
        }
        return result
    }
    
    func compressFile() -> Data {
        let fullChunkNumber: Int = self.fullTrack.length / Int(self.chunkSize * 2)
        print("Total: \(fullChunkNumber) chunks")
        
        var compressedData = Data()
        
        var totalSize = fullChunkNumber
        
        let totalSizeData = Data(bytes: &totalSize, count: MemoryLayout<Int>.size)
        
        compressedData.append(self.wavHeader!.rawHeaderData as Data)
        
        compressedData.append(totalSizeData)
        
        for i in 0 ..< (fullChunkNumber - 1) {
            let leftChunk = self.readHalfChunk(chunkNumber: UInt(i), channelNumber: 0)
            let rightChunk = self.readHalfChunk(chunkNumber: UInt(i), channelNumber: 1)
            
            var leftSpectrum = fft(leftChunk!)
            var rightSpectrum = fft(rightChunk!)
            
            let leftFilter = self.generateAdaptiveFilter(inputMagnitudes: leftSpectrum.magnitudes)
            let rightFilter = self.generateAdaptiveFilter(inputMagnitudes: rightSpectrum.magnitudes)
            
            leftSpectrum.magnitudes = mul(leftSpectrum.magnitudes, y: leftFilter)
            rightSpectrum.magnitudes = mul(rightSpectrum.magnitudes, y: rightFilter)
            leftSpectrum.phases = mul(leftSpectrum.phases, y: leftFilter)
            rightSpectrum.phases = mul(rightSpectrum.phases, y: rightFilter)
            
            
            //print("Array size: \(leftSpectrum.magnitudes.count); Chunk size: \(self.chunkSize / 2)")
            
            
            //let leftCompressed = self.compressChunk(Array(leftSpectrum.magnitudes[0 ..< Int(chunkSize / 2)]), phases: Array(leftSpectrum.phases[0 ..< Int(chunkSize / 2)]))
            //let rightCompressed = self.compressChunk(Array(rightSpectrum.magnitudes[0 ..< Int(chunkSize / 2)]), phases: Array(rightSpectrum.phases[0 ..< Int(chunkSize / 2)]))
            
            let leftCompressed = self.compressChunk(leftSpectrum.magnitudes, phases: leftSpectrum.phases)
            let rightCompressed = self.compressChunk(rightSpectrum.magnitudes, phases: rightSpectrum.phases)
            
            var leftCount = leftCompressed.count
            var rightCount = rightCompressed.count
            
            let leftDataSize = Data(bytes: &leftCount, count: MemoryLayout<Int>.size)
            let rightDataSize = Data(bytes: &rightCount, count: MemoryLayout<Int>.size)
            
            
            
            compressedData.append(leftDataSize)
            compressedData.append(leftCompressed)
            compressedData.append(rightDataSize)
            compressedData.append(rightCompressed)
            
            
            
            //print("Compression sizes: \(leftCompressed.count) bytes and \(rightCompressed.count) bytes")
            
            
            print("Chunk \(i) compressed succefully")
        }
        
        print("Total compressed size: \(compressedData.count / 1024) kbytes, \(fullChunkNumber) chunks")
        
        return compressedData
    }
    
    func testFilter() {
        let fullChunkNumber: Int = self.fullTrack.length / Int(self.chunkSize * 4)
        print("Total: \(fullChunkNumber) chunks")
        
        var compressedData = Data()
        
        var totalSize = fullChunkNumber
        
        let totalSizeData = Data(bytes: &totalSize, count: MemoryLayout<Int>.size)
        
        compressedData.append(totalSizeData)
        
        
        for i in 0 ..< (fullChunkNumber) {
            let leftChunk = self.readChunk(chunkNumber: UInt(i), channelNumber: 0)
            let rightChunk = self.readChunk(chunkNumber: UInt(i), channelNumber: 1)
            let filter = self.generateFilter()
            
            var leftSpectrum = fft(leftChunk!)
            var rightSpectrum = fft(rightChunk!)
            leftSpectrum.magnitudes = mul(leftSpectrum.magnitudes, y: filter)
            rightSpectrum.magnitudes = mul(rightSpectrum.magnitudes, y: filter)
            leftSpectrum.phases = mul(leftSpectrum.phases, y: filter)
            rightSpectrum.phases = mul(rightSpectrum.phases, y: filter)
            
            let leftCompressed = self.compressChunk(leftSpectrum.magnitudes, phases: leftSpectrum.phases)
            let rightCompressed = self.compressChunk(rightSpectrum.magnitudes, phases: rightSpectrum.phases)
            
            var leftCount = leftCompressed.count
            var rightCount = rightCompressed.count
            
            let leftDataSize = Data(bytes: &leftCount, count: MemoryLayout<Int>.size)
            let rightDataSize = Data(bytes: &rightCount, count: MemoryLayout<Int>.size)
            
    
            
            compressedData.append(leftDataSize)
            compressedData.append(leftCompressed)
            compressedData.append(rightDataSize)
            compressedData.append(rightCompressed)
            
            
            //print("Compression sizes: \(leftCompressed.count) bytes and \(rightCompressed.count) bytes")
            
            
            print("Chunk \(i) compressed succefully")
        }
        
        print("Total compressed size: \(compressedData.count / 1024) kbytes, \(fullChunkNumber) chunks")
        
        var readedTotal: Int = 0
        var offset: Int = 0
        
        (compressedData as NSData).getBytes(&readedTotal, range: NSMakeRange(offset, MemoryLayout<Int>.size))
        offset += MemoryLayout<Int>.size
        
        print("Read compressed data. Total: \(readedTotal) chunks")
        
        for i in 0 ..< readedTotal {
            var leftChunkLength: Int = 0
            (compressedData as NSData).getBytes(&leftChunkLength, range: NSMakeRange(offset, MemoryLayout<Int>.size))
            offset += MemoryLayout<Int>.size
            
            let leftCompressedChunkData = compressedData.subdata(in: offset ..< (offset + leftChunkLength))
            
            offset += leftChunkLength
            
            let uncompressedLeftChunk = self.uncompressChunk(leftCompressedChunkData)
            
            var rightChunkLength: Int = 0
            (compressedData as NSData).getBytes(&rightChunkLength, range: NSMakeRange(offset, MemoryLayout<Int>.size))
            offset += MemoryLayout<Int>.size
            
            let rightCompressedChunkData = compressedData.subdata(in: offset ..< (offset + rightChunkLength))
            
            
            offset += rightChunkLength
            
            let uncompressedRightChunk = self.uncompressChunk(rightCompressedChunkData)
            
            let newLeftChunk = inverse_fft(uncompressedLeftChunk.magnitudes, phases: uncompressedLeftChunk.phases)
            let newRightChunk = inverse_fft(uncompressedRightChunk.magnitudes, phases: uncompressedRightChunk.phases)
            
            self.replaceChunk(chunkNumber: UInt(i), newChunkLeft: newLeftChunk, newChunkRight: newRightChunk)
            print("Chunk \(i) replaced succefully")
        }
        
    }
    
    func testHalfFilter() {
        let fullChunkNumber: Int = self.fullTrack.length / Int(self.chunkSize * 2)  //перекрытие 50%
        print("Total: \(fullChunkNumber) chunks")
        
        var compressedData = Data()
        
        var totalSize = fullChunkNumber
        
        let totalSizeData = Data(bytes: &totalSize, count: MemoryLayout<Int>.size)
        
        compressedData.append(totalSizeData)
        
        
        let window = hann_window(windowSize: Int(self.chunkSize))
        
        
        for i in 0 ..< (fullChunkNumber - 1) {
            let leftChunk = self.readHalfChunk(chunkNumber: UInt(i), channelNumber: 0)
            let rightChunk = self.readHalfChunk(chunkNumber: UInt(i), channelNumber: 1)
            
            var leftSpectrum = fft(leftChunk!)
            var rightSpectrum = fft(rightChunk!)
            
            let leftFilter = self.generateAdaptiveFilter(inputMagnitudes: leftSpectrum.magnitudes)
            let rightFilter = self.generateAdaptiveFilter(inputMagnitudes: rightSpectrum.magnitudes)
            
            leftSpectrum.magnitudes = mul(leftSpectrum.magnitudes, y: leftFilter)
            rightSpectrum.magnitudes = mul(rightSpectrum.magnitudes, y: rightFilter)
            leftSpectrum.phases = mul(leftSpectrum.phases, y: leftFilter)
            rightSpectrum.phases = mul(rightSpectrum.phases, y: rightFilter)
            
            
            //print("Array size: \(leftSpectrum.magnitudes.count); Chunk size: \(self.chunkSize / 2)")
            
            
            //let leftCompressed = self.compressChunk(Array(leftSpectrum.magnitudes[0 ..< Int(chunkSize / 2)]), phases: Array(leftSpectrum.phases[0 ..< Int(chunkSize / 2)]))
            //let rightCompressed = self.compressChunk(Array(rightSpectrum.magnitudes[0 ..< Int(chunkSize / 2)]), phases: Array(rightSpectrum.phases[0 ..< Int(chunkSize / 2)]))
            
            let leftCompressed = self.compressChunk(leftSpectrum.magnitudes, phases: leftSpectrum.phases)
            let rightCompressed = self.compressChunk(rightSpectrum.magnitudes, phases: rightSpectrum.phases)
            
            var leftCount = leftCompressed.count
            var rightCount = rightCompressed.count
            
            let leftDataSize = Data(bytes: &leftCount, count: MemoryLayout<Int>.size)
            let rightDataSize = Data(bytes: &rightCount, count: MemoryLayout<Int>.size)
            
            
            
            compressedData.append(leftDataSize)
            compressedData.append(leftCompressed)
            compressedData.append(rightDataSize)
            compressedData.append(rightCompressed)
            
            
            
            //print("Compression sizes: \(leftCompressed.count) bytes and \(rightCompressed.count) bytes")
            
            
            print("Chunk \(i) compressed succefully")
        }
        
        print("Total compressed size: \(compressedData.count / 1024) kbytes, \(fullChunkNumber) chunks")
        
        var readedTotal: Int = 0
        var offset: Int = 0
        
        (compressedData as NSData).getBytes(&readedTotal, range: NSMakeRange(offset, MemoryLayout<Int>.size))
        offset += MemoryLayout<Int>.size
        
        print("Read compressed data. Total: \(readedTotal) chunks")
        
        var prevLeftHalfChunk: [Float]? = nil
        var prevRightHalfChunk: [Float]? = nil
        
        for i in 0 ..< readedTotal - 1 {
            var leftChunkLength: Int = 0
            (compressedData as NSData).getBytes(&leftChunkLength, range: NSMakeRange(offset, MemoryLayout<Int>.size))
            offset += MemoryLayout<Int>.size
            
            let leftCompressedChunkData = compressedData.subdata(in: offset ..< (offset + leftChunkLength))
            
            offset += leftChunkLength
            
            let uncompressedLeftChunk = self.uncompressChunk(leftCompressedChunkData)
            
            var rightChunkLength: Int = 0
            (compressedData as NSData).getBytes(&rightChunkLength, range: NSMakeRange(offset, MemoryLayout<Int>.size))
            offset += MemoryLayout<Int>.size
            
            let rightCompressedChunkData = compressedData.subdata(in: offset ..< (offset + rightChunkLength))
            
            
            offset += rightChunkLength
            
            let uncompressedRightChunk = self.uncompressChunk(rightCompressedChunkData)
            
            //uncompressedLeftChunk.magnitudes.append(contentsOf: uncompressedLeftChunk.magnitudes.reversed())
            //uncompressedLeftChunk.phases.append(contentsOf: uncompressedLeftChunk.phases.reversed().map({return $0 * (-1.0)}))
            
            //uncompressedRightChunk.magnitudes.append(contentsOf: uncompressedRightChunk.magnitudes.reversed())
            //uncompressedRightChunk.phases.append(contentsOf: uncompressedRightChunk.phases.reversed().map({return $0 * (-1.0)}))
            
            var inverseLeftChunk: [Float] = inverse_fft(uncompressedLeftChunk.magnitudes, phases: uncompressedLeftChunk.phases)
            var inverseRightChunk: [Float] = inverse_fft(uncompressedRightChunk.magnitudes, phases: uncompressedRightChunk.phases)
            
            inverseLeftChunk = mul(inverseLeftChunk, y: window)
            inverseRightChunk = mul(inverseRightChunk, y: window)
            
            var newLeftChunk: [Float]
            var newRightChunk: [Float]
            
            if prevLeftHalfChunk == nil || prevRightHalfChunk == nil {
                newLeftChunk = Array(inverseLeftChunk[0 ..< Int(self.chunkSize / 2)])
                newRightChunk = Array(inverseRightChunk[0 ..< Int(self.chunkSize / 2)])
            }
            else {
                newLeftChunk = add(Array(inverseLeftChunk[0 ..< Int(self.chunkSize / 2)]), y: prevLeftHalfChunk!)
                newRightChunk = add(Array(inverseRightChunk[0 ..< Int(self.chunkSize / 2)]), y: prevRightHalfChunk!)
            }
            
            self.replaceHalfChunk(chunkNumber: UInt(i), newChunkLeft: newLeftChunk, newChunkRight: newRightChunk)
            
            prevLeftHalfChunk = Array(inverseLeftChunk[Int(self.chunkSize / 2) ..< Int(self.chunkSize)])
            prevRightHalfChunk = Array(inverseRightChunk[Int(self.chunkSize / 2) ..< Int(self.chunkSize)])
            
            print("Chunk \(i) replaced succefully")
        }
        
    }
    
    func borders(_ index: Int) -> Bool {
        return (UInt(index) < (self.chunkSize * 1 / 32)) || (UInt(index) > (self.chunkSize * 31 / 32))
    }
    
    
    func compressChunk(_ magnitudes: [Float], phases: [Float]) -> Data {
        var totalArray = magnitudes
        totalArray.append(contentsOf: phases)
        var totalData = Data(bytes: &totalArray, count: totalArray.count * MemoryLayout<Float>.size)
        
        let sourceBuffer = (totalData as NSData).bytes.bindMemory(to: UInt8.self, capacity: totalData.count)
        let sourceBufferSize = totalData.count
        
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: sourceBufferSize)
        let destinationBufferSize = sourceBufferSize
        
        let status = compression_encode_buffer(destinationBuffer, destinationBufferSize, sourceBuffer, sourceBufferSize, nil, COMPRESSION_LZMA)
        return Data(bytesNoCopy: UnsafeMutablePointer<UInt8>(destinationBuffer), count: status, deallocator: .free)
    }
    
    func uncompressChunk(_ audioData: Data) -> (magnitudes: [Float], phases: [Float]) {
        
        let sourceBuffer = (audioData as NSData).bytes.bindMemory(to: UInt8.self, capacity: audioData.count)
        let sourceBufferSize = audioData.count
        
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(self.chunkSize) * 2 * MemoryLayout<Float>.size)
        let destinationBufferSize = Int(self.chunkSize) * 2 * MemoryLayout<Float>.size
        
        let status = compression_decode_buffer(destinationBuffer, destinationBufferSize, sourceBuffer, sourceBufferSize, nil, COMPRESSION_LZMA)
        let completedData =  Data(bytesNoCopy: UnsafeMutablePointer<UInt8>(destinationBuffer), count: status, deallocator: .free) as NSData
        
        var totalArray = [Float](repeating: 0.0, count: Int(completedData.length / MemoryLayout<Float>.size))
        
        completedData.getBytes(&totalArray, range: NSMakeRange(0, completedData.length))
        
        let amplitudeArray = totalArray.enumerated().filter({(index, value) in index < totalArray.count / 2}).map({(index, value) in return Float(value)})
        let phaseArray = totalArray.enumerated().filter({(index, value) in index >= totalArray.count / 2}).map({(index, value) in return Float(value)})
        return (amplitudeArray, phaseArray)
    }
    
    //до 4000 Гц => до 1/4 части спектра
    
}

