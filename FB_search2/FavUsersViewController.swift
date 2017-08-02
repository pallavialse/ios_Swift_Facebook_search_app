//
//  FavUsersViewController.swift
//  FB_search2
//
//  Created by pallavi alse on 4/25/17.
//  Copyright © 2017 pallavi alse. All rights reserved.
//

import UIKit
import SDWebImage

class FavUsersViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var menuButton: UIBarButtonItem!
  
    @IBOutlet weak var myTableView: UITableView!
   
    var my_id : String = ""
    var my_row : Int = 0;
    var user_arr : [[String : String]] = []
    var my_url : String = "";
    var my_type : String = "user"
    var my_name : String = "";

    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData();
        
        /* menu button */
        if revealViewController() != nil{
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        let mytab = self.tabBarController;
        mytab?.tabBar.isHidden = false;
        if(!my_id.isEmpty){
            let dict = defaults.object(forKey: my_id) as? [String: String] ?? [String: String]()
            if(dict.isEmpty){
                if(!user_arr.isEmpty){
                    user_arr.remove(at: my_row)
                    self.myTableView.reloadData()
                }
               
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    
    func fetchData() -> Void{
//        var i : Int = 0
//        print(UserDefaults.standard.dictionaryRepresentation().values)
//        for value in UserDefaults.standard.dictionaryRepresentation().values{
//            
//           
//
        var id_arr = self.defaults.object(forKey: "ids") as? [String] ?? [String]()
        for item in id_arr{
        let dict = defaults.object(forKey: item) as? [String: String] ?? [String: String]()
            print(dict)
            if(!dict.isEmpty){
                

                    if(dict["type"] == "user"){
                        user_arr.append(dict)
                    }
                
            }
                
            
            
        }
       
       // print(user_arr)
        self.myTableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "favusercell", for: indexPath)
        if(user_arr.count > indexPath.row){
            /* get item from favorited users array */
            var item = self.user_arr[indexPath.row]
            
            /* name */
            var name = item["name"]
            /* url of profile pic */
            var myUrlStr = item["url"]
            var myUrl = Foundation.URL(string:myUrlStr!)
            
            cell.imageView?.sd_setImage(
                            with: myUrl,
                            placeholderImage: #imageLiteral(resourceName: "transparent"),
                            options: [],
                            completed:{ (image, error, cacheType, imageURL) in
                                // Perform operation.
                                cell.setNeedsLayout()
                        });
            cell.setNeedsLayout()
            cell.textLabel?.text = name
            cell.textLabel?.textAlignment = NSTextAlignment.natural
            
            var imageview = UIImageView(image: #imageLiteral(resourceName: "filledStar"))
            imageview.frame.origin.x = 5.5*imageview.frame.width
            cell.contentView.addSubview(imageview)
            tableView.tableFooterView = UIView(frame: .zero)
        }
        return cell
    }
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return user_arr.count
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.my_row = indexPath.row
        self.my_id = user_arr[indexPath.row]["id"]!
        self.my_name = user_arr[indexPath.row]["name"]!
        self.my_url = user_arr[indexPath.row]["url"]!
        
//        
//        //self.navigationController?.navigationBar.isHidden = true
        performSegue(withIdentifier: "favuserToDetails", sender: Any?.self)
   }
//    
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        /* hide tab bar when segueing */
        let mytab = self.tabBarController;
        mytab?.tabBar.isHidden = true;
    
        let tabBarController = segue.destination as! UITabBarController;
        let destinationViewController = tabBarController.viewControllers?[0] as! AlbumsViewController
        destinationViewController.my_id = self.my_id
        destinationViewController.my_url = self.my_url
        destinationViewController.my_name = self.my_name
        destinationViewController.my_type = self.my_type
//        
//        
//        
   }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
