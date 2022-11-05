//
//  pet.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 30.10.2022.
//

struct Result: Codable {
    var animals: [animal]
}

struct animal: Codable {
    let name: String
    let breeds: breeds
    let size: String
    let gender: String
    let status: String
    let distance: Int?
    let species: String
}

struct breeds: Codable {
    let primary: String?
    let secondary: String?
}


