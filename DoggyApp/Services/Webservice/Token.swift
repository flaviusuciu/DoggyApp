//
//  Token.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 30.10.2022.
//

struct decodedToken: Codable {
    let token : token
    var isExpired: Bool
}

struct token: Codable {
    let token_type: String
    let expires_in: Int
    let access_token: String
}
