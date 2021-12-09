//
//  Log_in_ViewController.swift
//  datacollateorMibanIOS
//
//  Created by Lehel Dénes-Fazakas on 2021. 09. 29..
//

import UIKit
import Firebase


class Log_in_ViewController: UIViewController ,UITextFieldDelegate{
   
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.password.delegate = self
        self.email.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case self.email:
                self.password.becomeFirstResponder()
            default:
                self.password.resignFirstResponder()
            }
        return true
    }
    
    @IBAction func bejelenkezs(_ sender: Any) {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!,completion: {(user, error) in
        if user != nil {
                                                          
            let delegetem = (UIApplication.shared.delegate as? AppDelegate)
            let vc =       delegetem?.window?.rootViewController as? ViewController
            vc?.mibandconnectionlabel.text = "Connecting to Miban"
                                                                                                  
            delegetem?.centralManager.connect((delegetem?.miBand.peripheral)!, options: nil)
                                                                                                  
            vc?.mibandconnectionlabel.text = "Miban connected"
            vc?.statuslabel.text = "Az alkalmazás rendeltetésszerűen működik"
            vc?.statuslabel.textColor = .black
            vc?.statuslabel.backgroundColor = .green
                                                                                             
                                                                                          
                                                                                              
       let messageVC = UIAlertController(title: "Informacio", message: "Sikeres bejelentkezes" , preferredStyle: .actionSheet)
       self.present(messageVC, animated: true) {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
    messageVC.dismiss(animated: true, completion: {self.dismiss(animated: true, completion: nil)})})}
                                                                                          
        }
        })
    }
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
