//
//  DetailViewController.swift
//  FB_search2
//
//  Created by pallavi alse on 4/15/17.
//  Copyright © 2017 pallavi alse. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import SwiftSpinner

class UserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    var page: Int = 0
    var queryWord : String = "";
    var my_id : String = "";
    var my_url : String = "";
    var my_type : String = "user"
    var my_name : String = "";
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var testlabel: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var PrevButton: UIButton!
    @IBOutlet weak var NextButton: UIButton!
    var swiftyJsonVar : SwiftyJSON.JSON = []
    var chunks : [[SwiftyJSON.JSON]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Loading data...")
        PrevButton.setTitleColor(UIColor.gray, for: .disabled)
        NextButton.setTitleColor(UIColor.gray, for: .disabled)
        PrevButton.isEnabled = false
        NextButton.isEnabled = true
        
        fetchData();
        if revealViewController() != nil{
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }


        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        let mytab = self.tabBarController;
        mytab?.tabBar.isHidden = false;
        paginate()
        self.myTableView.reloadData()


    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func PrevPage(_ sender: Any) {
        page = page - 1
        paginate()
        self.myTableView.reloadData()
    }
    @IBAction func NextPage(_ sender: Any) {
        page = page + 1
        paginate()
        self.myTableView.reloadData()
    }
   
    func fetchData() -> Void{
        Alamofire.request(
           URL(string: "http://palse-fbsearch-env.us-west-2.elasticbeanstalk.com/index.php")!,
//            URL(string: "http://cs-server.usc.edu:28841/hw9/index.php")!,

            method: .get,
            parameters: ["keyword": queryWord, "tab": "user"])
        .validate()
            .responseJSON{ response in
                SwiftSpinner.hide()
//                print(response.request! as Any)
//                print(response.response as Any)
//                print(response.result as Any)
//                //print(response.result.value as Any)
//                print(response.error as Any)
               
                if((response.result.value) != nil) {
                    self.swiftyJsonVar = JSON(response.result.value!)
                    let chunkSize = 10
                    self.chunks = stride(from:0, to: self.swiftyJsonVar.count, by:chunkSize).map{
                        Array(self.swiftyJsonVar.arrayValue[$0..<min($0 + chunkSize, self.swiftyJsonVar.count)])
                    }
//                    print(self.chunks[0])
//                    print(self.chunks[1])
//                    print(self.chunks[2])
                    
//                    
//                    for item in self.swiftyJsonVar.arrayValue {
//                        print(item["id"].stringValue)
//                        print(item["name"].stringValue)
//                        print(item["url"].stringValue)
//                    }
                    self.PrevButton.setTitleColor(UIColor.gray,for: .disabled)
                        self.paginate()
                        self.myTableView.reloadData()
                        self.PrevButton.setTitleColor(UIColor.gray,for: .disabled)
                        
                    }
                }
        
        
        }
        
        
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if (self.chunks.count>page){
            var item = self.chunks[page][indexPath.row]
            var myUrlStr = item["url"].stringValue
            var myUrl = Foundation.URL(string:myUrlStr)
    
       
        cell.imageView?.sd_setImage(
            with: myUrl,
            placeholderImage: #imageLiteral(resourceName: "transparent"),
            options: [],
            completed:{ (image, error, cacheType, imageURL) in
                // Perform operation.
                cell.setNeedsLayout()
                });
        cell.setNeedsLayout()
        var str = item["name"].stringValue;
            if(str.characters.count > 20){
            let start = str.index(str.startIndex, offsetBy: 0)
            let end = str.index(str.startIndex, offsetBy: 20)
            let range = start..<end
            var substr = str.substring(with: range)
            substr.append("...")
            cell.textLabel?.text = substr
            } else {
                cell.textLabel?.text = str
            }
            cell.textLabel?.textAlignment = NSTextAlignment.natural
        
        
        
      
            
       

        let cur_id = chunks[page][indexPath.row]["id"].stringValue
        let dict = defaults.object(forKey: cur_id) as? [String : String] ?? [String : String]()
        if(!dict.isEmpty){
             cell.contentView.viewWithTag(1234)?.removeFromSuperview()
            var imageview = UIImageView(image: #imageLiteral(resourceName: "filledStar"))
            imageview.tag = 1234
            imageview.frame.origin.x = 5.5*imageview.frame.width
            cell.contentView.addSubview(imageview)
            tableView.tableFooterView = UIView(frame: .zero)
        } else {
            cell.contentView.viewWithTag(1234)?.removeFromSuperview()
            var imageview = UIImageView(image: #imageLiteral(resourceName: "emptyStar"))
            imageview.frame.origin.x = 5.5*imageview.frame.width
            cell.contentView.addSubview(imageview)
            tableView.tableFooterView = UIView(frame: .zero)
        }

        return cell
        } else {
            return cell
        }
    }
  
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryView = nil
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(chunks.count > page){
        
        switch page{
            
        case 0:
            return (chunks[0].count - 1)
        case 1:
            return (chunks[1].count - 1);
        case 2:
            return (chunks[2].count - 1);
        default:
            return 10;
        }
        } else {
            return 0;
        }
    }
    func paginate(){
        if(chunks.count == 1){
            NextButton.isEnabled = false
            PrevButton.isEnabled = false
        } else if(chunks.count == 2) {
            switch page{
            case 0:
                NextButton.isEnabled = true
                PrevButton.isEnabled = false
            case 1:
                PrevButton.isEnabled = true
                NextButton.isEnabled = false
            default:
                PrevButton.isEnabled = true
                NextButton.isEnabled = true
            }
        }else if(chunks.count == 3){
                switch page{
                case 0:
                    NextButton.isEnabled = true
                    PrevButton.isEnabled = false
                case 1:
                    NextButton.isEnabled = true
                    PrevButton.isEnabled = true
                case 2:
                    NextButton.isEnabled = false
                    PrevButton.isEnabled = true
                default:
                    NextButton.isEnabled = true
                    PrevButton.isEnabled = true
                }
            }
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(indexPath.row) row")
        my_id = chunks[page][indexPath.row]["id"].stringValue
        my_url = chunks[page][indexPath.row]["url"].stringValue
        my_name = chunks[page][indexPath.row]["name"].stringValue
        
        //self.navigationController?.navigationBar.isHidden = true
        performSegue(withIdentifier: "mainToDetails", sender: Any?.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /* hide tab bar when segueing */
        let mytab = self.tabBarController;
        mytab?.tabBar.isHidden = true;
        
        let tabBarController = segue.destination as! UITabBarController;
        let destinationViewController = tabBarController.viewControllers?[0] as! AlbumsViewController
        //let destinationViewController = destinationNavViewController.topViewController as! AlbumsViewController
        destinationViewController.my_id = self.my_id
        destinationViewController.my_url = self.my_url
        destinationViewController.my_name = self.my_name
        destinationViewController.my_type = self.my_type
        
        

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
