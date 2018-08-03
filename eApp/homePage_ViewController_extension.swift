//
//  ViewController_homePage_extension.swift
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
import MarqueeLabel


extension ViewController {
    func setup_mainContent(){
        UIView.animate(withDuration: 0.60, delay: 0, options: [.curveEaseInOut], animations: {
            let logoView = self.view.viewWithTag(326923457)
            logoView?.transform = CGAffineTransform(rotationAngle: CGFloat(degreesToRadians(degrees: 90)))
            logoView?.transform = CGAffineTransform(scaleX: 6, y: 6)
            self.view.viewWithTag(348629346)?.alpha = 0
            
        }, completion: {
            (thisParam: Bool) in
            UIView.animate(withDuration: 0.50, delay: 0, options: [.curveEaseInOut], animations: {
                
                
                
            }, completion: {
                (thisParam: Bool) in
                
                
                
            })
            
            
        })
        let categories = [["Today's Top Hits","spotify:user:spotify:playlist:37i9dQZF1DXcBWIGoYBM5M"],
                          ["New releases","spotify:user:spotify:playlist:37i9dQZF1DX4JAvHpjipBk"],
                          ["Suggested Pop","spotify:user:spotify:playlist:37i9dQZF1DWUa8ZRTfalHk"],
                          ["Suggested Rap","spotify:user:spotify:playlist:37i9dQZF1DX0XUsuxWHRQd"],
                          ["Suggested R&B","spotify:user:spotify:playlist:37i9dQZF1DWUzFXarNiofw"],
                          ["Suggested EDM","spotify:user:spotify:playlist:37i9dQZF1DX4dyzvuaRJ0n"]] as [Any]
        
        
        
        var dictionary_categoryContainerViews = [String : Any]()
        var stringForStacking = "V:|-(==0@900)-"
        
        
        //This is the asynchronous part, that gets the data from spotify
        for i in 0...categories.count-1 {
            
            var thisCategoryDictionary = NSMutableDictionary()
            
            var thisCategory_trackArray:[track_eApp] = []
            //var thisCategory_dictArray_ofSong = [NSMutableDictionary]()
            
            
            let thisCategory = categories[i] as! [String]
            
            
            
            thisCategoryDictionary.setValue(thisCategory[0], forKey: "playlistName")
            thisCategoryDictionary.setValue(thisCategory[1], forKey: "playlistURI")
            thisCategoryDictionary.setValue(Int(i*100), forKey: "category_instanceID")
            
            
            
            
            
            
            let mainContent_categoryContainer = parameterizedView()
            
            mainContent_categoryContainer.backgroundColor = UIColor.clear
            //mainContent_categoryContainer.alpha = CGFloat(Double(i)*0.1)
            
            mainContent_SV.addSubview(mainContent_categoryContainer)
            mainContent_categoryContainer.translatesAutoresizingMaskIntoConstraints = false
            
            
            
            
            
            mainContent_SV.addConstraint(parameterizedNSLayoutConstraint(item: mainContent_SV, attribute: .centerX, relatedBy: .equal, toItem: mainContent_categoryContainer, attribute: .centerX, multiplier: (1), constant: 0))
            mainContent_SV.addConstraint(parameterizedNSLayoutConstraint(item: mainContent_SV, attribute: .width, relatedBy: .equal, toItem: mainContent_categoryContainer, attribute: .width, multiplier: (1), constant: 0))
            mainContent_categoryContainer.addConstraint(parameterizedNSLayoutConstraint(item: mainContent_categoryContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 260))
            
            
            
            //This adds the components in each categoryContainer
            
            let categoryContainer_titleLabel = parameterizedLabel()
            
            categoryContainer_titleLabel.backgroundColor = UIColor.clear
            
            categoryContainer_titleLabel.text = thisCategory[0]
            categoryContainer_titleLabel.textColor = UIColor.white
            categoryContainer_titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
            categoryContainer_titleLabel.textAlignment = .center
            
            
            
            
            mainContent_categoryContainer.addSubview(categoryContainer_titleLabel)
            categoryContainer_titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            
            
            
            
            mainContent_categoryContainer.addConstraint(parameterizedNSLayoutConstraint(item: mainContent_categoryContainer, attribute: .leading, relatedBy: .equal, toItem: categoryContainer_titleLabel, attribute: .leading, multiplier: (1), constant: -10))
            
            mainContent_categoryContainer.addConstraint(parameterizedNSLayoutConstraint(item: mainContent_categoryContainer, attribute: .trailing, relatedBy: .equal, toItem: categoryContainer_titleLabel, attribute: .trailing, multiplier: (1), constant: 10))
            
            mainContent_categoryContainer.addConstraint(parameterizedNSLayoutConstraint(item: mainContent_categoryContainer, attribute: .top, relatedBy: .equal, toItem: categoryContainer_titleLabel, attribute: .top, multiplier: (1), constant: -5))
            
            categoryContainer_titleLabel.addConstraint(parameterizedNSLayoutConstraint(item: categoryContainer_titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 42))
            
            
            
            
            //Add the scrollView with the results
            
            let categoryContainer_tracksContainer = parameterizedScrollView()
            categoryContainer_tracksContainer.delegate = self
            categoryContainer_tracksContainer.tag = 4000000 + i
            
            categoryContainer_tracksContainer.backgroundColor = UIColor.clear
            
            categoryContainer_tracksContainer.tag = (thisCategoryDictionary.value(forKey: "category_instanceID") as! Int) + 5000000
            
            //categoryContainer_tracksContainer.text = "hello"
            //categoryContainer_tracksContainer.textColor = UIColor.white
            //categoryContainer_tracksContainer.font = UIFont.systemFont(ofSize: 32)
            
            
            mainContent_categoryContainer.addSubview(categoryContainer_tracksContainer)
            categoryContainer_tracksContainer.translatesAutoresizingMaskIntoConstraints = false
            
            
            
            
            
            mainContent_categoryContainer.addConstraint(parameterizedNSLayoutConstraint(item: mainContent_categoryContainer, attribute: .left, relatedBy: .equal, toItem: categoryContainer_tracksContainer, attribute: .left, multiplier: (1), constant: 0))
            
            mainContent_categoryContainer.addConstraint(parameterizedNSLayoutConstraint(item: mainContent_categoryContainer, attribute: .right, relatedBy: .equal, toItem: categoryContainer_tracksContainer, attribute: .right, multiplier: (1), constant: 0))
            
            mainContent_categoryContainer.addConstraint(parameterizedNSLayoutConstraint(item: categoryContainer_titleLabel, attribute: .bottom, relatedBy: .equal, toItem: categoryContainer_tracksContainer, attribute: .top, multiplier: (1), constant: -5))
            
            mainContent_categoryContainer.addConstraint(parameterizedNSLayoutConstraint(item: mainContent_categoryContainer, attribute: .bottom, relatedBy: .equal, toItem: categoryContainer_tracksContainer, attribute: .bottom, multiplier: (1), constant: 5))
            
            mainContent_categoryContainer.addConstraint(parameterizedNSLayoutConstraint(item: mainContent_categoryContainer, attribute: .width, relatedBy: .equal, toItem: categoryContainer_tracksContainer, attribute: .width, multiplier: (1), constant: 0))
            
            //mainContent_categoryContainer.addConstraint(parameterizedNSLayoutConstraint(item: mainContent_categoryContainer, attribute: .height, relatedBy: .equal, toItem: categoryContainer_tracksContainer, attribute: .height, multiplier: (1), constant: 5))
            
            
            
            
            
            
            
            
            
            
            dictionary_categoryContainerViews.updateValue(mainContent_categoryContainer, forKey: "cat\(i)")
            stringForStacking += "[cat\(i)]-(==0@900)-"
            
            
            //This is the remote data part
            let playlistURI_plain = spotify_playlistURI_to_ownerID_AND_playlistID(uriString: thisCategory[1])
            
            _ = Spartan.getUsersPlaylist(userId: playlistURI_plain.0, playlistId: playlistURI_plain.1, fields: nil, market: .us, success: { (playlist) in
                print("\(playlist.name!) has \(playlist.tracksObject.total!) tracks")
                let iterations = checkIterations_roundUp(Double(playlist.tracksObject.total), denominator: 50)
                print("\(iterations) iterations")
                var allTracks_inThisCategory:[track_eApp] = []
                
                var dictionary_containingSetsOfTracks = NSMutableDictionary()
                
                for iteration in 0...iterations-1 {
                    print("iteration #\(iteration)")
                    
                    var thisSet_tracks:[track_eApp] = []
                    
                    _ = Spartan.getPlaylistTracks(userId: playlistURI_plain.0, playlistId: playlistURI_plain.1, limit: 50, offset: iteration * 50, fields: nil, market: .us, success: { (pagingObject) in
                        consoleLog(msg: "Playlist Name: \(thisCategory[0])", level: 1)
                        for k in 0...pagingObject.items.count-1 {
                            let item = pagingObject.items[k]
                            let thisSong = track_eApp(isFromQueue: false, isSuggestion: false, suggestor: "hostUser_self")
                            thisSong.name = item.track.name
                            thisSong.uri = item.track.uri
                            
                            if item.track.album.images.count > 0 {
                                thisSong.albumArtURL = item.track.album.images[0].url
                            }
                            
                            if item.track.artists.count > 0 {
                                thisSong.artistString = artists_toArtistString(item.track.artists)
                            }
                            
                            thisSong.source_uri = thisCategory[1]
                            thisSong.source_name = thisCategory[0]
                            thisSong.source_owner = "spotify"
                            thisSong.locationInSource = k + iteration*50
                            

                            dictionary_containingSetsOfTracks = self.organizationStorage(storageDictionary: dictionary_containingSetsOfTracks, key: String(thisSong.locationInSource!), item: thisSong)
                            thisSet_tracks.append(thisSong)
                            
                            //print("Tracks in \(thisCategory[0]) dictionary || \(dictionary_containingSetsOfTracks.allKeys.count)/\(playlist.tracksObject.total!)")
                            
                            if (dictionary_containingSetsOfTracks.allKeys.count) == playlist.tracksObject.total! {
                                print("Loaded all tracks in  in \(thisCategory[0])")
                                thisCategory_trackArray = (self.enumerateDictionary(storageDictionary: dictionary_containingSetsOfTracks)) as! [track_eApp]
                                
                                
                                
                                thisCategoryDictionary.setValue(thisCategory_trackArray, forKey: "playlistContents")
                                
                                let categoricalContainer_scrollViewToMod = self.view.viewWithTag((thisCategoryDictionary.value(forKey: "category_instanceID") as! Int) + 5000000) as! parameterizedScrollView
                                
                                
                                
                                categoricalContainer_scrollViewToMod.backgroundColor = UIColor.clear
                                
                                
                                var dictionary_horizontalStacking_categorySongViews = [String : Any]()
                                var horiz_stringForStacking = "H:|-(==10@900)-"
                                
                                //This line is just to simplify the text; now it just says "songs" to refer to the variable
                                
                                
                                let songs = (thisCategoryDictionary.value(forKey: "playlistContents") as! [track_eApp])
                                for j in 0...songs.count-1{
                                    
                                    let song = songs[j]
                                    
                                    let assocTrk = song
                                    
                                    //This is just updating one property of each song
                                    assocTrk.sourceType = "featuredContent"
                                    
                                    
                                    let catTrack_containerView = parameterizedView()
                                    
                                    catTrack_containerView.backgroundColor = UIColor.clear
                                    
                                    
                                    
                                    
                                    
                                    categoricalContainer_scrollViewToMod.addSubview(catTrack_containerView)
                                    catTrack_containerView.translatesAutoresizingMaskIntoConstraints = false
                                    
                                    
                                    
                                    
                                    
                                    //categoricalContainer_scrollViewToMod.addConstraint(parameterizedNSLayoutConstraint(item: categoricalContainer_scrollViewToMod, attribute: .left, relatedBy: .equal, toItem: catTrack_imageView, attribute: .left, multiplier: (1), constant: 0))
                                    
                                    
                                    categoricalContainer_scrollViewToMod.addConstraint(parameterizedNSLayoutConstraint(item: categoricalContainer_scrollViewToMod, attribute: .top, relatedBy: .equal, toItem: catTrack_containerView, attribute: .top, multiplier: (1), constant: -5))
                                    
                                    categoricalContainer_scrollViewToMod.addConstraint(parameterizedNSLayoutConstraint(item: categoricalContainer_scrollViewToMod, attribute: .bottom, relatedBy: .equal, toItem: catTrack_containerView, attribute: .bottom, multiplier: (1), constant: 0))
                                    
                                    categoricalContainer_scrollViewToMod.addConstraint(parameterizedNSLayoutConstraint(item: categoricalContainer_scrollViewToMod, attribute: .height, relatedBy: .equal, toItem: catTrack_containerView, attribute: .height, multiplier: (1), constant: 10))
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_containerView, attribute: .height, relatedBy: .equal, toItem: catTrack_containerView, attribute: .width, multiplier: (1), constant: 40))
                                    
                                    
                                    //Add two labels and an imageView to each track container
                                    
                                    
                                    //Image
                                    let catTrack_imageView = parameterizedImageView()
                                    
                                    catTrack_imageView.backgroundColor = UIColor.clear
                                    
                                    catTrack_containerView.addSubview(catTrack_imageView)
                                    catTrack_imageView.translatesAutoresizingMaskIntoConstraints = false
                                    
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_containerView, attribute: .top, relatedBy: .equal, toItem: catTrack_imageView, attribute: .top, multiplier: (1), constant: 0))
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_containerView, attribute: .left, relatedBy: .equal, toItem: catTrack_imageView, attribute: .left, multiplier: (1), constant: 0))
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_containerView, attribute: .right, relatedBy: .equal, toItem: catTrack_imageView, attribute: .right, multiplier: (1), constant: 0))
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_containerView, attribute: .width, relatedBy: .equal, toItem: catTrack_imageView, attribute: .width, multiplier: (1), constant: 0))
                                    
