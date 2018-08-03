//
//  ViewController.swift
//  eApp
//
//  Created by Christopher Guirguis on 3/21/18.
//  Copyright © 2018 Christopher Guirguis. All rights reserved.
//

import AVKit
import AVFoundation
import UIKit
import Alamofire
import Alamofire.Swift
import Spartan
import SDWebImage
import LTMorphingLabel
import MediaPlayer
import MarqueeLabel
import SafariServices


public var authorizationToken: String?

class ViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    //--------------------------------------
    // MARK: Variables
    //--------------------------------------
    
    
    //These are the variables for someone that is broadcasting
    var isBroadcasting = false
    var thisLiveSession_id = -1
    
    //These variables are for someone who is listening to a live broadcast
    var isListening = false
    var thisListeningSession_id = -1
    var thisListeningSession_mostRecent_songURI = ""
    
    //These variables are for someone who is hosting a party
    var isPartyModeOn = false
    var partyName = "nil"
    var partyPassword = "nil"
    
    //These variables are for someone who has joined a party
    var isJoinedParty = false
    var joinedParty = party_eApp()
    
    //These variables are for the state of the player
    var repeatOn = false
    var shuffleOn = false
    
    
    //These variables are standard colors used throughout this app
    let spotifyGreen = UIColor.init(red: 0.4157, green: 0.8902, blue: 0.4078, alpha: 1)
    
    let purplePreset_100 = UIColor.init(red: 207/255, green: 131/255, blue: 1, alpha: 1)
    let purplePreset_075 = UIColor.init(red: 207/255, green: 131/255, blue: 1, alpha: 0.75)
    let purplePreset_050 = UIColor.init(red: 207/255, green: 131/255, blue: 1, alpha: 0.5)
    let purplePreset_025 = UIColor.init(red: 207/255, green: 131/255, blue: 1, alpha: 0.25)
    
    let bluePreset_100 = UIColor.init(red: 61/255, green: 103/255, blue: 233/255, alpha: 1)
    let bluePreset_075 = UIColor.init(red: 61/255, green: 103/255, blue: 233/255, alpha: 0.75)
    let bluePreset_050 = UIColor.init(red: 61/255, green: 103/255, blue: 233/255, alpha: 0.50)
    let bluePreset_025 = UIColor.init(red: 61/255, green: 103/255, blue: 233/255, alpha: 0.25)
    
    //These toggle keeps track of the size of the expanded player
    var expandedPlayer_isExpanded = false
    
    //This variable keeps track of the type of search that someone is doing
    var searchMode:ItemSearchType = .track

    //This variable determines whether the expanded player slider should be moving with the music. Tracking is always on unless the user has pressed on it to manually change the position in the song
    var progressTracksPosition = true
    
    
    //These variables are boilerplate variables for the Spotify/Spartan API
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    
    //These variables are timers for regular updates
    //This timer maintains the user's GUI synchronization
    var localUpdateTimer: Timer!
    
    //This timer maintains the playback information/status of someone who is live broadcasting
    var serverUpdatetimer: Timer!
    
    //This timer maintains synchronized listening for someone who is listening to a live broadcast
    var listener_refreshTimer: Timer!
    
    //This timer maintains synchronized queue information for someone who is part of a party
    var partyMember_refreshTimer: Timer!
    
    //This variable corresponds to the playback information on the lockscreen
    let mpic = MPNowPlayingInfoCenter.default()
    
    
    @IBOutlet var nextSong_buttonOutlet: UIButton!
    
    @IBOutlet var previousSong_buttonOutlet: UIButton!
    @IBAction func expandedView_panGestureRecognizer_action(_ sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
       
        //NOTE: the 400 is a hardcoded value of what the fully open version would look like. Anytime that hardcoded value changes in the generalExtensions code, it needs to be changed here
        if point.y > 0 && point.y < 400 {
            //This portion of the code is responsible for the view moving with the user's fingers/gestures
            expandedPlayer_heightConstraint.constant = 400 - point.y
            self.mainContent_overlyingBlurView.alpha = (400 - point.y)/400
        }
        
        //This next portion determines what happens the user lets their finger go
        if sender.state == UIGestureRecognizerState.ended {
            //If the user lets go in the bottom 70 pixels 
            if point.y > 330  || (velocity.y >= 800){
                hideAll_panels(leaveBlurViewShown: false)
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                    
                    
                    self.mainContent_overlyingBlurView.alpha = 1
                    
                }, completion: nil)
                
                self.expandedPlayer_heightConstraint.constant = 400
                updateAllSubviewOf_selfView()
            }
        }
    }
    @IBOutlet var whisperLabel: UILabel!
    @IBOutlet var whisperContainer: UIView!
    @IBOutlet var whisperContainer_heightConstraint: NSLayoutConstraint!
    
    @IBOutlet var listener_SearchForBroadcaster_resultsSV: UIScrollView!
    @IBOutlet var searchBar_broadcasters: UISearchBar!
    
    
    @IBOutlet var searchBar_party: UISearchBar!
    
    @IBOutlet var party_searchForParty_resultsSV: UIScrollView!
    
    
    
    @IBOutlet var alternateView_headerLabel: UILabel!
    @IBOutlet var alternateView_body: UIScrollView!
    @IBOutlet var alternateView_header: UIView!
    @IBOutlet var alternateView_downTriangle: UIButton!
    @IBAction func alternateView_downTriangle_hideButton(_ sender: Any) {
        toggleAlternateView(show: false)
    }
    
    

    @IBOutlet var partyMode_button: UIButton!

    @IBAction func partyMode_button_action(_ sender: Any) {
        if !isPartyModeOn {
            
          
            
            isPartyModeOn = true
            partyMode_button.setImage(#imageLiteral(resourceName: "group_green"), for: .normal)
            print("party mode activated")
            
            partyName = "partyTime"
            updateServer_scopeEquals_allQueueAllParty()
            SweetAlert().showAlert("Go!", subTitle: "Party started, successfully!", style: AlertStyle.success)
            toggle_whisper(text: "You're a party host", show: true)
            
        } else {
            isPartyModeOn = false
            partyMode_button.setImage(#imageLiteral(resourceName: "group_g"), for: .normal)
            print("party mode deactivated")
            
            partyName = "nil"
            partyPassword = "nil"
            updateServer_scopeEquals_allQueueAllParty()
            SweetAlert().showAlert("Party Ended!", subTitle: "Party ended successfully!", style: AlertStyle.success)
            
            toggle_whisper(show: false)

        }
    }
    
    @IBOutlet var partyPage_contentView: UIView!
    
    @IBOutlet var alternateViewTOP_equal_overarchingContainerTOP: NSLayoutConstraint!
    
    // Initialzed in either updateAfterFirstLogin: (if first time login) or in viewDidLoad (when there is a check for a session object in User Defaults
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    
    var currentSongLength = Double(0)
    
    var currentSong_dict = NSDictionary()
    var currentSongURI = ""
    var currentSong = track_eApp(isFromQueue: false, isSuggestion: false, suggestor: "nil")
    
    var currentPlaylistURI = ""
    var locationInPlaylist = -1
    
    var queue:[track_eApp] = []
    
    var currentPlaylist = playlist_eApp()
    var finishTimeString = "none"
    
    
    var clientID = "99667ab175244460aacb50a456dc0714"
    var clientSecret = "8b4bae15857e409b82ad4f6a92f17722"
    var bundleID = "com.cguirguis.eapp"
    var redirectURI = "eapp://returnAfterLogin"
    
    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    
    @IBAction func homeButton_action(_ sender: Any) {
        offsetSV(overarchingContainer_SV, 0)
        let customTitleView = self.navigationController?.view.viewWithTag(68395) as! LTMorphingLabel
        customTitleView.text = "Home"
        hideAll_panels(leaveBlurViewShown: false)
        toggleAlternateView(show: false)
        change_overarchingColor(UIColor.black)
        
    }
    @IBAction func listenButton_action(_ sender: Any) {
        offsetSV(overarchingContainer_SV, 1)
        (self.navigationController?.view.viewWithTag(68395) as! LTMorphingLabel).text = "Listen"
        hideAll_panels(leaveBlurViewShown: false)
        toggleAlternateView(show: false)
        change_overarchingColor(UIColor.init(red: 0.10, green: 0.10, blue: 0.10, alpha: 1))
    }
    @IBAction func meButton_action(_ sender: Any) {
        offsetSV(overarchingContainer_SV, 2)
        (self.navigationController?.view.viewWithTag(68395) as! LTMorphingLabel).text = "Me"
        hideAll_panels(leaveBlurViewShown: false)
        toggleAlternateView(show: false)
        change_overarchingColor(UIColor.black)
    }
    @IBAction func partyButton_action(_ sender: Any) {
        offsetSV(overarchingContainer_SV, 3)
        (self.navigationController?.view.viewWithTag(68395) as! LTMorphingLabel).text = "Party"
        hideAll_panels(leaveBlurViewShown: false)
        toggleAlternateView(show: false)
        change_overarchingColor(UIColor.init(red: 0.260, green: 0.260, blue: 0.260, alpha: 1))
    }
    @IBAction func settingsButton_action(_ sender: Any) {
        offsetSV(overarchingContainer_SV, 4)
        (self.navigationController?.view.viewWithTag(68395) as! LTMorphingLabel).text = "Settings"
        hideAll_panels(leaveBlurViewShown: false)
        toggleAlternateView(show: false)
        change_overarchingColor(UIColor.black)
        
        
    }
    
    @IBOutlet var overarchingContainer_SV: UIScrollView!
    
    @IBOutlet var ep_remainingTimeTimeStamp_label: UILabel!
    @IBOutlet var ep_positionTimeStamp_label: UILabel!
    @IBOutlet var minimizedView_expansionButtonImage: UIImageView!
    @IBAction func repeatToggleButton(_ sender: Any) {
        if repeatOn {
            repeatOn = false
            repeatButton.setImage(#imageLiteral(resourceName: "repeat_g"), for: .normal)
        } else {
            repeatOn = true
            repeatButton.setImage(#imageLiteral(resourceName: "repeat_green"), for: .normal)
        }
    }
    @IBOutlet var alternateViewer_SV: UIScrollView!
    
    @IBAction func shuffleToggleButton(_ sender: Any) {
        if shuffleOn {
            shuffleOn = false
            shuffleButton.setImage(#imageLiteral(resourceName: "shuffle_g"), for: .normal)
        } else {
            shuffleOn = true
            shuffleButton.setImage(#imageLiteral(resourceName: "shuffle_green"), for: .normal)
        }
    }
    @IBAction func ep_queue(_ sender: Any) {
        offsetSV(expanded_containerView, 1)
    }
    @IBOutlet var alternateViewer_heightConstraint: NSLayoutConstraint!
    @IBAction func ep_viewers(_ sender: Any) {
        //offsetSV(expanded_containerView, 2)
        if isBroadcasting {
            isBroadcasting = false
            
            viewerButton_outlet.setImage(#imageLiteral(resourceName: "broadcast_grayscale"), for: .normal)
            if serverUpdatetimer.isValid{
                serverUpdatetimer.invalidate()
                
                updateServer_broadcastOffline()
                SweetAlert().showAlert("Done!", subTitle: "Broadcasting Ended, successfully!", style: AlertStyle.success)
            }
        } else {
            if self.player != nil{
                if (self.player?.playbackState.isPlaying)!{
                    updateServer()
                    isBroadcasting = true
                    viewerButton_outlet.setImage(#imageLiteral(resourceName: "broadcast_green"), for: .normal)
                    if serverUpdatetimer == nil{
                        serverUpdatetimer = Timer.scheduledTimer(timeInterval: 2.1, target: self, selector: #selector(updateServer), userInfo: nil, repeats: true)
                        SweetAlert().showAlert("Go!", subTitle: "Broadcasting started, successfully!", style: AlertStyle.success)
                    } else if serverUpdatetimer.isValid == false{
                        serverUpdatetimer = Timer.scheduledTimer(timeInterval: 2.1, target: self, selector: #selector(updateServer), userInfo: nil, repeats: true)
                        SweetAlert().showAlert("Go!", subTitle: "Broadcasting started, successfully!", style: AlertStyle.success)
                    }
                } else {
                    SweetAlert().showAlert("Whoops!", subTitle: "Start playing a song before you can begin broadcasting!", style: AlertStyle.warning)
                }
            } else {
                SweetAlert().showAlert("Whoops!", subTitle: "Start playing a song before you can begin broadcasting!", style: AlertStyle.warning)
            }
        }
    }
    @IBOutlet var expandedView_albumArtThumbnail: UIImageView!
    
    @IBOutlet var shuffleButton: UIButton!
    @IBOutlet var repeatButton: UIButton!
    @IBAction func playPauseButton_action(_ sender: Any) {
        playPause_toggle()

    }
    func playPause_toggle(){
        if playbackState_isPresent() {
            if (self.player?.playbackState.isPlaying)! {
                
                self.player?.setIsPlaying(false, callback: nil)
                playPauseButton_outlet.setImage(#imageLiteral(resourceName: "play_w"), for: .normal)
            }else{
                
                
                self.player?.setIsPlaying(true, callback: nil)
                playPauseButton_outlet.setImage(#imageLiteral(resourceName: "pause_w"), for: .normal)
                
            }
        }
    }
    
    @IBAction func ep_playerCC_FFAction(_ sender: Any) {
        nextButton_action()
    }
    func nextButton_action(){
        playerPlay_nextSong()
    }
    
    @IBAction func ep_playerCC_rewindAction(_ sender: Any) {
        previousButton_action()
    }
    func previousButton_action(){
        if self.currentSong.locationInSource == nil {
            self.player?.seek(to: 0, callback: { (error) in
                if (error != nil) {
                    
                    consoleLog(msg: "\(String(describing: error))", level: 1)
                }
                
                
            })
        } else {
            let indexInSource = (self.currentSong.locationInSource)!
            if (self.player?.initialized)!{
                if (self.player?.playbackState.position)! >= Double(3){
                    consoleLog(msg: "restarting song", level: 1)
                    self.player?.seek(to: 0, callback: { (error) in
                        if (error != nil) {
                            
                            consoleLog(msg: "\(String(describing: error))", level: 1)
                        }
                        
                        
                    })
                } else {
                    if indexInSource > 0 {
                        self.playNewSong(trackToPlay: (self.currentPlaylist.tracks![indexInSource - 1]), onlyArm: false)
                    } else if indexInSource == 0 {
                        if repeatOn {
                            self.playNewSong(trackToPlay: (self.currentPlaylist.tracks?.last)!, onlyArm: false)
                        } else {
                            self.player?.seek(to: 0, callback: { (error) in
                                if (error != nil) {
                                    
                                    consoleLog(msg: "\(String(describing: error))", level: 1)
                                }
                                
                                
                            })
                        }
                    }
                }
            }
        }
    }
    
    
    @IBOutlet var playPauseButton_outlet: UIButton!
    
    
    @IBOutlet var expandedPlayer_heightConstraint: NSLayoutConstraint!
    
    
    
    @IBOutlet var minimizedPlayer_thumbnail: UIImageView!
    
    
    @IBOutlet var expanded_containerView: UIScrollView!
    
    @IBOutlet var queueButton_outlet: UIButton!
    
    @IBOutlet var viewerButton_outlet: UIButton!
    
    @IBAction func minimizedPlayer_expansionButton(_ sender: Any) {
        
        consoleLog(msg: "player is expanded: \(expandedPlayer_isExpanded)", level: 1)
        toggle_expand_minimizedPlayer(sender_takingOver: false)
    }
    @IBOutlet var expandedView_nameLabel: UILabel!
    @IBOutlet var expandedView_artistLabel: UILabel!
    
    
    @IBOutlet var mainContent_SV: UIScrollView!
    @IBOutlet var personalContent_SV: UIScrollView!
    //Song Buttons
  
    
    
    //Labels
    
    
    @IBOutlet var searchResultsContainer: UIView!
    
    
    @IBOutlet var mainContent_overlyingBlurView: UIVisualEffectView!
    
    @IBOutlet var expandedPlayerView: UIView!
    @IBOutlet var progressBar: UISlider!
    
    
    @IBOutlet var minimizedPlayer_progressBar: UIProgressView!
    
    @IBAction func progressBar_touchDown(_ sender: Any) {
        print("Touch Start")
        progressTracksPosition = false
        print(progressBar.value)
    }
    @IBAction func progressBar_touchUp(_ sender: Any) {
        print(progressBar.value)
        changePlayerPosition()
        progressTracksPosition = true
        print("Touch End")
    }
    @IBAction func progressBar_changedValue(_ sender: UISlider) {
        
    }
    @IBOutlet var search_dropdownView: UIView!
    
    @IBOutlet var searchBar_height: NSLayoutConstraint!
    
    @IBOutlet var searchResultsContainer_Height: NSLayoutConstraint!
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var minimizedPlayer_view: UIView!
    @IBOutlet var minimizedPlayer_view_songNameLabel: UILabel!
    //--------------------------------------
    // MARK: Functions
    //--------------------------------------
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .defaultToSpeaker)
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        setup()
        setup_expandedViewQueue()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
        
        let userDefaults = UserDefaults.standard
        consoleLog(msg: "sdg", level: 1)
        //*this needs to be removed later showEntryPortal()
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            consoleLog(msg: "gwe89v", level: 1)
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
            
            if self.session != nil && self.session.isValid() {
                consoleLog(msg: "g35gkdf", level: 1)
                initializaPlayer(authSession: session)
                authorizationToken = self.session.accessToken
                print("authToken: \(authorizationToken!)")
                Spartan.authorizationToken = authorizationToken
                Spartan.loggingEnabled = false
                
                
                finishSetup()
            } else {
                print("here")
                showEntryPortal()
            }
            
        } else {
            consoleLog(msg: "bs98dr", level: 1)
        }
        
        
        
        
        //This is where I add gestures for static items
        let blurView_hidePanels_touchGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.gesture_clickBlurView_hideAllPanels(_:)))
        

        expanded_containerView.delegate = self
        blurView_hidePanels_touchGesture.delegate = self
        alternateViewer_SV.delegate = self
        alternateViewer_SV.tag = 5731496
        
        //Add this gesture recognizer to "theMap"
        mainContent_overlyingBlurView.addGestureRecognizer(blurView_hidePanels_touchGesture)
        
        progressBar.setThumbImage(UIImage(), for: .normal)
        progressBar.minimumTrackTintColor = spotifyGreen
        progressBar.maximumTrackTintColor = UIColor.init(red: 0.14, green: 0.14, blue: 0.14, alpha: 1)
        
        
        minimizedPlayer_progressBar.progressTintColor = spotifyGreen
        
        minimizedPlayer_progressBar.trackTintColor = UIColor.init(red: 0.14, green: 0.14, blue: 0.14, alpha: 1)
       
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    
    
    
    
    
    
    func setup_barButton(){
        
        let customBarButtonView = parameterizedButton()
        
        customBarButtonView.backgroundColor = UIColor.clear
        customBarButtonView.addTarget(self, action: #selector(ViewController.activateSearch(_:)), for: .touchUpInside)
        
        
        customBarButtonView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        customBarButtonView.setImage(#imageLiteral(resourceName: "search_w_padded"), for: .normal)
        customBarButtonView.imageView?.contentMode = .scaleAspectFill
customBarButtonView.addConstraint(NSLayoutConstraint(item: customBarButtonView, attribute: .height, relatedBy: .equal, toItem: customBarButtonView, attribute: .width, multiplier: 1, constant: 0))
        
        
        let refreshBarButton = UIBarButtonItem(customView: customBarButtonView)
     
        
        navigationItem.setRightBarButtonItems([refreshBarButton], animated: true)
    }
    
    func updateAllSubviewOf_selfView(){
        
        UIView.animate(withDuration: 0.3 , delay: 0.0, options: [.curveEaseInOut], animations: {
            
            self.view.layoutIfNeeded()
        }, completion:nil)
        
    }
    
    @objc func activateSearch(_ sender:parameterizedButton){
        
        hideAll_panels(leaveBlurViewShown: true)
        //toggle_expand_minimizedPlayer(sender_takingOver: true)
        
        self.hide_mainContent_overlyingBlurView(hideBool: false)
        
        setup_searchResults_leftBar_rightScrollView()
        consoleLog(msg: "debug: shjfk", level: 1)
        
        
            self.searchBar_height.constant = 56
        self.searchResultsContainer_Height.constant = 300;
        
        
            updateAllSubviewOf_selfView()
//            self.cancelMenuContentsButton_HeightConstraint.constant = 0
        
        self.navigationItem.rightBarButtonItem = nil
        
        let cancel_searchBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ViewController.deactivateSearch(_:)))
        
        
        self.navigationItem.rightBarButtonItem = cancel_searchBarButton
        
        
        

        
    }
    
    @objc func deactivateSearch(_ sender:parameterizedButton){
        deactivateSearch_noSender()
    }
    
    func deactivateSearch_noSender(){
        consoleLog(msg: "debug: sdfh", level: 1)
        
        if !expandedPlayer_isExpanded {
            hide_mainContent_overlyingBlurView(hideBool: true)
        }
        
        self.searchBar_height.constant = 0
        
        self.searchResultsContainer_Height.constant = 0;
        
        
        updateAllSubviewOf_selfView()
        //            self.cancelMenuContentsButton_HeightConstraint.constant = 0
        
        
        let customBarButtonView = parameterizedButton()
        
        customBarButtonView.backgroundColor = UIColor.clear
        customBarButtonView.addTarget(self, action: #selector(ViewController.activateSearch(_:)), for: .touchUpInside)
        
        
        customBarButtonView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        customBarButtonView.setImage(#imageLiteral(resourceName: "search_w_padded"), for: .normal)
        customBarButtonView.imageView?.contentMode = .scaleAspectFill
        customBarButtonView.addConstraint(NSLayoutConstraint(item: customBarButtonView, attribute: .height, relatedBy: .equal, toItem: customBarButtonView, attribute: .width, multiplier: 1, constant: 0))
        
        
        let refreshBarButton = UIBarButtonItem(customView: customBarButtonView)
        
        
        navigationItem.setRightBarButtonItems([refreshBarButton], animated: true)
    }
    func setup(){
        //1) Spotify Auth setup
        SPTAuth.defaultInstance().clientID = "99667ab175244460aacb50a456dc0714"
            SPTAuth.defaultInstance().redirectURL = URL(string: "eapp://returnAfterLogin")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
        
        //2) Default Playlist Queue setup
        let defaultPlaylist = playlist_eApp()
        defaultPlaylist.name = "none"
        defaultPlaylist.uri = "none"
        defaultPlaylist.tracks = []
        
        
        currentPlaylist = defaultPlaylist
        
        //3) Turn labels into morphing labels
        (expandedView_nameLabel as! LTMorphingLabel).morphingEffect = .evaporate
        (self.expandedView_artistLabel as! LTMorphingLabel).morphingEffect = .evaporate
        
        
        
        
        

        let customTitleView = LTMorphingLabel()
        
        customTitleView.morphingEffect = .evaporate
        customTitleView.tag = 68395
        customTitleView.addConstraint(NSLayoutConstraint(item: customTitleView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200))
        customTitleView.text = "Home"
        customTitleView.textAlignment = .center
        customTitleView.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        customTitleView.textColor = UIColor.white
        
        
        customTitleView.backgroundColor = UIColor.clear
        self.navigationItem.titleView = customTitleView
        

    }
    
    func initializaPlayer(authSession:SPTSession){
        print("player initializing")
        
        if self.player == nil {
            
            
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player?.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
            
        }
        
    }
    
    @objc func updateAfterFirstLogin () {
        
        dismiss(animated: true, completion: nil)
        consoleLog(msg: "sfasdg", level: 1)

        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
            initializaPlayer(authSession: session)
            authorizationToken = self.session.accessToken
            print("authToken: \(authorizationToken!)")
            Spartan.authorizationToken = authorizationToken
            Spartan.loggingEnabled = false
            

            finishSetup()
        }
    }
    
    func finishSetup(){
        let customBarButtonView = parameterizedButton()
        
        customBarButtonView.backgroundColor = UIColor.clear
        customBarButtonView.addTarget(self, action: #selector(ViewController.activateSearch(_:)), for: .touchUpInside)
        
        
        customBarButtonView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        customBarButtonView.setImage(#imageLiteral(resourceName: "search_w_padded"), for: .normal)
        customBarButtonView.imageView?.contentMode = .scaleAspectFill
        customBarButtonView.addConstraint(NSLayoutConstraint(item: customBarButtonView, attribute: .height, relatedBy: .equal, toItem: customBarButtonView, attribute: .width, multiplier: 1, constant: 0))
        
        
        let refreshBarButton = UIBarButtonItem(customView: customBarButtonView)
        
        
        navigationItem.setRightBarButtonItems([refreshBarButton], animated: true)
        
        
        
        ///***************************************************************
        setup_mainContent()
        setup_personalContent()
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
        
        
        self.scheduledTimerWithTimeInterval()
        
        
    }

    
    
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        localUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounting), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateServer(){
        //if (self.player?.playbackState.isPlaying)!{
        print("updatingServer")
        print(session.canonicalUsername)
        let broadcasterId = String(describing: session.canonicalUsername!)
        let currentSong_String = (self.player?.metadata.currentTrack?.uri)!
        let estimateEndTime = finishTimeString
        let queue = ""
        let currentSongDuration = (self.player?.metadata.currentTrack?.duration)!
        var playerStatus = ""
        let lastActive = String(describing: Date(timeIntervalSinceNow: 0))
        let onlineStatus = "online"
        
        if (self.player?.playbackState.isPlaying)! {
            playerStatus = "playing"
            
        } else if !(self.player?.playbackState.isPlaying)! {
            playerStatus = "paused"
        }
        
        var update_liveListeningSession_parameters = Parameters()
        update_liveListeningSession_parameters = addStandardParameters(emptyParameters: update_liveListeningSession_parameters)
        
        if thisLiveSession_id >= 0 {
            update_liveListeningSession_parameters.updateValue("UPDATE liveListenSession SET currentSong = '\(currentSong_String)', estimateEndTime = '\(estimateEndTime)', queue = '\(queue)', playerStatus = '\(playerStatus)', currentSongDuration = '\(currentSongDuration)', onlineStatus = '\(onlineStatus)', lastActive = '\(lastActive)' WHERE broadcasterId = '\(broadcasterId)'", forKey: "argument")
            print(update_liveListeningSession_parameters)
            Alamofire.request("http://www.flasheducational.com/phpScripts/update/generalUpdateBlankDBInfo.php", method: .post, parameters:update_liveListeningSession_parameters) .responseString { response in
                switch response.result {
                case .success( _):
                    
                    //This prints the value of the repsonse string
                    print("Response String: \(response.result.value!)")
                    if (response.result.value! != "Error"){
                        
                    }
                    
                case .failure(let error):
                    consoleLog(msg: "debug: wefh88", level: 5)
                    print("Request failed with error: \(error)")
                }
                
            }
            
        } else {
        update_liveListeningSession_parameters.updateValue("SELECT * FROM liveListenSession WHERE broadcasterId = '\(broadcasterId)'", forKey: "argument")
        

        
        print(update_liveListeningSession_parameters)
        
        
        Alamofire.request("http://www.flasheducational.com/phpScripts/fetch/generalSelectBlankDBInfo.php", method: .post, parameters:update_liveListeningSession_parameters) .responseJSON { response in
            switch response.result {
            case .success( _):
                consoleLog(msg: "debug:  hlkjf", level: 1)
                let this_liveListenSessionID = ((response.result.value! as! NSArray)[0] as! NSDictionary)["id"]!
                print("Share this number: \(this_liveListenSessionID)")
                self.thisLiveSession_id = Int(String(describing: this_liveListenSessionID))!
                
                
            case .failure(let error):
                print("error: \(error)")
                var parametersForInsert = update_liveListeningSession_parameters
                
                
                parametersForInsert.updateValue("INSERT INTO liveListenSession (currentSong, estimateEndTime, queue, playerStatus, broadcasterId, onlineStatus) VALUES ('\(currentSong_String)', '\(estimateEndTime)', '\(queue)', '\(playerStatus)', '\(broadcasterId)','\(onlineStatus)')", forKey: "argument")
                print("=================")
                print(error)
                print(parametersForInsert)
                Alamofire.request("http://www.flasheducational.com/phpScripts/insert/generalInsertBlankDBInfo.php", method: .post, parameters:parametersForInsert) .responseString { response in
                    
                    //This prints the value of the repsonse string
                    print("Response String: \(response.result.value!)")
                    if (response.result.value! != "Error"){
                        print("No error with insert")
                        self.navigationItem.title = "sessionID: \(response.result.value!)"
                        self.thisLiveSession_id = Int(String(response.result.value!))!
                        
                        
                        
                    } else {
                        print("yes error with insert")
                    }
                    
                }
                
            }
            }
            
        }
        
        //}
        
    }
    
    @objc func updateCounting(){
//        print("------------")
        
        if isJoinedParty {
            print("displaying party info")
            //This code is currently a modified copy of the func "updateSongInfo()" so i need to go clean that out. The biggest thing here is that i need to remove the NSDictionary intermediate that is currently being used
            
            let songName = currentSong.name!
            let artistName = currentSong.artistString!
            let albumArtURL = currentSong.albumArtURL!
            
            self.expandedView_nameLabel.text = songName
            self.expandedView_artistLabel.text = artistName
            
            if songName == "nil"  || artistName == "nil"{
                self.minimizedPlayer_view_songNameLabel.text = "Loading party info"
            } else {
                self.minimizedPlayer_view_songNameLabel.text = songName + " • " + artistName + "  "
            }
            
            
            
            
            
            /*
            SDWebImageDownloader.shared().downloadImage(with: URL(string: albumArtURL), options: .highPriority, progress:nil, completed: {
                (image, error, cacheType, url) in
                
                
                self.minimizedPlayer_thumbnail.image = image
                self.minimizedPlayer_thumbnail.contentMode = .scaleAspectFill
                
                self.expandedView_albumArtThumbnail.image = image
                self.expandedView_albumArtThumbnail.contentMode = .scaleAspectFill
                
                if self.isListening {
                    let listeningView_albumArt = self.view.viewWithTag(4377579) as! parameterizedImageView
                    listeningView_albumArt.image = image
                    listeningView_albumArt.contentMode = .scaleAspectFill
                }
                
                
            })*/
            
            
            
        } else {
            if (self.player?.initialized)! && self.player?.metadata != nil && self.player?.metadata.currentTrack != nil{
                //print("updatingCounting")
            
                let position_Double = Double((self.player?.playbackState.position)!)
                let position_Int = Int((self.player?.playbackState.position)!)
                
                
                let thisSong_Dict = NSMutableDictionary()
                
                thisSong_Dict.setValue(self.player?.metadata.currentTrack?.name, forKey: "name")
                thisSong_Dict.setValue(self.player?.metadata.currentTrack?.artistName, forKey: "artists")
                thisSong_Dict.setValue(self.player?.metadata.currentTrack?.uri, forKey: "URI")
                thisSong_Dict.setValue(self.player?.metadata.currentTrack?.albumCoverArtURL, forKey: "albumArtURL")
                
                currentSong_dict = thisSong_Dict
                

                let timeLeft_Double = Double(currentSongLength) - Double((self.player?.playbackState.position)!)
                let timeLeft_Int = Int(timeLeft_Double)
                //print(self.player)
                //print(self.player?.metadata.currentTrack)
                if self.player?.metadata.currentTrack != nil {
                    currentSongLength = Double((self.player?.metadata.currentTrack?.duration)!)
                    //print("Song Length: " + String(describing: currentSongLength))
                    //print("Position: " + String(describing: position_Int))
                    let date = Date()
                    let calendar = Calendar.current
    //                let hour = String(calendar.component(.hour, from: date))
    //                let minutes = String(calendar.component(.minute, from: date))
    //                let seconds = String(calendar.component(.second, from: date))
             
                    let finishTime = Date(timeIntervalSinceNow: timeLeft_Double)
                    //print("Now: " + hour + ":" + minutes + "." + seconds)
                    
                    finishTimeString = String(describing: finishTime)
                    
                    //print("Finish Time: " + finishTimeString)
                    if progressTracksPosition {
                    progressBar.value = Float(position_Double/currentSongLength)
                        
                        minimizedPlayer_progressBar.setProgress(Float(position_Double/currentSongLength)
    , animated: true)
                    }
                    
                    //consoleLog(msg: "time to finish: \(timeLeft_Double)", level: 1)
                    
                    
                    ep_positionTimeStamp_label.text = "\(secondsToHoursMinutesSeconds(seconds: position_Int).1):\(secondsToHoursMinutesSeconds(seconds: position_Int).2)"
                    
                    ep_remainingTimeTimeStamp_label.text = "-\(secondsToHoursMinutesSeconds(seconds: timeLeft_Int).1):\(secondsToHoursMinutesSeconds(seconds: timeLeft_Int).2)"
                    
                    
                    
                    if (timeLeft_Double > 0 && timeLeft_Double < 1.6) {
                        consoleLog(msg: "about to play next song", level: 1)
                        DispatchQueue.main.asyncAfter(deadline: .now() + timeLeft_Double - 0.1) { // change 2 to desired number of seconds
                            self.playerPlay_nextSong()
                        }
                    }
                    
                    
                }
                //Update the minimized and expanded player info
                updateSongInfo()
                
                
                
                
                
                
            }
        }
        
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if let event = event {
            if event.type == .remoteControl {
                switch event.subtype {
                    case .remoteControlPlay:
                        print("play")
                        playPause_toggle()
                    case .remoteControlPause:
                        print("pause")
                        playPause_toggle()
                    case .remoteControlNextTrack:
                        print("next")
                        nextButton_action()
                    case .remoteControlPreviousTrack:
                        print("previous")
                        previousButton_action()
                    default:
                        print("error")
                    
                }
            }
        }
    }
    
    func changePlayerPosition(){
        
        let newPosition = Double(progressBar.value) * currentSongLength
        
        self.player?.seek(to: newPosition, callback: { (error) in
            if (error != nil) {
                print("playing!")
                print(self.player?.metadata.currentTrack?.name)
            }
            
            print("move player position")
            
            
            
        })
    }
 
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.tag == 473489 {
        submitSearch()
        } else if searchBar.tag == 234596 {
            submit_listener_searchForBroadcaster(searchBar)
        } else if searchBar.tag == 56734 {
            submit_searchForParty(searchBar)
        }
    }
    
    func submitSearch(){
        
        
        
        var instance_resultsDict = [NSDictionary]()
        let instance_searchMode = searchMode
        
        
        print("searchText \(searchBar.text)")
        
        let keywords = searchBar.text
        let finalkeywords = keywords?.replacingOccurrences(of: " ", with: "+")
        
        
        let optional_accessToken  = self.session?.accessToken
        
        if optional_accessToken != nil {
            //print(self.session.accessToken)
            
            if searchMode == .track {
                let search = Spartan.search(query: finalkeywords!, type: searchMode, success: { (pagingObjects: PagingObject<SimplifiedTrack>) in
                    for item in pagingObjects.items {
                        let thisResult = NSMutableDictionary()
                        thisResult.setValue(item.name, forKey: "name")
                        thisResult.setValue(item.artists, forKey: "artists")
                        thisResult.setValue(item.uri, forKey: "URI")
                        thisResult.setValue(instance_searchMode, forKey: "resultType")
                        instance_resultsDict.append(thisResult)
                        
                    }
                    self.visualizeSearchResults(instance_searchMode: instance_searchMode, instance_resultsDict: instance_resultsDict)
                }, failure: { (error) in
                    print(error)
                })
            } else if searchMode == .album {
                let search = Spartan.search(query: finalkeywords!, type: searchMode, success: { (pagingObjects: PagingObject<SimplifiedAlbum>) in
                    for item in pagingObjects.items {
                        let thisResult = NSMutableDictionary()
                        thisResult.setValue(item.name, forKey: "name")
                        thisResult.setValue(item.artists, forKey: "artists")
                        thisResult.setValue(item.uri, forKey: "URI")
                        thisResult.setValue(instance_searchMode, forKey: "resultType")
                        instance_resultsDict.append(thisResult)
                    }
                    self.visualizeSearchResults(instance_searchMode: instance_searchMode, instance_resultsDict: instance_resultsDict)
                }, failure: { (error) in
                    print(error)
                })
            } else if searchMode == .playlist {
                let search = Spartan.search(query: finalkeywords!, type: searchMode, success: { (pagingObjects: PagingObject<SimplifiedPlaylist>) in
                    for item in pagingObjects.items {
                        let thisResult = NSMutableDictionary()
                        thisResult.setValue(item.name, forKey: "name")
                        thisResult.setValue(item.owner, forKey: "owner")
                        thisResult.setValue(item.uri, forKey: "URI")
                        thisResult.setValue(instance_searchMode, forKey: "resultType")
                        instance_resultsDict.append(thisResult)
                    }
                    self.visualizeSearchResults(instance_searchMode: instance_searchMode, instance_resultsDict: instance_resultsDict)
                }, failure: { (error) in
                    print(error)
                })
            } else if searchMode == .artist {
                let search = Spartan.search(query: finalkeywords!, type: searchMode, success: { (pagingObjects: PagingObject<SimplifiedArtist>) in
                    for item in pagingObjects.items {
                        let thisResult = NSMutableDictionary()
                        thisResult.setValue(item.name, forKey: "name")
                        thisResult.setValue(item.uri, forKey: "URI")
                        thisResult.setValue(instance_searchMode, forKey: "resultType")
                        instance_resultsDict.append(thisResult)
                    }
                    self.visualizeSearchResults(instance_searchMode: instance_searchMode, instance_resultsDict: instance_resultsDict)
                }, failure: { (error) in
                    print(error)
                })
            }
            
            
            
            
            
            
        } else {
            print("no auth token acquired")
        }
        
        
        
        
    }
    
    
    func visualizeSearchResults(instance_searchMode:ItemSearchType, instance_resultsDict:[NSDictionary]) {
        consoleLog(msg: "debug: gyk45", level: 1)
        let searchResults_SV = self.view.viewWithTag(234623) as! parameterizedScrollView
        searchResults_SV.translatesAutoresizingMaskIntoConstraints = false
        
        //The properties of the various subclasses of PagingObject are different, and they change the info displayed in the results, container, so for now we keep it as <SimplifiedTrack> just for counting purposes, and when properties need to be called, the type will be determined
        //let pagingObjects_unclassified = pagingObject as!
        
        if instance_resultsDict.count > 0 {
            clearViewOfSubviews(viewToClear: searchResults_SV)
            
            
            var dictionary_resultViews = [String : Any]()
            var stringForStacking = "V:|-(==0@900)-"
            searchResults_SV.backgroundColor = UIColor.clear
            
            //for item in pagingObject.items{
            
            for i in 0...instance_resultsDict.count-1{
                //print("Name: " + pagingObject.items[i].name)
                
                
                let resultViewInstance = parameterizedView()
                
                resultViewInstance.backgroundColor = UIColor.clear//UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
                //resultViewInstance.clipsToBounds = true
                searchResults_SV.addSubview(resultViewInstance)
                resultViewInstance.translatesAutoresizingMaskIntoConstraints = false
                
                //resultViewInstance.alpha = CGFloat(Double(item) * 0.1)
                
                
                
                searchResults_SV.addConstraint(parameterizedNSLayoutConstraint(item: searchResults_SV, attribute: .centerX, relatedBy: .equal, toItem: resultViewInstance, attribute: .centerX, multiplier: (1), constant: 0))
                
                searchResults_SV.addConstraint(parameterizedNSLayoutConstraint(item: searchResults_SV, attribute: .width, relatedBy: .equal, toItem: resultViewInstance, attribute: .width, multiplier: (1), constant: 0))
                
                resultViewInstance.addConstraint(parameterizedNSLayoutConstraint(item: resultViewInstance, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 50))
                
                //Add the search result label
                
                let result_nameLabel = parameterizedLabel()
                
                result_nameLabel.translatesAutoresizingMaskIntoConstraints = false
                resultViewInstance.addSubview(result_nameLabel)
                
                result_nameLabel.textColor = UIColor.white
                
                let result_artistLabel = parameterizedLabel()
                
                result_artistLabel.textColor = UIColor.lightGray
                result_artistLabel.translatesAutoresizingMaskIntoConstraints = false
                resultViewInstance.addSubview(result_artistLabel)
                var artistString = ""
                
                
                let resultDict_entry = instance_resultsDict[i]
                result_nameLabel.text = resultDict_entry.value(forKey: "name") as! String
                
                if instance_searchMode == .track || instance_searchMode == .album{
                    artistString = artists_toArtistString(resultDict_entry.value(forKey: "artists") as! [SimplifiedArtist])
                }
                
                
                if instance_searchMode == .playlist {
                    let ownerString = (resultDict_entry.value(forKey: "owner") as! PublicUser).displayName
                    if ownerString != nil {
                        artistString = (resultDict_entry.value(forKey: "owner") as! PublicUser).displayName!
                    }
                }
                
                
                
                
                
                
                
                
                result_artistLabel.text = artistString
                
                
                resultViewInstance.addConstraint(parameterizedNSLayoutConstraint(item: resultViewInstance, attribute: .leading, relatedBy: .equal, toItem: result_nameLabel, attribute: .leading, multiplier: (1), constant: -10))
                resultViewInstance.addConstraint(parameterizedNSLayoutConstraint(item: resultViewInstance, attribute: .trailing, relatedBy: .equal, toItem: result_nameLabel, attribute: .trailing, multiplier: (1), constant: 10))
                
                resultViewInstance.addConstraint(parameterizedNSLayoutConstraint(item: resultViewInstance, attribute: .leading, relatedBy: .equal, toItem: result_artistLabel, attribute: .leading, multiplier: (1), constant: -10))
                resultViewInstance.addConstraint(parameterizedNSLayoutConstraint(item: resultViewInstance, attribute: .trailing, relatedBy: .equal, toItem: result_artistLabel, attribute: .trailing, multiplier: (1), constant: 10))
                //resultViewInstance.addConstraint(parameterizedNSLayoutConstraint(item: resultViewInstance, attribute: .centerY, relatedBy: .equal, toItem: result_nameLabel, attribute: .centerY, multiplier: (1), constant: 0))
                
                var resultInstance_dictionaryValues = ["result_artistLabel": result_artistLabel,"result_nameLabel": result_nameLabel] as [String : Any]
                var stringFor_resultInstance_Stacking = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==6@900)-[result_nameLabel]-(==4@900)-[result_artistLabel]-(==6@900)-|", options: [], metrics: nil, views: resultInstance_dictionaryValues)
                
                resultViewInstance.addConstraints(stringFor_resultInstance_Stacking)
                
                
                self.view.layoutIfNeeded()
                //let modifiedKey = "keyK" + pagingObject.items[i].name.replacingOccurrences(of: " ", with: "")
                dictionary_resultViews.updateValue(resultViewInstance, forKey: "v\(i)")
                stringForStacking += "[v\(i)]-(==0@900)-"
                
                
                //Setup overlying button
                
                let resultViewInstance_Button = parameterizedButton()
                
                resultViewInstance_Button.backgroundColor = UIColor.clear//.init(red: 255/255, green: 25/255, blue: 25/255, alpha: 0.2)
                //resultViewInstance.clipsToBounds = true
                resultViewInstance.addSubview(resultViewInstance_Button)
                resultViewInstance_Button.translatesAutoresizingMaskIntoConstraints = false
                
                resultViewInstance_Button.dictionaryTagForPass = instance_resultsDict[i]
                
                resultViewInstance_Button.addTarget(self, action: #selector(ViewController.playTrack_fromSearch(_:)), for: .touchUpInside)
                //resultViewInstance.alpha = CGFloat(Double(item) * 0.1)
                
                
                
                resultViewInstance.addConstraint(parameterizedNSLayoutConstraint(item: resultViewInstance_Button, attribute: .centerX, relatedBy: .equal, toItem: resultViewInstance, attribute: .centerX, multiplier: (1), constant: 0))
                
                resultViewInstance.addConstraint(parameterizedNSLayoutConstraint(item: resultViewInstance_Button, attribute: .centerY, relatedBy: .equal, toItem: resultViewInstance, attribute: .centerY, multiplier: (1), constant: 0))
                
                resultViewInstance.addConstraint(parameterizedNSLayoutConstraint(item: resultViewInstance_Button, attribute: .height, relatedBy: .equal, toItem: resultViewInstance, attribute: .height, multiplier: (1), constant: 0))
                
                resultViewInstance.addConstraint(parameterizedNSLayoutConstraint(item: resultViewInstance_Button, attribute: .width, relatedBy: .equal, toItem: resultViewInstance, attribute: .width, multiplier: (1), constant: 0))
                
                
                
                
                
                
                
                
            }
            
            
            
            stringForStacking += "|"
            
            let searchResultView_instances_stackingConstraint = NSLayoutConstraint.constraints(withVisualFormat: stringForStacking, options: [], metrics: nil, views: dictionary_resultViews)
            
            searchResults_SV.addConstraints(searchResultView_instances_stackingConstraint)
            //consoleLog(msg: "String for stacking: \(stringForStacking)", level: 1)
            //consoleLog(msg: "dictionary_resultViews: \(dictionary_resultViews)", level: 1)
            //consoleLog(msg: "dictionary_resultViews.count: \(dictionary_resultViews.count)", level: 1)
            searchResults_SV.contentSize.height = CGFloat(instance_resultsDict.count * 50)
            self.view.layoutIfNeeded()
        }
    }
    
    func setup_searchResults_leftBar_rightScrollView(){
        searchResultsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        var searchResultsContainer_views = [:] as [String : Any]
        var searchResultsContainer_viewsConstraints = [NSLayoutConstraint]()
        
        
        consoleLog(msg: "searchResultsContainer.subviews.count = \(searchResultsContainer.subviews.count)", level: 1)
        if searchResultsContainer.subviews.count < 2 {
            
            //All of this creates the left bar
            
            var leftBar_containerView = parameterizedView()
            leftBar_containerView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
            leftBar_containerView .clipsToBounds = true
            searchResultsContainer.addSubview(leftBar_containerView)
            leftBar_containerView.translatesAutoresizingMaskIntoConstraints = false
            
        searchResultsContainer.addConstraint(parameterizedNSLayoutConstraint(item: leftBar_containerView, attribute: .top, relatedBy: .equal, toItem: searchResultsContainer, attribute: .top, multiplier: (1), constant: 0))
        searchResultsContainer.addConstraint(parameterizedNSLayoutConstraint(item: leftBar_containerView, attribute: .bottom, relatedBy: .equal, toItem: searchResultsContainer, attribute: .bottom, multiplier: (1), constant: 0))
            searchResultsContainer.addConstraint(parameterizedNSLayoutConstraint(item: leftBar_containerView, attribute: .leading, relatedBy: .equal, toItem: searchResultsContainer, attribute: .leading, multiplier: (1), constant: 0))
        searchResultsContainer.addConstraint(parameterizedNSLayoutConstraint(item: leftBar_containerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 75))
            
            
            

            //updateAllSubviewOf_selfView()
            
            
            //Track filter button
            let tracksFilterButton_buttonsContainer = parameterizedView()
            tracksFilterButton_buttonsContainer.backgroundColor = UIColor.clear
            tracksFilterButton_buttonsContainer.clipsToBounds = true
            leftBar_containerView.addSubview(tracksFilterButton_buttonsContainer)
            tracksFilterButton_buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
            
            
            leftBar_containerView.addConstraint(parameterizedNSLayoutConstraint(item: leftBar_containerView, attribute: .leading, relatedBy: .equal, toItem: tracksFilterButton_buttonsContainer, attribute: .leading, multiplier: (1), constant: 0))
            
            leftBar_containerView.addConstraint(parameterizedNSLayoutConstraint(item: leftBar_containerView, attribute: .trailing, relatedBy: .equal, toItem: tracksFilterButton_buttonsContainer, attribute: .trailing, multiplier: (1), constant: 0))
            
            tracksFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: tracksFilterButton_buttonsContainer, attribute: .width, relatedBy: .equal, toItem: tracksFilterButton_buttonsContainer, attribute: .height, multiplier: (1), constant: 0))
            
            //add the buttonsin the button container
            
            //add the icon button
            let tracksFilterButton_iconButton = parameterizedButton()
            tracksFilterButton_iconButton.backgroundColor = UIColor.clear
            tracksFilterButton_iconButton.setImage(#imageLiteral(resourceName: "tracks_w"), for: .normal)
            tracksFilterButton_iconButton.clipsToBounds = true
            tracksFilterButton_buttonsContainer.addSubview(tracksFilterButton_iconButton)
            tracksFilterButton_iconButton.translatesAutoresizingMaskIntoConstraints = false
            tracksFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: tracksFilterButton_buttonsContainer, attribute: .centerX, relatedBy: .equal, toItem: tracksFilterButton_iconButton, attribute: .centerX, multiplier: (1), constant: 0))
            
            tracksFilterButton_iconButton.addConstraint(parameterizedNSLayoutConstraint(item: tracksFilterButton_iconButton, attribute: .width, relatedBy: .equal, toItem: tracksFilterButton_iconButton, attribute: .height, multiplier: (1), constant: 0))
            
            //add the text button
            
            let tracksFilterButton_textButton = parameterizedButton()
            tracksFilterButton_textButton.backgroundColor = UIColor.clear
            tracksFilterButton_textButton.clipsToBounds = true
            tracksFilterButton_buttonsContainer.addSubview(tracksFilterButton_textButton)
            tracksFilterButton_textButton.translatesAutoresizingMaskIntoConstraints = false
            
            tracksFilterButton_textButton.setTitle("Tracks", for: .normal)
            tracksFilterButton_textButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)

            tracksFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: tracksFilterButton_buttonsContainer, attribute: .centerX, relatedBy: .equal, toItem: tracksFilterButton_textButton, attribute: .centerX, multiplier: (1), constant: 0))
            
            tracksFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: tracksFilterButton_textButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 10))
            consoleLog(msg: "text setup", level: 1  )
            
            
            
            let tracksFilterButton_buttonsContainerViews = ["tracksFilterButton_textButton": tracksFilterButton_textButton,"tracksFilterButton_iconButton": tracksFilterButton_iconButton] as [String : Any]
            
            let tracksButtonStackingConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==10@900)-[tracksFilterButton_iconButton]-(==7@900)-[tracksFilterButton_textButton]-(==10@900)-|", options: [], metrics: nil, views: tracksFilterButton_buttonsContainerViews)
            
            tracksFilterButton_buttonsContainer.addConstraints(tracksButtonStackingConstraint)
            
            var localSearchMode:ItemSearchType = .track
            
            tracksFilterButton_textButton.arrayTagForPass.append(localSearchMode)
            tracksFilterButton_iconButton.arrayTagForPass.append(localSearchMode)
            
            tracksFilterButton_textButton.tagForPass = "track"
            tracksFilterButton_textButton.addTarget(self, action: #selector(ViewController.changeSearchFilter(_:)), for: .touchUpInside)
            tracksFilterButton_iconButton.tagForPass = "track"
            tracksFilterButton_iconButton.addTarget(self, action: #selector(ViewController.changeSearchFilter(_:)), for: .touchUpInside)
            
            //Artist filter button
            let artistsFilterButton_buttonsContainer = parameterizedView()
            artistsFilterButton_buttonsContainer.backgroundColor = UIColor.clear
            artistsFilterButton_buttonsContainer.clipsToBounds = true
            leftBar_containerView.addSubview(artistsFilterButton_buttonsContainer)
            artistsFilterButton_buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
            
            leftBar_containerView.addConstraint(parameterizedNSLayoutConstraint(item: leftBar_containerView, attribute: .leading, relatedBy: .equal, toItem: artistsFilterButton_buttonsContainer, attribute: .leading, multiplier: (1), constant: 0))
            
            leftBar_containerView.addConstraint(parameterizedNSLayoutConstraint(item: leftBar_containerView, attribute: .trailing, relatedBy: .equal, toItem: artistsFilterButton_buttonsContainer, attribute: .trailing, multiplier: (1), constant: 0))
            
            artistsFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: artistsFilterButton_buttonsContainer, attribute: .width, relatedBy: .equal, toItem: artistsFilterButton_buttonsContainer, attribute: .height, multiplier: (1), constant: 0))
            
            //add the buttonsin the button container
            
            //add the icon button
            let artistsFilterButton_iconButton = parameterizedButton()
            artistsFilterButton_iconButton.backgroundColor = UIColor.clear
            artistsFilterButton_iconButton.setImage(#imageLiteral(resourceName: "guitar_w"), for: .normal)
            artistsFilterButton_iconButton.clipsToBounds = true
            artistsFilterButton_buttonsContainer.addSubview(artistsFilterButton_iconButton)
            artistsFilterButton_iconButton.translatesAutoresizingMaskIntoConstraints = false
            artistsFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: artistsFilterButton_buttonsContainer, attribute: .centerX, relatedBy: .equal, toItem: artistsFilterButton_iconButton, attribute: .centerX, multiplier: (1), constant: 0))
            
            artistsFilterButton_iconButton.addConstraint(parameterizedNSLayoutConstraint(item: artistsFilterButton_iconButton, attribute: .width, relatedBy: .equal, toItem: artistsFilterButton_iconButton, attribute: .height, multiplier: (1), constant: 0))
            
            //add the text button
            
            let artistsFilterButton_textButton = parameterizedButton()
            artistsFilterButton_textButton.backgroundColor = UIColor.clear
            artistsFilterButton_textButton.clipsToBounds = true
            artistsFilterButton_buttonsContainer.addSubview(artistsFilterButton_textButton)
            artistsFilterButton_textButton.translatesAutoresizingMaskIntoConstraints = false
            
            artistsFilterButton_textButton.setTitle("Artists", for: .normal)
            artistsFilterButton_textButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            
            
            artistsFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: artistsFilterButton_buttonsContainer, attribute: .centerX, relatedBy: .equal, toItem: artistsFilterButton_textButton, attribute: .centerX, multiplier: (1), constant: 0))
            
            artistsFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: artistsFilterButton_textButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 10))
            consoleLog(msg: "text setup", level: 1  )
            
            
            
            let artistsFilterButton_buttonsContainerViews = ["artistsFilterButton_textButton": artistsFilterButton_textButton,"artistsFilterButton_iconButton": artistsFilterButton_iconButton] as [String : Any]
            
            let artistsButtonStackingConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==10@900)-[artistsFilterButton_iconButton]-(==7@900)-[artistsFilterButton_textButton]-(==10@900)-|", options: [], metrics: nil, views: artistsFilterButton_buttonsContainerViews)
            
            artistsFilterButton_buttonsContainer.addConstraints(artistsButtonStackingConstraint)
            
            localSearchMode = .artist
            artistsFilterButton_textButton.arrayTagForPass.append(localSearchMode)
            artistsFilterButton_iconButton.arrayTagForPass.append(localSearchMode)
            
            artistsFilterButton_textButton.tagForPass = "artist"
            artistsFilterButton_textButton.addTarget(self, action: #selector(ViewController.changeSearchFilter(_:)), for: .touchUpInside)
            artistsFilterButton_iconButton.tagForPass = "artist"
            artistsFilterButton_iconButton.addTarget(self, action: #selector(ViewController.changeSearchFilter(_:)), for: .touchUpInside)
            
            //Album filter button
            let albumsFilterButton_buttonsContainer = parameterizedView()
            albumsFilterButton_buttonsContainer.backgroundColor = UIColor.clear
            albumsFilterButton_buttonsContainer.clipsToBounds = true
            leftBar_containerView.addSubview(albumsFilterButton_buttonsContainer)
            albumsFilterButton_buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
            
            leftBar_containerView.addConstraint(parameterizedNSLayoutConstraint(item: leftBar_containerView, attribute: .leading, relatedBy: .equal, toItem: albumsFilterButton_buttonsContainer, attribute: .leading, multiplier: (1), constant: 0))
            
            leftBar_containerView.addConstraint(parameterizedNSLayoutConstraint(item: leftBar_containerView, attribute: .trailing, relatedBy: .equal, toItem: albumsFilterButton_buttonsContainer, attribute: .trailing, multiplier: (1), constant: 0))
            
            albumsFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: albumsFilterButton_buttonsContainer, attribute: .width, relatedBy: .equal, toItem: albumsFilterButton_buttonsContainer, attribute: .height, multiplier: (1), constant: 0))
            
            
            //add the buttonsin the button container
            
            //add the icon button
            let albumsFilterButton_iconButton = parameterizedButton()
            albumsFilterButton_iconButton.backgroundColor = UIColor.clear
            albumsFilterButton_iconButton.setImage(#imageLiteral(resourceName: "album_w"), for: .normal)
            albumsFilterButton_iconButton.clipsToBounds = true
            albumsFilterButton_buttonsContainer.addSubview(albumsFilterButton_iconButton)
            albumsFilterButton_iconButton.translatesAutoresizingMaskIntoConstraints = false
            albumsFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: albumsFilterButton_buttonsContainer, attribute: .centerX, relatedBy: .equal, toItem: albumsFilterButton_iconButton, attribute: .centerX, multiplier: (1), constant: 0))
            
            albumsFilterButton_iconButton.addConstraint(parameterizedNSLayoutConstraint(item: albumsFilterButton_iconButton, attribute: .width, relatedBy: .equal, toItem: albumsFilterButton_iconButton, attribute: .height, multiplier: (1), constant: 0))
            
            //add the text button
            
            let albumsFilterButton_textButton = parameterizedButton()
            albumsFilterButton_textButton.backgroundColor = UIColor.clear
            albumsFilterButton_textButton.clipsToBounds = true
            albumsFilterButton_buttonsContainer.addSubview(albumsFilterButton_textButton)
            albumsFilterButton_textButton.translatesAutoresizingMaskIntoConstraints = false
            
            albumsFilterButton_textButton.setTitle("Albums", for: .normal)
            albumsFilterButton_textButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            
            albumsFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: albumsFilterButton_buttonsContainer, attribute: .centerX, relatedBy: .equal, toItem: albumsFilterButton_textButton, attribute: .centerX, multiplier: (1), constant: 0))
            
            albumsFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: albumsFilterButton_textButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 10))
            consoleLog(msg: "text setup", level: 1  )
            
            
            
            let albumsFilterButton_buttonsContainerViews = ["albumsFilterButton_textButton": albumsFilterButton_textButton,"albumsFilterButton_iconButton": albumsFilterButton_iconButton] as [String : Any]
            
            let albumsButtonStackingConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==10@900)-[albumsFilterButton_iconButton]-(==7@900)-[albumsFilterButton_textButton]-(==10@900)-|", options: [], metrics: nil, views: albumsFilterButton_buttonsContainerViews)
            
            albumsFilterButton_buttonsContainer.addConstraints(albumsButtonStackingConstraint)
            
            
            localSearchMode = .album
            albumsFilterButton_textButton.arrayTagForPass.append(localSearchMode)
            albumsFilterButton_iconButton.arrayTagForPass.append(localSearchMode)
            
            albumsFilterButton_textButton.tagForPass = "album"
            albumsFilterButton_textButton.addTarget(self, action: #selector(ViewController.changeSearchFilter(_:)), for: .touchUpInside)
            albumsFilterButton_iconButton.tagForPass = "album"
            albumsFilterButton_iconButton.addTarget(self, action: #selector(ViewController.changeSearchFilter(_:)), for: .touchUpInside)
            
            //Playlist filter button
            let playlistsFilterButton_buttonsContainer = parameterizedView()
            playlistsFilterButton_buttonsContainer.backgroundColor = UIColor.clear
            playlistsFilterButton_buttonsContainer.clipsToBounds = true
            leftBar_containerView.addSubview(playlistsFilterButton_buttonsContainer)
            playlistsFilterButton_buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
            
            leftBar_containerView.addConstraint(parameterizedNSLayoutConstraint(item: leftBar_containerView, attribute: .leading, relatedBy: .equal, toItem: playlistsFilterButton_buttonsContainer, attribute: .leading, multiplier: (1), constant: 0))
            
            leftBar_containerView.addConstraint(parameterizedNSLayoutConstraint(item: leftBar_containerView, attribute: .trailing, relatedBy: .equal, toItem: playlistsFilterButton_buttonsContainer, attribute: .trailing, multiplier: (1), constant: 0))
            
            playlistsFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: playlistsFilterButton_buttonsContainer, attribute: .width, relatedBy: .equal, toItem: playlistsFilterButton_buttonsContainer, attribute: .height, multiplier: (1), constant: 0))
            
            
            
            //add the buttonsin the button container
            
            //add the icon button
            let playlistsFilterButton_iconButton = parameterizedButton()
            playlistsFilterButton_iconButton.backgroundColor = UIColor.clear
            playlistsFilterButton_iconButton.setImage(#imageLiteral(resourceName: "playlist_w"), for: .normal)
            playlistsFilterButton_iconButton.clipsToBounds = true
            playlistsFilterButton_buttonsContainer.addSubview(playlistsFilterButton_iconButton)
            playlistsFilterButton_iconButton.translatesAutoresizingMaskIntoConstraints = false
            playlistsFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: playlistsFilterButton_buttonsContainer, attribute: .centerX, relatedBy: .equal, toItem: playlistsFilterButton_iconButton, attribute: .centerX, multiplier: (1), constant: 0))
            
            playlistsFilterButton_iconButton.addConstraint(parameterizedNSLayoutConstraint(item: playlistsFilterButton_iconButton, attribute: .width, relatedBy: .equal, toItem: playlistsFilterButton_iconButton, attribute: .height, multiplier: (1), constant: 0))
            
            //add the text button
            
            let playlistsFilterButton_textButton = parameterizedButton()
            playlistsFilterButton_textButton.backgroundColor = UIColor.clear
            playlistsFilterButton_textButton.clipsToBounds = true
            playlistsFilterButton_buttonsContainer.addSubview(playlistsFilterButton_textButton)
            playlistsFilterButton_textButton.translatesAutoresizingMaskIntoConstraints = false
            
            playlistsFilterButton_textButton.setTitle("playlists", for: .normal)
            playlistsFilterButton_textButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            
            playlistsFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: playlistsFilterButton_buttonsContainer, attribute: .centerX, relatedBy: .equal, toItem: playlistsFilterButton_textButton, attribute: .centerX, multiplier: (1), constant: 0))
            
            playlistsFilterButton_buttonsContainer.addConstraint(parameterizedNSLayoutConstraint(item: playlistsFilterButton_textButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 10))
            consoleLog(msg: "text setup", level: 1  )
            
            
            
            let playlistsFilterButton_buttonsContainerViews = ["playlistsFilterButton_textButton": playlistsFilterButton_textButton,"playlistsFilterButton_iconButton": playlistsFilterButton_iconButton] as [String : Any]
            
            let playlistsButtonStackingConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==10@900)-[playlistsFilterButton_iconButton]-(==7@900)-[playlistsFilterButton_textButton]-(==10@900)-|", options: [], metrics: nil, views: playlistsFilterButton_buttonsContainerViews)
            
            playlistsFilterButton_buttonsContainer.addConstraints(playlistsButtonStackingConstraint)
            
            
            localSearchMode = .playlist
            playlistsFilterButton_textButton.arrayTagForPass.append(localSearchMode)
            playlistsFilterButton_iconButton.arrayTagForPass.append(localSearchMode)
            
            playlistsFilterButton_textButton.tagForPass = "playlist"
            playlistsFilterButton_textButton.addTarget(self, action: #selector(ViewController.changeSearchFilter(_:)), for: .touchUpInside)
            playlistsFilterButton_iconButton.tagForPass = "playlist"
            playlistsFilterButton_iconButton.addTarget(self, action: #selector(ViewController.changeSearchFilter(_:)), for: .touchUpInside)
            
            
            //Finish setting up constraints for overall left bar
            
            
            let leftBarView = ["playlistsFilterButton_buttonsContainer": playlistsFilterButton_buttonsContainer,"albumsFilterButton_buttonsContainer": albumsFilterButton_buttonsContainer,"artistsFilterButton_buttonsContainer": artistsFilterButton_buttonsContainer,"tracksFilterButton_buttonsContainer": tracksFilterButton_buttonsContainer] as [String : Any]
            
            let stackingConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==0@900)-[tracksFilterButton_buttonsContainer]-(==0@900)-[artistsFilterButton_buttonsContainer]-(==0@900)-[albumsFilterButton_buttonsContainer]-(==0@900)-[playlistsFilterButton_buttonsContainer]-(==0@900)-|", options: [], metrics: nil, views: leftBarView)
            
            leftBar_containerView.addConstraints(stackingConstraint)
            
            //updateAllSubviewOf_selfView()
            
            
            
            //All of this creates the right container for the search results
            

            
            var rightSearchContainer_containerView = parameterizedScrollView()
            rightSearchContainer_containerView.tag = 234623
            rightSearchContainer_containerView.backgroundColor = UIColor.init(red: 22/255, green: 22/255, blue: 22/255, alpha: 0.4)
            rightSearchContainer_containerView.clipsToBounds = true
            searchResultsContainer.addSubview(rightSearchContainer_containerView)
            rightSearchContainer_containerView.translatesAutoresizingMaskIntoConstraints = false
            
            searchResultsContainer.addConstraint(parameterizedNSLayoutConstraint(item: rightSearchContainer_containerView, attribute: .top, relatedBy: .equal, toItem: searchResultsContainer, attribute: .top, multiplier: (1), constant: 0))
            searchResultsContainer.addConstraint(parameterizedNSLayoutConstraint(item: rightSearchContainer_containerView, attribute: .bottom, relatedBy: .equal, toItem: searchResultsContainer, attribute: .bottom, multiplier: (1), constant: 0))
            searchResultsContainer.addConstraint(parameterizedNSLayoutConstraint(item: rightSearchContainer_containerView, attribute: .trailing, relatedBy: .equal, toItem: searchResultsContainer, attribute: .trailing, multiplier: (1), constant: 0))
            searchResultsContainer.addConstraint(parameterizedNSLayoutConstraint(item: rightSearchContainer_containerView, attribute: .width, relatedBy: .equal, toItem: searchResultsContainer, attribute: .width, multiplier: (1), constant: -75))
            
            
            
            
            
            //updateAllSubviewOf_selfView()
            self.view.layoutIfNeeded()
            
            
            
            consoleLog(msg: "searchResultsContainer.subviews.count = \(searchResultsContainer.subviews.count)", level: 1)
        }
        
    }
    
    @objc func changeSearchFilter(_ sender: parameterizedButton){
        consoleLog(msg: "\(sender.tagForPass)", level: 1)
        
        searchMode = sender.arrayTagForPass[0] as! ItemSearchType
        
        submitSearch()
    }
    
    @objc func playTrack_fromSearch(_ sender: parameterizedButton){
        consoleLog(msg: "debug:sdfhjk", level: 1)
        
        
        self.view.endEditing(true)
        
        
        let trackToPlay = track_eApp(isFromQueue: false, isSuggestion: false, suggestor: "hostUser_self")
        
        trackToPlay.name = sender.dictionaryTagForPass.value(forKey: "name")! as? String
        trackToPlay.uri = sender.dictionaryTagForPass.value(forKey: "URI")! as? String
        trackToPlay.sourceType = "searchResult"
        trackToPlay.source_name = "Search Result"
        
        
        playNewSong(trackToPlay: trackToPlay, onlyArm: false)
    
}

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }

    func toggle_expand_minimizedPlayer(sender_takingOver:Bool){
        
        if sender_takingOver {
            hide_expandedPlayerView(hideBool: true)
            hide_mainContent_overlyingBlurView(hideBool: true)
            expandedPlayer_isExpanded = false
            
        } else {
            if expandedPlayer_isExpanded{
                hide_expandedPlayerView(hideBool: true)
                hide_mainContent_overlyingBlurView(hideBool: true)
                expandedPlayer_isExpanded = false
                deactivateSearch_noSender()
            } else {
                hide_expandedPlayerView(hideBool: false)
                hide_mainContent_overlyingBlurView(hideBool: false)
                expandedPlayer_isExpanded = true
                deactivateSearch_noSender()
            }
        }
    }
    
    
    
    
    @objc func gesture_clickBlurView_hideAllPanels(_ sender:UITapGestureRecognizer){
        hideAll_panels(leaveBlurViewShown: false)
    }
    
    func updateSongInfo(){
        
        let songName = currentSong_dict.value(forKey: "name") as! String
        let artistName = currentSong_dict.value(forKey: "artists") as! String
        let albumArtURL = currentSong_dict.value(forKey: "albumArtURL") as! String
        
        self.expandedView_nameLabel.text = songName
        self.expandedView_artistLabel.text = artistName


        
        self.minimizedPlayer_view_songNameLabel.text = songName + " • " + artistName + "  "
        
        //print("after begin playback")
        
        
        SDWebImageDownloader.shared().downloadImage(with: URL(string: albumArtURL), options: .highPriority, progress:nil, completed: {
            (image, error, cacheType, url) in
            
            
            self.minimizedPlayer_thumbnail.image = image
            self.minimizedPlayer_thumbnail.contentMode = .scaleAspectFill
            
            self.expandedView_albumArtThumbnail.image = image
            self.expandedView_albumArtThumbnail.contentMode = .scaleAspectFill
            
            if self.isListening {
                let listeningView_albumArt = self.view.viewWithTag(4377579) as! parameterizedImageView
                listeningView_albumArt.image = image
                listeningView_albumArt.contentMode = .scaleAspectFill
            }
            
            
        })
        
        
        
    }
    
    func setup_expandedViewQueue(){
        let queue_SV = parameterizedView()
        
        queue_SV.backgroundColor = UIColor.init(red: 0.13, green: 0.13, blue: 0.13, alpha: 0.5)
        
        expanded_containerView.addSubview(queue_SV)
        expanded_containerView.translatesAutoresizingMaskIntoConstraints = false
        queue_SV.translatesAutoresizingMaskIntoConstraints = false
        
        //resultViewInstance.alpha = CGFloat(Double(item) * 0.1)
        
        
        
        expanded_containerView.addConstraint(parameterizedNSLayoutConstraint(item: queue_SV, attribute: .top, relatedBy: .equal, toItem: expanded_containerView, attribute: .top, multiplier: (1), constant: 0))
        expanded_containerView.addConstraint(parameterizedNSLayoutConstraint(item: queue_SV, attribute: .bottom, relatedBy: .equal, toItem: expanded_containerView, attribute: .bottom, multiplier: (1), constant: 0))
        self.view.addConstraint(parameterizedNSLayoutConstraint(item: queue_SV, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: (1), constant: 0))
        
        
        
        
        //Add headerContainer
        
        let queue_headerContainer = parameterizedView()
        
        queue_headerContainer.backgroundColor = UIColor.clear
        
        queue_SV.addSubview(queue_headerContainer)
        queue_headerContainer.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        queue_SV.addConstraint(parameterizedNSLayoutConstraint(item: queue_SV, attribute: .top, relatedBy: .equal, toItem: queue_headerContainer, attribute: .top, multiplier: (1), constant: 0))
        queue_SV.addConstraint(parameterizedNSLayoutConstraint(item: queue_SV, attribute: .left, relatedBy: .equal, toItem: queue_headerContainer, attribute: .left, multiplier: (1), constant: 0))
        queue_SV.addConstraint(parameterizedNSLayoutConstraint(item: queue_SV, attribute: .right, relatedBy: .equal, toItem: queue_headerContainer, attribute: .right, multiplier: (1), constant: 0))
        
        queue_headerContainer.addConstraint(parameterizedNSLayoutConstraint(item: queue_headerContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 60))
        
        
        //Add headerTitle
        
        let queue_backButton = parameterizedButton()
        queue_backButton.setImage(#imageLiteral(resourceName: "back_w"), for: .normal)
        
        queue_backButton.backgroundColor = UIColor.clear
        
        queue_headerContainer.addSubview(queue_backButton)
        queue_backButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        queue_headerContainer.addConstraint(parameterizedNSLayoutConstraint(item: queue_backButton, attribute: .top, relatedBy: .equal, toItem: queue_headerContainer, attribute: .top, multiplier: (1), constant: 10))
        queue_headerContainer.addConstraint(parameterizedNSLayoutConstraint(item: queue_backButton, attribute: .bottom, relatedBy: .equal, toItem: queue_headerContainer, attribute: .bottom, multiplier: (1), constant: -10))
        
        queue_headerContainer.addConstraint(parameterizedNSLayoutConstraint(item: queue_backButton, attribute: .left, relatedBy: .equal, toItem: queue_headerContainer, attribute: .left, multiplier: (1), constant: 10))
        queue_backButton.addConstraint(parameterizedNSLayoutConstraint(item: queue_backButton, attribute: .height, relatedBy: .equal, toItem: queue_backButton, attribute: .width, multiplier: (1), constant: 0))
        
        
        queue_backButton.addTarget(self, action: #selector(ViewController.backFromQueue(_:)), for: .touchUpInside)
        
        //Add header button
        
        let queue_titleLabel = parameterizedLabel()
        
        queue_titleLabel.backgroundColor = UIColor.clear
        queue_titleLabel.textColor = UIColor.white
        queue_titleLabel.textAlignment = .center
        queue_titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        queue_titleLabel.text = "Playing from..."
        queue_titleLabel.tag = 37846
        
        queue_headerContainer.addSubview(queue_titleLabel)
        queue_titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        queue_headerContainer.addConstraint(parameterizedNSLayoutConstraint(item: queue_titleLabel, attribute: .top, relatedBy: .equal, toItem: queue_headerContainer, attribute: .top, multiplier: (1), constant: 10))
        queue_headerContainer.addConstraint(parameterizedNSLayoutConstraint(item: queue_titleLabel, attribute: .bottom, relatedBy: .equal, toItem: queue_headerContainer, attribute: .bottom, multiplier: (1), constant: -10))
        
        queue_headerContainer.addConstraint(parameterizedNSLayoutConstraint(item: queue_backButton, attribute: .right, relatedBy: .equal, toItem: queue_titleLabel, attribute: .left, multiplier: (1), constant: -10))
        
        queue_headerContainer.addConstraint(parameterizedNSLayoutConstraint(item: queue_headerContainer, attribute: .right, relatedBy: .equal, toItem: queue_titleLabel, attribute: .right, multiplier: (1), constant: 40))
        
        //Add SV for queue contents

        let queue_contentsSV = parameterizedScrollView()
        queue_contentsSV.tag = 96726
        
        queue_contentsSV.backgroundColor = UIColor.purple
        
        queue_SV.addSubview(queue_contentsSV)
        queue_contentsSV.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        queue_SV.addConstraint(parameterizedNSLayoutConstraint(item: queue_SV, attribute: .bottom, relatedBy: .equal, toItem: queue_contentsSV, attribute: .bottom, multiplier: (1), constant: 0))
        
        queue_SV.addConstraint(parameterizedNSLayoutConstraint(item: queue_headerContainer, attribute: .bottom, relatedBy: .equal, toItem: queue_contentsSV, attribute: .top, multiplier: (1), constant: 0))
        
        queue_SV.addConstraint(parameterizedNSLayoutConstraint(item: queue_SV, attribute: .left, relatedBy: .equal, toItem: queue_contentsSV, attribute: .left, multiplier: (1), constant: 0))
        queue_SV.addConstraint(parameterizedNSLayoutConstraint(item: queue_SV, attribute: .right, relatedBy: .equal, toItem: queue_contentsSV, attribute: .right, multiplier: (1), constant: 0))
        
        
        
        
        
        
        var expandedView_internalViewDict = [String : Any]()
        
        
        expandedView_internalViewDict.updateValue(expandedPlayerView, forKey: "expandedPlayerView")
        expandedView_internalViewDict.updateValue(queue_SV, forKey: "queue_SV")
        
        var horiz_stringForStacking = "H:|-(==0@900)-[expandedPlayerView]-(==0@900)-[queue_SV]-(==0@900)-|"
        
        
        let horiz_expandedViewConstraint = NSLayoutConstraint.constraints(withVisualFormat: horiz_stringForStacking, options: [], metrics: nil, views: expandedView_internalViewDict)
        
        expanded_containerView.addConstraints(horiz_expandedViewConstraint)
    
    self.view.layoutIfNeeded()
        updateQueue()
        
    }
    
    
    
    
    func offsetSV(_ SV: UIScrollView, _ page: Int){
        
        let pageWidth = Float(self.view.frame.width)
        let offsetPoint = CGPoint(x: page * Int(pageWidth), y: 0)
        SV.setContentOffset(offsetPoint, animated: true)
    }

    func updateQueue(){
        let queueTitleLabel = self.view.viewWithTag(37846) as! parameterizedLabel
        var combined_upcoming:[track_eApp] = []
        
        if isJoinedParty {
            queueTitleLabel.text = "Playing from: \(joinedParty.partyName!)"
            combined_upcoming = joinedParty.queue!
            print("Party tracks: \(combined_upcoming.count)")
        } else {
            queueTitleLabel.text = "Playing from: \(currentPlaylist.name!)"
            combined_upcoming = queue + currentPlaylist.tracks
        }
        //This piece dispalys how many tracks are from each potential source:
        // 1) the playlist, 2) the host's queue, 3) suggestions
        let playlistTrack_count = check_trackTypes(combined_upcoming).0
        let hostQueue_count = check_trackTypes(combined_upcoming).1
        let suggestions_count = check_trackTypes(combined_upcoming).2
        
        
        //Need to create the containers accordingly, and create the containers, accordingly
        //Then need to assign each track to its proper container, AFTER the necessary containers are created
        
        
        consoleLog(msg: "updating queue", level: 1)
        consoleLog(msg: (currentPlaylist.name)!, level: 1)
        print(check_trackTypes(combined_upcoming))
        //consoleLog(msg: "\(currentPlaylist.tracks!.count)", level: 1)
        
        let upcomingContents_SV = self.view.viewWithTag(96726) as! parameterizedScrollView
        var dictionary_summativeContents = [String : Any]()
        
        clearViewOfSubviews(viewToClear: upcomingContents_SV)
        upcomingContents_SV.backgroundColor = UIColor.clear
        
        
        let queueContents_contentsView = UIView()
        queueContents_contentsView.translatesAutoresizingMaskIntoConstraints = false
        queueContents_contentsView.backgroundColor = UIColor.clear
        upcomingContents_SV.addSubview(queueContents_contentsView)
        dictionary_summativeContents.updateValue(queueContents_contentsView, forKey: "queueContents")
        
        
        upcomingContents_SV.addConstraint(parameterizedNSLayoutConstraint(item: upcomingContents_SV, attribute: .width, relatedBy: .equal, toItem: queueContents_contentsView, attribute: .width, multiplier: (1), constant: 0))
        upcomingContents_SV.addConstraint(parameterizedNSLayoutConstraint(item: upcomingContents_SV, attribute: .left, relatedBy: .equal, toItem: queueContents_contentsView, attribute: .left, multiplier: (1), constant: 0))
        upcomingContents_SV.addConstraint(parameterizedNSLayoutConstraint(item: upcomingContents_SV, attribute: .right, relatedBy: .equal, toItem: queueContents_contentsView, attribute: .right, multiplier: (1), constant: 0))
        
        let playlistContents_contentsView = UIView()
        playlistContents_contentsView.translatesAutoresizingMaskIntoConstraints = false
        playlistContents_contentsView.backgroundColor = UIColor.clear
        upcomingContents_SV.addSubview(playlistContents_contentsView)
        dictionary_summativeContents.updateValue(playlistContents_contentsView, forKey: "playlistContents")
        
        
        
        upcomingContents_SV.addConstraint(parameterizedNSLayoutConstraint(item: upcomingContents_SV, attribute: .width, relatedBy: .equal, toItem: playlistContents_contentsView, attribute: .width, multiplier: (1), constant: 0))
        upcomingContents_SV.addConstraint(parameterizedNSLayoutConstraint(item: upcomingContents_SV, attribute: .left, relatedBy: .equal, toItem: playlistContents_contentsView, attribute: .left, multiplier: (1), constant: 0))
        upcomingContents_SV.addConstraint(parameterizedNSLayoutConstraint(item: upcomingContents_SV, attribute: .right, relatedBy: .equal, toItem: playlistContents_contentsView, attribute: .right, multiplier: (1), constant: 0))
        
        var stringForStacking_summativeContainers = "V:|-(==0@900)-[queueContents]-(==0@900)-[playlistContents]-(==0@900)-|"
        
        let qSV_summativeContainers_verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: stringForStacking_summativeContainers, options: [], metrics: nil, views: dictionary_summativeContents)
        
        upcomingContents_SV.addConstraints(qSV_summativeContainers_verticalConstraint)
        
        
        
        
        
        if combined_upcoming.count > 1 {
            
            
            var stringForStacking_queueContents = "V:|-(==0@800)-"
            var stringForStacking_playlistContents = "V:|-(==0@850)-"
            
            var dictionary_queueContents = [String : Any]()
            var dictionary_playlistContents = [String : Any]()
            
            for k in 0...combined_upcoming.count-1{
                
                
                var this_upcomingTrack = combined_upcoming[k]
                //Without this conditional, all songs in the playlist will show up on the queue - essentially it means that songs we've already passed will show up in the queue. This keeps track, visually, of where we are in the playlist. This only gets bypassed when someone is in a party because a party member doesn't need to keep track of where in a playlist the host is. This is because they can't go forward or backward in the list. its simply a non-interactive visual of whats coming up next. the "location in source" for all upcoming items is -1 when the user is has joined a party.
                if !this_upcomingTrack.isFromQueue && !this_upcomingTrack.isSuggestion && (this_upcomingTrack.locationInSource)! <= locationInPlaylist && !isJoinedParty{
                    print("songs location in source: \(this_upcomingTrack.locationInSource!)")
                    print("users location in playlist: \(self.locationInPlaylist)")
                
                } else {
                let upcomingItem_Container = parameterizedView()
                
                
                var receiverViewUIView:UIView!
                
                upcomingItem_Container.translatesAutoresizingMaskIntoConstraints = false
                
                            if this_upcomingTrack.isSuggestion {
                                upcomingItem_Container.backgroundColor = purplePreset_075
                                receiverViewUIView = queueContents_contentsView
                                
                                dictionary_queueContents.updateValue(upcomingItem_Container, forKey: "upcomingItem\(k)")
                                stringForStacking_queueContents += "[upcomingItem\(k)]-(==0@900)-"
                            } else if this_upcomingTrack.isFromQueue {
                                upcomingItem_Container.backgroundColor = bluePreset_075
                                receiverViewUIView = queueContents_contentsView
                                
                                dictionary_queueContents.updateValue(upcomingItem_Container, forKey: "upcomingItem\(k)")
                                stringForStacking_queueContents += "[upcomingItem\(k)]-(==0@900)-"
                            } else {
                                //This section of the conditional refers to tracks that come from a playlist.
                                print(this_upcomingTrack.locationInSource)
                                upcomingItem_Container.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.1)
                                receiverViewUIView = playlistContents_contentsView
                                
                                dictionary_playlistContents.updateValue(upcomingItem_Container, forKey: "upcomingItem\(k)")
                                stringForStacking_playlistContents += "[upcomingItem\(k)]-(==0@900)-"
                            }
                
                receiverViewUIView.addSubview(upcomingItem_Container)
                
                receiverViewUIView.addConstraint(parameterizedNSLayoutConstraint(item: receiverViewUIView, attribute: .centerX, relatedBy: .equal, toItem: upcomingItem_Container, attribute: .centerX, multiplier: (1), constant: 0))
                receiverViewUIView.addConstraint(parameterizedNSLayoutConstraint(item: receiverViewUIView, attribute: .width, relatedBy: .equal, toItem: upcomingItem_Container, attribute: .width, multiplier: (1), constant: 0))
                upcomingItem_Container.addConstraint(parameterizedNSLayoutConstraint(item: upcomingItem_Container, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 50))
                
                
                
                
                let upcomingItem_nameLabel = parameterizedLabel()
                
                upcomingItem_nameLabel.translatesAutoresizingMaskIntoConstraints = false
                upcomingItem_Container.addSubview(upcomingItem_nameLabel)
                
                upcomingItem_nameLabel.textColor = UIColor.white
                
                let upcomingItem_artistLabel = parameterizedLabel()
                
                upcomingItem_artistLabel.textColor = UIColor.lightGray
                upcomingItem_artistLabel.translatesAutoresizingMaskIntoConstraints = false
                upcomingItem_Container.addSubview(upcomingItem_artistLabel)
                
                
                upcomingItem_nameLabel.text = (this_upcomingTrack.name)!
                upcomingItem_artistLabel.text = (this_upcomingTrack.artistString)!
                
                upcomingItem_Container.addConstraint(parameterizedNSLayoutConstraint(item: upcomingItem_Container, attribute: .leading, relatedBy: .equal, toItem: upcomingItem_nameLabel, attribute: .leading, multiplier: (1), constant: -10))
                upcomingItem_Container.addConstraint(parameterizedNSLayoutConstraint(item: upcomingItem_Container, attribute: .trailing, relatedBy: .equal, toItem: upcomingItem_nameLabel, attribute: .trailing, multiplier: (1), constant: 10))
                
                upcomingItem_Container.addConstraint(parameterizedNSLayoutConstraint(item: upcomingItem_Container, attribute: .leading, relatedBy: .equal, toItem: upcomingItem_artistLabel, attribute: .leading, multiplier: (1), constant: -10))
                upcomingItem_Container.addConstraint(parameterizedNSLayoutConstraint(item: upcomingItem_Container, attribute: .trailing, relatedBy: .equal, toItem: upcomingItem_artistLabel, attribute: .trailing, multiplier: (1), constant: 10))
                
                
                let upcomingItem_dictionaryValues = ["upcomingItem_artistLabel": upcomingItem_artistLabel,"upcomingItem_nameLabel": upcomingItem_nameLabel] as [String : Any]
                let stringFor_upcomingItem_Stacking = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==6@900)-[upcomingItem_nameLabel]-(==4@900)-[upcomingItem_artistLabel]-(==6@900)-|", options: [], metrics: nil, views: upcomingItem_dictionaryValues)
                
                upcomingItem_Container.addConstraints(stringFor_upcomingItem_Stacking)
                
                let upcomingItem_overlyingButton = parameterizedButton()
                upcomingItem_overlyingButton.backgroundColor = UIColor.clear
                upcomingItem_overlyingButton.associatedTrk = this_upcomingTrack
                upcomingItem_overlyingButton.addTarget(self, action: #selector(ViewController.selectSong_inQueue(_:)), for: .touchUpInside)
                
                upcomingItem_Container.addSubview(upcomingItem_overlyingButton)
                upcomingItem_overlyingButton.translatesAutoresizingMaskIntoConstraints = false
                
                
                
                upcomingItem_Container.addConstraint(parameterizedNSLayoutConstraint(item: upcomingItem_Container, attribute: .top, relatedBy: .equal, toItem: upcomingItem_overlyingButton, attribute: .top, multiplier: (1), constant: 0))
                upcomingItem_Container.addConstraint(parameterizedNSLayoutConstraint(item: upcomingItem_Container, attribute: .bottom, relatedBy: .equal, toItem: upcomingItem_overlyingButton, attribute: .bottom, multiplier: (1), constant: 0))
                upcomingItem_Container.addConstraint(parameterizedNSLayoutConstraint(item: upcomingItem_nameLabel, attribute: .left, relatedBy: .equal, toItem: upcomingItem_overlyingButton, attribute: .left, multiplier: (1), constant: 0))
                upcomingItem_Container.addConstraint(parameterizedNSLayoutConstraint(item: upcomingItem_nameLabel, attribute: .right, relatedBy: .equal, toItem: upcomingItem_overlyingButton, attribute: .right, multiplier: (1), constant: 0))
                
                self.view.layoutIfNeeded()
                
            }
            }
            
            stringForStacking_queueContents += "|"
            stringForStacking_playlistContents += "|"
            
            
            
            
            
            if (hostQueue_count + suggestions_count) > 0 {
                let queueContainer_objects_heightConstraint = NSLayoutConstraint.constraints(withVisualFormat: stringForStacking_queueContents, options: [], metrics: nil, views: dictionary_queueContents)
                queueContents_contentsView.addConstraints(queueContainer_objects_heightConstraint)
            }
            
            if (playlistTrack_count) > 0 {
                let playlistContainer_objects_heightConstraint = NSLayoutConstraint.constraints(withVisualFormat: stringForStacking_playlistContents, options: [], metrics: nil, views: dictionary_playlistContents)
                playlistContents_contentsView.addConstraints(playlistContainer_objects_heightConstraint)
            }
            
        }
        
        
        
        //This begin the segment for displaying queue items rather than playlist items
        
        
    //This ends the segment for creating containers for the queue items and begins the creation of playlist item containers
        
        
        
        
        
        
        else {
            if queue.count < 1 {
                let noQItems_notifLabel = parameterizedLabel()
                noQItems_notifLabel.backgroundColor = UIColor.clear
                noQItems_notifLabel.textColor = UIColor.lightGray
                noQItems_notifLabel.text = "You are not playing from any given playlist."
                noQItems_notifLabel.numberOfLines = 0
                noQItems_notifLabel.textAlignment = .center
                noQItems_notifLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
                upcomingContents_SV.addSubview(noQItems_notifLabel)
                noQItems_notifLabel.translatesAutoresizingMaskIntoConstraints = false
                
                upcomingContents_SV.addConstraint(parameterizedNSLayoutConstraint(item: upcomingContents_SV, attribute: .centerX, relatedBy: .equal, toItem: noQItems_notifLabel, attribute: .centerX, multiplier: (1), constant: 0))
               
                upcomingContents_SV.addConstraint(parameterizedNSLayoutConstraint(item: upcomingContents_SV, attribute: .centerY, relatedBy: .equal, toItem: noQItems_notifLabel, attribute: .centerY, multiplier: (1), constant: 0))
                
                upcomingContents_SV.addConstraint(parameterizedNSLayoutConstraint(item: upcomingContents_SV, attribute: .width, relatedBy: .equal, toItem: noQItems_notifLabel, attribute: .width, multiplier: (1), constant: 100))
            }
            
        }
        
        
        
        //queueContents_SV.contentSize.height = CGFloat((currentPlaylist.tracks!.count)! * 50)
        self.view.layoutIfNeeded()
        if isPartyModeOn {
            updateServer_scopeEquals_allQueueAllParty()
        }
                
    }
    

    @objc func playerPlay_nextSong(){
        
        if self.currentSong.locationInSource == -1 {
            self.player?.seek(to: 0, callback: { (error) in
                if (error != nil) {
                    
                    consoleLog(msg: "\(error)", level: 1)
                } else {
                    self.player?.setIsPlaying(false, callback: nil)
                }
            })
        } else {
            
            if queue.count > 0 {
                consoleLog(msg: "There's a song in the queue", level: 1)
                self.playNewSong(trackToPlay: queue[0], onlyArm: false )
                queue.remove(at: 0)
                
            } else {
            
                let indexInSource = locationInPlaylist
                let lastIndex_inSource = (self.currentPlaylist.tracks!.last?.locationInSource)!
                if indexInSource < lastIndex_inSource {
                    self.playNewSong(trackToPlay: (self.currentPlaylist.tracks![indexInSource + 1]), onlyArm: false)
                } else if indexInSource == lastIndex_inSource {
                    if repeatOn{
                        self.playNewSong(trackToPlay: (self.currentPlaylist.tracks![0]), onlyArm: false )
                        
                    } else {
                        self.playNewSong(trackToPlay: (self.currentPlaylist.tracks![0]), onlyArm: true)
                    }
                }
            }
            
        
        }
        
    }
    
    
    
    func playNewSong(trackToPlay:track_eApp, onlyArm: Bool, position:TimeInterval = 0){
        
        if isJoinedParty {
            
        } else {
            
            print("playing uri: \(trackToPlay.uri)")
            self.player?.playSpotifyURI(trackToPlay.uri!, startingWith: 0, startingWithPosition: position, callback: { (error) in
                if (error != nil) {
                    
                    
                } else {
                    print("playing!")
                    //This conditional sets the current location in playlist = to the location in source of the new song ONLY IF its from the playlist, not if its from the queue
                    if !trackToPlay.isFromQueue && !trackToPlay.isSuggestion {
                        
                        self.locationInPlaylist = trackToPlay.locationInSource!
                        
                    }
                    print("songs location in source: \(trackToPlay.locationInSource!)")
                    print("users location in playlist: \(self.locationInPlaylist)")
                    //print(self.player?.metadata.currentTrack?.name)
                    if onlyArm {
                        self.player?.setIsPlaying(false, callback: nil)
                    }
                    
                    self.currentSong = trackToPlay
                    if trackToPlay.source_uri == nil {
                        print("trackToPlay.source_uri is nil")
                        
                        let thisPlaylist = playlist_eApp()
                        thisPlaylist.name = trackToPlay.source_name
                        thisPlaylist.uri = trackToPlay.source_uri
                        thisPlaylist.tracks =  [trackToPlay]
                        
                        
                        self.currentPlaylist = thisPlaylist
                        
                        self.updateQueue()
                        
                    } else {
                        
                        let playlistURI_plain = spotify_playlistURI_to_ownerID_AND_playlistID(uriString: trackToPlay.source_uri!)
                        
                        
                        
                        
                        print("trackToPlay.source_uri is \(trackToPlay.source_uri)")
                        
                        _ = Spartan.getPlaylistTracks(userId: playlistURI_plain.0, playlistId: playlistURI_plain.1, limit: 100, offset: 0, fields: nil, market: .us, success: { (pagingObject) in
                            var tracksInPlaylist = [track_eApp]()
                            for i in 0...pagingObject.items.count-1 {
                                let item = pagingObject.items[i]
                                print("trackname: " + item.track.name)
                                //Had some confusion understanding how this area of code is reached - tf the variables for trk in the initialization might be wrong/might need to be adjusted
                                let trk = track_eApp(isFromQueue: false, isSuggestion: false, suggestor: "hostUser_self")
                                
                                trk.name = item.track.name
                                trk.artistString = artists_toArtistString(item.track.artists)
                                trk.albumArtURL = item.track.album.images[0].url
                                trk.uri = item.track.uri
                                trk.sourceType = trackToPlay.sourceType
                                trk.source_uri = trackToPlay.source_uri
                                trk.source_name = trackToPlay.source_name
                                trk.source_owner = trackToPlay.source_owner
                                trk.locationInSource = i
                                
                                
                                
                                tracksInPlaylist.append(trk)
                                
                                
                            }
                            
                            let thisPlaylist = playlist_eApp()
                            
                            thisPlaylist.name = trackToPlay.source_name
                            thisPlaylist.uri = trackToPlay.source_uri
                            thisPlaylist.tracks = tracksInPlaylist
                            
                            
                            self.currentPlaylist = thisPlaylist
                            
                            self.updateQueue()
                            
                         
                            }, failure: { (error) in
                                print(error)
                            })
                    }
                    
                    
                    
                }
                
                
            })
            
        }
        
    }
    
    @objc func backFromQueue(_ sender: parameterizedButton){
        offsetSV(expanded_containerView, 0)
    }
    
    @objc func selectSong_inQueue(_ sender: parameterizedButton){
        playNewSong(trackToPlay: sender.arrayTagForPass[0] as! track_eApp, onlyArm: false)
    }
    
    func playerIsInitializedANDArmed()->Bool{
        let player = self.player
        if player == nil {
            return false
        } else {
            let track:SPTPlaybackTrack? = player?.metadata.currentTrack
            if track == nil {
                return false
            } else {
                return true
            }
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if isPlaying{
            self.viewerButton_outlet.isHidden = false
            localUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounting), userInfo: nil, repeats: true)
            if isBroadcasting {
                //This timer just runs the update script periodically to kinda keep things in check. It is not fired constantly to preserve battery. In addition, this script is run when any important action occurs, so likely, this timer might be overkill. tbd later w.r.t. battery and data resources and
                serverUpdatetimer = Timer.scheduledTimer(timeInterval: 2.1, target: self, selector: #selector(updateServer), userInfo: nil, repeats: true)
            }
            playPauseButton_outlet.setImage(#imageLiteral(resourceName: "pause_w"), for: .normal)
        } else {
            localUpdateTimer.invalidate()
            
            //TODO: Need to setup alamofire script to notify paused. otherwise will think playing still and will have listener keep listening because the DB moves based on estimated finish time
            playPauseButton_outlet.setImage(#imageLiteral(resourceName: "play_w"), for: .normal)
            
            
        }
    }


    @objc func loginWithSpotify_button(_ sender:parameterizedButton){
        //let url = URL(string: "https://www.google.com")
        if auth.canHandle(auth.redirectURL) {
            let vc = SFSafariViewController(url: loginUrl!)
            present(vc, animated: true, completion:
                nil
                
            )
            
            // To do - build in error handling
            print("sdf8dyf")
        }
    
        

        
        /*if UIApplication.shared.openURL(loginUrl!) {
            print("asdgas7")
            
        }*/
    }
        
    
    func showEntryPortal(){
        let loading_coverView = parameterizedView()
        loading_coverView.tag = 348629346
        
        loading_coverView.backgroundColor = UIColor.black//UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        //resultViewInstance.clipsToBounds = true
        self.view.addSubview(loading_coverView)
        loading_coverView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
        self.view.addConstraint(parameterizedNSLayoutConstraint(item: self.view, attribute: .centerX, relatedBy: .equal, toItem: loading_coverView, attribute: .centerX, multiplier: (1), constant: 0))
        self.view.addConstraint(parameterizedNSLayoutConstraint(item: self.view, attribute: .centerY, relatedBy: .equal, toItem: loading_coverView, attribute: .centerY, multiplier: (1), constant: 0))
        self.view.addConstraint(parameterizedNSLayoutConstraint(item: self.view, attribute: .width, relatedBy: .equal, toItem: loading_coverView, attribute: .width, multiplier: (1), constant: 0))
        self.view.addConstraint(parameterizedNSLayoutConstraint(item: self.view, attribute: .height, relatedBy: .equal, toItem: loading_coverView, attribute: .height, multiplier: (1), constant: 0))
        
        
        //Add image
        let coverView_logo = parameterizedImageView()
        coverView_logo.tag = 326923457
        coverView_logo.backgroundColor = UIColor.clear//UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        //resultViewInstance.clipsToBounds = true
        coverView_logo.image = #imageLiteral(resourceName: "logo_v1_transparentBackground")
        loading_coverView.addSubview(coverView_logo)
        coverView_logo.translatesAutoresizingMaskIntoConstraints = false
        
        loading_coverView.addConstraint(parameterizedNSLayoutConstraint(item: coverView_logo, attribute: .centerX, relatedBy: .equal, toItem: loading_coverView, attribute: .centerX, multiplier: (1), constant: 0))
        
        loading_coverView.addConstraint(parameterizedNSLayoutConstraint(item: coverView_logo, attribute: .centerY, relatedBy: .equal, toItem: loading_coverView, attribute: .centerY, multiplier: (1), constant: -80))
        
        loading_coverView.addConstraint(parameterizedNSLayoutConstraint(item: coverView_logo, attribute: .width, relatedBy: .equal, toItem: loading_coverView, attribute: .width, multiplier: (1), constant: -80))
        
        coverView_logo.addConstraint(parameterizedNSLayoutConstraint(item: coverView_logo, attribute: .width, relatedBy: .equal, toItem: coverView_logo, attribute: .height, multiplier: (1), constant: 0))
        
        //Add login button
        let coverView_loginButton = parameterizedButton()
        coverView_loginButton.tag = 87654232357
        coverView_loginButton.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
        coverView_loginButton.setTitle("LOGIN WITH SPOTIFY", for: .normal)
        coverView_loginButton.titleLabel?.font = UIFont.init(name: "Avenir", size: 20)
        
        loading_coverView.addSubview(coverView_loginButton)
        coverView_loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        loading_coverView.addConstraint(parameterizedNSLayoutConstraint(item: coverView_loginButton, attribute: .bottom, relatedBy: .equal, toItem: loading_coverView, attribute: .bottom, multiplier: (1), constant: -50))
        
        loading_coverView.addConstraint(parameterizedNSLayoutConstraint(item: coverView_loginButton, attribute: .centerX, relatedBy: .equal, toItem: loading_coverView, attribute: .centerX, multiplier: (1), constant: 0))
        
        loading_coverView.addConstraint(parameterizedNSLayoutConstraint(item: coverView_loginButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 50))
        
        loading_coverView.addConstraint(parameterizedNSLayoutConstraint(item: coverView_loginButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 270))
        
        coverView_loginButton.layer.cornerRadius = 25
        
        
        //loading_coverView.addConstraint(parameterizedNSLayoutConstraint(item: coverView_loginButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 200))
        
        coverView_loginButton.addTarget(self, action: #selector(ViewController.loginWithSpotify_button(_:)), for: .touchUpInside)
    }
    
    @objc func select_playlist(_ sender:parameterizedButton){
        
        
        
        let selectedPlaylist_instance = (sender.arrayTagForPass[0] as! SimplifiedPlaylist)
        print("Selected Playlist Name: \(selectedPlaylist_instance.name)")
        print("Selected Playlist Instance: \(selectedPlaylist_instance)")
        
        setupAlternateView(selectedPlaylist_instance, action: "viewPlaylist")
        
    }
    
    
    
    func setupAlternateView(_ sender: Any, action: String){
        print("sender")
        
        clearViewOfSubviews(viewToClear: alternateView_body)
        alternateView_body.tag = 3869545
        alternateView_body.delegate = self
        
        if action == "viewPlaylist" {
            let selectedPlaylist = sender as! SimplifiedPlaylist
            alternateView_headerLabel.text = selectedPlaylist.name
            
            let playlistURI_plain = spotify_playlistURI_to_ownerID_AND_playlistID(uriString: selectedPlaylist.uri)
            
            print(selectedPlaylist.name)
            print(playlistURI_plain)
            print(selectedPlaylist.owner.displayName)
            
            
            let tracksPerIteration = 50
            let numberOfIterations_forFullContents_double = Double(Double(String(selectedPlaylist.tracksObject.total!))!/Double(tracksPerIteration))
            let numberOfIterations_forFullContents_Int_roundDown = Double(String(Double(Double(String(selectedPlaylist.tracksObject.total!))!/Double(tracksPerIteration))).split(separator: ".")[0])!
            
            print("numberOfIterations_forFullContents_RoundDoub: \(numberOfIterations_forFullContents_Int_roundDown)")
            print("numberOfIterations_forFullContents_RawDoub: \(numberOfIterations_forFullContents_double)")
            
            var finalNumber_iterationsNecessary = 0
            if numberOfIterations_forFullContents_double > numberOfIterations_forFullContents_Int_roundDown {
                finalNumber_iterationsNecessary = Int(numberOfIterations_forFullContents_Int_roundDown) + 1
            } else {
                finalNumber_iterationsNecessary = Int(numberOfIterations_forFullContents_Int_roundDown)
            }
            
            print("finalNumber_iterationsNecessary: \(finalNumber_iterationsNecessary)")
            
            
            _ = Spartan.getPlaylistTracks(userId: playlistURI_plain.0, playlistId: playlistURI_plain.1, limit: tracksPerIteration, offset: 0, fields: nil, market: .us, success: { (pagingObject) in
                consoleLog(msg: "Playlist Name: \(selectedPlaylist.name)", level: 1)
                var dictionary_sFPl_containers = [String : Any]()
                var stringForStacking = "V:|-(==0@900)-"
                for m in 0...pagingObject.items.count-1 {
                    let item = pagingObject.items[m]
                    print(item.track.name)
                    
                    
                    
                    
                        let sFPl_container = parameterizedView()
                        
                        sFPl_container.backgroundColor = UIColor.clear
                        //sFPl_container.alpha = 1 - (CGFloat(i) * 0.10)
                        
                        
                    self.alternateView_body.addSubview(sFPl_container)
                        sFPl_container.translatesAutoresizingMaskIntoConstraints = false
                        
                        self.alternateView_body.addConstraint(parameterizedNSLayoutConstraint(item: self.alternateView_body, attribute: .centerX, relatedBy: .equal, toItem: sFPl_container, attribute: .centerX, multiplier: (1), constant: 0))
                    self.alternateView_body.addConstraint(parameterizedNSLayoutConstraint(item: self.alternateView_body, attribute: .width, relatedBy: .equal, toItem: sFPl_container, attribute: .width, multiplier: (1), constant: 0))
                        sFPl_container.addConstraint(parameterizedNSLayoutConstraint(item: sFPl_container, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: (1), constant: 50))
                        
                        
                        
                        //Add more button
                        
                        let sFPl_moreButton = parameterizedImageView()
                        sFPl_moreButton.backgroundColor = UIColor.clear
                        sFPl_moreButton.contentMode = .scaleAspectFit
                        sFPl_moreButton.translatesAutoresizingMaskIntoConstraints = false
                        sFPl_moreButton.image = #imageLiteral(resourceName: "rightArrow_w")
                        sFPl_container.addSubview(sFPl_moreButton)
                        
                        sFPl_container.addConstraint(parameterizedNSLayoutConstraint(item: sFPl_container, attribute: .trailing, relatedBy: .equal, toItem: sFPl_moreButton, attribute: .trailing, multiplier: (1), constant: 12))
                        sFPl_container.addConstraint(parameterizedNSLayoutConstraint(item: sFPl_container, attribute: .top, relatedBy: .equal, toItem: sFPl_moreButton, attribute: .top, multiplier: (1), constant: -12))
                        sFPl_container.addConstraint(parameterizedNSLayoutConstraint(item: sFPl_container, attribute: .bottom, relatedBy: .equal, toItem: sFPl_moreButton, attribute: .bottom, multiplier: (1), constant: 12))
                        sFPl_moreButton.addConstraint(parameterizedNSLayoutConstraint(item: sFPl_moreButton, attribute: .height, relatedBy: .equal, toItem: sFPl_moreButton, attribute: .width, multiplier: (1), constant: 0))
                        
                        //Add labels
                        
                        
                        
                        
                        let sFPl_nameLabel = parameterizedLabel()
                        
                        sFPl_nameLabel.textColor = UIColor.white
                        sFPl_nameLabel.translatesAutoresizingMaskIntoConstraints = false
                        sFPl_container.addSubview(sFPl_nameLabel)
                        
                        
                        let sFPl_trackDataLabel = parameterizedLabel()
                        
                        sFPl_trackDataLabel.textColor = UIColor.lightGray
                    sFPl_trackDataLabel.font = UIFont.systemFont(ofSize: 11)
                        sFPl_trackDataLabel.translatesAutoresizingMaskIntoConstraints = false
                        sFPl_container.addSubview(sFPl_trackDataLabel)
                        
                        
                        sFPl_nameLabel.text = item.track.name
                            sFPl_trackDataLabel.text = artists_toArtistString(item.track.artists)
                        
                        
                        
                        sFPl_container.addConstraint(parameterizedNSLayoutConstraint(item: sFPl_container, attribute: .leading, relatedBy: .equal, toItem: sFPl_nameLabel, attribute: .leading, multiplier: (1), constant: -10))
                        sFPl_container.addConstraint(parameterizedNSLayoutConstraint(item: sFPl_moreButton, attribute: .leading, relatedBy: .equal, toItem: sFPl_nameLabel, attribute: .trailing, multiplier: (1), constant: 25))
                        
                        sFPl_container.addConstraint(parameterizedNSLayoutConstraint(item: sFPl_container, attribute: .leading, relatedBy: .equal, toItem: sFPl_trackDataLabel, attribute: .leading, multiplier: (1), constant: -10))
                        sFPl_container.addConstraint(parameterizedNSLayoutConstraint(item: sFPl_moreButton, attribute: .leading, relatedBy: .equal, toItem: sFPl_trackDataLabel, attribute: .trailing, multiplier: (1), constant: 25))
                    
                    
                    
                    
                    
                    
                    //setup overlyingButton
                    let sFPl_overlyingButton = parameterizedButton()
                    sFPl_overlyingButton.backgroundColor = UIColor.clear
                    
                    sFPl_overlyingButton.arrayTagForPass.append(item)
                   
                    let dict = NSMutableDictionary()
                    dict.setValue(selectedPlaylist.uri, forKey: "sourceURI")
                   
                    
                    
                    dict.setValue(selectedPlaylist.name, forKey: "sourceName")
                    dict.setValue(selectedPlaylist.owner.displayName, forKey: "sourceOwner")
                    dict.setValue(m, forKey: "locationInSource")
                    
                    sFPl_overlyingButton.dictionaryTagForPass = dict
                    
                    
                    
                    
                    
                    sFPl_container.addSubview(sFPl_overlyingButton)
                    sFPl_overlyingButton.translatesAutoresizingMaskIntoConstraints = false
                    sFPl_container.addConstraint(parameterizedNSLayoutConstraint(item: sFPl_container, attribute: .top, relatedBy: .equal, toItem: sFPl_overlyingButton, attribute: .top, multiplier: (1), constant: 0))
                    sFPl_container.addConstraint(parameterizedNSLayoutConstraint(item: sFPl_container, attribute: .bottom, relatedBy: .equal, toItem: sFPl_overlyingButton, attribute: .bottom, multiplier: (1), constant: 0))
                    sFPl_container.addConstraint(parameterizedNSLayoutConstraint(item: sFPl_container, attribute: .left, relatedBy: .equal, toItem: sFPl_overlyingButton, attribute: .left, multiplier: (1), constant: 0))
                    sFPl_container.addConstraint(parameterizedNSLayoutConstraint(item: sFPl_container, attribute: .right, relatedBy: .equal, toItem: sFPl_overlyingButton, attribute: .right, multiplier: (1), constant: 0))
                    
                    
                    
                    sFPl_overlyingButton.addTarget(self, action: #selector(ViewController.playlistTrk_pressed(_:)), for: .touchUpInside)
                    
                    
                    
                        
                        
                        var sFPl_internalContentsDict = ["sFPl_trackDataLabel": sFPl_trackDataLabel,"sFPl_nameLabel": sFPl_nameLabel] as [String : Any]
                        var stringFor_sFPl_Stacking = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==6@900)-[sFPl_nameLabel]-(==4@900)-[sFPl_trackDataLabel]-(==6@900)-|", options: [], metrics: nil, views: sFPl_internalContentsDict)
                        
                        sFPl_container.addConstraints(stringFor_sFPl_Stacking)
                        
                        
                        self.view.layoutIfNeeded()
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        dictionary_sFPl_containers.updateValue(sFPl_container, forKey: "sFPlItem\(m)")
                        stringForStacking += "[sFPlItem\(m)]-(==0@900)-"
                    }
                    stringForStacking += "|"
                    let sFPl_stackingConstraint = NSLayoutConstraint.constraints(withVisualFormat: stringForStacking, options: [], metrics: nil, views: dictionary_sFPl_containers)
                    
                self.alternateView_body.addConstraints(sFPl_stackingConstraint)
                    
                    self.view.layoutIfNeeded()
                self.toggleAlternateView(show: true)
                    
                
            }, failure: { (error) in
                print(error)
            })
            
            
            
            
            
            
            
           
        }
    }
    
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: self.player?.metadata.currentTrack?.name,
            //MPMediaItemPropertyAlbumTitle: file.album?.title ?? "",
            MPMediaItemPropertyArtist: self.player?.metadata.currentTrack?.artistName,
            MPMediaItemPropertyPlaybackDuration: self.player?.metadata.currentTrack?.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: position
        ]
      
    }
    
    @objc func playlistTrk_pressed(_ sender: parameterizedButton){
        consoleLog(msg: "pressed playlistTrk", level: 1)
        print(sender.arrayTagForPass[0])
        print(sender.dictionaryTagForPass)
        let thisPlaylistTrack = sender.arrayTagForPass[0] as! PlaylistTrack
        
        
        
        let trackToPlay = track_eApp(isFromQueue: false, isSuggestion: false, suggestor: "hostUser_self")
        
        trackToPlay.name = thisPlaylistTrack.track.name
        trackToPlay.artistString = artists_toArtistString(thisPlaylistTrack.track.artists)
        trackToPlay.uri = thisPlaylistTrack.track.uri
        trackToPlay.sourceType = "playlist"
        trackToPlay.source_uri = sender.dictionaryTagForPass.value(forKey: "sourceURI")! as? String
        trackToPlay.source_name = sender.dictionaryTagForPass.value(forKey: "sourceName")! as? String
        trackToPlay.source_owner = sender.dictionaryTagForPass.value(forKey: "sourceOwner")! as? String
        trackToPlay.locationInSource = sender.dictionaryTagForPass.value(forKey: "locationInSource")! as? Int
        
        playNewSong(trackToPlay: trackToPlay, onlyArm: false)
    }
    
    
    func updateServer_broadcastOffline(){
        //if (self.player?.playbackState.isPlaying)!{
        print("updatingServer")
        print(session.canonicalUsername)
        let broadcasterId = String(describing: session.canonicalUsername!)
        let currentSong_param = "status_offline"//(self.player?.metadata.currentTrack?.uri)!
        let estimateEndTime = "status_offline"//finishTimeString
        let queue = "status_offline"
        let currentSongDuration = "status_offline"
        var playerStatus = ""
        let lastActive = String(describing: Date(timeIntervalSinceNow: 0))
        let onlineStatus = "offline"
        if (self.player?.playbackState.isPlaying)! {
            playerStatus = "playing"
            
        } else if !(self.player?.playbackState.isPlaying)! {
            playerStatus = "paused"
        }
        
        var update_liveListeningSession_parameters = Parameters()
        update_liveListeningSession_parameters = addStandardParameters(emptyParameters: update_liveListeningSession_parameters)
        
        if thisLiveSession_id >= 0 {
            update_liveListeningSession_parameters.updateValue("UPDATE liveListenSession SET currentSong = '\(currentSong_param)', estimateEndTime = '\(estimateEndTime)', queue = '\(queue)', playerStatus = '\(playerStatus)', currentSongDuration = '\(currentSongDuration)', onlineStatus = '\(onlineStatus)', lastActive = '\(lastActive)' WHERE broadcasterId = '\(broadcasterId)'", forKey: "argument")
            print(update_liveListeningSession_parameters)
            Alamofire.request("http://www.flasheducational.com/phpScripts/update/generalUpdateBlankDBInfo.php", method: .post, parameters:update_liveListeningSession_parameters) .responseString { response in
                switch response.result {
                case .success( _):
                    
                    //This prints the value of the repsonse string
                    print("Response String: \(response.result.value!)")
                    if (response.result.value! != "Error"){
                        
                    }
                    
                case .failure(let error):
                    consoleLog(msg: "debug: wefh88", level: 5)
                    print("Request failed with error: \(error)")
                }
                
            }
            
        }
        
        //}
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 3869545 {
            
            //print(scrollView.contentOffset)
            
            
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("checkingIf SV wanted here --- SVTAG = \(scrollView.tag)")
        if scrollView.tag >= 4000000 {
            print("SV dragged and stopped")
        }
    }
    
    func updateServer_scopeEquals_allQueueAllParty(){
        
        
            print("updatingServer with queue and party info")
            print(session.canonicalUsername)
            let broadcasterId = String(describing: session.canonicalUsername!)
        
        let totalQueue = queue + (currentPlaylist.tracks)!
        
        var db_queueString = ""
        
        
        for song in totalQueue {
            
            if !song.isFromQueue && !song.isSuggestion && (song.locationInSource)! <= locationInPlaylist{
                
                
            } else {
            
            /* The format of the queueString will be as follows w.r.t. delimiters:
             ..!..[song name]||[uri]||[artists]||[isFromQueue]||[isSuggestion]||[suggestor]..!..
             */
            db_queueString += "..!..\(song.name!)||\(song.uri!)||\(song.artistString!)||\(song.isFromQueue!)||\(song.isSuggestion!)||\(song.suggestor!)"
            print(song.name!)
            }
            
        }
        db_queueString += "..!.."
        db_queueString = alamoFire_cleansing(db_queueString, deviceToServer: true)
        
        print("songs in overall queue = \(totalQueue.count)")
        print(db_queueString.count)
        let queueString = db_queueString
        let currentSong_String = (self.player?.metadata.currentTrack?.uri)!
        var partyStatus = "nil"
        if isPartyModeOn {
            partyStatus = "active"
            
        } else {
            partyStatus = "inactive"
        }
        
        
        
            var updateServer_scopeEquals_allQueueAllParty_parameters = Parameters()
            updateServer_scopeEquals_allQueueAllParty_parameters = addStandardParameters(emptyParameters: updateServer_scopeEquals_allQueueAllParty_parameters)
        
        
         
                updateServer_scopeEquals_allQueueAllParty_parameters.updateValue("UPDATE liveListenSession SET queue = '\(queueString)', partyStatus = '\(partyStatus)', partyName = '\(partyName)', partyPassword = '\(partyPassword)', currentSong = '\(currentSong_String)' WHERE broadcasterId = '\(broadcasterId)'", forKey: "argument")
                print(updateServer_scopeEquals_allQueueAllParty_parameters)
                Alamofire.request("http://www.flasheducational.com/phpScripts/update/generalUpdateBlankDBInfo.php", method: .post, parameters:updateServer_scopeEquals_allQueueAllParty_parameters) .responseString { response in
                    switch response.result {
                    case .success( _):
                        print("party queue updated")
                        //This prints the value of the repsonse string
                        //print("Response String: \(response.result.value!)")
                        if (response.result.value! != "Error"){
                            
                        }
                        
                    case .failure(let error):
                        consoleLog(msg: "debug: wefh88", level: 5)
                        print("Request failed with error: \(error)")
                    }
                    
         
                
            }
            
        
        }
    
}



