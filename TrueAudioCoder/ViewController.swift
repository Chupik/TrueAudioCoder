//
//  ViewController.swift
//  TrueAudioCoder
//
//  Created by Alexander on 06.11.16.
//  Copyright © 2016 Alexander Kochupalov. All rights reserved.
//

import Cocoa
import AVFoundation
import Charts

class ViewController: NSViewController {
    
    var player: AVAudioPlayer?
    var audioFile: WavFile?
    //@IBOutlet var barChartView: BarChartView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func openButtonPushed(_ sender: Any?) {
        let openDialog = NSOpenPanel()
        openDialog.allowsMultipleSelection = false
        openDialog.canChooseDirectories = false
        openDialog.allowedFileTypes = ["WAV", "wav"]
        
        openDialog.begin(completionHandler: { (res: Int) in
            if openDialog.urls.first != nil {
                self.audioFile = WavFile(fileUrl: openDialog.urls.first!)
            }
        })
    }
    
    @IBAction func compressButtonPushed(_ sender: Any?) {
        if self.audioFile != nil {
            let saveDialog = NSSavePanel()
            saveDialog.allowedFileTypes = ["CCF"]
            
            saveDialog.begin(completionHandler: { (res: Int) in
                if saveDialog.url != nil {
                    let compressedData = self.audioFile?.compressFile()
                    try! compressedData?.write(to: saveDialog.url!)
                }
            })
        }
    }
    
    @IBAction func openCompressedButtonPushed(_ sender: Any?) {
        let openDialog = NSOpenPanel()
        openDialog.allowsMultipleSelection = false
        openDialog.canChooseDirectories = false
        openDialog.allowedFileTypes = ["CCF"]
        
        openDialog.begin(completionHandler: { (res: Int) in
            if openDialog.urls.first != nil {
                let compressedData = try! Data(contentsOf: openDialog.urls.first!)
                self.audioFile = WavFile(compressedData: compressedData)
            }
        })
    }
    
    @IBAction func playButtonPushed(_ sender: Any?) {
        player = try! AVAudioPlayer(data: self.audioFile?.fullTrack as! Data)
        
        DispatchQueue.main.async {
            self.player!.prepareToPlay()
            
            
            self.player!.play()
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

