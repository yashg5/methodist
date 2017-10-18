//
//  LoginViewController.swift
//  methodist
//
//  Created by Zemoso Labs on 18/10/17.
//  Copyright © 2017 Zemoso Labs. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: Any) {
        if checkInput() {
            // TODO: Do call API and get uniqueId back (Alamofire calls)
            self.performSegue(withIdentifier: "showHomeScreen", sender: self)
        } else {
            let alertController = UIAlertController(title: "ONCO", message:
                "Please provide all required values", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onQuestions(_ sender: UIButton) {
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        if segue.identifier == "showHomeScreen" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! HomeViewController
            if let name = firstName.text {
                controller.message = "Welcome \(name). How can we help you today?"
                controller.cusUniqueID = name
            }
        }
    }

    // MARK: - Functions
    func checkInput() -> Bool {
        
        let lastNameValue = lastName.text
        let firstNameValue = firstName.text
        let dobValue = dob.text
        
        if !lastNameValue!.isEmpty && !firstNameValue!.isEmpty && !dobValue!.isEmpty {
            return true
        }
        return false
    }
}
