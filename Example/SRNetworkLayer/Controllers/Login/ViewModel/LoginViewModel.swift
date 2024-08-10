//
//  LoginViewModel.swift
//  SRNetworkLayer
//
//  Created by Siamak Rostami on 7/4/24.
//

import Combine
import Foundation
import SRGenericNetworkLayer
// MARK: - LoginViewModel

class LoginViewModel: BaseViewModel<GeneralErrorResponse> {
    @Published var userModel: UserResponseModel?
    @Published var isLoading: Bool = false
    var loginCancellableSet = Set<AnyCancellable>()
}

extension LoginViewModel {
    func login(email: String, password: String) {
        isLoading = true
        remoteRepositories.loginServices?
            .login(email: email, password: password)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    self?.isLoading = false
                    self?.error.send(failure)
                }
            }, receiveValue: { [weak self] model in
                self?.isLoading = false
                self?.userModel = model
            }).store(in: &loginCancellableSet)
    }

    @MainActor
    func asyncLogin(email: String, password: String) {
        isLoading = true
        Task {
            do {
                let response = try await remoteRepositories.loginServices?.asyncLogin(email: email, password: password)
                userModel = response
                isLoading = false
            } catch let error as NetworkError<GeneralErrorResponse> {
                isLoading = false
                self.error.send(error)
            }
        }
    }
}
