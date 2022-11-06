//
//  PetsDetailsViewController.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 05.11.2022.
//

import UIKit

class PetsDetailsViewController: UIViewController {
    
    enum knownAnimalTypes:String {
    case cat = "Cat"
    case dog = "Dog"
    }
    
    enum knownAnimalGenders:String {
    case female = "Female"
    case male = "Male"
    }
    
    var currentlySelectedAnimal: animal?
    
    @IBOutlet weak var adoptMeButton: UIButton!
    @IBOutlet weak var animalNameLabel: UILabel!
    @IBOutlet weak var animalTypeImage: UIImageView!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        navigationController?.navigationBar.tintColor = GlobalConstants.petFinderPurple
        navigationItem.title = "Pet Details"
        
    }
    
    private func configureView() {
        
        setupAdoptButton()
        
        switch currentlySelectedAnimal?.species {
        case knownAnimalTypes.cat.rawValue:
            self.animalTypeImage.image = #imageLiteral(resourceName: "CatImage")
        case knownAnimalTypes.dog.rawValue:
            self.animalTypeImage.image = #imageLiteral(resourceName: "DogImage")
        default:
            self.animalTypeImage.backgroundColor = .red
        }
        self.animalTypeImage.layer.cornerRadius = 5.0
        self.animalTypeImage.clipsToBounds = true
        
        self.tryLoadingPetFinderAnimalPhoto()
        
        self.animalNameLabel.text = currentlySelectedAnimal?.name
        
        self.breedLabel.text = "Breed: \(currentlySelectedAnimal?.breeds.primary ?? "Unknown")"
        self.sizeLabel.text = "Size: \(currentlySelectedAnimal?.size ?? "Unknown")"
        
        switch currentlySelectedAnimal?.gender {
        case knownAnimalGenders.female.rawValue:
            self.genderLabel.text = "\(knownAnimalGenders.female.rawValue) ♀"
        case knownAnimalGenders.male.rawValue:
            self.genderLabel.text = "\(knownAnimalGenders.male.rawValue) ♂"
        default:
            self.genderLabel.text = "Unknow"
        }
        
        self.statusLabel.text = "Status: \(currentlySelectedAnimal?.status ?? "Unknown")"
        self.distanceLabel.text = "Distance from you: \(currentlySelectedAnimal?.size ?? "Far")"
    }
    
    private func tryLoadingPetFinderAnimalPhoto() {
        
        guard let petPhotos = self.currentlySelectedAnimal?.photos else {
            return
        }
        if petPhotos.count > 0 {
            guard let firstPhotoString = petPhotos.first?.medium else { return }
            self.animalTypeImage.loadFrom(URLAddress: firstPhotoString)
        }
    }
    
    private func setupAdoptButton() {
        adoptMeButton.tintColor = GlobalConstants.petFinderPurple
        adoptMeButton.layer.cornerRadius = 12
        adoptMeButton.translatesAutoresizingMaskIntoConstraints = false
        
//        let constraints = [
//            adoptMeButton.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: 10),
//            adoptMeButton.centerXAnchor.constraint(equalTo:view.centerXAnchor),
//            adoptMeButton.widthAnchor.constraint (equalToConstant: 200),
//            adoptMeButton.heightAnchor.constraint (equalToConstant: 60),
//        ]
//        NSLayoutConstraint.activate(constraints)
        adoptMeButton.addTarget(self, action: #selector(self.adoptMeButtonAction(sender:)), for: .touchUpInside)
    }
    
    @objc private func adoptMeButtonAction(sender: UIButton) {
        self.animateView(sender)
    }
    
    private func animateView(_ viewToAnimate: UIView) {
        UIView.animate (withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            viewToAnimate.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { (_) in
            UIView.animate (withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.4,
                            initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                viewToAnimate.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
}

extension UIImageView {
    func loadFrom(URLAddress: String) {
        guard let url = URL(string: URLAddress) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                        self?.image = loadedImage
                }
            }
        }
    }
}
