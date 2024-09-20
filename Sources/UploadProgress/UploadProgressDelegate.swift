import Foundation

/// A closure type for handling upload progress updates.
public typealias ProgressHandler = @Sendable (_ totalProgress: Double, _ totalBytesSent: Int64, _ totalBytesExpectedToSend: Int64) -> Void?

/// A class that acts as a delegate for monitoring upload progress.
public final class UploadProgressDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate, @unchecked Sendable {
    
    /// The closure to be called when progress updates occur.
    var progressHandler: ProgressHandler?

    /// URLSession delegate method for monitoring upload progress.
    /// - Parameters:
    ///   - session: The URLSession.
    ///   - task: The URLSessionTask.
    ///   - bytesSent: The number of bytes sent in the latest transmission.
    ///   - totalBytesSent: The total number of bytes sent so far.
    ///   - totalBytesExpectedToSend: The expected length of the body data.
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        
        // Safely call the progressHandler closure, passing the labeled values
        progressHandler?(progress, totalBytesSent, totalBytesExpectedToSend)
    }
}
