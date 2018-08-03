//
//  ViewController_mePage_extension.swift
//  eApp
//
//  Created by Christopher Guirguis on 5/3/18.
//  Copyright © 2018 Christopher Guirguis. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire.Swift
import Spartan
import SDWebImage
import LTMorphingLabel

extension ViewController {
    
    func setup_personalContent(){
        
        Spartan.getUsersPlaylists(userId: session.canonicalUsername, limit: 50, offset: 0, success: {
            (pagingObject) in
            
            var dictionary_userPlaylist_containerss = [String : Any]()
            var stringForStacking = "V:|-(==0@900)-"
            
            self.personalContent_SV.translatesAutoresizingMaskIntoConstraints = false
            for i in 0...pagingObject.items.count-1 {
                let userPlaylist = pagingObject.items[i]
                consoleLog(msg: "Playlist Name: \(userPlaylist.name)", level: 1)
                consoleLog(msg: "Total number of tracks: \(userPlaylist.tracksObject.total!)", level: 1)
                
                
                
                let userPlaylistContainer = parameterizedView()
                
                    userPlaylistContainer.backgroundColor = UIColor.clear
                
                
                self.personalContent_SV.addSubview(userPlaylistContainer)
                userPlaylistContainer.translatesAutoresizingMaskIntoConstraints = false
                
                self.personalContent_SV.addConstraint(parameterizedNSLayoutConstraint(item: self.personalContent_SV, attribute: .centerX, relatedBy: .equal, toItem: userPlaylistContainer, attribute: .centerX, multiplier: (1), constant: 0))
                self.personalContent_SV.addConstraint(parameterizedNSLayoutConstraint(item: self.personalContent_SV, attribute: .width, relatedBy: .equal, toItem: userPlaylistContainer, attribute: .width, multiplier: (1), constant: 0))
                userPlaylistContainer.addConstraint(parameterizedNSLayoutConstraint(item: userPlaylistContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 50))
                
                
                //Add arrow button
                
                let userPlaylist_arrowButton = parameterizedImageView()
                userPlaylist_arrowButton.backgroundColor = UIColor.clear
                userPlaylist_arrowButton.contentMode = .scaleAspectFit
                userPlaylist_arrowButton.translatesAutoresizingMaskIntoConstraints = false
                userPlaylist_arrowButton.image = #imageLiteral(resourceName: "rightArrow_w")
                userPlaylistContainer.addSubview(userPlaylist_arrowButton)
                
                userPlaylistContainer.addConstraint(parameterizedNSLayoutConstraint(item: userPlaylistContainer, attribute: .trailing, relatedBy: .equal, toItem: userPlaylist_arrowButton, attribute: .trailing, multiplier: (1), constant: 12))
                userPlaylistContainer.addConstraint(parameterizedNSLayoutConstraint(item: userPlaylistContainer, attribute: .top, relatedBy: .equal, toItem: userPlaylist_arrowButton, attribute: .top, multiplier: (1), constant: -12))
                 userPlaylistContainer.addConstraint(parameterizedNSLayoutConstraint(item: userPlaylistContainer, attribute: .bottom, relatedBy: .equal, toItem: userPlaylist_arrowButton, attribute: .bottom, multiplier: (1), constant: 12))
                userPlaylist_arrowButton.addConstraint(parameterizedNSLayoutConstraint(item: userPlaylist_arrowButton, attribute: .height, relatedBy: .equal, toItem: userPlaylist_arrowButton, attribute: .width, multiplier: (1), constant: 0))
                
                //Add the Queue nameLabel
                
                let userPlaylist_nameLabel = parameterizedLabel()
                
                userPlaylist_nameLabel.textColor = UIColor.white
                
                userPlaylist_nameLabel.translatesAutoresizingMaskIntoConstraints = false
                userPlaylistContainer.addSubview(userPlaylist_nameLabel)
                
                
                let userPlaylist_trackDataLabel = parameterizedLabel()
                
                userPlaylist_trackDataLabel.textColor = UIColor.lightGray
                userPlaylist_trackDataLabel.font = UIFont.systemFont(ofSize: 11)
                userPlaylist_trackDataLabel.translatesAutoresizingMaskIntoConstraints = false
                userPlaylistContainer.addSubview(userPlaylist_trackDataLabel)
                
                
                userPlaylist_nameLabel.text = userPlaylist.name
                userPlaylist_trackDataLabel.text = userPlaylist.owner.displayName
                
                
                
                userPlaylistContainer.addConstraint(parameterizedNSLayoutConstraint(item: userPlaylistContainer, attribute: .leading, relatedBy: .equal, toItem: userPlaylist_nameLabel, attribute: .leading, multiplier: (1), constant: -10))
                userPlaylistContainer.addConstraint(parameterizedNSLayoutConstraint(item: userPlaylist_arrowButton, attribute: .leading, relatedBy: .equal, toItem: userPlaylist_nameLabel, attribute: .trailing, multiplier: (1), constant: 25))
                
                userPlaylistContainer.addConstraint(parameterizedNSLayoutConstraint(item: userPlaylistContainer, attribute: .leading, relatedBy: .equal, toItem: userPlaylist_trackDataLabel, attribute: .leading, multiplier: (1), constant: -10))
                userPlaylistContainer.addConstraint(parameterizedNSLayoutConstraint(item: userPlaylist_arrowButton, attribute: .leading, relatedBy: .equal, toItem: userPlaylist_trackDataLabel, attribute: .trailing, multiplier: (1), constant: 25))
                
                
                let userPlaylist_internalContentsDict = ["userPlaylist_trackDataLabel": userPlaylist_trackDataLabel,"userPlaylist_nameLabel": userPlaylist_nameLabel] as [String : Any]
                let stringFor_userPlaylist_Stacking = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==6@900)-[userPlaylist_nameLabel]-(==4@900)-[userPlaylist_trackDataLabel]-(==6@900)-|", options: [], metrics: nil, views: userPlaylist_internalContentsDict)
                
                userPlaylistContainer.addConstraints(stringFor_userPlaylist_Stacking)
                
                
                self.view.layoutIfNeeded()
                dictionary_userPlaylist_containerss.updateValue(userPlaylistContainer, forKey: "upItem\(i)")
                stringForStacking += "[upItem\(i)]-(==0@900)-"
                
                
                
                
                //Setup queueItem_overlying button - only is the width of the label but is height of entire item
                let userPlaylist_overlyingButton = parameterizedButton()
                userPlaylist_overlyingButton.backgroundColor = UIColor.clear
                //userPlaylist_overlyingButton.alpha = 0.1
                userPlaylist_overlyingButton.arrayTagForPass.append(userPlaylist)
                userPlaylistContainer.addSubview(userPlaylist_overlyingButton)
                userPlaylist_overlyingButton.translatesAutoresizingMaskIntoConstraints = false
                userPlaylistContainer.addConstraint(parameterizedNSLayoutConstraint(item: userPlaylistContainer, attribute: .top, relatedBy: .equal, toItem: userPlaylist_overlyingButton, attribute: .top, multiplier: (1), constant: 0))
                userPlaylistContainer.addConstraint(parameterizedNSLayoutConstraint(item: userPlaylistContainer, attribute: .bottom, relatedBy: .equal, toItem: userPlaylist_overlyingButton, attribute: .bottom, multiplier: (1), constant: 0))
                userPlaylistContainer.addConstraint(parameterizedNSLayoutConstraint(item: userPlaylistContainer, attribute: .left, relatedBy: .equal, toItem: userPlaylist_overlyingButton, attribute: .left, multiplier: (1), constant: 0))
                userPlaylistContainer.addConstraint(parameterizedNSLayoutConstraint(item: userPlaylistContainer, attribute: .right, relatedBy: .equal, toItem: userPlaylist_overlyingButton, attribute: .right, multiplier: (1), constant: 0))
                
                
                userPlaylist_overlyingButton.addTarget(self, action: #selector(ViewController.select_playlist(_:)), for: .touchUpInside)
                
                
            }
                
                
                
                
            
            
            stringForStacking += "|"
            let categories_stackingConstraint = NSLayoutConstraint.constraints(withVisualFormat: stringForStacking, options: [], metrics: nil, views: dictionary_userPlaylist_containerss)
            
            self.personalContent_SV.addConstraints(categories_stackingConstraint)
            
            self.view.layoutIfNeeded()
            
        }, failure: { (error) in
            print("hereasgasd")
            print(error)
        })
        
    
    

    
    
    
    
}
}
