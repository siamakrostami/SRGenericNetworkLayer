//
//  DownloadManagerConfig.swift
//  SRNetworkManager
//
//  Created by Siamak Rostami on 12/20/24.
//


import Foundation

/// Configuration options for the download manager.
///
/// This structure provides all the configurable parameters that control
/// the behavior of the download manager, including resource limits,
/// network settings, and storage locations.
public struct DownloadManagerConfig: Sendable {
    /// Maximum number of concurrent downloads allowed
    let maxConcurrentDownloads: Int
    
    /// Maximum number of downloads that can be queued
    let maxQueueSize: Int
    
    /// Number of times to retry failed downloads
    let maxRetryAttempts: Int
    
    /// Whether downloads can use cellular data
    let allowsCellularAccess: Bool
    
    /// Directory where completed downloads are stored
    let downloadDirectory: URL
    
    /// Directory for temporary download files
    let temporaryDirectory: URL
    
    /// Minimum required free disk space in bytes
    let minFreeDiskSpace: Int64
    
    /// Timeout interval for download requests
    let timeoutInterval: TimeInterval
    
    /// Default configuration with reasonable values
    public static var `default`: DownloadManagerConfig {
        DownloadManagerConfig(
            maxConcurrentDownloads: 3,
            maxQueueSize: 100,
            maxRetryAttempts: 3,
            allowsCellularAccess: true,
            downloadDirectory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0],
            temporaryDirectory: FileManager.default.temporaryDirectory,
            minFreeDiskSpace: 1024 * 1024 * 1024, // 1GB
            timeoutInterval: 60
        )
    }
    
    /// Creates a new configuration with custom values.
    /// - Parameters:
    ///   - maxConcurrentDownloads: Maximum parallel downloads (default: 3)
    ///   - maxQueueSize: Maximum queue size (default: 100)
    ///   - maxRetryAttempts: Maximum retry attempts (default: 3)
    ///   - allowsCellularAccess: Allow cellular data usage (default: true)
    ///   - downloadDirectory: Custom download directory (optional)
    ///   - temporaryDirectory: Custom temporary directory (optional)
    ///   - minFreeDiskSpace: Minimum required free space (default: 1GB)
    ///   - timeoutInterval: Request timeout in seconds (default: 60)
    public init(
        maxConcurrentDownloads: Int = 3,
        maxQueueSize: Int = 100,
        maxRetryAttempts: Int = 3,
        allowsCellularAccess: Bool = true,
        downloadDirectory: URL? = nil,
        temporaryDirectory: URL? = nil,
        minFreeDiskSpace: Int64 = 1024 * 1024 * 1024,
        timeoutInterval: TimeInterval = 60
    ) {
        self.maxConcurrentDownloads = maxConcurrentDownloads
        self.maxQueueSize = maxQueueSize
        self.maxRetryAttempts = maxRetryAttempts
        self.allowsCellularAccess = allowsCellularAccess
        self.downloadDirectory = downloadDirectory ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.temporaryDirectory = temporaryDirectory ?? FileManager.default.temporaryDirectory
        self.minFreeDiskSpace = minFreeDiskSpace
        self.timeoutInterval = timeoutInterval
    }
}
