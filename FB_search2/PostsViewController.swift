//
//  PostsViewController.swift
//  FB_search2
//
//  Created by pallavi alse on 4/19/17.
//  Copyright © 2017 pallavi alse. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import SwiftSpinner
import FacebookCore
import FacebookLogin
import FacebookShare
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import EasyToast


class PostsViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var myScroll: UIScrollView!
    
    var my_id: String = ""
    @IBOutlet weak var options: UIBarButtonItem!
    var my_url : String = ""
    var my_fav : Int = 0
    var my_type : String = ""
    var my_name : String = "";
    let defaults = UserDefaults.standard

    
    var swiftyJsonVar : SwiftyJSON.JSON = []
    
    @IBOutlet weak var myPostsTableView: UITableView!
    
    var main_id : String {
        get {
            let destinationViewController = tabBarController?.viewControllers?[0] as! AlbumsViewController
            //let destinationViewController = destinationNavViewController.topViewController as! AlbumsViewController
            return destinationViewController.my_id
        }
    }
    var main_url : String {
        get {
            let destinationViewController = tabBarController?.viewControllers?[0] as! AlbumsViewController
           // let destinationViewController = destinationNavViewController.topViewController as! AlbumsViewController
            return destinationViewController.my_url
        }
    }
    func get_details(){
        let destinationViewController = tabBarController?.viewControllers?[0] as! AlbumsViewController
        my_url = main_url
        my_name = destinationViewController.my_name
        my_type = destinationViewController.my_type
        my_id = main_id
        
    }

    @IBAction func optionsClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "MENU", message: "", preferredStyle: .actionSheet)
        if(my_fav == 0){
            my_fav = 1
            let favoriteAction = UIAlertAction(title: "Add to Favorites", style: .default) { action in
                let dict = ["name": self.my_name, "url": self.my_url, "type": self.my_type]
                self.defaults.set(dict, forKey: self.my_id)
                var id_arr = self.defaults.object(forKey: "ids") as? [String] ?? [String]()
                id_arr.append(self.my_id)
                self.defaults.set(id_arr, forKey:"ids")
                self.view.showToast("Added to Favorites", position: .bottom, popTime: 2, dismissOnTap: false, bgColor: UIColor.black, textColor: UIColor.white)
            }
            alertController.addAction(favoriteAction)

        } else{
            my_fav = 0
            let favoriteAction = UIAlertAction(title: "Remove from Favorites", style: .default) { action in
                self.defaults.removeObject(forKey: self.my_id)
                /* get the ids array and remove the my_id from it and set it back */
                var id_arr = self.defaults.object(forKey: "ids") as? [String] ?? [String]()
                if let index = id_arr.index(of:self.my_id) {
                    id_arr.remove(at: index)
                }
                self.defaults.set(id_arr, forKey:"ids")
                self.view.showToast("Removed from Favorites", position: .bottom, popTime: 2, dismissOnTap: false, bgColor: UIColor.black, textColor: UIColor.white)
            }
            alertController.addAction(favoriteAction)

        }
        let shareAction = UIAlertAction(title: "Share", style: .default) { action in
            print(action)
            self.share_pic()
        }

        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print(action)
        }
        alertController.addAction(shareAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)

    }

//    @IBAction func BackClicked(_ sender: Any) {
//       // self.navigationController?.popToViewController(UserViewController as UIViewController, animated: true)
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Loading data...")
                // Do any additional setup after loading the view.
        myScroll.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+900)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        get_details()
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image:#imageLiteral(resourceName: "options"), style: .plain, target: self, action: #selector(self.optionsClicked(_:)))
        let dict = defaults.object(forKey: my_id) as? [String : String] ?? [String : String]()
        if(!dict.isEmpty){
            my_fav = 1
        }  else {
            my_fav = 0
        }

        
        fetchPosts()
    }
    func fetchPosts(){
        
        Alamofire.request(
            URL(string: "http://palse-fbsearch-env.us-west-2.elasticbeanstalk.com/index.php")!,
            method: .get,
            parameters: ["id": my_id])
            .validate()
            .responseJSON{ response in
                SwiftSpinner.hide()
                //                print(response.request! as Any)
                //                print(response.response as Any)
                //                print(response.result as Any)
                //              //  print(response.result.value as Any)
                //                print(response.error as Any)
                
                
                if((response.result.value) != nil) {
                    self.swiftyJsonVar = JSON(response.result.value!)
                }
                
//                var arr = self.swiftyJsonVar
//                print(arr)
                
                //                for item in self.swiftyJsonVar.arrayValue {
                //                    print("***************************************")
                //                    print(item["id"].stringValue)
                //                    print(item["name"].stringValue)
                //                    print(item["photos"].stringValue)
                //                }
                self.myPostsTableView.reloadData()
                
                
        }
        
        
        
    }
    
    func share_pic(){
        var myContent = LinkShareContent(url: Foundation.URL(string:"http://facebook.com/"+self.my_id)!)
        
        
        let shareDialog = ShareDialog(content: myContent)
        shareDialog.mode = .feedBrowser
        shareDialog.failsOnInvalidData = true
        shareDialog.presentingViewController = self
            shareDialog.completion = { result in
            print(result)
            switch result{
                
            case .success:
                self.view.showToast("Shared", position: .bottom, popTime: 2, dismissOnTap: false, bgColor: UIColor.black, textColor: UIColor.white)
                
            case .failed:
                self.view.showToast("Share failed", position: .bottom, popTime: 2, dismissOnTap: false, bgColor: UIColor.black, textColor: UIColor.white)
            case .cancelled:
                self.view.showToast("Share cancelled", position: .bottom, popTime: 2, dismissOnTap: false, bgColor: UIColor.black, textColor: UIColor.white)
                
            default:
                self.view.showToast("Shared", position: .bottom, popTime: 2, dismissOnTap: false, bgColor: UIColor.black, textColor: UIColor.white)
                
            }
        }
        do{
            try shareDialog.show()
        } catch let error{
            print("error while sharing")
        }
        
        
    }
    
    
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = PostCell()
        cell = tableView.dequeueReusableCell(withIdentifier: "postcell", for: indexPath) as! PostCell
        
        var myUrlStr = my_url
        var myUrl = Foundation.URL(string:myUrlStr)
        
        
        cell.profilePic?.sd_setImage(
            with: myUrl,
            placeholderImage: #imageLiteral(resourceName: "transparent"),
            options: [],
            completed:{ (image, error, cacheType, imageURL) in
                // Perform operation.
                cell.setNeedsLayout()
        });
        cell.setNeedsLayout()
        
        cell.textArea?.numberOfLines = 0;
        cell.textArea?.text = self.swiftyJsonVar["posts"][indexPath.row]["message"].stringValue
        
        
       /* created_time */
        var time: String = self.swiftyJsonVar["posts"][indexPath.row]["created_time"]["date"].stringValue
        var substring:String = time.components(separatedBy: ".")[0]
        print(substring)
        cell.timeLabel?.text = substring
        
        
        
        tableView.tableFooterView = UIView(frame: .zero)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(swiftyJsonVar.count > 0){
            return swiftyJsonVar["posts"].count;
        }
        return 0;
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSection: NSInteger = 0
        
        if (!self.swiftyJsonVar["posts"].isEmpty) {
            
            self.myPostsTableView.backgroundView = nil
            numOfSection = 1
            
            
        } else {
            
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            noDataLabel.text = "No Data Available"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = NSTextAlignment.center
            self.myPostsTableView.backgroundView = noDataLabel
            self.myPostsTableView.separatorStyle = .none
            
            
            
            
        }
        return numOfSection
    }


//
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