                                    catTrack_imageView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_imageView, attribute: .height, relatedBy: .equal, toItem: catTrack_imageView, attribute: .width, multiplier: (1), constant: 0))
                                    
                                    
                                    catTrack_imageView.image = #imageLiteral(resourceName: "tracks_w")
                                    catTrack_imageView.contentMode = .center
                                    
                                    
                                    SDWebImageDownloader.shared().downloadImage(with: URL(string: song.albumArtURL!), options: .highPriority, progress:nil, completed: {
                                        (image, error, cacheType, url) in
                                        
                                        
                                        catTrack_imageView.image = image//.setImage(image, for: .normal)
                                        catTrack_imageView.contentMode = .scaleAspectFill
                                        
                                        
                                        
                                        
                                    })
                                    
                                    
                                    //morebutton
                                    let catTrack_moreButton = parameterizedButton()
                                    
                                    //catTrack_moreButton.backgroundColor = UIColor.yellow
                                    catTrack_moreButton.backgroundColor = UIColor.clear
                                    catTrack_moreButton.setImage(#imageLiteral(resourceName: "more_g_padded"), for: .normal)
                                    
                                    catTrack_containerView.addSubview(catTrack_moreButton)
                                    catTrack_moreButton.translatesAutoresizingMaskIntoConstraints = false
                                    
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_moreButton, attribute: .top, relatedBy: .equal, toItem: catTrack_imageView, attribute: .bottom, multiplier: (1), constant: 0))
                                    
                                    
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_containerView, attribute: .trailing, relatedBy: .equal, toItem: catTrack_moreButton, attribute: .trailing, multiplier: (1), constant: 0))
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_containerView, attribute: .bottom, relatedBy: .equal, toItem: catTrack_moreButton, attribute: .bottom, multiplier: (1), constant: 0))
                                    
                                    catTrack_moreButton.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_moreButton, attribute: .width, relatedBy: .equal, toItem: catTrack_moreButton, attribute: .height, multiplier: (1), constant: 0))
                                    
                                    //catTrack_topLabel.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_topLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 10))
                                    
                                    catTrack_moreButton.associatedTrk = assocTrk
                                    
                                    catTrack_moreButton.addTarget(self, action: #selector(ViewController.moreButton_catTrk(_:)), for: .touchUpInside)
                                    
                                    
                                    
                                    
                                    let catTrack_topLabel = parameterizedLabel()
                                    
                                    catTrack_topLabel.backgroundColor = UIColor.clear
                                    catTrack_topLabel.textColor = UIColor.white
                                    catTrack_topLabel.font = UIFont.systemFont(ofSize: 15)
                                    catTrack_topLabel.text = song.name!
                                    
                                    catTrack_containerView.addSubview(catTrack_topLabel)
                                    catTrack_topLabel.translatesAutoresizingMaskIntoConstraints = false
                                    
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_topLabel, attribute: .top, relatedBy: .equal, toItem: catTrack_imageView, attribute: .bottom, multiplier: (1), constant: 0))
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_containerView, attribute: .leading, relatedBy: .equal, toItem: catTrack_topLabel, attribute: .leading, multiplier: (1), constant: 0))
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_moreButton, attribute: .leading, relatedBy: .equal, toItem: catTrack_topLabel, attribute: .trailing, multiplier: (1), constant: 0))
                                    
                                    //catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_containerView, attribute: .width, relatedBy: .equal, toItem: catTrack_topLabel, attribute: .width, multiplier: (1), constant: 0))
                                    //catTrack_topLabel.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_topLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 10))
                                    
                                    
                                    //Label2
                                    let catTrack_bottomLabel = parameterizedLabel()
                                    
                                    catTrack_bottomLabel.backgroundColor = UIColor.clear
                                    catTrack_bottomLabel.textColor = UIColor.lightGray
                                    catTrack_bottomLabel.font = UIFont.systemFont(ofSize: 12)
                                    catTrack_bottomLabel.text = song.artistString!
                                    
                                    catTrack_containerView.addSubview(catTrack_bottomLabel)
                                    catTrack_bottomLabel.translatesAutoresizingMaskIntoConstraints = false
                                    
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_bottomLabel, attribute: .top, relatedBy: .equal, toItem: catTrack_topLabel, attribute: .bottom, multiplier: (1), constant: 0))
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_containerView, attribute: .leading, relatedBy: .equal, toItem: catTrack_bottomLabel, attribute: .leading, multiplier: (1), constant: 0))
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_containerView, attribute: .bottom, relatedBy: .equal, toItem: catTrack_bottomLabel, attribute: .bottom, multiplier: (1), constant: 0))
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_topLabel, attribute: .height, relatedBy: .equal, toItem: catTrack_bottomLabel, attribute: .height, multiplier: (1), constant: 0))
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_moreButton, attribute: .leading, relatedBy: .equal, toItem: catTrack_bottomLabel, attribute: .trailing, multiplier: (1), constant: 0))
                                    
                                    
                                    
                                    //Add button for action on catTrk
                                    
                                    let catTrack_button = parameterizedButton()
                                    
                                    catTrack_button.backgroundColor = UIColor.clear
                                    
                                    
                                    catTrack_containerView.addSubview(catTrack_button)
                                    catTrack_button.translatesAutoresizingMaskIntoConstraints = false
                                    
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_button, attribute: .centerX, relatedBy: .equal, toItem: catTrack_imageView, attribute: .centerX, multiplier: (1), constant: 0))
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_button, attribute: .centerY, relatedBy: .equal, toItem: catTrack_imageView, attribute: .centerY, multiplier: (1), constant: 0))
                                    
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_button, attribute: .width, relatedBy: .equal, toItem: catTrack_imageView, attribute: .width, multiplier: (1), constant: 0))
                                    
                                    
                                    catTrack_containerView.addConstraint(parameterizedNSLayoutConstraint(item: catTrack_button, attribute: .height, relatedBy: .equal, toItem: catTrack_imageView, attribute: .height, multiplier: (1), constant: 0))
                                    
                                    
                                    
                                    
                                    
                                    catTrack_button.associatedTrk = assocTrk
                                    
                                    catTrack_button.addTarget(self, action: #selector(ViewController.catTrk_Pressed(_:)), for: .touchUpInside)
                                    
                                    
                                    
                                    
                                    dictionary_horizontalStacking_categorySongViews.updateValue(catTrack_containerView, forKey: "trk\(j)")
                                    horiz_stringForStacking += "[trk\(j)]-(==10@900)-"
                                    
                                    
                                    
                                }
                                
                                
                                horiz_stringForStacking += "|"
                                
                                let horiz_catTrk_stackingConstraint = NSLayoutConstraint.constraints(withVisualFormat: horiz_stringForStacking, options: [], metrics: nil, views: dictionary_horizontalStacking_categorySongViews)
                                
                                categoricalContainer_scrollViewToMod.addConstraints(horiz_catTrk_stackingConstraint)
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                            }
                        }
                        
                        
                        
                        
                        
                        
