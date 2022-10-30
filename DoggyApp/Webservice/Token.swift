//
//  Token.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 30.10.2022.
//

struct token: Decodable {
    let token_type: String
    let expires_in: Int
    let access_token: String
}
