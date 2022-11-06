//
//  PetsViewModel.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 03.11.2022.
//

struct PetsViewModel {
    
    let animal: animal
    
    var displayText: String {
        return "\(animal.name ?? "Unknown") - \(animal.species ?? "animal") "
    }
    
    init(pet: animal) {
        self.animal = pet
    }
}
