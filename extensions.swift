//
//  extensions.swift
//  cheerOn
//
//  Created by Christopher Guirguis on 3/13/17.
//  Copyright © 2017 Christopher Guirguis. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import Spartan
import Alamofire
//import FacebookCore
//import FBSDKLoginKit
//import VectorArithmetic


//========================================================================

public var canBeginUpdatingLocationInDatabase = false
public var currentEntryEntity:NSArray = []
public var currentUserEntity:NSDictionary = [:]
public var currentUserEntity_from_SQLdb:NSDictionary = [:]
public var currentEvent = ""
public var currentOrganizer:NSDictionary = [:]

public var all_races = [NSDictionary]()

var watcher_activeRunner:[watcher_activeRunner_annotation] = []
//Used a dictionary because the keys are easy to call, despite not even entering values for the entrys
var listOf_entrysBeingTracked:NSMutableDictionary = [:]
var runnerUpdating = Timer()
var watcher_liveTracking = Timer()

var mapSender = ""

var location_fromAppDel = CLLocationCoordinate2D.init()

var current_racerFor_calculations = ""

//This will save the last 30 points
var runner_currentPaceHistory:[Double] = [1]

//This will save the last 300 points
var runner_longTermPaceHistory:[Double] = [1]

//========================================================================


precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: CGFloat, power: CGFloat) -> CGFloat {
    return CGFloat(pow(CGFloat(radix), CGFloat(power)))
}

func ^^ (radix: Double, power: Double) -> Double {
    return Double(pow(Double(radix), Double(power)))
}

extension Int {
    
    
    
    func isDivisibleBy(divisibleBy:Int) -> Bool{
        if (round(Double(self)/Double(divisibleBy)) == Double(self)/Double(divisibleBy)){
            return true
        } else {
            return false
        }
    }
}

func addPolyLineToMap(locations: [CLLocation], mapToEdit:MKMapView)
{
    var coordinates = locations.map({ (location: CLLocation!) -> CLLocationCoordinate2D in
        return location.coordinate
    })
    
    
    let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
    
    mapToEdit.add(polyline)
}



extension Double {
    func absoluteValue() -> Double{
        if (self > 0){
            return self
        } else {
            return (self * -1)
        }
    }
    
    func roundTo(_ decimals: Int) -> Double{
        let dividend = 10 ^^ Double(decimals)
        let x = self
        let y = Double(Darwin.round(dividend*x)/dividend)
        return y
    }
    
    func doubleMin_toMinSec() -> (String, String){
        if self.isFinite {let stringForm = String(self)
            
            let leftDecimalString = String(Int(Double(stringForm.components(separatedBy: ".")[0])!))
            let rightDecimalString = "." + stringForm.components(separatedBy: ".")[1]
            var rightDecimalString_asSec = String(Int((Double(rightDecimalString)!*60).rounded()))
            
            if rightDecimalString_asSec.characters.count == 1{
                rightDecimalString_asSec = "0" + rightDecimalString_asSec
            }
            
            return(leftDecimalString, rightDecimalString_asSec)
        } else {
            return ("paceTooHigh","paceTooHigh")
        }
    }
}

func pythagoreanHypotenus(leg1: Double, leg2: Double) -> Double {
    
    let aSquared_plus_bSquared = (leg1.absoluteValue() ^^ 2) + (leg2.absoluteValue() ^^ 2)
    let c = sqrt(aSquared_plus_bSquared)
    return c
}

func pythagoreanLeg(leg1: Double, hypotenus: Double) -> Double {
    
    let cSquared_minus_aSquared = (hypotenus.absoluteValue() ^^ 2) - (leg1.absoluteValue() ^^ 2)
    let b = sqrt(cSquared_minus_aSquared)
    return b
}





var logLevel = 5

func consoleLog(msg:String, level:Int){
    if (level <= logLevel){
        print(msg)
    }
}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

func addStandardParameters(emptyParameters:Parameters) -> Parameters{
    var transientParameters = emptyParameters
    transientParameters.updateValue("flasheducationalcom.domaincommysql.com", forKey: "host")
    transientParameters.updateValue("eapp", forKey: "db")
    transientParameters.updateValue("1f90326fde", forKey: "dbUser")
    transientParameters.updateValue("125687394beeco", forKey: "dbPass")
    return transientParameters
    
}

extension UIView {
    func paramNSLayoutConstraint_withTagForPass(_ queryTag:String) -> NSLayoutConstraint {
        var returnConstraint = NSLayoutConstraint()
        self.constraints.forEach({
            if ($0 is parameterizedNSLayoutConstraint){
                if (($0 as! parameterizedNSLayoutConstraint).tagForPass == queryTag){
                    returnConstraint = $0
                }
            }
        })
        return returnConstraint
    }
    
