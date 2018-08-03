//
//  viewController_extension.swift
//  Alamofire
//
//  Created by Christopher Guirguis on 4/23/18.
//

extension ViewController {
    
    func toggleAlternateView(show:Bool){
        if show {
            alternateViewer_heightConstraint.isActive = false
            alternateViewTOP_equal_overarchingContainerTOP.isActive = true
            navigationController?.isNavigationBarHidden = true

        } else {
            alternateViewer_heightConstraint.isActive = true
            alternateViewTOP_equal_overarchingContainerTOP.isActive = false
            navigationController?.isNavigationBarHidden == false

        }
        updateAllSubviewOf_selfView()
        
    }
    func hide_mainContent_overlyingBlurView(hideBool: Bool){
        if hideBool {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: {
                
                self.mainContent_overlyingBlurView.alpha = 0
                
            }, completion: {
                (thisParam: Bool) in
                
                if !thisParam {
                    self.mainContent_overlyingBlurView.isHidden = true
                }
                
            })
            
            
            
        } else {
            mainContent_overlyingBlurView.isHidden = false
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: {
                
                self.mainContent_overlyingBlurView.alpha = 1
                
            }, completion: nil)
        }
    }
    
    
    func hide_expandedPlayerView(hideBool: Bool){
        if hideBool {
            expandedPlayer_heightConstraint.constant = 0
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut], animations: {
                
                self.minimizedView_expansionButtonImage.transform = CGAffineTransform(rotationAngle: CGFloat(degreesToRadians(degrees: 0)))
                self.offsetSV(self.expanded_containerView, 0)
                
            }, completion: nil)
            
        } else {
            expandedPlayer_heightConstraint.constant = 400
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut], animations: {
                
                self.minimizedView_expansionButtonImage.transform = CGAffineTransform(rotationAngle: CGFloat(degreesToRadians(degrees: 180)))
                
            }, completion: nil)
        }
        
        
    }
    
    func toggleBottomPopup(action: String){
        let bottomPopup = self.view.viewWithTag(76589)
        var heightConstraint = parameterizedNSLayoutConstraint()
            
        for constraint in (bottomPopup?.constraints)! {
            if (constraint.firstAttribute == .height){
                heightConstraint = constraint as! parameterizedNSLayoutConstraint
            }
        }
        
        
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: {
            if action == "show"{
                
                heightConstraint.constant = 600
            } else if action == "hide"{
                
                heightConstraint.constant = 0
                clearViewOfSubviews(viewToClear: bottomPopup!)
            }
            
        }, completion: {
            (thisParam: Bool) in
            
            
            
        })
        
        updateAllSubviewOf_selfView()
        
        
    }
    
    func hideAll_panels(leaveBlurViewShown: Bool) {
        if (!leaveBlurViewShown) { hide_mainContent_overlyingBlurView(hideBool: true)}
        toggle_expand_minimizedPlayer(sender_takingOver: true)
        deactivateSearch_noSender()
        
        toggleBottomPopup(action: "hide")
        self.view.endEditing(true)
    }

    func addSongToQueue(trkToQueue: track_eApp){
        print(trkToQueue.name)
        trkToQueue.isFromQueue = true
        queue.append(trkToQueue)
        print(queue.count)
        updateQueue()
        
        hideAll_panels(leaveBlurViewShown: false)
        
    }
    
    //This function allows non-synchronized items to be added to a dictionary to be fully enumerated, before being returned as an array in the correct order
    func organizationStorage(storageDictionary:NSMutableDictionary, key:String, item:Any) -> NSMutableDictionary {
        storageDictionary.setValue(item, forKey: key)
        return storageDictionary
    }
    
    //This function allows the completed dicitonary to be returned as a properly ordered array
    func enumerateDictionary(storageDictionary:NSMutableDictionary) -> [Any]{
        
        var sortedKeys = (storageDictionary.allKeys) as! [String]
        sortedKeys.sort()
        
        var returnArray:[Any] = []
        for key in sortedKeys{
            returnArray.append(storageDictionary.value(forKey: key)) 
        }
        return returnArray
        
    }
    
    func change_overarchingColor(_ color:UIColor){
        UIView.animate(withDuration: 0.3 , delay: 0.0, options: [.curveEaseInOut], animations: {
            self.overarchingContainer_SV.backgroundColor = color
            
        }, completion:nil)
        
    }
    
    func playbackState_isPresent() -> Bool {
        if String(describing: self.player?.playbackState) == "nil" {
            return false
        } else {
            return true
        }
    }
}

