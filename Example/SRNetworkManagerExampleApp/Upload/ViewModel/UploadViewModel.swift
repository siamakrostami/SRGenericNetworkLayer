//
//  UploadViewModel.swift
//  SRNetworkManagerExampleApp
//
//  Created by Siamak on 12/18/24.
//

import Combine
import Foundation
import SRNetworkManager

@MainActor
final class UploadViewModel: ObservableObject, Sendable {
    @Published private(set) var uploadResponse: UploadResponse?
    @Published var showError = false
    @Published var errorMessage = ""

    private var cancellables = Set<AnyCancellable>()
    private let apiClient = APIClient(logLevel: .verbose)
}
extension UploadViewModel {
    func upload(file: Data) {
        apiClient.uploadRequest(UploadAPI(), withName: "file", data: file) {
            [weak self] totalProgress, totalBytesSent, totalBytesExpectedToSend
            in
            guard let _ = self else {return}
            debugPrint("total progress \(totalProgress)")
        }.sink { [weak self] completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self?.showError = true
                self?.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] (response: UploadResponse) in
            self?.uploadResponse = response
        }.store(in: &cancellables)

    }

    func upload(file: Data) async throws {
        Task {
            do {
                let response: UploadResponse =
                    try await apiClient.uploadRequest(
                        UploadAPI(), withName: "file", data: file
                    ) {
                        totalProgress, totalBytesSent, totalBytesExpectedToSend
                        in
                        debugPrint("total progress \(totalProgress)")
                    }
                self.uploadResponse = response
            } catch let error as NetworkError {
                self.showError = true
                self.errorMessage = error.localizedErrorDescription ?? ""
            }
        }
    }

}
