//
//  ViewController_listenPage_extension.swift
//  eApp
//
//  Created by Christopher Guirguis on 5/5/18.
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
    func submit_listener_searchForBroadcaster(_ searchBar: UISearchBar){
        
        
        //**************
        print("searchingForBroadcaster")
        
        let searchBarContent = searchBar.text!
        
        
        
        var search_broadcasters_parameters = Parameters()
        search_broadcasters_parameters = addStandardParameters(emptyParameters: search_broadcasters_parameters)
        
        
        search_broadcasters_parameters.updateValue("SELECT * FROM liveListenSession WHERE broadcasterId = '\(searchBarContent)'", forKey: "argument")
        

            
            
            
            print(search_broadcasters_parameters)
            
            
            Alamofire.request("http://www.flasheducational.com/phpScripts/fetch/generalSelectBlankDBInfo.php", method: .post, parameters:search_broadcasters_parameters) .responseJSON { response in
                switch response.result {
                case .success( _):
                    consoleLog(msg: "debug:  dhfug", level: 1)
                    let broadcasterResults = (response.result.value! as! NSArray)
                    clearViewOfSubviews(viewToClear: self.listener_SearchForBroadcaster_resultsSV)
                    
                    
                    var dictionary_broadcasterResults_containers = [String : Any]()
                    var stringForStacking = "V:|-(==0@900)-"
                    
                    
                    for m in 0...broadcasterResults.count-1{
                        let thisBroadcaster = broadcasterResults[m] as! NSDictionary
                        let this_liveListenSessionID = thisBroadcaster["id"]!
                        let this_liveListenSession_broadcasterId = thisBroadcaster["broadcasterId"]!
                        let this_liveListenSession_onlineStatus = thisBroadcaster["onlineStatus"]! as! String
                        print("Share this number: \(this_liveListenSessionID)")
                        print("BCID: \(this_liveListenSession_broadcasterId)")
                        
                        
                        
                        
                        
                        
                        
                        let containerHeight = CGFloat(70)
                        let buttonPadding = CGFloat(24)
                        
                        
                        let broadcaster_container = parameterizedView()
                        
                        broadcaster_container.backgroundColor = UIColor.clear
                        //broadcaster_container.alpha = 1 - (CGFloat(m) * 0.10)
                        
                        
                        self.listener_SearchForBroadcaster_resultsSV.addSubview(broadcaster_container)
                        broadcaster_container.translatesAutoresizingMaskIntoConstraints = false
                        
                        self.listener_SearchForBroadcaster_resultsSV.addConstraint(parameterizedNSLayoutConstraint(item: self.listener_SearchForBroadcaster_resultsSV, attribute: .centerX, relatedBy: .equal, toItem: broadcaster_container, attribute: .centerX, multiplier: (1), constant: 0))
                        self.listener_SearchForBroadcaster_resultsSV.addConstraint(parameterizedNSLayoutConstraint(item: self.listener_SearchForBroadcaster_resultsSV, attribute: .width, relatedBy: .equal, toItem: broadcaster_container, attribute: .width, multiplier: (1), constant: 0))
                        broadcaster_container.addConstraint(parameterizedNSLayoutConstraint(item: broadcaster_container, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: containerHeight))
                        
                        
                        
                       
                        
                        //Add more button
                        let broadcaster_moreButton = parameterizedImageView()
                        
                        broadcaster_moreButton.contentMode = .scaleAspectFit
                        broadcaster_moreButton.translatesAutoresizingMaskIntoConstraints = false
                        //broadcaster_moreButton.image = #imageLiteral(resourceName: "rightArrow_w")
                        broadcaster_container.addSubview(broadcaster_moreButton)
                        
                        broadcaster_container.addConstraint(parameterizedNSLayoutConstraint(item: broadcaster_container, attribute: .trailing, relatedBy: .equal, toItem: broadcaster_moreButton, attribute: .trailing, multiplier: (1), constant: buttonPadding))
                        broadcaster_container.addConstraint(parameterizedNSLayoutConstraint(item: broadcaster_container, attribute: .top, relatedBy: .equal, toItem: broadcaster_moreButton, attribute: .top, multiplier: (1), constant: -1*buttonPadding))
                        broadcaster_container.addConstraint(parameterizedNSLayoutConstraint(item: broadcaster_container, attribute: .bottom, relatedBy: .equal, toItem: broadcaster_moreButton, attribute: .bottom, multiplier: (1), constant: buttonPadding))
                        broadcaster_moreButton.addConstraint(parameterizedNSLayoutConstraint(item: broadcaster_moreButton, attribute: .height, relatedBy: .equal, toItem: broadcaster_moreButton, attribute: .width, multiplier: (1), constant: 0))
                        
                        
                        
                        //Add labels
                        
                        
                        
                        
                        let broadcaster_nameLabel = parameterizedLabel()
                        
                        broadcaster_nameLabel.font = UIFont.systemFont(ofSize: 20)
                        broadcaster_nameLabel.textColor = UIColor.white
                        broadcaster_nameLabel.translatesAutoresizingMaskIntoConstraints = false
                        broadcaster_container.addSubview(broadcaster_nameLabel)
                        
                        
                        let broadcaster_lastActive = parameterizedLabel()
                        
                        
                        broadcaster_lastActive.translatesAutoresizingMaskIntoConstraints = false
                        broadcaster_container.addSubview(broadcaster_lastActive)
                        
                        
                        broadcaster_nameLabel.text = thisBroadcaster["broadcasterId"] as? String
                        
                        
                        
                        
                        broadcaster_container.addConstraint(parameterizedNSLayoutConstraint(item: broadcaster_container, attribute: .leading, relatedBy: .equal, toItem: broadcaster_nameLabel, attribute: .leading, multiplier: (1), constant: -10))
                        broadcaster_container.addConstraint(parameterizedNSLayoutConstraint(item: broadcaster_moreButton, attribute: .leading, relatedBy: .equal, toItem: broadcaster_nameLabel, attribute: .trailing, multiplier: (1), constant: 25))
                        
                        broadcaster_container.addConstraint(parameterizedNSLayoutConstraint(item: broadcaster_container, attribute: .leading, relatedBy: .equal, toItem: broadcaster_lastActive, attribute: .leading, multiplier: (1), constant: -10))
                        broadcaster_container.addConstraint(parameterizedNSLayoutConstraint(item: broadcaster_moreButton, attribute: .leading, relatedBy: .equal, toItem: broadcaster_lastActive, attribute: .trailing, multiplier: (1), constant: 25))
                        
                        
                        let broad_internalContentsDict = ["broadcaster_lastActive": broadcaster_lastActive,"broadcaster_nameLabel": broadcaster_nameLabel] as [String : Any]
                        let stringFor_broad_Stacking = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==6@900)-[broadcaster_nameLabel]-(==4@900)-[broadcaster_lastActive]-(==10@900)-|", options: [], metrics: nil, views: broad_internalContentsDict)
                        
                        broadcaster_container.addConstraints(stringFor_broad_Stacking)
                        
                        
                        
                        //***********here
                        
                        
                        
                        let thisBroadcaster_lastActive = thisBroadcaster["lastActive"]! as! String
                        let thisBroadcaster_lastActive_atrArray = timeString_toAtrArray(thisBroadcaster_lastActive)
                        print(thisBroadcaster_lastActive_atrArray)
                        
                        let currentTime_atrArray = timeString_toAtrArray(String(describing: Date(timeIntervalSinceNow: 0)))
                        print(currentTime_atrArray)
                        
                        let deltaTime_atrArray = delta_times(time1: currentTime_atrArray, time2: thisBroadcaster_lastActive_atrArray)
                        let deltaTime_seconds = time_atrArray_sThroughD_to_seconds(deltaTime_atrArray)
                        print("time since last active: \(deltaTime_seconds) seconds")
                        
                        
                        
                        if abs(deltaTime_seconds) <= 60 && this_liveListenSession_onlineStatus == "online"{
                            
                            broadcaster_lastActive.text = "Active now"
                            broadcaster_lastActive.textColor = UIColor.init(red: 28/255, green: 188/255, blue: 55/255, alpha: 1)
                            
                            broadcaster_moreButton.backgroundColor = UIColor.init(red: 28/255, green: 188/255, blue: 55/255, alpha: 1)
                            
                            
                            
                            let broadcaster_overlyingButton = parameterizedButton()
                            broadcaster_overlyingButton.backgroundColor = UIColor.clear
                            //broadcaster_overlyingButton.alpha = 0.1
                            
                            broadcaster_container.addSubview(broadcaster_overlyingButton)
                            broadcaster_overlyingButton.translatesAutoresizingMaskIntoConstraints = false
                            broadcaster_container.addConstraint(parameterizedNSLayoutConstraint(item: broadcaster_container, attribute: .top, relatedBy: .equal, toItem: broadcaster_overlyingButton, attribute: .top, multiplier: (1), constant: 0))
                            broadcaster_container.addConstraint(parameterizedNSLayoutConstraint(item: broadcaster_container, attribute: .bottom, relatedBy: .equal, toItem: broadcaster_overlyingButton, attribute: .bottom, multiplier: (1), constant: 0))
                            broadcaster_container.addConstraint(parameterizedNSLayoutConstraint(item: broadcaster_container, attribute: .left, relatedBy: .equal, toItem: broadcaster_overlyingButton, attribute: .left, multiplier: (1), constant: 0))
                            broadcaster_container.addConstraint(parameterizedNSLayoutConstraint(item: broadcaster_container, attribute: .right, relatedBy: .equal, toItem: broadcaster_overlyingButton, attribute: .right, multiplier: (1), constant: 0))
                            broadcaster_overlyingButton.arrayTagForPass.append(thisBroadcaster)
                            
                            broadcaster_overlyingButton.addTarget(self, action: #selector(ViewController.activate_listeningMode(_:)), for: .touchUpInside)
                            
                            
                        } else {
                            let minutes_sinceLastActive = secondsToHoursMinutesSeconds(seconds: abs(deltaTime_seconds))
                            broadcaster_lastActive.text = "Last active \(minutes_sinceLastActive.1) minutes ago"
                            broadcaster_lastActive.textColor = UIColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
                            
                            broadcaster_moreButton.backgroundColor = UIColor.darkGray
                        }
                        
                        
                        
                        
                        
                        
                        //***********here end
                        
                        
                        self.view.layoutIfNeeded()
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        dictionary_broadcasterResults_containers.updateValue(broadcaster_container, forKey: "broadItem\(m)")
                        stringForStacking += "[broadItem\(m)]-(==0@900)-"
                        
                        
                        broadcaster_moreButton.layer.cornerRadius = (containerHeight - (2*buttonPadding))/2
                        
                        
                        
                        
                        
                        
                    }
                    
                    stringForStacking += "|"
                    let broad_VertStackingConstraint = NSLayoutConstraint.constraints(withVisualFormat: stringForStacking, options: [], metrics: nil, views: dictionary_broadcasterResults_containers)
                    
                    self.listener_SearchForBroadcaster_resultsSV.addConstraints(broad_VertStackingConstraint)
                    
                    self.view.layoutIfNeeded()
                    
                    
                    
                    
                    
                case .failure(let error):
                    print("error: \(error)")
                    clearViewOfSubviews(viewToClear: self.listener_SearchForBroadcaster_resultsSV)
                    
                    let failureNotification_label = parameterizedLabel()
                    
                    failureNotification_label.backgroundColor = UIColor.clear
                    failureNotification_label.textColor = UIColor.darkGray
                    failureNotification_label.numberOfLines = 0
                    failureNotification_label.text = "No results were found for the user you entered"
                    failureNotification_label.textAlignment = .center
                    
                    
                    self.listener_SearchForBroadcaster_resultsSV.addSubview(failureNotification_label)
                    failureNotification_label.translatesAutoresizingMaskIntoConstraints = false
                    
                    self.listener_SearchForBroadcaster_resultsSV.addConstraint(parameterizedNSLayoutConstraint(item: self.listener_SearchForBroadcaster_resultsSV, attribute: .centerX, relatedBy: .equal, toItem: failureNotification_label, attribute: .centerX, multiplier: (1), constant: 0))
                    self.listener_SearchForBroadcaster_resultsSV.addConstraint(parameterizedNSLayoutConstraint(item: failureNotification_label, attribute: .width, relatedBy: .equal, toItem: self.listener_SearchForBroadcaster_resultsSV, attribute: .width, multiplier: (1), constant: -150))
                    self.listener_SearchForBroadcaster_resultsSV.addConstraint(parameterizedNSLayoutConstraint(item: self.listener_SearchForBroadcaster_resultsSV, attribute: .centerY, relatedBy: .equal, toItem: failureNotification_label, attribute: .centerY, multiplier: (1), constant: 80))
                    
                    self.view.layoutIfNeeded()
                }
            
            
        }
    
        
        
       
    }
    
    
    @objc func activate_listeningMode(_ sender: parameterizedButton){
        self.view.endEditing(true)
        thisListeningSession_id = Int(((sender.arrayTagForPass[0] as! NSDictionary)["id"] as! String))!
        
        isListening = true
        print("activating listening mode")
        listener_refreshTimer = Timer.scheduledTimer(timeInterval: 2.1, target: self, selector: #selector(activeListener_refreshData), userInfo: nil, repeats: true)
        
            let listeningMode_viewContainer = UIView()
            listeningMode_viewContainer.backgroundColor = UIColor.clear
            listeningMode_viewContainer.tag = 55674839
            listeningMode_viewContainer.alpha = 0
            
        
            self.view.addSubview(listeningMode_viewContainer)
            listeningMode_viewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        
            
            
            
            self.view.addConstraint(parameterizedNSLayoutConstraint(item: search_dropdownView, attribute: .top, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .top, multiplier: (1), constant: 0))
            self.view.addConstraint(parameterizedNSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .bottom, multiplier: (1), constant: 0))
            self.view.addConstraint(parameterizedNSLayoutConstraint(item: self.view, attribute: .left, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .left, multiplier: (1), constant: 0))
            self.view.addConstraint(parameterizedNSLayoutConstraint(item: self.view, attribute: .right, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .right, multiplier: (1), constant: 0))
        
        
        let listeningMode_blurView = UIVisualEffectView()
        listeningMode_blurView.effect = UIBlurEffect(style: .light)
        listeningMode_viewContainer.addSubview(listeningMode_blurView)
        
        listeningMode_blurView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(parameterizedNSLayoutConstraint(item: self.view, attribute: .centerX, relatedBy: .equal, toItem: listeningMode_blurView, attribute: .centerX, multiplier: (1), constant: 0))
        self.view.addConstraint(parameterizedNSLayoutConstraint(item: self.view, attribute: .centerY, relatedBy: .equal, toItem: listeningMode_blurView, attribute: .centerY, multiplier: (1), constant: 0))
        self.view.addConstraint(parameterizedNSLayoutConstraint(item: self.view, attribute: .width, relatedBy: .equal, toItem: listeningMode_blurView, attribute: .width, multiplier: (1), constant: 0))
        self.view.addConstraint(parameterizedNSLayoutConstraint(item: self.view, attribute: .height, relatedBy: .equal, toItem: listeningMode_blurView, attribute: .height, multiplier: (1), constant: 0))
        
        
        
            //Add image
            let listeningMode_albumArt = parameterizedImageView()
            listeningMode_albumArt.tag = 4377579
            listeningMode_albumArt.backgroundColor = UIColor.darkGray//UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
            //resultViewInstance.clipsToBounds = true
        
            listeningMode_viewContainer.addSubview(listeningMode_albumArt)
            listeningMode_albumArt.translatesAutoresizingMaskIntoConstraints = false
            
            listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_albumArt, attribute: .centerX, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .centerX, multiplier: (1), constant: 0))
            
            listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_albumArt, attribute: .centerY, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .centerY, multiplier: (1), constant: -80))
            
            listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_albumArt, attribute: .width, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .width, multiplier: (1), constant: -150))
            
            listeningMode_albumArt.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_albumArt, attribute: .width, relatedBy: .equal, toItem: listeningMode_albumArt, attribute: .height, multiplier: (1), constant: 0))
        
        //Add labels
        let listeningMode_songNameLabel = MarqueeLabel()
        listeningMode_songNameLabel.fadeLength = 10.0
        listeningMode_songNameLabel.animationDelay = 5.0
        listeningMode_songNameLabel.tag = 211235
        listeningMode_songNameLabel.textColor = UIColor.black
        listeningMode_songNameLabel.numberOfLines = 0
        listeningMode_songNameLabel.text = "..."
        listeningMode_songNameLabel.textAlignment = .center
        listeningMode_songNameLabel.font = UIFont.systemFont(ofSize: 25)
        
        
        listeningMode_viewContainer.addSubview(listeningMode_songNameLabel)
        listeningMode_songNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_songNameLabel, attribute: .centerX, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .centerX, multiplier: (1), constant: 0))
        
        listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_songNameLabel, attribute: .width, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .width, multiplier: (1), constant: -100))
        
        listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_songNameLabel, attribute: .top, relatedBy: .equal, toItem: listeningMode_albumArt, attribute: .bottom, multiplier: (1), constant: 50))
        
        
        let listeningMode_artistNameLabel = MarqueeLabel()
        listeningMode_artistNameLabel.fadeLength = 10.0
        listeningMode_artistNameLabel.tag = 8994635
        listeningMode_artistNameLabel.textColor = UIColor.darkGray
        listeningMode_artistNameLabel.numberOfLines = 0
        listeningMode_artistNameLabel.text = "..."
        listeningMode_artistNameLabel.textAlignment = .center
        listeningMode_artistNameLabel.font = UIFont.systemFont(ofSize: 18)
        
        
        listeningMode_viewContainer.addSubview(listeningMode_artistNameLabel)
        listeningMode_artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_artistNameLabel, attribute: .centerX, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .centerX, multiplier: (1), constant: 0))
        
        listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_artistNameLabel, attribute: .width, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .width, multiplier: (1), constant: -100))
        
        listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_artistNameLabel, attribute: .top, relatedBy: .equal, toItem: listeningMode_songNameLabel, attribute: .bottom, multiplier: (1), constant: 4))
        
        let listeningMode_broadcasterLabel = LTMorphingLabel()
        listeningMode_broadcasterLabel.tag = 7436565773
        listeningMode_broadcasterLabel.textColor = UIColor.darkGray
        listeningMode_broadcasterLabel.numberOfLines = 0
        listeningMode_broadcasterLabel.text = "Listening with " + ((sender.arrayTagForPass[0] as! NSDictionary)["broadcasterId"] as! String)
        
        listeningMode_broadcasterLabel.textAlignment = .center
        listeningMode_broadcasterLabel.font = UIFont.systemFont(ofSize: 14)
        
        
        listeningMode_viewContainer.addSubview(listeningMode_broadcasterLabel)
        listeningMode_broadcasterLabel.translatesAutoresizingMaskIntoConstraints = false
        
        listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_broadcasterLabel, attribute: .centerX, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .centerX, multiplier: (1), constant: 0))
        
        listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_broadcasterLabel, attribute: .width, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .width, multiplier: (1), constant: -100))
        
        listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_broadcasterLabel, attribute: .bottom, relatedBy: .equal, toItem: listeningMode_albumArt, attribute: .top, multiplier: (1), constant: -14))
        
        
        
        
        
        
        let listeningMode_deactivateButton = parameterizedButton()
        listeningMode_deactivateButton.tag = 2343743
        listeningMode_deactivateButton.setImage(#imageLiteral(resourceName: "x_b"), for: .normal)
        
        listeningMode_deactivateButton.backgroundColor = UIColor.clear//UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        //resultViewInstance.clipsToBounds = true
        
        listeningMode_viewContainer.addSubview(listeningMode_deactivateButton)
        listeningMode_deactivateButton.translatesAutoresizingMaskIntoConstraints = false
        
        listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_deactivateButton, attribute: .top, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .top, multiplier: (1), constant: 15))
        
        listeningMode_viewContainer.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_deactivateButton, attribute: .right, relatedBy: .equal, toItem: listeningMode_viewContainer, attribute: .right, multiplier: (1), constant: -15))
        
        listeningMode_deactivateButton.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_deactivateButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 35))
        listeningMode_deactivateButton.addConstraint(parameterizedNSLayoutConstraint(item: listeningMode_deactivateButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 35))
        listeningMode_deactivateButton.addTarget(self, action: #selector(ViewController.deactivate_listeningMode(_:)), for: .touchUpInside)
      
            
        
        
        
        
        
        
        let customTitleView = self.navigationController?.view.viewWithTag(68395) as! LTMorphingLabel
        customTitleView.text = "Listening mode"
        self.navigationItem.rightBarButtonItem = nil
        
        
            self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: {
            
            listeningMode_viewContainer.alpha = 1
            
        }, completion: nil)
            
        
        
    }
    
    @objc func deactivate_listeningMode(_ sender: parameterizedButton?){
        
        self.player?.setIsPlaying(false, callback: nil)
        
        isListening = false
        thisListeningSession_id = -1
        thisListeningSession_mostRecent_songURI = ""
        listener_refreshTimer.invalidate()
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: {
            
            self.view.viewWithTag(55674839)?.alpha = 0
            
        }, completion: {
            (thisParam: Bool) in
            
            if thisParam {
                let customTitleView = self.navigationController?.view.viewWithTag(68395) as! LTMorphingLabel
                customTitleView.text = "Listen"
                clearViewOfSubviews(viewToClear: self.view.viewWithTag(55674839)!)
                self.setup_barButton()
                self.view.viewWithTag(55674839)?.removeFromSuperview()
            }
            
        })
    }
    
    @objc func activeListener_refreshData(){
        if thisListeningSession_id != -1 {
            let listeningMode_songNameLabel = self.view.viewWithTag(211235) as! UILabel
            let listeningMode_artistNameLabel = self.view.viewWithTag(8994635) as! UILabel

        var select_activeListener_data_parameters = Parameters()
        select_activeListener_data_parameters = addStandardParameters(emptyParameters: select_activeListener_data_parameters)
        
        
        select_activeListener_data_parameters.updateValue("SELECT * FROM liveListenSession WHERE id = '\(thisListeningSession_id)'", forKey: "argument")
        
        
        
        
        
        print(select_activeListener_data_parameters)
        
        
        Alamofire.request("http://www.flasheducational.com/phpScripts/fetch/generalSelectBlankDBInfo.php", method: .post, parameters:select_activeListener_data_parameters) .responseJSON { response in
            switch response.result {
            case .success( _):
                consoleLog(msg: "debug:  fgjdfgjks", level: 1)
                let broadcasterResults = (response.result.value! as! NSArray)
                
                
                if broadcasterResults.count == 1 {
                    let thisBroadcaster = broadcasterResults[0] as! NSDictionary
                    let this_liveListenSessionID = thisBroadcaster["id"]!
                    let this_liveListenSession_broadcasterId = thisBroadcaster["broadcasterId"]!
                    let this_liveListenSession_currentSongURI = String(describing: thisBroadcaster["currentSong"]!)
                    let this_liveListenSession_finishTime = String(describing: thisBroadcaster["estimateEndTime"]!)
                    let this_liveListenSession_songDuration = String(describing: thisBroadcaster["currentSongDuration"]!)
                    let this_liveListenSession_playerStatus = String(describing: thisBroadcaster["playerStatus"]!)
                    let this_liveListenSession_onlineStatus = String(describing: thisBroadcaster["onlineStatus"]!)
                    
                    print("Listening to session: \(this_liveListenSessionID)")
                    print("Listening to user: \(this_liveListenSession_broadcasterId)")
                    print("Listening to songURI: \(this_liveListenSession_currentSongURI)")
                    
                    
                    
                    //Look for broadcaster going offline HERE with and if statement using this that will trigger this function deactivate_listeningMode
                    
                    
                    let currentTime_atrArray = timeString_toAtrArray(String(describing: Date(timeIntervalSinceNow: 0)))
                    print(currentTime_atrArray)
                    
                    let finishTime_atrArray = timeString_toAtrArray(this_liveListenSession_finishTime)
                    print(finishTime_atrArray)
                    
                    let deltaTime_atrArray = delta_times(time1: currentTime_atrArray, time2: finishTime_atrArray)
                    let deltaTime_seconds = time_atrArray_sThroughD_to_seconds(deltaTime_atrArray)
                    print("Time left in song: \(deltaTime_seconds)")
                    
                    let broadcaster_positionInSong = Double(this_liveListenSession_songDuration)! - Double(deltaTime_seconds)
                    print("broadcaster_positionInSong: \(broadcaster_positionInSong)")
                    
                    
                    //This checks for lastactive time from current, in seconds
                    let thisBroadcaster_lastActive = thisBroadcaster["lastActive"]! as! String
                    let thisBroadcaster_lastActive_atrArray = timeString_toAtrArray(thisBroadcaster_lastActive)
                    print(thisBroadcaster_lastActive_atrArray)
                    
                    
                    
                    let deltaTime_atrArray2 = delta_times(time1: currentTime_atrArray, time2: thisBroadcaster_lastActive_atrArray)  
                    let deltaTime_seconds2 = time_atrArray_sThroughD_to_seconds(deltaTime_atrArray2)
                    print("time since last active: \(deltaTime_seconds2) seconds")
                    
                    
                    
                    if abs(deltaTime_seconds2) > 60 || this_liveListenSession_onlineStatus == "offline"{
                    
                    
                        self.deactivate_listeningMode(nil)
                        
                    } else {
                    
                        
                        let finishTime_atrArray = timeString_toAtrArray(this_liveListenSession_finishTime)
                        print(finishTime_atrArray)
                        
                        let deltaTime_atrArray = delta_times(time1: currentTime_atrArray, time2: finishTime_atrArray)
                        let deltaTime_seconds = time_atrArray_sThroughD_to_seconds(deltaTime_atrArray)
                        print("Time left in song: \(deltaTime_seconds)")
                        
                        let broadcaster_positionInSong = Double(this_liveListenSession_songDuration)! - Double(deltaTime_seconds)
                        print("broadcaster_positionInSong: \(broadcaster_positionInSong)")
                        
                        if self.thisListeningSession_mostRecent_songURI == this_liveListenSession_currentSongURI {
                            
                            let listener_positionInSong = (self.player?.playbackState.position)!
                            
                            let delta_positionInSong_double = Double(listener_positionInSong) - Double(broadcaster_positionInSong)
                            let delta_positionInSong_absInt = abs(Int(delta_positionInSong_double.roundTo(0)))
                            print("delta position double: \(delta_positionInSong_double)")
                            print("delta position absInt: \(delta_positionInSong_absInt)")
                            if this_liveListenSession_playerStatus == "paused" {
                                self.player?.setIsPlaying(false, callback: nil)
                                
                            } else {
                                if delta_positionInSong_absInt >= 3 {
                                    
                                    self.player?.seek(to: broadcaster_positionInSong, callback: { (error) in
                                        if (error != nil) {
                                            print("realigned to broadcaster")
                                            print(self.player?.metadata.currentTrack?.name)
                                        }
                                        
                                        print("move player position")
                                        self.player?.setIsPlaying(true, callback: nil)
                                        
                                        
                                        
                                    })
                                }
                            }
                            
                        } else {
                            consoleLog(msg: "updating activeListener current song info", level: 1)
                            self.thisListeningSession_mostRecent_songURI = this_liveListenSession_currentSongURI
                            _ = Spartan.getTrack(id: String(describing: this_liveListenSession_currentSongURI.split(separator: ":")[2]), success:{ (fetchedTrack: SimplifiedTrack) in
                                
                                listeningMode_songNameLabel.text = fetchedTrack.name
                                listeningMode_artistNameLabel.text = artists_toArtistString(fetchedTrack.artists)
                                
                                
                                
                                let trackToPlay = track_eApp(isFromQueue: false, isSuggestion: false, suggestor: "listening")
                                trackToPlay.name = fetchedTrack.name
                                trackToPlay.artistString = artists_toArtistString(fetchedTrack.artists)
                                trackToPlay.uri = fetchedTrack.uri
                                trackToPlay.sourceType = "listeningMode"
                                trackToPlay.source_name = "Listening Mode"
                                
                                
                                
                                
                                
                                print("playing track")
                                
                                 self.playNewSong(trackToPlay: trackToPlay, onlyArm: false, position: TimeInterval(broadcaster_positionInSong))
                                
                            }, failure: { (error) in
                                print(error)
                            })
                            
                            
                        }
                    }
                    
                } else {
                    consoleLog(msg: "error: count is \(broadcasterResults.count)", level: 1)
                }
                
                
                
            case .failure(let error):
                print("error: \(error)")
                
            }
            
            
        }
        }
        
    }
    
    
    
}
