//
//  ViewController.swift
//  FB_search2
//
//  Created by pallavi alse on 4/11/17.
//  Copyright © 2017 pallavi alse. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var queryBox: UITextField!
    @IBOutlet weak var errorMsg: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.isHidden = false
        queryBox.delegate = self;
        if revealViewController() != nil{
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        
        /* Uncomment this if you want to remove all data from Userdefaults */
//        let defaults = UserDefaults.standard
//        defaults.dictionaryRepresentation().keys.forEach { defaults.removeObject(forKey: $0) }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    @IBAction func textfieldClicked(_ sender: Any) {
        errorMsg.isHidden = true
    }

    @IBAction func clearClicked(_ sender: UIButton) {
        queryBox.text = "";
    }

    @IBAction func searchClicked(_ sender: UIButton) {
        if(queryBox.text == ""){
            print("query not entered");
            errorMsg.isHidden = false;
            errorMsg.text = "Enter a valid query!";
            errorMsg.textColor = UIColor.white;
            errorMsg.backgroundColor = UIColor.darkGray;
            errorMsg.backgroundColor?.withAlphaComponent(0.7);
            errorMsg.textAlignment = NSTextAlignment.center;
        } else {
            print("\(queryBox.text) entered");
            errorMsg.isHidden = true;
            performSegue(withIdentifier: "searchToDetails", sender: Any?.self)
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorMsg.isHidden = true;
    
    }
   

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        errorMsg.isHidden = true;
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let tabBarController = segue.destination as! UITabBarController;
        /* user */
        let destinationNavViewController = tabBarController.viewControllers?[0] as! UINavigationController
        let destinationViewController = destinationNavViewController.topViewController as! UserViewController
        destinationViewController.queryWord = queryBox.text!
        self.navigationController?.navigationBar.isHidden = true;
        
        /* pages */
//        let destinationPageViewController = tabBarController.viewControllers?[1] as! PagesViewController
//       // let destinationPageViewController = destinationNavPageViewController.topViewController as! PagesViewController
//        destinationPageViewController.queryWord = queryBox.text!
        
//        /*groups */
//        let destinationNavGroupViewController = tabBarController.viewControllers?[2] as! UINavigationController
//        let destinationGroupViewController = destinationNavGroupViewController.topViewController as! GroupsViewController
//        destinationGroupViewController.queryWord = queryBox.text!
//        
//        /*places*/
//        let destinationNavPlacesViewController = tabBarController.viewControllers?[3] as! UINavigationController
//        let destinationPlacesViewController = destinationNavPlacesViewController.topViewController as! PlacesViewController
//        destinationPlacesViewController.queryWord = queryBox.text!
//        
//        /*events*/
//        let destinationNavEventsViewController = tabBarController.viewControllers?[4] as! UINavigationController
//        let destinationEventsViewController = destinationNavEventsViewController.topViewController as! EventsViewController
//        destinationEventsViewController.queryWord = queryBox.text!

        
    }
//    override func performSegue(withIdentifier identifier: tabSegue, sender: Any?) {
//        
//    }

}

