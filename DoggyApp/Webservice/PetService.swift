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

class PetService {
    
    private lazy var dateFormatter = DateFormatter()
    
    func fetchToken() -> Observable<token> {
        return Observable.create { observer -> Disposable in
            let url =  URL(string:"https://api.petfinder.com/v2/oauth2/token")
            let username = "8FvB92COL3loJkRHBozGPLOVKZTG4CgXal6Dou6EjsH5lj2SXB"
            let password = "zcYSA3CrhG6yW1dc539o8rAVgj7ecwLUaYHTSe3s"
            let body = "grant_type=client_credentials&client_id=\(username)&client_secret=\(password)"
            let finalBody = body.data(using: String.Encoding.utf8)
            
            var request = URLRequest(url: url!)
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
                    var token = try JSONDecoder().decode(token.self, from: data)
                    token.isExpired = false
                    self.persistTokenAndExpiration(token: token)
                } catch {
                    
                }
                print(data, String(data: data, encoding: .utf8) ?? "*unknown encoding*")
                
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
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
                    let pets = try JSONDecoder().decode([pet].self, from: data)
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
    
    private func persistTokenAndExpiration(token: token){
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrCreationDate as String: self.dateFormatter.string(from: Date().addingTimeInterval(Double(token.expires_in))), //Will be used as expiration date instead
            kSecValueData as String: token.access_token
        ]
        if SecItemAdd(attributes as CFDictionary, nil) == noErr {
            print("User saved successfully in the keychain")
        } else {
            print("Something went wrong trying to save the user in the keychain")
        }
    }
    
    private func fetchAPITokenAndExpiration() -> token? {
        
        // Set query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: kSecMatchLimitOne,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]
        
        var item: CFTypeRef?

        // Check if user exists in the keychain
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            // Extract result
            if let existingItem = item as? [String: Any],
               let date = existingItem[kSecAttrCreationDate as String] as? String,
               let tokenData = existingItem[kSecValueData as String] as? Data,
               let tokenPassword = String(data: tokenData, encoding: .utf8)
            {
                print(date)
                print(tokenPassword)
                
                guard let expirationDate = self.dateFormatter.date(from: date) else {
                return token(token_type: "Bearer",
                             expires_in: 0,
                             access_token: tokenPassword,
                             isExpired: true)
                }
                if expirationDate < Date() {
                return token(token_type: "Bearer",
                              expires_in: Int(expirationDate.timeIntervalSince(Date())),
                              access_token: tokenPassword,
                              isExpired: false)
                } else {
                    return token(token_type: "Bearer",
                                  expires_in: 0,
                                  access_token: tokenPassword,
                                  isExpired: true)
                }
                
            }
        } else {
            print("Something went wrong trying to find the user in the keychain")
            return nil
        }
    
        return nil
    }
}
