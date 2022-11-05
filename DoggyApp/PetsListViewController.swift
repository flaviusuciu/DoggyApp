//
//  ViewController.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 30.10.2022.
//

import UIKit
import RxSwift
import RxCocoa

class PetsListViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    private var viewModel: PetsListViewModel! //TODO: remove unwrapping
    
    @IBOutlet weak var tableView: UITableView!
    
    static func instantiate(viewModel: PetsListViewModel) -> PetsListViewController {
        let storyboard = UIStoryboard(name:"Main", bundle: .main)
        let viewContoller = storyboard.instantiateInitialViewController() as! PetsListViewController
        viewContoller.viewModel = viewModel
        return viewContoller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: GlobalConstants.petFinderPurple]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: GlobalConstants.petFinderPurple]
        
        tableView.tableFooterView = UIView()
        navigationItem.title = viewModel.title
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.contentInsetAdjustmentBehavior = .never
        viewModel.fetchPetsViewModels().observe(on: MainScheduler.instance).bind(to:
                                                tableView.rx.items(cellIdentifier: "cell")) { index, viewModel, cell in
            cell.textLabel?.text = viewModel.displayText
            cell.textLabel?.textColor = GlobalConstants.petFinderPurple
        }.disposed(by: disposeBag)
        
        
//        let service = PetService()
//        service.fetchPets().subscribe(onNext: { pets in
//            print(pets)
//        }).disposed(by: disposeBag)
//        service.fetchToken().subscribe(onNext: { token in
//            print(token)
//        }).disposed(by: disposeBag)
    }


}

