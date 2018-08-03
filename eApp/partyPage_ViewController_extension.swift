//
//  partyPage_ViewController_extension.swift
//  eApp
//
//  Created by Christopher Guirguis on 7/23/18.
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
    func submit_searchForParty(_ searchBar: UISearchBar){
        
        
        //**************
        print("searchingForParty")
        
        let searchBarContent = searchBar.text!
        
        
        
        var search_party_parameters = Parameters()
        search_party_parameters = addStandardParameters(emptyParameters: search_party_parameters)
        
        
        search_party_parameters.updateValue("SELECT * FROM liveListenSession WHERE partyName = '\(searchBarContent)' OR broadcasterId = '\(searchBarContent)'", forKey: "argument")
        
        
        
        
        
        print(search_party_parameters)
        
        
        Alamofire.request("http://www.flasheducational.com/phpScripts/fetch/generalSelectBlankDBInfo.php", method: .post, parameters:search_party_parameters) .responseJSON { response in
            switch response.result {
            case .success( _):
                let partyResults = (response.result.value! as! NSArray)
                
                
                //This section will just check to make sure that even if a party is found, it's still active
                
                var minimum_onePartyIsActive = false
                for m in 0...partyResults.count-1{
                    let thisParty = partyResults[m] as! NSDictionary
                    
                    let partyStatus = thisParty["partyStatus"]! as! String
                    
                    if partyStatus == "active" {
                        print(partyStatus)
                        minimum_onePartyIsActive = true
                        
                        print("foundActiveParty")
                    }
                    
                }
                consoleLog(msg: "debug:  dhfug", level: 1)
                
                
                if minimum_onePartyIsActive {
                    clearViewOfSubviews(viewToClear: self.party_searchForParty_resultsSV)
                    
                    
                    var dictionary_partyResults_containers = [String : Any]()
                    var stringForStacking = "V:|-(==0@900)-"
                    
                    
                    for m in 0...partyResults.count-1{
                        let thisParty = partyResults[m] as! NSDictionary
                        print(thisParty)
                        let partyStatus = thisParty["partyStatus"]!
                        let partyName = thisParty["partyName"]!
                        let partyPassword = thisParty["partyPassword"]!
                        let partyBroadcasterId = thisParty["broadcasterId"]!
                        let partyQueue = thisParty["queue"]!
                        let partyCurrentSong = thisParty["currentSong"]!
                        
                        
                        
                        let containerHeight = CGFloat(70)
                        let buttonPadding = CGFloat(24)
                        
                        
                        let party_container = parameterizedView()
                        
                        party_container.backgroundColor = UIColor.clear
                        //broadcaster_container.alpha = 1 - (CGFloat(m) * 0.10)
                        
                        
                        self.party_searchForParty_resultsSV.addSubview(party_container)
                        //////////////
                        party_container.translatesAutoresizingMaskIntoConstraints = false
                        
                        self.party_searchForParty_resultsSV.addConstraint(parameterizedNSLayoutConstraint(item: self.party_searchForParty_resultsSV, attribute: .centerX, relatedBy: .equal, toItem: party_container, attribute: .centerX, multiplier: (1), constant: 0))
                        
                        self.party_searchForParty_resultsSV.addConstraint(parameterizedNSLayoutConstraint(item: self.party_searchForParty_resultsSV, attribute: .width, relatedBy: .equal, toItem: party_container, attribute: .width, multiplier: (1), constant: 0))
                        
                        party_container.addConstraint(parameterizedNSLayoutConstraint(item: party_container, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: containerHeight))
                        
                        
                        
                        
                        
                        //Add more button
                        let party_moreButton = parameterizedImageView()
                        
                        party_moreButton.contentMode = .scaleAspectFit
                        party_moreButton.translatesAutoresizingMaskIntoConstraints = false
                        //broadcaster_moreButton.image = #imageLiteral(resourceName: "rightArrow_w")
                        party_container.addSubview(party_moreButton)
                        
                        party_container.addConstraint(parameterizedNSLayoutConstraint(item: party_container, attribute: .trailing, relatedBy: .equal, toItem: party_moreButton, attribute: .trailing, multiplier: (1), constant: buttonPadding))
                        party_container.addConstraint(parameterizedNSLayoutConstraint(item: party_container, attribute: .top, relatedBy: .equal, toItem: party_moreButton, attribute: .top, multiplier: (1), constant: -1*buttonPadding))
                        party_container.addConstraint(parameterizedNSLayoutConstraint(item: party_container, attribute: .bottom, relatedBy: .equal, toItem: party_moreButton, attribute: .bottom, multiplier: (1), constant: buttonPadding))
                        party_moreButton.addConstraint(parameterizedNSLayoutConstraint(item: party_moreButton, attribute: .height, relatedBy: .equal, toItem: party_moreButton, attribute: .width, multiplier: (1), constant: 0))
                        
                        
                        
                        //Add labels
                        
                        
                        
                        
                        let party_nameLabel = parameterizedLabel()
                        
                        party_nameLabel.text = partyName as! String
                        party_nameLabel.font = UIFont.systemFont(ofSize: 20)
                        party_nameLabel.textColor = UIColor.white
                        party_nameLabel.translatesAutoresizingMaskIntoConstraints = false
                        party_container.addSubview(party_nameLabel)
                        
                        
                        let party_broadcasterId = parameterizedLabel()
                        
                        party_broadcasterId.text = partyBroadcasterId as! String
                        party_broadcasterId.translatesAutoresizingMaskIntoConstraints = false
                        party_container.addSubview(party_broadcasterId)
                        
                        
                        
                        
                        
                        party_container.addConstraint(parameterizedNSLayoutConstraint(item: party_container, attribute: .leading, relatedBy: .equal, toItem: party_nameLabel, attribute: .leading, multiplier: (1), constant: -10))
                        party_container.addConstraint(parameterizedNSLayoutConstraint(item: party_moreButton, attribute: .leading, relatedBy: .equal, toItem: party_nameLabel, attribute: .trailing, multiplier: (1), constant: 25))
                        
                        party_container.addConstraint(parameterizedNSLayoutConstraint(item: party_container, attribute: .leading, relatedBy: .equal, toItem: party_broadcasterId, attribute: .leading, multiplier: (1), constant: -10))
                        party_container.addConstraint(parameterizedNSLayoutConstraint(item: party_moreButton, attribute: .leading, relatedBy: .equal, toItem: party_broadcasterId, attribute: .trailing, multiplier: (1), constant: 25))
                        
                        
                        let party_internalContentsDict = ["party_nameLabel": party_nameLabel, "party_broadcasterId": party_broadcasterId] as [String : Any]
                        let stringFor_party_Stacking = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==6@900)-[party_nameLabel]-(==4@900)-[party_broadcasterId]-(==10@900)-|", options: [], metrics: nil, views: party_internalContentsDict)
                        
                        party_container.addConstraints(stringFor_party_Stacking)
                        
                        
                        
                        //***********here
                        
                        
                        
                        let thisBroadcaster_lastActive = thisParty["lastActive"]! as! String
                        let thisBroadcaster_lastActive_atrArray = timeString_toAtrArray(thisBroadcaster_lastActive)
                        print(thisBroadcaster_lastActive_atrArray)
                        
                        let currentTime_atrArray = timeString_toAtrArray(String(describing: Date(timeIntervalSinceNow: 0)))
                        print(currentTime_atrArray)
                        
                        let deltaTime_atrArray = delta_times(time1: currentTime_atrArray, time2: thisBroadcaster_lastActive_atrArray)
                        let deltaTime_seconds = time_atrArray_sThroughD_to_seconds(deltaTime_atrArray)
                        print("time since last active: \(deltaTime_seconds) seconds")
                        
                        
                        
                        
                        
                        
                        party_broadcasterId.textColor = UIColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
                        
                        party_moreButton.backgroundColor = UIColor.init(red: 28/255, green: 188/255, blue: 55/255, alpha: 1)
                        
                        
                        
                            let party_overlyingButton = parameterizedButton()
                            party_overlyingButton.backgroundColor = UIColor.clear
                        
                        
                            party_container.addSubview(party_overlyingButton)
                            party_overlyingButton.translatesAutoresizingMaskIntoConstraints = false
                            party_container.addConstraint(parameterizedNSLayoutConstraint(item: party_container, attribute: .top, relatedBy: .equal, toItem: party_overlyingButton, attribute: .top, multiplier: (1), constant: 0))
                            party_container.addConstraint(parameterizedNSLayoutConstraint(item: party_container, attribute: .bottom, relatedBy: .equal, toItem: party_overlyingButton, attribute: .bottom, multiplier: (1), constant: 0))
                            party_container.addConstraint(parameterizedNSLayoutConstraint(item: party_container, attribute: .left, relatedBy: .equal, toItem: party_overlyingButton, attribute: .left, multiplier: (1), constant: 0))
                            party_container.addConstraint(parameterizedNSLayoutConstraint(item: party_container, attribute: .right, relatedBy: .equal, toItem: party_overlyingButton, attribute: .right, multiplier: (1), constant: 0))
                                party_overlyingButton.arrayTagForPass.append(thisParty)
                            party_overlyingButton.arrayTagForPass.append(party_moreButton)
                        
                            party_overlyingButton.addTarget(self, action: #selector(ViewController.joinParty(_:)), for: .touchUpInside)
                        
                       
                        
                        
                        
                        
                        
                        //***********here end
                        
                        
                        self.view.layoutIfNeeded()
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        dictionary_partyResults_containers.updateValue(party_container, forKey: "partyItem\(m)")
                        stringForStacking += "[partyItem\(m)]-(==0@900)-"
                        
                        
                        party_moreButton.layer.cornerRadius = (containerHeight - (2*buttonPadding))/2
                        
                        
                        
                        
                        
                        
                    }
                    
                    stringForStacking += "|"
                    let party_VertStackingConstraint = NSLayoutConstraint.constraints(withVisualFormat: stringForStacking, options: [], metrics: nil, views: dictionary_partyResults_containers)
                    
                    self.party_searchForParty_resultsSV.addConstraints(party_VertStackingConstraint)
                    
                    self.view.layoutIfNeeded()
                
                } else {
                    self.display_noPartiesFound()
                }
                
                
                
            case .failure(let error):
                print("error: \(error)")
                self.display_noPartiesFound()
            }
            
            
        }
        
        
        
        
    }
    
    
    func display_noPartiesFound(){
        
        clearViewOfSubviews(viewToClear: self.party_searchForParty_resultsSV)
        
        let failureNotification_label = parameterizedLabel()
        
        failureNotification_label.backgroundColor = UIColor.clear
        failureNotification_label.textColor = UIColor.darkGray
        failureNotification_label.numberOfLines = 0
        failureNotification_label.text = "No parties were found matching your search"
        failureNotification_label.textAlignment = .center
        
        
        self.party_searchForParty_resultsSV.addSubview(failureNotification_label)
        failureNotification_label.translatesAutoresizingMaskIntoConstraints = false
        
        self.party_searchForParty_resultsSV.addConstraint(parameterizedNSLayoutConstraint(item: self.party_searchForParty_resultsSV, attribute: .centerX, relatedBy: .equal, toItem: failureNotification_label, attribute: .centerX, multiplier: (1), constant: 0))
        self.party_searchForParty_resultsSV.addConstraint(parameterizedNSLayoutConstraint(item: failureNotification_label, attribute: .width, relatedBy: .equal, toItem: self.party_searchForParty_resultsSV, attribute: .width, multiplier: (1), constant: -150))
        self.party_searchForParty_resultsSV.addConstraint(parameterizedNSLayoutConstraint(item: self.party_searchForParty_resultsSV, attribute: .centerY, relatedBy: .equal, toItem: failureNotification_label, attribute: .centerY, multiplier: (1), constant: 80))
        
        self.view.layoutIfNeeded()
    }
    
    @objc func joinParty(_ sender: parameterizedButton){
        //This will change the look of the party screen until the user leaves the party:
        
        let moreButton = sender.arrayTagForPass[1] as! UIView
        
        let overlyingView = parameterizedView()
        overlyingView.backgroundColor = moreButton.backgroundColor
        
        
        partyPage_contentView.addSubview(overlyingView)
        overlyingView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        var overlyingView_constraints:[NSLayoutConstraint] = []
        
        overlyingView_constraints.append(parameterizedNSLayoutConstraint(item: moreButton, attribute: .centerX, relatedBy: .equal, toItem: overlyingView, attribute: .centerX, multiplier: (1), constant: 0))
        overlyingView_constraints.append(parameterizedNSLayoutConstraint(item: moreButton, attribute: .centerY, relatedBy: .equal, toItem: overlyingView, attribute: .centerY, multiplier: (1), constant: 0))
        
        overlyingView_constraints.append(parameterizedNSLayoutConstraint(item: overlyingView, attribute: .height, relatedBy: .equal, toItem: moreButton, attribute: .height, multiplier: (1), constant: 0))
        
        overlyingView_constraints.append(parameterizedNSLayoutConstraint(item: overlyingView, attribute: .width, relatedBy: .equal, toItem: moreButton, attribute: .width, multiplier: (1), constant: 0))
        
        partyPage_contentView.addConstraints(overlyingView_constraints)
        
        
        self.view.layoutIfNeeded()
        overlyingView.layer.cornerRadius = overlyingView.frame.width/2
        
        partyPage_contentView.removeConstraints(overlyingView_constraints)
        
        var second_overlyingView_constraints:[NSLayoutConstraint] = []
        
        second_overlyingView_constraints.append(parameterizedNSLayoutConstraint(item: partyPage_contentView, attribute: .centerX, relatedBy: .equal, toItem: overlyingView, attribute: .centerX, multiplier: (1), constant: 0))
        second_overlyingView_constraints.append(parameterizedNSLayoutConstraint(item: partyPage_contentView, attribute: .centerY, relatedBy: .equal, toItem: overlyingView, attribute: .centerY, multiplier: (1), constant: 0))
        
        second_overlyingView_constraints.append(parameterizedNSLayoutConstraint(item: partyPage_contentView, attribute: .height, relatedBy: .equal, toItem: overlyingView, attribute: .height, multiplier: (1), constant: 0))
        second_overlyingView_constraints.append(parameterizedNSLayoutConstraint(item: partyPage_contentView, attribute: .width, relatedBy: .equal, toItem: overlyingView, attribute: .width, multiplier: (1), constant: 0))
        
        partyPage_contentView.addConstraints(second_overlyingView_constraints)
        
        updateAllSubviewOf_selfView()
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            
            
            overlyingView.backgroundColor = UIColor.white
            overlyingView.layer.cornerRadius = 0
            
            var gradientLayer: CAGradientLayer!
            gradientLayer = CAGradientLayer()
            
            gradientLayer.frame = overlyingView.bounds
            
            gradientLayer.colors = [UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 1).cgColor]
            
            
            overlyingView.layer.addSublayer(gradientLayer)
            
            
        }, completion: nil)
        
        
        isJoinedParty = true
        
        let thisParty = sender.arrayTagForPass[0] as! NSDictionary
        let thisPartyName = thisParty["partyName"] as! String
        let thisPartyQueue = thisParty["queue"] as! String
        
        let thisPartyStatus = thisParty["partyStatus"]! as! String
        let thisPartyPassword = thisParty["partyPassword"]! as! String
        let thisPartyBroadcasterId = thisParty["broadcasterId"]! as! String
        let thisPartyCurrentSong = thisParty["currentSong"]! as! String
        
        joinedParty.queue_string = thisPartyQueue
        joinedParty.broadcasterId = thisPartyBroadcasterId
        joinedParty.partyName = thisPartyName
        joinedParty.partyPassword = thisPartyPassword
        joinedParty.currentSong = thisPartyCurrentSong
        joinedParty.partyStatus = thisPartyStatus
        
        let partyTracks = parse_queueStringTo_truncTracks(thisPartyQueue)
        joinedParty.queue = partyTracks
        
        updateQueue()
        
        
        
        print(thisPartyName)
        print(thisPartyQueue)
        
        //Visual changes
        toggleGradientLayer(show: true)
        toggle_whisper(text: "Joined party: \(thisPartyName)", backgroundColor: purplePreset_100, show: true)
        
        progressBar.minimumTrackTintColor = purplePreset_100
        minimizedPlayer_progressBar.progressTintColor = purplePreset_100
        progressBar.isUserInteractionEnabled = false
        
        partyMode_button.isHidden = true
        viewerButton_outlet.isHidden = true
        repeatButton.isHidden = true
        
        playPauseButton_outlet.alpha = 0.25
        playPauseButton_outlet.isUserInteractionEnabled = false
        previousSong_buttonOutlet.alpha = 0.25
        previousSong_buttonOutlet.isUserInteractionEnabled = false
        nextSong_buttonOutlet.alpha = 0.25
        nextSong_buttonOutlet.isUserInteractionEnabled = false
        
        if playbackState_isPresent() {
            self.player?.setIsPlaying(false, callback: nil)
        }
        
        
        
        
        
        
        
        print(partyTracks.count)
        print(partyTracks)
        
        print(joinedParty.currentSong)
        //This updates the data in the minimized and expanded player views:
        _ = Spartan.getTrack(id: String(describing: joinedParty.currentSong!.split(separator: ":")[2]), success:{ (fetchedTrack: SimplifiedTrack) in
            
            print(fetchedTrack.name)
            let trackToPlay = track_eApp(isFromQueue: false, isSuggestion: false, suggestor: "partyMember_superficialData")
            trackToPlay.name = fetchedTrack.name
            trackToPlay.artistString = artists_toArtistString(fetchedTrack.artists)
            trackToPlay.uri = fetchedTrack.uri
            
            
            
            //self.playNewSong(trackToPlay: trackToPlay, onlyArm: true, position: 0)
            self.currentSong = trackToPlay
            print(self.currentSong)
            
        }, failure: { (error) in
            print(error)
        })
        
        
        partyMember_refreshTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(activePartyMember_refreshData), userInfo: nil, repeats: true)
        
        
    }
    
    func toggleGradientLayer(show:Bool) {
        if show {
        var gradientLayer: CAGradientLayer!
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = minimizedPlayer_view.bounds
        
        gradientLayer.colors = [purplePreset_025, purplePreset_050.cgColor]
        
        
        minimizedPlayer_view.layer.addSublayer(gradientLayer)
        
        } else {
            minimizedPlayer_view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        }
    }
    
    
    @objc func activePartyMember_refreshData(){
        
            print("refreshing party data")
            
            var select_partyData_parameters = Parameters()
            select_partyData_parameters = addStandardParameters(emptyParameters: select_partyData_parameters)
            
            
            select_partyData_parameters.updateValue("SELECT * FROM liveListenSession WHERE broadcasterId = '\(joinedParty.broadcasterId!)'", forKey: "argument")
            
            
            
            
            
            print(select_partyData_parameters)
            
            
            Alamofire.request("http://www.flasheducational.com/phpScripts/fetch/generalSelectBlankDBInfo.php", method: .post, parameters:select_partyData_parameters) .responseJSON { response in
                switch response.result {
                case .success( _):
                    consoleLog(msg: "dgfjdhfsg", level: 1)
                    let partyResults = (response.result.value! as! NSArray)
                    
                    consoleLog(msg: "debug:  56hb", level: 1)
                    
                        
                        
                    
                        for m in 0...partyResults.count-1{
                            let thisParty = partyResults[m] as! NSDictionary
                            print(thisParty)
                            
                            let updatedPartyInfo = party_eApp()
                            
                            updatedPartyInfo.broadcasterId = thisParty["broadcasterId"]! as! String
                            updatedPartyInfo.currentSong = thisParty["currentSong"]! as! String
                            updatedPartyInfo.partyName  = thisParty["partyName"]! as! String
                            updatedPartyInfo.partyStatus = thisParty["partyStatus"]! as! String
                            updatedPartyInfo.partyPassword = thisParty["partyPassword"]! as! String
                            updatedPartyInfo.queue_string = thisParty["queue"]! as! String
                            
                            self.updateParty_info(updatedPartyInfo)
                            
                            
                        }
                    
                    
                case .failure(let error):
                    print("error: \(error)")
                    
                }
                
                
            }
        
        
    }
    
    func updateParty_info(_ updatedInfo: party_eApp){
        if updatedInfo.partyStatus == "" {
            leaveParty()
        } else {
            //First compare the queue strings, so that no unnecessary processor power is used. if the strings are the same, the no need to parse it all out.
            if updatedInfo.queue_string! != joinedParty.queue_string! {
                print("queue changed - update in progress")
                let updated_partyTracks = parse_queueStringTo_truncTracks(updatedInfo.queue_string!)
                joinedParty.queue = updated_partyTracks
                updateQueue()
            }
            
            print(updatedInfo)
            
            print("updatingCurrentSong")
            print(updatedInfo.currentSong!)
            print(currentSong.uri!)
            
            if updatedInfo.currentSong! != currentSong.uri {
                _ = Spartan.getTrack(id: String(describing: updatedInfo.currentSong!.split(separator: ":")[2]), success:{ (fetchedTrack: SimplifiedTrack) in
                    
                    print(fetchedTrack.name)
                    let trackToPlay = track_eApp(isFromQueue: false, isSuggestion: false, suggestor: "partyMember_superficialData")
                    trackToPlay.name = fetchedTrack.name
                    trackToPlay.artistString = artists_toArtistString(fetchedTrack.artists)
                    trackToPlay.uri = fetchedTrack.uri
                    trackToPlay.sourceType = "listeningMode"
                    trackToPlay.source_name = "Listening Mode"
                    
                    
                    //self.playNewSong(trackToPlay: trackToPlay, onlyArm: true, position: 0)
                    self.currentSong = trackToPlay
                    print(self.currentSong)
                    
                }, failure: { (error) in
                    print(error)
                })
            }
            
            
        }
    }
    
    func leaveParty(){
        //Make sure to take care of all visual and nonvisual changes (i.e. variable toggles)
        isJoinedParty = false
        
        joinedParty = party_eApp()
        
        updateQueue()
        
        
        //Visual changes
        toggleGradientLayer(show: false)
        toggle_whisper(show: false)
        
        progressBar.minimumTrackTintColor = spotifyGreen
        minimizedPlayer_progressBar.progressTintColor = spotifyGreen
        progressBar.isUserInteractionEnabled = true
        
        partyMode_button.isHidden = false
        viewerButton_outlet.isHidden = false
        repeatButton.isHidden = false
        
        playPauseButton_outlet.alpha = 1
        playPauseButton_outlet.isUserInteractionEnabled = true
        previousSong_buttonOutlet.alpha = 1
        previousSong_buttonOutlet.isUserInteractionEnabled = true
        nextSong_buttonOutlet.alpha = 1
        nextSong_buttonOutlet.isUserInteractionEnabled = true
        
        if playbackState_isPresent() {
            self.player?.setIsPlaying(false, callback: nil)
        }
        
        
        
        
        minimizedPlayer_view_songNameLabel.text = "Empty Song Queue"
        
        
        
        partyMember_refreshTimer.invalidate()
        
        
        
    }

    @objc func goToPartyPane(_ sender:UITapGestureRecognizer){
        offsetSV(overarchingContainer_SV, 3)
        (self.navigationController?.view.viewWithTag(68395) as! LTMorphingLabel).text = "Party"
        hideAll_panels(leaveBlurViewShown: false)
        toggleAlternateView(show: false)
        change_overarchingColor(UIColor.init(red: 0.260, green: 0.260, blue: 0.260, alpha: 1))
    }
    
}


