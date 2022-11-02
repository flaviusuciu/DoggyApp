//
//  ViewController.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 30.10.2022.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    static func instantiate() -> ViewController {
        let storyboard = UIStoryboard(name:"Main", bundle: .main)
        let viewContoller = storyboard.instantiateInitialViewController() as! ViewController
        return viewContoller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let service = PetService()
//        service.fetchPets().subscribe(onNext: { pets in
//            print(pets)
//        }).disposed(by: disposeBag)
        service.fetchToken().subscribe(onNext: { token in
            print(token)
        }).disposed(by: disposeBag)
    }


}

