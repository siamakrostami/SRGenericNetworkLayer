//
//  UploadProgressDelegate.swift
//  SRNetworkLayer
//
//  Created by Siamak Rostami on 7/19/24.
//

import Foundation

class UploadProgressDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    var progressHandler: ((Double) -> Void)?

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        progressHandler?(progress)
    }
}
