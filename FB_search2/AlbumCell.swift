//
//  AlbumCell.swift
//  FB_search2
//
//  Created by pallavi alse on 4/22/17.
//  Copyright © 2017 pallavi alse. All rights reserved.
//

import UIKit

class AlbumCell: UITableViewCell {

    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    override func awakeFromNib() {
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class var expandedHeight: CGFloat { get { return 400 } }
    class var defaultHeight: CGFloat { get { return 44 } }
    var frameAdded = false;
    func checkHeight(){
        image1.isHidden = (frame.size.height < AlbumCell.expandedHeight)
    }
    func watchFrameChanges(){
        if(!frameAdded){
            addObserver(self, forKeyPath: "frame", options: .new, context: nil)
            checkHeight()
            frameAdded = true
        }
    }
    func ignoreFrameChanges(){
        if(frameAdded){
            (removeObserver(self, forKeyPath: "frame"))
            frameAdded = false
        }
        
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
    override func prepareForReuse() {
        ignoreFrameChanges()
    }
    deinit{
        ignoreFrameChanges()
    }
}
