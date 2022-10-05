//
//  AppDelegate.swift
//  SliceOfSpice
//
//  Created by 2022M3 on 29/04/22.
//

@_exported import Firebase
@_exported import FirebaseFirestore
@_exported import Photos
@_exported import OpalImagePicker
//@_exported import FBSDKCoreKit
//@_exported import FBSDKLoginKit
@_exported import GoogleSignIn
import FirebaseCore

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var db : Firestore!
    static let shared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        return true
    }

    override init() {
        super.init()
        GIDSignIn.sharedInstance().clientID = "828643426745-b2ckrushqivp5pdi1kol35rb01tq1qsj.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
    }

    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func openLink(){
        if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }

}

extension AppDelegate: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }

        // Post notification after user successfully sign in
        NotificationCenter.default.post(name: .signInGoogleCompleted, object: nil)
    }
}


// MARK:- Notification names
extension Notification.Name {
    
    /// Notification when user successfully sign in using Google
    static var signInGoogleCompleted: Notification.Name {
        return .init(rawValue: #function)
    }
}
