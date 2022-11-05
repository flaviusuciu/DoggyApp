//
//  PetsViewModel.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 03.11.2022.
//

import Foundation

struct PetsViewModel {
    
    private let animal: animal
    
    var displayText: String {
        return "\(animal.name) - \(animal.species)"
    }
    
    init(pet: animal) {
        self.animal = pet
    }
}
