//
//  LoginResponse.swift
//  SRNetworkLayer
//
//  Created by Siamak Rostami on 7/4/24.
//

import Foundation

// MARK: - UserResponseModel

struct UserResponseModel: Codable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }

    var accessToken, refreshToken: String?
    var user: UserModel?
}

// MARK: - UserModel

struct UserModel: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case avatar
        case name
        case gender
        case dateOfBirth = "date_of_birth"
    }

    var avatar, dateOfBirth, email, gender: String?
    var id: Int?
    var name: String?
}
