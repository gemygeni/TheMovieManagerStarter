//
//  TMDBClient.swift
//  TheMovieManager
// Ahmed Gamal's Version
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
        case logout
        case getFavrites
        case search (String)
        case markWatchlist
        case posterImageURL(String)
        
        
        
        
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                
            case .getRequestToken : return Endpoints.base +
                Endpoints.TokenRequest + Endpoints.apiKeyParam
                
                
            case .login : return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
                
            case .createSessionID  : return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
                
            case .webAuth : return "https://www.themoviedb.org/authenticate/" + Auth.requestToken + "?redirect_to=themoviemanager:authenticate"
              
                
            case .logout : return Endpoints.base + "/authentication/session" + Endpoints.apiKeyParam
                
            case .getFavrites : return Endpoints.base + "/account/\(Auth.accountId)/favorite/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
               
            case .search(let query):
                return Endpoints.base + "/search/movie" + Endpoints.apiKeyParam + "&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))"
                
            case .markWatchlist:
            return Endpoints.base + "/account/\(Auth.accountId)/watchlist" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                
            case .posterImageURL(let posterPath) : return
                "https://image.tmdb.org/t/p/w500/" + posterPath
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    class func  taskForGETRequest <ResponseType : Decodable> (url : URL , responseType : ResponseType.Type, completion : @escaping ( ResponseType? , Error?) -> Void){
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
               guard let data = data else{
                
                DispatchQueue.main.async {
                completion(nil, error)
                }
                   return}
               
               let decoder = JSONDecoder()
               
               do{
                let  responseObject = try decoder.decode(ResponseType.self, from: data)
                   
                   DispatchQueue.main.async {
                   completion(responseObject, nil)
                }
               }
               catch {
                   DispatchQueue.main.async {
                   completion(nil, error)
                }
               }
           }
           task.resume()
    }
    
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.getWatchlist.url, responseType: MovieResults.self) { (response, error) in
            if let response = response {
                completion(response.results , nil)
            }
            else{
                completion([] , error)
            }
        }
       
    }
    
    class func getfavorites (completion :@escaping ([Movie], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getFavrites.url, responseType: MovieResults.self) { (response, error) in
            if let response = response {
                          completion(response.results , nil)
                      }
                      else{
                          completion([] , error)
                      }
        }
    }

    
    class func getRequestToken(completion : @escaping (Bool , Error?) -> Void){
        
        taskForGETRequest(url: Endpoints.getRequestToken.url, responseType: RequestTokenResponse.self) { (response, error) in
            if let response = response{
                Auth.requestToken  = response.request_token
                completion(true, nil)
            }
            else{
             completion(false , error)
            }
        }
    }
    
    class func search(query: String , completion : @escaping ([Movie] , Error?) -> Void){
        taskForGETRequest(url: Endpoints.search(query).url, responseType: MovieResults.self) { (response, error) in
            if let response = response{
                completion(response.results, nil)
            }
            else{
                completion([], error)
            }
        }
    }
        
    class func taskForPOSTRequest<RequestType : Encodable , ResponseType : Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void){
        
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let body = body
    request.httpBody = try! JSONEncoder().encode(body)
    
    let task = URLSession.shared.dataTask(with: request) { (data, responseType, error) in
        guard let data = data else{
             DispatchQueue.main.async {
            completion( nil, error)
            }
            return
        }
        
        let decoder = JSONDecoder()
        do {
            let responseToken = try decoder.decode(ResponseType.self, from: data)
            DispatchQueue.main.async {
          completion(responseToken , nil)
            }
        }
        catch{
            completion(nil , error)
        }
                }
    
    task.resume()
        }
    
    class func login (username : String, password : String , completion : @escaping (Bool , Error?) -> Void){
         let body = LoginRequest(username: username, password: password, request_token: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.login.url, responseType: RequestTokenResponse.self, body: body) { (response, error) in
            if let response = response {
                Auth.requestToken = response.request_token
                completion(true, nil)
            }
            else {
                completion(false, nil)
            }
        }
        
            }
    
    class func getSessionID(completion : @escaping (Bool , Error?) -> Void){
          let body = PostSession(request_token: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.createSessionID.url, responseType: sessionResponse.self, body: body) { (response, error) in
            if let response = response{
                Auth.sessionId = response.session_id
                              completion(true , nil)
            }
            else{
               completion(false , error)
            }
        }
              }
    
    class func markWatchlist(movieId: Int, watchlist: Bool, completion: @escaping (Bool, Error?) -> Void) {
           let body = MarkWatchlist(mediaType: "movie", mediaId: movieId, watchlist: watchlist)
           taskForPOSTRequest(url: Endpoints.markWatchlist.url, responseType: TMDBResponse.self, body: body) { response, error in
               if let response = response {
                   // separate codes are used for posting, deleting, and updating a response
                   // all are considered "successful"
                   completion(response.statusCode == 1 || response.statusCode == 12 || response.statusCode == 13, nil)
               } else {
                   completion(false, nil)
               }
           }
       }
    class func logout(completion : @escaping () -> Void){
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = LogoutRequest(session_id: Auth.sessionId)
        request.httpBody = try! JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            Auth.requestToken = ""
             Auth.sessionId = ""
                   completion ()
        }
        task.resume()
           }
    
    class func downloadPosterImage(posterPath : String, completion: @escaping (Data?, Error?) -> Void ){
        let task = URLSession.shared.dataTask(with: Endpoints.posterImageURL(posterPath).url) { (data, response, error) in
            guard let data = data else{
                completion(nil, error)
                return
            }
            completion(data, nil)
                    }
        task.resume()
    }
    
    
    
    }