    func addStandardShadow(offsetX:CGFloat,offsetY:CGFloat){
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 3
    }
    
    func paramView_withTagForPass(_ queryTag:String) -> UIView {
        var returnView = UIView()
        self.subviews.forEach({
            if ($0 is parameterizedButton){
                if (($0 as! parameterizedButton).tagForPass == queryTag){
                    returnView = $0
                }
            } else if ($0 is parameterizedView){
                if (($0 as! parameterizedView).tagForPass == queryTag){
                    returnView = $0
                }
            } else if ($0 is parameterizedLabel){
                if (($0 as! parameterizedLabel).tagForPass == queryTag){
                    returnView = $0
                }
            }
        })
        return returnView
    }
    
    
    func paramViews_withClassTagForPass(_ queryTag:String) -> [UIView] {
        var returnView = [UIView]()
        self.subviews.forEach({
            if ($0 is parameterizedButton){
                consoleLog(msg: "paramButtonFound", level: 5)
                if (($0 as! parameterizedButton).classTagForPass == queryTag){
                    returnView.append($0)
                }
            } else if ($0 is parameterizedView){
                consoleLog(msg: "paramViewFound", level: 5)
                if (($0 as! parameterizedView).classTagForPass == queryTag){
                    returnView.append($0)
                }
            }
        })
        return returnView
    }
}


public extension MKPolyline {
    public var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: self.pointCount)
        
        self.getCoordinates(&coords, range: NSRange(location: 0, length: self.pointCount))
        
        return coords
    }
}

extension String {
    func stringToCoordinate() -> [CLLocationCoordinate2D]{
        var coordinatesForReturn = [CLLocationCoordinate2D]()
        var coordinateList = self.components(separatedBy: "__")
        coordinateList.removeLast()
        for coordinateString in coordinateList{
            coordinatesForReturn.append(CLLocationCoordinate2D(latitude: Double(coordinateString.components(separatedBy: "_")[0])!, longitude: Double(coordinateString.components(separatedBy: "_")[1])!))
        }
        return coordinatesForReturn
    }
    
    func force_letNilString() -> String {
        
        if self == nil {
            return "nil"
        } else {
            return self
        }
    }
    
    
}



func clearViewOfSubviews(viewToClear:UIView){
    viewToClear.subviews.forEach({ $0.removeFromSuperview() })
}

func getRandomColor_fromColorScheme() -> (CGFloat, CGFloat, CGFloat){
    let colorArray:[[CGFloat]] = [
    [0,0,1],
    [0,1,0],
    [0,1,1],
    [1,0,0],
    [1,0,1],
    [1,1,0],
    [1,1,1]
    ]
    
    let randomColor_index = Int(arc4random_uniform(UInt32(colorArray.count-1)))
    return (colorArray[randomColor_index][0], colorArray[randomColor_index][1], colorArray[randomColor_index][2])
}

func degreesToRadians(degrees:Double) -> Double{
    return (M_PI * Double(degrees) / 180.0)
    
}


func getAngle(deltaY:Double, deltaX:Double, inDegrees: Bool) -> Double {
    //The negative is because we were getting negative values when we wanted positive for some reason
    
    var radians = atan2(Double(-deltaY), Double(deltaX))
    
    if (radians < 0) {
        
        
        radians = (2 * M_PI) + radians;
    }
    
    
    
    if inDegrees {
        radians = radians * (180/M_PI)
    }
    return Double(radians)
}


func average(arrayToAverage:[Double]) -> Double{
    var average:Double = 0
    var total:Double = 0
    if (arrayToAverage.count != 0){
        for i in 0...arrayToAverage.count-1{
            total += arrayToAverage[i]
        }
        average = total/Double(arrayToAverage.count)
    }
    
    return average
}

func sum(arrayToSum:[Double]) -> Double{
    
    var total:Double = 0
    if (arrayToSum.count != 0){
        for i in 0...arrayToSum.count-1{
            total += arrayToSum[i]
        }
    }
    return Double(total)
}



