//
//  SceneDelegate.swift
//  MibandDataCollector
//
//  Created by Lehel Dénes-Fazakas on 2021. 12. 06..
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        print("szia")
        print(window)
        (UIApplication.shared.delegate as? AppDelegate)?.window = window
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        if Auth.auth().currentUser?.uid != nil{
            let vc = window?.rootViewController as? ViewController
        
            
            vc?.statuslabel.text = "Az alkalmazás rendeltetésszerűen működik"
            vc?.statuslabel.textColor = .black
            vc?.statuslabel.backgroundColor = .green
        }
        else{
        let vc = window?.rootViewController as? ViewController
        vc?.statuslabel.text = "Az alkalmazás nem működik: kérjük regisztráljon be, vagy jelentkezzen be"
        vc?.statuslabel.textColor = .white
        vc?.statuslabel.backgroundColor = .red
        }
        if !UIApplication.shared.connectedScenes.contains(where: { $0.activationState == .foregroundActive && $0 != scene }) {
                    UIApplication.shared.delegate?.applicationDidBecomeActive?(.shared)
                }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        if Auth.auth().currentUser?.uid != nil{
            let vc = window?.rootViewController as? ViewController
          
            
            vc?.statuslabel.text = "Az alkalmazás rendeltetésszerűen működik"
            vc?.statuslabel.textColor = .black
            vc?.statuslabel.backgroundColor = .green
            
        }
        else{
        let vc = window?.rootViewController as? ViewController
        vc?.statuslabel.text = "Az alkalmazás nem működik: kérjük regisztráljon be, vagy jelentkezzen be"
        vc?.statuslabel.textColor = .white
        vc?.statuslabel.backgroundColor = .red
        }
        if !UIApplication.shared.connectedScenes.contains(where: { $0.activationState == .foregroundActive && $0 != scene }) {
                    UIApplication.shared.delegate?.applicationWillResignActive?(.shared)
                }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        if Auth.auth().currentUser?.uid != nil{
            let vc = window?.rootViewController as? ViewController
         
            
            vc?.statuslabel.text = "Az alkalmazás rendeltetésszerűen működik"
            vc?.statuslabel.textColor = .black
            vc?.statuslabel.backgroundColor = .green
        }
        else{
        let vc = window?.rootViewController as? ViewController
        vc?.statuslabel.text = "Az alkalmazás nem működik: kérjük regisztráljon be, vagy jelentkezzen be"
        vc?.statuslabel.textColor = .white
        vc?.statuslabel.backgroundColor = .red
        }
        if !UIApplication.shared.connectedScenes.contains(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) {
                    UIApplication.shared.delegate?.applicationWillEnterForeground?(.shared)
                }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        if !UIApplication.shared.connectedScenes.contains(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) {
                    UIApplication.shared.delegate?.applicationDidEnterBackground?(.shared)
                }
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

