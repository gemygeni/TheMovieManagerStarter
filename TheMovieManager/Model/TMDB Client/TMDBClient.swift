//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class TMDBClient {
    
    static let apiKey = "beaca543824e95b1fae1f904190eeabe"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        static let TokenRequest = "/authentication/token/new"
        
        case getWatchlist
        case getRequestToken
        case login
        case createSessionID
        case webAuth
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                
            case .getRequestToken : return Endpoints.base +
                Endpoints.TokenRequest + Endpoints.apiKeyParam
                
                
            case .login : return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
                
            case .createSessionID  : return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
                
            case .webAuth : return "https://www.themoviedb.org/authenticate/" + Auth.requestToken + "?redirect_to=themoviemanager:authenticate"
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getWatchlist.url) { data, response, error in
            guard let data = data else {
                completion([], error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(MovieResults.self, from: data)
                completion(responseObject.results, nil)
            } catch {
                completion([], error)
            }
        }
        task.resume()
    }
    
    
    class func getRequestToken(completion : @escaping (Bool , Error?) -> Void){
        let task = URLSession.shared.dataTask(with: Endpoints.getRequestToken.url) { (data, response, error) in
            guard let data = data else {completion(false, error)
                 print("ohhh1")
                return}
            
            let decoder = JSONDecoder()
            
            do{
              let  responsedToken = try decoder.decode(RequestTokenResponse.self, from: data)
                print(responsedToken.request_token)
                Auth.requestToken  = responsedToken.request_token
                completion(true, nil)
            }
            catch {
                 print("ohhh2")
                completion(false, nil)
            }
        }
        task.resume()
    }
    
    
    class func login (username : String, password : String , completion : @escaping (Bool , Error?) -> Void){
        var request = URLRequest(url: Endpoints.login.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = LoginRequest(username: username, password: password, request_token: Auth.requestToken)
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else{completion(false , error)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responsedToken = try decoder.decode(RequestTokenResponse.self, from: data)
               
                Auth.requestToken = responsedToken.request_token
              completion(true , nil)
            }
            catch{
                completion(false , error)
            }
                    }
        
        task.resume()
            }
    
    class func getSessionID(completion : @escaping (Bool , Error?) -> Void){
        
   var request = URLRequest(url: Endpoints.createSessionID.url)
          request.httpMethod = "POST"
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = PostSession(request_token: Auth.requestToken)
          request.httpBody = try! JSONEncoder().encode(body)
          
          let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
              guard let data = data else{completion(false , error)
                  return
              }
              
              let decoder = JSONDecoder()
              do {
                let sessionID = try decoder.decode(sessionResponse.self, from: data)
                print(sessionID.session_id)
                  Auth.sessionId = sessionID.session_id
                completion(true , nil)
              }
              catch{
                  completion(false , error)
              }
                      }
          
          task.resume()
              }
    }
