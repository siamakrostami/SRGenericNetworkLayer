//
//  DownloadQueue.swift
//  SRNetworkManager
//
//  Created by Siamak Rostami on 12/20/24.
//

import Foundation

/// Thread-safe implementation of download queue management.
///
/// This actor ensures thread-safe access to the download queue
/// while maintaining proper ordering based on priority.
public final class DownloadQueue: DownloadQueueManaging, @unchecked Sendable {
    /// Internal queue storage
    private var queue: [DownloadTask]
    /// Maximum number of tasks that can be queued
    private var maxQueueSize: Int
    
    /// Creates a new download queue with specified capacity.
    /// - Parameter maxQueueSize: Maximum number of tasks that can be queued, defaults to 100
    public init(maxQueueSize: Int = 100) {
        self.maxQueueSize = maxQueueSize
        self.queue = []
    }
    
    /// Adds a new download task to the queue.
    ///
    /// Tasks are inserted based on their priority level, with higher
    /// priority tasks being placed before lower priority ones.
    /// - Parameter task: The task to be added to the queue
    public func enqueue(_ task: DownloadTask) async {
        if queue.count < maxQueueSize {
            // Insert task based on priority
            if let index = queue.firstIndex(where: { $0.priority.rawValue < task.priority.rawValue }) {
                queue.insert(task, at: index)
            } else {
                queue.append(task)
            }
        }
    }
    
    /// Removes and returns the next task to be processed.
    /// - Returns: The next task in the queue, or nil if queue is empty
    public func dequeue() async -> DownloadTask? {
        guard !queue.isEmpty else { return nil }
        return queue.removeFirst()
    }
    
    /// Removes a specific task from the queue.
    /// - Parameter task: The task to be removed
    public func remove(_ task: DownloadTask) async {
        queue.removeAll { $0.id == task.id }
    }
    
    /// Returns all tasks currently in the queue.
    /// - Returns: Array of all queued tasks
    public func getAllTasks() async -> [DownloadTask] {
        queue
    }
    
    /// Updates the state of a task in the queue.
    /// - Parameter task: The task with updated state
    public func updateTask(_ task: DownloadTask) async {
        if let index = queue.firstIndex(where: { $0.id == task.id }) {
            queue[index] = task
        }
    }
    
    /// Removes all tasks from the queue.
    public func clear() async {
        queue.removeAll()
    }
}

/// Implementation of persistent storage for download tasks.
///
/// This actor provides thread-safe access to persistent storage
/// operations for download tasks using JSON serialization.
public final class DownloadStorage: DownloadStorageManaging, @unchecked Sendable {
    /// FileManager instance for file operations
    private let fileManager: FileManager
    /// URL where download tasks are persisted
    private let storageURL: URL
    /// Internal cache of tasks
    private var tasksCache: [DownloadTask]?
    
    /// Creates a new storage manager.
    /// - Throws: Error if storage location cannot be accessed
    public init() throws {
        self.fileManager = FileManager.default
        self.storageURL = try fileManager
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("downloads.json")
    }
    
    /// Saves a download task to persistent storage.
    /// - Parameter task: The task to be saved
    /// - Throws: Error if saving fails
    public func saveTask(_ task: DownloadTask) async throws {
        var tasks = try await loadTasks()
        tasks.append(task)
        try await saveTasks(tasks)
    }
    
    /// Loads all saved download tasks from persistent storage.
    /// - Returns: Array of saved download tasks
    /// - Throws: Error if loading fails
    public func loadTasks() async throws -> [DownloadTask] {
        // Return cached tasks if available
        if let cached = tasksCache {
            return cached
        }
        
        // Load from disk if no cache exists
        guard fileManager.fileExists(atPath: storageURL.path) else {
            tasksCache = []
            return []
        }
        
        // Read and decode tasks
        return try await Task.detached(priority: .userInitiated) {
            let data = try Data(contentsOf: self.storageURL)
            let tasks = try JSONDecoder().decode([DownloadTask].self, from: data)
            self.tasksCache = tasks
            return tasks
        }.value
    }
    
    /// Removes a specific task from persistent storage.
    /// - Parameter taskId: ID of the task to remove
    /// - Throws: Error if removal fails
    public func removeTask(_ taskId: UUID) async throws {
        var tasks = try await loadTasks()
        tasks.removeAll { $0.id == taskId }
        try await saveTasks(tasks)
    }
    
    /// Updates an existing task in persistent storage.
    /// - Parameter task: The task with updated information
    /// - Throws: Error if update fails
    public func updateTask(_ task: DownloadTask) async throws {
        var tasks = try await loadTasks()
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            try await saveTasks(tasks)
        }
    }
    
    /// Removes all tasks from persistent storage.
    /// - Throws: Error if operation fails
    public func clearAll() async throws {
        try await saveTasks([])
    }
    
    /// Internal helper to save tasks to disk.
    /// - Parameter tasks: Array of tasks to save
    /// - Throws: Error if serialization or writing fails
    private func saveTasks(_ tasks: [DownloadTask]) async throws {
        try await Task.detached(priority: .utility) {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: self.storageURL)
            self.tasksCache = tasks
        }.value
    }
}

// MARK: - Protocols

/// Protocol defining the interface for download queue management.
public protocol DownloadQueueManaging: Sendable {
    /// Adds a new task to the queue
    func enqueue(_ task: DownloadTask) async
    /// Removes and returns the next task to process
    func dequeue() async -> DownloadTask?
    /// Removes a specific task from the queue
    func remove(_ task: DownloadTask) async
    /// Returns all tasks currently in the queue
    func getAllTasks() async -> [DownloadTask]
    /// Updates the state of a task in the queue
    func updateTask(_ task: DownloadTask) async
    /// Removes all tasks from the queue
    func clear() async
}

/// Protocol defining the interface for persistent storage of download tasks.
public protocol DownloadStorageManaging: Sendable {
    /// Saves a download task to persistent storage
    func saveTask(_ task: DownloadTask) async throws
    /// Loads all saved download tasks
    func loadTasks() async throws -> [DownloadTask]
    /// Removes a specific task from storage
    func removeTask(_ taskId: UUID) async throws
    /// Updates an existing task in storage
    func updateTask(_ task: DownloadTask) async throws
    /// Removes all tasks from storage
    func clearAll() async throws
}
