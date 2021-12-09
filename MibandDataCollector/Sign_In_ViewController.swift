//
//  Sign_In_ViewController.swift
//  datacollateorMibanIOS
//
//  Created by Lehel Dénes-Fazakas on 2021. 09. 29..
//

import UIKit
import Firebase


class Sign_In_ViewController: UIViewController,UITextFieldDelegate {

   
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var pass1: UITextField!
    
    @IBOutlet weak var pass2: UITextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pass1.delegate = self
        
    
            self.pass2.delegate = self
            self.email.delegate = self
      

        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case self.email:
                self.pass1.becomeFirstResponder()
            case self.pass1:
                self.pass2.becomeFirstResponder()
            default:
                self.pass2.resignFirstResponder()
            }
        return true
    }
    
    @IBAction func reg(_ sender: Any) {
    
        Auth.auth().createUser(withEmail: email.text!, password: pass1.text!, completion: {authResult, error in
            
            let delegetem = (UIApplication.shared.delegate as? AppDelegate)
     let vc =       delegetem?.window?.rootViewController as? ViewController
            vc?.mibandconnectionlabel.text = "Connecting to Miban"
            
            delegetem?.centralManager.connect((delegetem?.miBand.peripheral)!, options: nil)
            
            vc?.mibandconnectionlabel.text = "Miban connected"
            vc?.statuslabel.text = "Az alkalmazás rendeltetésszerűen működik"
            vc?.statuslabel.textColor = .black
            vc?.statuslabel.backgroundColor = .green
            
            let messageVC = UIAlertController(title: "Informacio", message: "Sikeres regisztralas" , preferredStyle: .actionSheet)
            self.present(messageVC, animated: true) {
                            Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
                                messageVC.dismiss(animated: true, completion: {self.dismiss(animated: true, completion: nil)})})}})
        
    }
    
    
    }
    




    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


