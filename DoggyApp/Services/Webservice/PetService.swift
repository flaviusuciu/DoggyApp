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
            let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI4RnZCOTJDT0wzbG9Ka1JIQm96R1BMT1ZLWlRHNENnWGFsNkRvdTZFanNINWxqMlNYQiIsImp0aSI6ImRiZjYyMzY3YTI1YjU2ZTNkM2M0NzI4YWRmZTBkNDgyZWZlMGRmNmE3NTczMzM3ZDQ4N2Y1ZGUwM2UwOGEwOGI5YTYzNzBiZDM2ODk0YjJmIiwiaWF0IjoxNjY3OTQ2MjAxLCJuYmYiOjE2Njc5NDYyMDEsImV4cCI6MTY2Nzk0OTgwMSwic3ViIjoiIiwic2NvcGVzIjpbXX0.iAs9EqeCvDyDv1YB5xJxjF4MybiQkD_oCjXy6r0cM8I6toj3bGg1cVliGfpIZciT5fyWz5U7vAqs2IT3BM7UjyNrNlolGqAuQ8QBflVTzOteSG1zPxfvswmdhzpr8nCv3DoBw6x_CIHJCzqmI8iHkDZQSShTfayXU4DrBQkJbDGJZ2O0fFULFFsFT8S4IuCbhXDOrKJSxyqdmVj7inOjr9b2UVwnAKSp9ZL0YgMgNx3Y7w5N9H6RDEsxac-yzv1XcmIy8V8A8sy2XGnvdFtC_SrwGXEtTyKUU_c5_l0eDXFv1ntOpMexDmAAneREErc-6pqSCs3w4ZkvhiWs0xVJFQ"
            let url = URL(string: "https://api.petfinder.com/v2/animals")
            let header = "Bearer \(token)"
            
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