func nearestPoint_fromGivenPoint(givenPoint: CLLocationCoordinate2D, opposing_pointList: [CLLocationCoordinate2D]) -> Double{
    
    var current_closestDistance:Double = 1000000000000000
    var indexFor_nearestPoint:Double = -1
    for i in 0...opposing_pointList.count-1{
        let leg1 = givenPoint.latitude - opposing_pointList[i].latitude
        let leg2 = givenPoint.longitude - opposing_pointList[i].longitude
        let thisDistance = hav_distance_answerIn_meters(lat1: givenPoint.latitude, lon1: givenPoint.longitude, lat2: opposing_pointList[i].latitude, lon2: opposing_pointList[i].longitude)
        if thisDistance < current_closestDistance{
            current_closestDistance = thisDistance
            indexFor_nearestPoint = Double(i)
        }
    }
    
    return indexFor_nearestPoint
}

func serialDistance_coordsInArray_fromIndices_answerIn_meters(startIndex:Int, endIndex:Int, coordArray:[CLLocationCoordinate2D]) -> Double{
    var totalDistance:Double = 0
    //need the " + 1" because technically toure doing the loop with +1 and we do that becauase youre checking between two points and you start from the point at the start index to the point after the start index  
    if startIndex + 1 < endIndex{
        //will return in meters
        consoleLog(msg: "debug: u84wh", level: 5)
        consoleLog(msg: "\(startIndex+1)", level: 5)
        consoleLog(msg: "\(endIndex)", level: 5)
        for i in startIndex+1...endIndex{
            totalDistance += hav_distance_answerIn_meters(lat1: coordArray[i-1].latitude, lon1: coordArray[i-1].longitude, lat2: coordArray[i].latitude, lon2: coordArray[i].longitude)
        }
        consoleLog(msg: "This Seg - Serial Dist - mUniversal: \(totalDistance)", level: 5)
        
        
    } else {
        totalDistance = -1
    }
    return totalDistance
}

func hav_distance_answerIn_meters(lat1:Double, lon1:Double, lat2:Double, lon2:Double, radius: Double = 6367444.7) -> Double {
    
    
    let haversin = { (angle: Double) -> Double in
        return (1 - cos(angle))/2
    }
    
    let ahaversin = { (angle: Double) -> Double in
        return 2*asin(sqrt(angle))
    }
    
    // Converts from degrees to radians
    let dToR = { (angle: Double) -> Double in
        return (angle / 360) * 2 * M_PI
    }
    
    let lat1 = dToR(lat1)
    let lon1 = dToR(lon1)
    let lat2 = dToR(lat2)
    let lon2 = dToR(lon2)
    
    //print(lat2-lat1)
    //print(lon2-lon1)
    
    //distance in meters
    return abs(radius * ahaversin(haversin(lat2 - lat1) + cos(lat1) * cos(lat2) * haversin(lon2 - lon1)))
    
}


func convert_24hr_to_12hr(hr: Int, min: Int) -> (String, String) {
    var returnHr = ""
    var returnMin = ""
    
    //Fix "hr" string
    if hr >= 1 && hr <= 12 {
        returnHr = String(hr)
    } else if hr == 0{
        returnHr = String(hr + 12)
    } else {
        returnHr = String(hr - 12)
    }
    
    
    //Fix "min" string
    if String(min).characters.count == 1 {
        returnMin = "0" + String(min)
    } else {
        returnMin = String(min)
    }
    
    return (returnHr, returnMin)
    
}

func showCheerOnLoader(parentView:UIView){
    
    
    
    let flashLoaderBackground = UIView()
    flashLoaderBackground.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.7)
    flashLoaderBackground.frame.size = parentView.frame.size
    flashLoaderBackground.center = parentView.center
    flashLoaderBackground.tag = 536536
    parentView.addSubview(flashLoaderBackground)
    
    let flashLoaderImage = UIImageView()
    flashLoaderImage.image = UIImage(named: "logo_icon_v3_transparentBackground")
    flashLoaderImage.frame.size = CGSize(width: 100, height: 100)
    flashLoaderImage.center = parentView.center
    flashLoaderBackground.addSubview(flashLoaderImage)
    
    let squarePathElement = UIView()
    squarePathElement.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
    squarePathElement.backgroundColor = UIColor.black
    squarePathElement.center = CGPoint(x:  (parentView.center.x)-50, y: (parentView.center.y)+70)
    squarePathElement.layer.cornerRadius = 10
    
    flashLoaderBackground.addSubview(squarePathElement)
    
    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut,.autoreverse,.repeat], animations: {
        squarePathElement.center = CGPoint(x: (parentView.center.x)+50, y: squarePathElement.center.y)
    }, completion:nil)
    
    
}

