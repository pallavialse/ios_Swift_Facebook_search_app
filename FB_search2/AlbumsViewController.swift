//
//  AlbumsViewController.swift
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
import EasyToast

class AlbumsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var selectedIndexPath : NSIndexPath?
    
    var my_id: String = ""
    var my_url : String = ""
    var my_fav : Int = 0
    var my_type : String = ""
    var my_name : String = "";
    let defaults = UserDefaults.standard
  
    
    var swiftyJsonVar : SwiftyJSON.JSON = []
    @IBOutlet weak var myAlbumTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Loading data...")
        print(my_id);
        print(my_url);
        fetchAlbums();
        let dict = defaults.object(forKey: my_id) as? [String : String] ?? [String : String]()
        if(!dict.isEmpty){
            my_fav = 1
            
        } else {
            my_fav = 0
        }


        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
         self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image:#imageLiteral(resourceName: "options"), style: .plain, target: self, action: #selector(self.optionsClicked(_:)))
        let dict = defaults.object(forKey: my_id) as? [String : String] ?? [String : String]()
        if(!dict.isEmpty){
            my_fav = 1
            
        } else {
            my_fav = 0
        }

    }
    
    @IBAction func optionsClicked(_ sender: Any) {
        
        let alertController = UIAlertController(title: "MENU", message: "", preferredStyle: .actionSheet)
        if(my_fav == 0){
            my_fav = 1
            let favoriteAction = UIAlertAction(title: "Add to Favorites", style: .default) { action in
                print(action)
                let dict = ["id":self.my_id, "name": self.my_name, "url": self.my_url, "type": self.my_type]
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
                print(action)
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
           // print(action)
           // print("Sharing to facebook")
            self.share_pic()
            
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print(action)
        }
        alertController.addAction(shareAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
        
    }
    func share_pic(){
        var myContent = LinkShareContent(url: Foundation.URL(string:"http://facebook.com/"+self.my_id)!)
        
        
        let shareDialog = ShareDialog(content: myContent)
        shareDialog.mode = .feedBrowser
//        shareDialog.failsOnInvalidData = true
//        shareDialog.presentingViewController = self
        shareDialog.completion = { result in
            switch result{
            case .success:
                   self.view.showToast("Share failed", position: .bottom, popTime: 2, dismissOnTap: false, bgColor: UIColor.black, textColor: UIColor.white)
            
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
    

    func fetchAlbums(){
        
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
                
                
                //var arr = self.swiftyJsonVar
                //print(arr["albums"][0]["photos"][0]["picture"])
                
//                for item in self.swiftyJsonVar.arrayValue {
//                    print("***************************************")
//                    print(item["id"].stringValue)
//                    print(item["name"].stringValue)
//                    print(item["photos"].stringValue)
//                }
                                    self.myAlbumTableView.reloadData()
                
                
                   
                

        }
        
 
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = AlbumCell()
        cell = tableView.dequeueReusableCell(withIdentifier: "albumcell", for: indexPath) as! AlbumCell
        var arr = self.swiftyJsonVar["albums"][indexPath.row]["name"]
        var myUrlStr1 = self.swiftyJsonVar["albums"][indexPath.row]["photos"][0]["picture"].stringValue
        var myUrlStr2 = self.swiftyJsonVar["albums"][indexPath.row]["photos"][1]["picture"].stringValue
        var myUrl1 = Foundation.URL(string:myUrlStr1)
        var myUrl2 = Foundation.URL(string:myUrlStr2)
        
        
        cell.albumName.text = arr.stringValue
    
        
        cell.image1?.sd_setImage(
            with: myUrl1,
            placeholderImage: #imageLiteral(resourceName: "transparent"),
            options: [],
            completed:{ (image, error, cacheType, imageURL) in
                // Perform operation.
                cell.setNeedsLayout()
        });
        cell.image2?.sd_setImage(
            with: myUrl2,
            placeholderImage: #imageLiteral(resourceName: "transparent"),
            options: [],
            completed:{ (image, error, cacheType, imageURL) in
                // Perform operation.
                cell.setNeedsLayout()
        });

        tableView.tableFooterView = UIView(frame: .zero)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(swiftyJsonVar.count > 0){
        return swiftyJsonVar["albums"].count;
        }
        return 0;
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSection: NSInteger = 0
        
        if (!self.swiftyJsonVar["albums"].isEmpty) {
            
            self.myAlbumTableView.backgroundView = nil
            numOfSection = 1
            
            
        } else {
            
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: -10, width: 150, height: 10))
            
            noDataLabel.text = "No Data Available"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = NSTextAlignment.center
            self.myAlbumTableView.backgroundView = noDataLabel
            self.myAlbumTableView.separatorStyle = .none

           

            
        }
        return numOfSection
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexPath = selectedIndexPath
        if indexPath as NSIndexPath? == selectedIndexPath{
            selectedIndexPath = nil
        } else {
                selectedIndexPath = indexPath as NSIndexPath?
        }
        var indexPaths: [NSIndexPath] = []
        if let previous = previousIndexPath{
                indexPaths += [previous]
        }
        if let current = selectedIndexPath{
            indexPaths += [current]
        }
        if indexPaths.count > 0{
            self.myAlbumTableView.reloadRows(at: indexPaths as [IndexPath], with: UITableViewRowAnimation.automatic)
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! AlbumCell).watchFrameChanges()
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! AlbumCell).ignoreFrameChanges()
    }
    
    
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath as NSIndexPath? == selectedIndexPath{
            return AlbumCell.expandedHeight
        } else {
            return AlbumCell.defaultHeight
        }
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
