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
    private var viewModel = PetsListViewModel()
    
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
        tableView.register(PetsTableViewCell.self, forCellReuseIdentifier: "petsCell")
        viewModel.fetchPetsViewModels().observe(on: MainScheduler.instance).bind(to:
                                                                                    tableView.rx.items(cellIdentifier: "petsCell", cellType: PetsTableViewCell.self)) { index, viewModel, cell in
            cell.textLabel?.text = viewModel.displayText
            cell.textLabel?.textColor = GlobalConstants.petFinderPurple
            cell.animal = viewModel.animal
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
            let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! PetsDetailsViewController
            if let selectedCell = self.tableView.cellForRow(at: indexPath) as? PetsTableViewCell {
                detailsVC.currentlySelectedAnimal = selectedCell.animal
            }
            
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }).disposed(by: disposeBag)
        
        
//        let service = PetService()
//        service.fetchPets().subscribe(onNext: { pets in
//            print(pets)
//        }).disposed(by: disposeBag)
//        service.fetchToken(apiKey: "8FvB92COL3loJkRHBozGPLOVKZTG4CgXal6Dou6EjsH5lj2SXB", apiSecret: "zcYSA3CrhG6yW1dc539o8rAVgj7ecwLUaYHTSe3s").subscribe(onNext: { token in
//            print(token)
//        }).disposed(by: disposeBag)
    }


}