func manage_runnerPace_history(_ locationManager:CLLocationManager){
if mapSender == "runner" {
    if (runner_currentPaceHistory.count == 30){
        runner_currentPaceHistory.removeFirst()
    }
    
    if (runner_longTermPaceHistory.count == 300){
        runner_longTermPaceHistory.removeFirst()
    }
    
    
    if locationManager.location?.speed != nil{
        runner_currentPaceHistory.append((locationManager.location?.speed)!)
        runner_longTermPaceHistory.append((locationManager.location?.speed)!)
        
        let pace_metersPerSec_decimal = average(arrayToAverage: runner_currentPaceHistory)
        let pace_minSec_decimal = 26.8224/pace_metersPerSec_decimal
        
        consoleLog(msg: "Pace Data Points: \(runner_currentPaceHistory.count)", level: 5)
        consoleLog(msg: "Runner Average Pace: \(pace_minSec_decimal)", level: 5)
        
        if pace_minSec_decimal.isFinite{
            consoleLog(msg: "Runner Average Pace - Min: \(pace_minSec_decimal.doubleMin_toMinSec().0))", level: 5)
            consoleLog(msg: "Runner Average Pace - Sec: \(pace_minSec_decimal.doubleMin_toMinSec().1))", level: 5)
        }
        
        
    }
}
}

func metersPerSeconds_to_minAndSecPerMile_decimalReturn(_ speed:Double) -> Double{
    
    let pace_metersPerSec_decimal = speed
    return(26.8224/pace_metersPerSec_decimal)
    
}

func parseAddress(_ selectedItem:MKPlacemark) -> String {
    // put a space between "4" and "Melrose Place"
    let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
    // put a comma between street and city/state
    let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
    // put a space between "Washington" and "DC"
    let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
    let addressLine = String(
        format:"%@%@%@%@%@%@%@",
        // street number
        selectedItem.subThoroughfare ?? "",
        firstSpace,
        // street name
        selectedItem.thoroughfare ?? "",
        comma,
        // city
        selectedItem.locality ?? "",
        secondSpace,
        // state
        selectedItem.administrativeArea ?? ""
    )
    return addressLine
}

func rgba(_ red:CGFloat, _ green:CGFloat, _ blue:CGFloat, _ alpha:CGFloat) -> UIColor{
    return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
}

extension MKMapView {
    func getOverlaysByTitle(_ title:String) -> [MKOverlay]{
        var arrayForReturn:[MKOverlay] = []
        self.overlays.forEach({
            print("\($0.title!)")
            if "\($0.title!)" != "nil"{
                if $0.title!! == title{
                    arrayForReturn.append($0)
                }
            }
        })
        
        return arrayForReturn
    }
}






func artists_toArtistString(_ artists:[SimplifiedArtist]) -> String {
    var artistString = ""
    
    for artist in artists{
        artistString += artist.name + ", "
    }
    
    
    for _ in 0...1 {
        if artistString.count > 0 {
            artistString.removeLast()
            
        }
    }
    
    return artistString
}

func secondsToHoursMinutesSeconds (seconds : Int) -> (String, String, String) {
    var h = String(seconds / 3600)
    var m = String((seconds % 3600) / 60)
    var s = String((seconds % 3600) % 60)
    if s.count == 1 {
        s = "0" + s
    }
    if m.count == 1 && Int(h)! > 0{
        m = "0" + m
    }
    
    return (h, m, s)
}

func roundTopCorners (_ viewToRound: UIView, borderRadius: CGFloat){
    let path = UIBezierPath(roundedRect:viewToRound.bounds,
                            byRoundingCorners:[.topRight, .topLeft],
                            cornerRadii: CGSize(width: borderRadius, height:  borderRadius))

    let maskLayer = CAShapeLayer()

    maskLayer.path = path.cgPath
    viewToRound.layer.mask = maskLayer
}

func timeString_toAtrArray(_ timeString:String) -> [String:Int]{
    var AtrArray = [:] as [String : Int]
    AtrArray = [
        "year":Int(String(describing: timeString.split(separator: " ")[0]).split(separator: "-")[0])!,
        "month":Int(String(describing: timeString.split(separator: " ")[0]).split(separator: "-")[1])!,
        "day":Int(String(describing: timeString.split(separator: " ")[0]).split(separator: "-")[2])!,
    
        "hour":Int(String(describing: timeString.split(separator: " ")[1]).split(separator: ":")[0])!,
        "minute":Int(String(describing: timeString.split(separator: " ")[1]).split(separator: ":")[1])!,
        "second":Int(String(describing: timeString.split(separator: " ")[1]).split(separator: ":")[2])!
    ]
    
    
    return AtrArray
}

