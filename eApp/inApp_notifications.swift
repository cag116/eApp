//
//  inApp_notifications.swift
//  eApp
//
//  Created by Christopher Guirguis on 7/26/18.
//  Copyright © 2018 Christopher Guirguis. All rights reserved.
//

extension ViewController {
    func toggle_whisper(permanence: Bool = true, duration: Double = 0, text: String = "", backgroundColor: UIColor = UIColor.init(red: 76/255, green: 165/255, blue: 239/255, alpha: 1), show:Bool){
        if show {
            whisperContainer.backgroundColor = backgroundColor
            whisperLabel.text = text
            
            
            whisperContainer_heightConstraint.constant = 20
            updateAllSubviewOf_selfView()
            
            
            if isJoinedParty {
                
                    
                let whisper_goToPartyPane = UITapGestureRecognizer(target: self, action: #selector(ViewController.goToPartyPane(_:)))
                whisperContainer.addGestureRecognizer(whisper_goToPartyPane)
            }
        } else {
            whisperContainer.backgroundColor = backgroundColor
            whisperLabel.text = ""
            
            
            whisperContainer_heightConstraint.constant = 0
            updateAllSubviewOf_selfView()
        }
        
    }
}
