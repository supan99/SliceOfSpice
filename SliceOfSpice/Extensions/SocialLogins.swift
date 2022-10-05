//
//  SocialLogins.swift
//  BookKart
//
//  Created by 2022M3 on 08/05/22.
//

import Foundation
//import FBSDKCoreKit
//import FBSDKLoginKit
import AuthenticationServices
import GoogleSignIn

struct SocialLoginDataModel {
    
    init() {
        
    }
    
    var socialId: String!
    var loginType: String!
    var firstName: String!
    var lastName: String!
    var email: String!
    var profileImage: String?
}

protocol SocialLoginDelegate: AnyObject {
    func socialLoginData(data: SocialLoginDataModel)
}

class SocialLoginManager: NSObject, GIDSignInDelegate, ASAuthorizationControllerDelegate {
    
    //MARK: Class Variable
//    static let shaared: SocialLoginManager = SocialLoginManager()
    weak var delegate: SocialLoginDelegate? = nil
    
    //init
    override init() {
        
    }
}

//MARK: Google Login
extension SocialLoginManager {
    //MARK: Google login methods
    /// Open google login view
    func performGoogleLogin(vc: UIViewController) {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = vc
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance()?.signIn()
    }
}

//MARK: Google login delegate
extension SocialLoginManager {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            
        } else {
            //Call delegate
            if let delegate = self.delegate {
                
                var dataObj: SocialLoginDataModel = SocialLoginDataModel()
                dataObj.socialId = user.userID
                dataObj.loginType = "G"
                dataObj.firstName = user.profile?.givenName
                dataObj.lastName = user.profile?.familyName
                dataObj.email = user.profile?.email
                //GFunction.shared.firebaseRegister(data: dataObj.email)
                if user.profile!.hasImage {
                    dataObj.profileImage = user.profile?.imageURL(withDimension: 100)?.description
                }
                delegate.socialLoginData(data: dataObj)
            }
        }
    }
}

//MARK : Apple Login
extension SocialLoginManager {
    
    //MARK: Apple Login Methods
    /// Open apple login view
    @available(iOS 13.0, *)
    func performAppleLogin() {
        
        //request
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let authoriztionRequest = appleIdProvider.createRequest()
        authoriztionRequest.requestedScopes = [.fullName, .email]
        
        //Apple’s Keychain sign in // give the resukt of save id - password for this app
        let passwordProvider = ASAuthorizationPasswordProvider()
        let passwordRequest = passwordProvider.createRequest()

        //create authorization controller
        let authorizationController = ASAuthorizationController(authorizationRequests: [authoriztionRequest]) //[authoriztionRequest, passwordRequest]
        authorizationController.presentationContextProvider = self
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}

//MARK : Apple Login Delegate
@available(iOS 13.0, *)
extension SocialLoginManager: ASAuthorizationControllerPresentationContextProviding {
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return UIApplication.topViewController()!.view.window!
        return UIApplication.topViewController()!.view.window!
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        print(appleIDCredential.user, appleIDCredential.fullName as Any, appleIDCredential.email as Any)
        //self.isSocialLogin = true
        
        var dataObj: SocialLoginDataModel = SocialLoginDataModel()
        dataObj.socialId = appleIDCredential.user
        dataObj.loginType = "A"
        dataObj.firstName =  appleIDCredential.fullName?.givenName ?? ""//myUserDefault.string(forKey: kFirstName) ?? ""
        dataObj.lastName = appleIDCredential.fullName?.familyName ?? ""//myUserDefault.string(forKey: kLastName) ?? ""
        dataObj.email = appleIDCredential.email ?? ""//myUserDefault.string(forKey: kEmail) ?? ""
//        GFunction.shared.firebaseRegister(data: dataObj.email)
        delegate?.socialLoginData(data: dataObj)
        
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        Alert.shared.showAlert(message: "Something went wrong", completion: nil)
    }
}
