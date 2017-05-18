//
//  ViewController.swift
//  Speedr
//
//  Created by Andrew Odintsov on 17/05/2017.
//  Copyright © 2017 Andrew Odintsov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate {
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    var startTime: TimeInterval! = 0
    var speedEntries = [Double]()
    
    @IBOutlet weak var downSpeedLabel: UILabel!
    @IBOutlet weak var beginBtn: UIButton!
    @IBOutlet weak var progressDownloadIndicator: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
       
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = URLSession (configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        progressDownloadIndicator.setProgress(0.0, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func beginPressed(_ sender: Any) {
        downloadTestFile();
        startTime = Date.timeIntervalSinceReferenceDate
        
        
        
    }
    
    func downloadTestFile() {
        
        
        let url = URL(string: "http://ipv4.download.thinkbroadband.com/50MB.zip")!
        downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    
   
    // 1
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        
        downSpeedLabel.text = "\(String(format: "%.2f", calculateSpeed()))"+" Mb/s"
        
        
    }
    // 2
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        progressDownloadIndicator.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
    let currentTime = Date.timeIntervalSinceReferenceDate
    let downloadSpeed = (((Double(totalBytesWritten) / (currentTime - startTime)))/(1024*1024)*8);
        let text = String(format: "%.2f", downloadSpeed)
        downSpeedLabel.text = "\(text)"+" Mb/s"
        speedEntries.append(downloadSpeed)
        
    }
    
    func calculateSpeed() -> Double {
        var acc = 0.0
        for entry in speedEntries {
            acc+=entry
        }
        acc = acc/Double(speedEntries.count)
        return acc;
    }
    

}