//                        print(thisSet_tracks)
                
                    }, failure: { (error) in
                        print(error)
                    })
                    
                }
                
                //while dictionary_containingSetsOfTracks.allKeys.count < iterations {
                  //  print("completed iterations = \(dictionary_containingSetsOfTracks.allKeys.count)/\(iterations)")
                //}
            }, failure: { (error) in
                print(error)
            })
                    
                
            
            
        }
        
        
        
        stringForStacking += "|"
        
        let categories_stackingConstraint = NSLayoutConstraint.constraints(withVisualFormat: stringForStacking, options: [], metrics: nil, views: dictionary_categoryContainerViews)
        
        mainContent_SV.addConstraints(categories_stackingConstraint)
        
        self.view.layoutIfNeeded()
        
    }


    @objc func catTrk_Pressed(_ sender:parameterizedButton){
        consoleLog(msg: "pressed catTrk", level: 1)
        
        
        
        
        
        
        
        playNewSong(trackToPlay: sender.associatedTrk!, onlyArm: false)
        
        
        
    }
    
    @objc func moreButton_catTrk(_ sender: parameterizedButton){
        let bottomPopup = self.view.viewWithTag(76589) as! UIView
        
        let songInfoContainer = UIView()
        songInfoContainer.backgroundColor = UIColor.clear
        bottomPopup.addSubview(songInfoContainer)
        songInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        
        
        bottomPopup.addConstraint(parameterizedNSLayoutConstraint(item: bottomPopup, attribute: .top, relatedBy: .equal, toItem: songInfoContainer, attribute: .top, multiplier: (1), constant: 0))
        
        bottomPopup.addConstraint(parameterizedNSLayoutConstraint(item: bottomPopup, attribute: .leading, relatedBy: .equal, toItem: songInfoContainer, attribute: .leading, multiplier: (1), constant: 0))
        
        bottomPopup.addConstraint(parameterizedNSLayoutConstraint(item: bottomPopup, attribute: .trailing, relatedBy: .equal, toItem: songInfoContainer, attribute: .trailing, multiplier: (1), constant: 0))
        
        songInfoContainer.addConstraint(parameterizedNSLayoutConstraint(item: songInfoContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 220))
        
        let songImageView = parameterizedImageView()

        songImageView.backgroundColor = UIColor.clear
        songImageView.image = #imageLiteral(resourceName: "album_g")
        
        songInfoContainer.addSubview(songImageView)
        songImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        songInfoContainer.addConstraint(parameterizedNSLayoutConstraint(item: songImageView, attribute: .top, relatedBy: .equal, toItem: songInfoContainer, attribute: .top, multiplier: (1), constant: 10))
        
        songImageView.addConstraint(parameterizedNSLayoutConstraint(item: songImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 130))
        
        songImageView.addConstraint(parameterizedNSLayoutConstraint(item: songImageView, attribute: .height, relatedBy: .equal, toItem: songImageView, attribute: .width, multiplier: (1), constant: 0))
        
        songInfoContainer.addConstraint(parameterizedNSLayoutConstraint(item: songImageView, attribute: .centerX, relatedBy: .equal, toItem: songInfoContainer, attribute: .centerX, multiplier: (1), constant: 0))
        
        
        SDWebImageDownloader.shared().downloadImage(with: URL(string: sender.associatedTrk!.albumArtURL!), options: .highPriority, progress:nil, completed: {
            (image, error, cacheType, url) in
            
            
            songImageView.image = image//.setImage(image, for: .normal)
            songImageView.contentMode = .scaleAspectFill
            
            
            
            
        })
        
        let songTitle = parameterizedLabel()
        
        songTitle.backgroundColor = UIColor.clear
        songTitle.textAlignment = .center
        songInfoContainer.addSubview(songTitle)
        songTitle.translatesAutoresizingMaskIntoConstraints = false
        songTitle.text = sender.associatedTrk?.name
        songTitle.textColor = UIColor.white
        songTitle.font = UIFont.systemFont(ofSize: 25)
        
        songInfoContainer.addConstraint(parameterizedNSLayoutConstraint(item: songTitle, attribute: .top, relatedBy: .equal, toItem: songImageView, attribute: .bottom, multiplier: (1), constant: 10))
        
        songInfoContainer.addConstraint(parameterizedNSLayoutConstraint(item: songTitle, attribute: .leading, relatedBy: .equal, toItem: songInfoContainer, attribute: .leading, multiplier: (1), constant: 10))
        
        songInfoContainer.addConstraint(parameterizedNSLayoutConstraint(item: songTitle, attribute: .trailing, relatedBy: .equal, toItem: songInfoContainer, attribute: .trailing, multiplier: (1), constant: -10))
        
        let songArtists = parameterizedLabel()
        
        songArtists.backgroundColor = UIColor.clear
        songInfoContainer.addSubview(songArtists)
        songArtists.textAlignment = .center
        songArtists.textColor = UIColor.lightGray
        songArtists.translatesAutoresizingMaskIntoConstraints = false
        songArtists.text = sender.associatedTrk!.artistString
        songArtists.font = UIFont.systemFont(ofSize: 15)
        
        songInfoContainer.addConstraint(parameterizedNSLayoutConstraint(item: songArtists, attribute: .top, relatedBy: .equal, toItem: songTitle, attribute: .bottom, multiplier: (1), constant: 6))
        
        songInfoContainer.addConstraint(parameterizedNSLayoutConstraint(item: songArtists, attribute: .leading, relatedBy: .equal, toItem: songInfoContainer, attribute: .leading, multiplier: (1), constant: 10))
        
        songInfoContainer.addConstraint(parameterizedNSLayoutConstraint(item: songArtists, attribute: .trailing, relatedBy: .equal, toItem: songInfoContainer, attribute: .trailing, multiplier: (1), constant: -10))
        
        
        
        let addToQueueContainer = parameterizedView()
        addToQueueContainer.backgroundColor = UIColor.clear
        bottomPopup.addSubview(addToQueueContainer)
        addToQueueContainer.translatesAutoresizingMaskIntoConstraints = false
        
        bottomPopup.addConstraint(parameterizedNSLayoutConstraint(item: addToQueueContainer, attribute: .top, relatedBy: .equal, toItem: songInfoContainer, attribute: .bottom, multiplier: (1), constant: 0))
        
        bottomPopup.addConstraint(parameterizedNSLayoutConstraint(item: bottomPopup, attribute: .leading, relatedBy: .equal, toItem: addToQueueContainer, attribute: .leading, multiplier: (1), constant: 0))
        
        bottomPopup.addConstraint(parameterizedNSLayoutConstraint(item: bottomPopup, attribute: .trailing, relatedBy: .equal, toItem: addToQueueContainer, attribute: .trailing, multiplier: (1), constant: 0))
        
        addToQueueContainer.addConstraint(parameterizedNSLayoutConstraint(item: addToQueueContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 50))
        
        let addToQueue_image = parameterizedImageView()
        addToQueue_image.backgroundColor = UIColor.clear
        addToQueue_image.image = #imageLiteral(resourceName: "plus_circle_w")
        addToQueueContainer.addSubview(addToQueue_image)
        addToQueue_image.translatesAutoresizingMaskIntoConstraints = false
        
        addToQueueContainer.addConstraint(parameterizedNSLayoutConstraint(item: addToQueueContainer, attribute: .centerY, relatedBy: .equal, toItem: addToQueue_image, attribute: .centerY, multiplier: (1), constant: 0))
        
        addToQueueContainer.addConstraint(parameterizedNSLayoutConstraint(item: addToQueue_image, attribute: .leading, relatedBy: .equal, toItem: addToQueueContainer, attribute: .leading, multiplier: (1), constant: 10))
        
        addToQueue_image.addConstraint(parameterizedNSLayoutConstraint(item: addToQueue_image, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 30))
        
        addToQueue_image.addConstraint(parameterizedNSLayoutConstraint(item: addToQueue_image, attribute: .height, relatedBy: .equal, toItem: addToQueue_image, attribute: .width, multiplier: (1), constant: 0))
        
        
        
        let addToQueue_label = parameterizedLabel()
        addToQueue_label.backgroundColor = UIColor.clear
        addToQueueContainer.addSubview(addToQueue_label)
        
        addToQueue_label.textColor = UIColor.white
        addToQueue_label.translatesAutoresizingMaskIntoConstraints = false
        addToQueue_label.text = "Add to queue"
        addToQueue_label.font = UIFont.systemFont(ofSize: 18)
        
        addToQueueContainer.addConstraint(parameterizedNSLayoutConstraint(item: addToQueueContainer, attribute: .centerY, relatedBy: .equal, toItem: addToQueue_label, attribute: .centerY, multiplier: (1), constant: 0))
        
        addToQueueContainer.addConstraint(parameterizedNSLayoutConstraint(item: addToQueue_label, attribute: .leading, relatedBy: .equal, toItem: addToQueue_image, attribute: .trailing, multiplier: (1), constant: 10))
        
        addToQueueContainer.addConstraint(parameterizedNSLayoutConstraint(item: addToQueue_label, attribute: .trailing, relatedBy: .equal, toItem: addToQueueContainer, attribute: .trailing, multiplier: (1), constant: -10))
        
        
        let addToQueue_button = parameterizedButton()
        addToQueue_button.backgroundColor = UIColor.clear
        addToQueueContainer.addSubview(addToQueue_button)
        
        
        addToQueue_button.translatesAutoresizingMaskIntoConstraints = false
        
        addToQueue_button.associatedTrk = sender.associatedTrk
        
        addToQueueContainer.addConstraint(parameterizedNSLayoutConstraint(item: addToQueue_button, attribute: .centerX, relatedBy: .equal, toItem: addToQueueContainer, attribute: .centerX, multiplier: (1), constant: 0))
        
        addToQueueContainer.addConstraint(parameterizedNSLayoutConstraint(item: addToQueue_button, attribute: .centerY, relatedBy: .equal, toItem: addToQueueContainer, attribute: .centerY, multiplier: (1), constant: 0))
        
        
        addToQueueContainer.addConstraint(parameterizedNSLayoutConstraint(item: addToQueue_button, attribute: .width, relatedBy: .equal, toItem: addToQueueContainer, attribute: .width, multiplier: (1), constant: 0))
        
        
        addToQueueContainer.addConstraint(parameterizedNSLayoutConstraint(item: addToQueue_button, attribute: .height, relatedBy: .equal, toItem: addToQueueContainer
            , attribute: .height, multiplier: (1), constant: 0))
        
        addToQueue_button.addTarget(self, action: #selector(ViewController.bottomPopup_addToQueueButtonClicked(_:)), for: .touchUpInside)
        
        
        
        let cancelContainer = parameterizedView()
        cancelContainer.backgroundColor = UIColor.clear
        bottomPopup.addSubview(cancelContainer)
        cancelContainer.translatesAutoresizingMaskIntoConstraints = false
        
        bottomPopup.addConstraint(parameterizedNSLayoutConstraint(item: cancelContainer, attribute: .top, relatedBy: .equal, toItem: addToQueueContainer, attribute: .bottom, multiplier: (1), constant: 0))
        
        bottomPopup.addConstraint(parameterizedNSLayoutConstraint(item: bottomPopup, attribute: .leading, relatedBy: .equal, toItem: cancelContainer, attribute: .leading, multiplier: (1), constant: 0))
        
        bottomPopup.addConstraint(parameterizedNSLayoutConstraint(item: bottomPopup, attribute: .trailing, relatedBy: .equal, toItem: cancelContainer, attribute: .trailing, multiplier: (1), constant: 0))
        
        cancelContainer.addConstraint(parameterizedNSLayoutConstraint(item: cancelContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 50))
        
        let cancel_label = parameterizedLabel()
        cancel_label.backgroundColor = UIColor.clear
        cancelContainer.addSubview(cancel_label)
        
        cancel_label.textColor = UIColor.white
        cancel_label.translatesAutoresizingMaskIntoConstraints = false
        cancel_label.text = "Cancel"
        cancel_label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        
        cancelContainer.addConstraint(parameterizedNSLayoutConstraint(item: cancelContainer, attribute: .centerY, relatedBy: .equal, toItem: cancel_label, attribute: .centerY, multiplier: (1), constant: 0))
        
        cancelContainer.addConstraint(parameterizedNSLayoutConstraint(item: cancelContainer, attribute: .centerX, relatedBy: .equal, toItem: cancel_label, attribute: .centerX, multiplier: (1), constant: 0))
        
        
        let cancel_button = parameterizedButton()
        cancel_button.backgroundColor = UIColor.clear
        cancelContainer.addSubview(cancel_button)
        
        
        cancel_button.translatesAutoresizingMaskIntoConstraints = false
        
        
        cancelContainer.addConstraint(parameterizedNSLayoutConstraint(item: cancel_button, attribute: .centerX, relatedBy: .equal, toItem: cancelContainer, attribute: .centerX, multiplier: (1), constant: 0))
        
        cancelContainer.addConstraint(parameterizedNSLayoutConstraint(item: cancel_button, attribute: .centerY, relatedBy: .equal, toItem: cancelContainer, attribute: .centerY, multiplier: (1), constant: 0))
        
        
        cancelContainer.addConstraint(parameterizedNSLayoutConstraint(item: cancel_button, attribute: .width, relatedBy: .equal, toItem: cancelContainer, attribute: .width, multiplier: (1), constant: 0))
        
        
        cancelContainer.addConstraint(parameterizedNSLayoutConstraint(item: cancel_button, attribute: .height, relatedBy: .equal, toItem: cancelContainer
            , attribute: .height, multiplier: (1), constant: 0))
        
        
        
        
        cancel_button.addTarget(self, action: #selector(ViewController.bottomPopup_cancelButtonClicked(_:)), for: .touchUpInside)
        
        
        
        
        self.view.layoutIfNeeded()
        self.hide_mainContent_overlyingBlurView(hideBool: false)
        toggleBottomPopup(action: "show")
    }
    
    @objc func bottomPopup_cancelButtonClicked(_ sender: parameterizedButton){
        hideAll_panels(leaveBlurViewShown: false)
    }
    
    @objc func bottomPopup_addToQueueButtonClicked(_ sender: parameterizedButton){
        addSongToQueue(trkToQueue: sender.associatedTrk!)
    }
    
    
}
