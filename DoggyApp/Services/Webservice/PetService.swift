//
//  PetService.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 30.10.2022.
//

import Foundation
import RxSwift
import UIKit
import Security

protocol PetsServiceProtocol {
    func fetchPets() -> Observable<[animal]>
}

class PetService: PetsServiceProtocol {
    
    private let disposeBag = DisposeBag()
    
    func fetchToken(apiKey: String, apiSecret: String) -> Observable<decodedToken> {
        return Observable.create { observer -> Disposable in
            let url =  URL(string:"https://api.petfinder.com/v2/oauth2/token")
            let username = apiKey
            let password = apiSecret
            let body = "grant_type=client_credentials&client_id=\(username)&client_secret=\(password)"
            let finalBody = body.data(using: String.Encoding.utf8)
            
            var request = URLRequest(url: url!) //TODO: fix unwrap
            request.httpMethod = "POST"
            request.httpBody = finalBody
            
            let task = URLSession.shared.dataTask(with: request){
                (data, response, error) in
                print(response as Any)
                if let error = error {
                    print(error)
                    return
                }
                guard let data = data else{
                    return
                }
                do {
                    let token = try JSONDecoder().decode(token.self, from: data)
                    observer.onNext(decodedToken(token: token, isExpired: false))
                } catch {
                    print("Uh-Oh")
                }
                print(data, String(data: data, encoding: .utf8) ?? "*unknown encoding*")
                
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func fetchPets() -> Observable<[animal]> {
        return Observable.create { observer -> Disposable in
            //TODO: check for PersistanceManager.shared.currentTokenIsActive
            let token = PersistanceManager.shared.currentToken?.token.access_token
            let url = URL(string: "https://api.petfinder.com/v2/animals")
            let header = "Bearer \(token ?? "")"
            
            var request = URLRequest(url: url!) //TODO: fix unwrap
            request.httpMethod = "GET"
            request.setValue(header, forHTTPHeaderField: "Authorization")

            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                guard let data = data else {
                    observer.onError(NSError(domain: "", code: -1, userInfo: nil))
                    return
                }
                
                do {
                    let pets = try JSONDecoder().decode(Result.self, from: data)
                    observer.onNext(pets.animals)
                } catch {
                    observer.onError(error)
                }
                
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