func delta_times(time1:[String:Int], time2:[String:Int]) -> [String:Int]{
    var AtrArray = [:] as [String : Int]
    AtrArray = [
        "year":(time2["year"]! - time1["year"]!),
        "month":(time2["month"]! - time1["month"]!),
        "day":(time2["day"]! - time1["day"]!),
        
        "hour":(time2["hour"]! - time1["hour"]!),
        "minute":(time2["minute"]! - time1["minute"]!),
        "second":(time2["second"]! - time1["second"]!)
        
    ]
    
    
    
    return AtrArray
}

func time_atrArray_sThroughD_to_seconds(_ time: [String:Int])->Int {
    var seconds = 0
    let s2s = time["second"]!
    let m2s = time["minute"]! * 60
    let h2s = time["hour"]! * 60 * 60
    
    let D2s = time["hour"]! * 60 * 60 * 24
    seconds = s2s + m2s + h2s + D2s

    return seconds
}

func spotify_playlistURI_to_ownerID_AND_playlistID(uriString:String) -> (String,String) {
    print("uriString: \(uriString)")
    return (String(uriString.split(separator: ":")[2]),String(uriString.split(separator: ":")[4]))
}

func alamoFire_cleansing(_ cleansingString: String, deviceToServer:Bool) -> String{
    var stringToReturn = cleansingString
    let conversions:[[String]] = [["'", "sh7f0g"]]
    
    if deviceToServer {
        for conversion in conversions {
            stringToReturn = stringToReturn.replacingOccurrences(of: conversion[0], with: conversion[1])
        }
    } else {
        for conversion in conversions {
            stringToReturn = stringToReturn.replacingOccurrences(of: conversion[1], with: conversion[0])
        }
    }
    return stringToReturn
    
}

func checkIterations_roundUp(_ numberToCheck:Double, denominator:Double) -> Int {
    let doubleForm = numberToCheck/denominator
    let intForm = Double(Int(doubleForm))
    
    if doubleForm == intForm {
        return Int(intForm)
    } else {
        return Int(intForm + 1)
    }
    
}

func parse_queueStringTo_truncTracks(_ queueString:String) -> [track_eApp]{
    
    let  cleanedString = alamoFire_cleansing(queueString, deviceToServer: false)
    
    var truncTracks_arr:[track_eApp] = []
    
    var lvl1Parse = cleanedString.components(separatedBy: "..!..")
    
    print("level 1 parse")
    print(lvl1Parse.count)
    //print(lvl1Parse)
    
    
   lvl1Parse = clearEmptyIndices(lvl1Parse)
    
    for trackString in lvl1Parse {
        
        
        let lvl2Parse = trackString.components(separatedBy: "||")
        
        //"..!..\(song.name!)||\(song.uri!)||\(song.artistString!)||\(song.isFromQueue!)||\(song.isSuggestion!)||\(song.suggestor!)"
        
        let truncTrack_isFromQueue = lvl2Parse[3].toBool()
        let truncTrack_isSuggestion = lvl2Parse[4].toBool()
        let truncTrack_suggestor = lvl2Parse[5]
        
        let truncTrack = track_eApp(isFromQueue: truncTrack_isFromQueue!, isSuggestion: truncTrack_isSuggestion!, suggestor: truncTrack_suggestor)
        
        truncTrack.name = lvl2Parse[0]
        truncTrack.uri = lvl2Parse[1]
        truncTrack.artistString = lvl2Parse[2]
        
        truncTracks_arr.append(truncTrack)
    }
    
    return truncTracks_arr
}

func clearEmptyIndices(_ arrayToClean:[String]) -> [String] {
    var emptyIndices:[Int] = []
    
    for i in 0...arrayToClean.count-1 {
        
        
        if arrayToClean[i] == "" {
            emptyIndices.append(i)
        }
        
    }
    var returnArray:[String] = []
    returnArray.append(contentsOf: arrayToClean)
    returnArray.remove(at: emptyIndices)
    
    return returnArray
    
}

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

extension Array {
    mutating func remove(at indexes: [Int]) {
        for index in indexes.sorted(by: >) {
            remove(at: index)
        }
    }
}


func check_trackTypes(_ trackToCheck:[track_eApp]) -> (Int, Int, Int){
    var playlistTracks_counter = 0
    var hostQueue_counter = 0
    var suggestions_counter = 0
    
    for track in trackToCheck {
        if track.isSuggestion {
            suggestions_counter += 1
        } else if (track.isFromQueue){
            hostQueue_counter += 1
        } else {
            playlistTracks_counter += 1
        }
    }
    
    return (playlistTracks_counter, hostQueue_counter, suggestions_counter)
}


