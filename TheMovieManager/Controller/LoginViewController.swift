//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        TMDBClient.getRequestToken(completion: handleRequestTokenResponse)
    }
    
    @IBAction func loginViaWebsiteTapped() {
        TMDBClient.getRequestToken { (success, error) in
            if success{
                
                    UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    func handleRequestTokenResponse(success :Bool, error : Error?) -> Void{
        if success {
            print(TMDBClient.Auth.requestToken)
                TMDBClient.login(username: self.emailTextField.text ?? "",
                                 password: self.passwordTextField.text ?? "",
                                 completion: self.handleLoginResponse(success:error:))
        }
    }
    
    
    func handleLoginResponse(success : Bool , error : Error?) -> Void{
        print(TMDBClient.Auth.requestToken)
        if success {
            TMDBClient.getSessionID(completion: handleSessinResponse(success:error:))
        }
    }
    
    func handleSessinResponse(success : Bool , error : Error?) -> Void{
        if success{
        self.performSegue(withIdentifier: "completeLogin", sender: nil)
        }
    }
}
