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
    var uploadTask: URLSessionTask!
    var backgroundSession: URLSession!
    var startTime: TimeInterval! = 0
    var speedEntries = [Double]()
    var fileLocation: URL!
    var finishedTransfers: Int! = 0
    

    @IBOutlet weak var downSpeedLabel: UILabel!
    @IBOutlet weak var beginBtn: UIButton!
    @IBOutlet weak var progressDownloadIndicator: UIProgressView!
    @IBOutlet weak var progressUploadIndicator: UIProgressView!
    @IBOutlet weak var upSpeedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        upSpeedLabel.text = ""
        downSpeedLabel.text = ""
        downloadTask = nil
        uploadTask = nil
        
       
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = URLSession (configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        progressDownloadIndicator.setProgress(0.0, animated: false)
        progressUploadIndicator.setProgress(0.0, animated: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func beginPressed(_ sender: Any) {
        progressDownloadIndicator.setProgress(0.0, animated: false)
        progressUploadIndicator.setProgress(0.0, animated: false)
        upSpeedLabel.text = ""
        downSpeedLabel.text = ""
        speedEntries.removeAll();
        downloadTestFile();
        startTime = Date.timeIntervalSinceReferenceDate
        
        
        
    }
    
    func downloadTestFile() {
        
        
        let url = URL(string: "http://162.208.10.89:3000/down")!
        downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    
   
    // 1
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        
        downSpeedLabel.text = "\(String(format: "%.2f", calculateSpeed()))"+" Mb/s"
        fileLocation = location
        print(fileLocation)
        
        uploadTestFile();
        
        
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
    
    
    func uploadTestFile() {
        speedEntries.removeAll();
        var r  = URLRequest(url: URL(string: "http://162.208.10.89:3000/up")!)
        r.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        r.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let zipData = try! Data(contentsOf: fileLocation)
        
        r.httpBody = createBody(parameters: ["Test" : "File"],
                                boundary: boundary,
                                data: zipData,
                                mimeType: "application/zip",
                                filename: "test.zip")
        
        
        //uploadTask = URLSession.shared.dataTask(with: r)
        uploadTask = backgroundSession.uploadTask(withStreamedRequest: r)
        /*
        uploadTask = URLSession.shared.dataTask(with: r) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
 */
        uploadTask.resume()
    }
    
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        finishedTransfers=finishedTransfers+1
        if (finishedTransfers>1) {
            upSpeedLabel.text = "\(String(format: "%.2f", calculateSpeed()))"+" Mb/s"
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        progressUploadIndicator.setProgress(Float(totalBytesSent)/Float(totalBytesExpectedToSend), animated: true)
        let currentTime = Date.timeIntervalSinceReferenceDate
        let upSpeed = (((Double(totalBytesSent) / (currentTime - startTime)))/(1024*1024)*8);
        let text = String(format: "%.2f", upSpeed)
        upSpeedLabel.text = "\(text)"+" Mb/s"
        speedEntries.append(upSpeed)

        
    }
    }
    
    
    
    
    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        
        let body = NSMutableData()
        
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
        
        
    }
    

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

