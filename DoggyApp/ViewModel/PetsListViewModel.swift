//
//  PetsListViewModel.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 03.11.2022.
//

import RxSwift

final class PetsListViewModel {
    let title = GlobalConstants.localPetsTitle
    
    private let petsService: PetsServiceProtocol
    
    init(petsService: PetsServiceProtocol = PetService()) {
        self.petsService = petsService
    }
    
    func fetchPetsViewModels () -> Observable<[PetsViewModel]> {
        petsService.fetchPets().map { $0.map { PetsViewModel(pet: $0) } }
    }
}
