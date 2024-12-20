import Foundation
import Combine

/// Protocol defining the interface for download event management
public protocol DownloadEventManaging: Sendable {
    var eventsPublisher: AnyPublisher<DownloadEvent, Never> { get }
    var tasksPublisher: AnyPublisher<[DownloadTask], Never> { get }
    
    func emitProgress(taskId: UUID, progress: Double, speed: Double) async
    func emitStateChange(taskId: UUID, state: DownloadState) async
    func emitError(taskId: UUID, error: String) async
    func updateTask(_ task: DownloadTask) async
    func removeTask(_ taskId: UUID) async
    func getAllTasks() async -> [DownloadTask]
}

/// Manages download-related events and state updates.
///
/// This actor provides thread-safe event emission and state tracking
/// for all download operations, supporting both individual task
/// monitoring and global event observation.
public final class DownloadEventsManager: DownloadEventManaging, @unchecked Sendable {
    // MARK: - Properties
    
    /// Subject for broadcasting download events
    private let eventSubject: PassthroughSubject<DownloadEvent, Never>
    
    /// Subject for broadcasting task state updates
    private let taskSubject: CurrentValueSubject<[DownloadTask], Never>
    
    /// Internal storage of current tasks
    private var tasks: [UUID: DownloadTask]
    
    // MARK: - Initialization
    
    public init() {
        self.eventSubject = PassthroughSubject<DownloadEvent, Never>()
        self.taskSubject = CurrentValueSubject<[DownloadTask], Never>([])
        self.tasks = [:]
    }
    
    // MARK: - Public Interface
    
    /// Publisher for all download-related events
    nonisolated public var eventsPublisher: AnyPublisher<DownloadEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    /// Publisher for task state updates
    nonisolated public var tasksPublisher: AnyPublisher<[DownloadTask], Never> {
        taskSubject.eraseToAnyPublisher()
    }
    
    /// Emits a progress update event
    /// - Parameters:
    ///   - taskId: ID of the task
    ///   - progress: Current progress (0.0 to 1.0)
    ///   - speed: Current download speed in bytes/second
    public func emitProgress(taskId: UUID, progress: Double, speed: Double) async {
        eventSubject.send(.progress(taskId, progress, speed))
    }
    
    /// Emits a state change event
    /// - Parameters:
    ///   - taskId: ID of the task
    ///   - state: New state
    public func emitStateChange(taskId: UUID, state: DownloadState) async {
        eventSubject.send(.stateChange(taskId, state))
    }
    
    /// Emits an error event
    /// - Parameters:
    ///   - taskId: ID of the task
    ///   - error: Error message
    public func emitError(taskId: UUID, error: String) async {
        eventSubject.send(.error(taskId, error))
    }
    
    /// Updates task state and broadcasts change
    /// - Parameter task: Updated task
    public func updateTask(_ task: DownloadTask) async {
        tasks[task.id] = task
        taskSubject.send(Array(tasks.values))
    }
    
    /// Removes task and broadcasts update
    /// - Parameter taskId: ID of task to remove
    public func removeTask(_ taskId: UUID) async {
        tasks.removeValue(forKey: taskId)
        taskSubject.send(Array(tasks.values))
    }
    
    /// Returns all current tasks
    /// - Returns: Array of all tasks
    public func getAllTasks() async -> [DownloadTask] {
        Array(tasks.values)
    }
    
    // MARK: - Helper Methods
    
    /// Updates multiple tasks at once
    /// - Parameter tasks: Array of tasks to update
    public func updateTasks(_ tasks: [DownloadTask]) async {
        for task in tasks {
            self.tasks[task.id] = task
        }
        taskSubject.send(Array(self.tasks.values))
    }
    
    /// Removes multiple tasks at once
    /// - Parameter taskIds: Array of task IDs to remove
    public func removeTasks(_ taskIds: [UUID]) async {
        for id in taskIds {
            tasks.removeValue(forKey: id)
        }
        taskSubject.send(Array(tasks.values))
    }
    
    /// Clears all tasks
    public func clearAllTasks() async {
        tasks.removeAll()
        taskSubject.send([])
    }
}

// MARK: - Helper Extensions

extension DownloadEventsManager {
    /// Filters tasks by state
    /// - Parameter state: The state to filter by
    /// - Returns: Array of tasks in the specified state
    public func getTasks(inState state: DownloadState) async -> [DownloadTask] {
        Array(tasks.values.filter { $0.state == state })
    }
    
    /// Gets a specific task by ID
    /// - Parameter id: The task ID to look for
    /// - Returns: The task if found, nil otherwise
    public func getTask(withId id: UUID) async -> DownloadTask? {
        tasks[id]
    }
    
    /// Checks if a task exists
    /// - Parameter id: The task ID to check
    /// - Returns: True if the task exists
    public func hasTask(withId id: UUID) async -> Bool {
        tasks[id] != nil
    }
}
