//
//  PetService.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 30.10.2022.
//

import Foundation
import RxSwift
import UIKit

class PetService {
    
    func fetchToken() -> Observable<token> {
        return Observable.create { observer -> Disposable in
            guard let url =  URL(string:"https://api.petfinder.com/v2/oauth2/token")
                    else {
                        return
                    }
            let username = "8FvB92COL3loJkRHBozGPLOVKZTG4CgXal6Dou6EjsH5lj2SXB"
            let password = "zcYSA3CrhG6yW1dc539o8rAVgj7ecwLUaYHTSe3s"
            let body = "grant_type=client_credentials&client_id={\(username)}&client_secret={\(password)}"
            let finalBody = body.data(using: .utf8)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalBody
            
            URLSession.shared.dataTask(with: request){
                (data, response, error) in
                print(response as Any)
                if let error = error {
                    print(error)
                    return
                }
                guard let data = data else{
                    return
                }
                print(data, String(data: data, encoding: .utf8) ?? "*unknown encoding*")
                
            }.resume()
        }
    }
    
    func fetchPets() -> Observable<[pet]> {
        return Observable.create { observer -> Disposable in
            let task = URLSession.shared.dataTask(with: URL(string: "")!) { data, _, error in
                
                guard let data = data else {
                    observer.onError(NSError(domain: "", code: -1, userInfo: nil))
                    return
                }
                
                do {
                    let pets = try JSONDecoder.decode([pet].self, from: data)
                    observer.onNext(pets)
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
