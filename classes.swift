import MapKit

class preliminaryRouteOptionAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var overlay:MKOverlay!
    var overlayTitle:String!
    var coordinateArray:[CLLocationCoordinate2D]!
    var color:UIColor!
    
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class medicalTentAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var phone: String!
    var name: String!
    var address: String!
    var image: UIImage!
    
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}


class foodAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var phone: String!
    var name: String!
    var address: String!
    var image: UIImage!
    var mkMapItem:MKMapItem!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}


class eventCenterAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var phone: String!
    var name: String!
    var address: String!
    var image: UIImage!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class waterStationAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var phone: String!
    var name: String!
    var address: String!
    var image: UIImage!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}


class viewingPointAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var phone: String!
    var name: String!
    var address: String!
    var image: UIImage!
    var tag:Double!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class majorVertexAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var phone: String!
    var name: String!
    var address: String!
    var image: UIImage!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class watcher_activeRunner_annotation: NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    var runner_dict: NSDictionary!
    var image: UIImage!
    var runnerId: String!
    var runnerPace: Double!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}




class AnnotationView: MKAnnotationView{
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil)
        {
            self.superview?.bringSubview(toFront: self)
        }
        return hitView
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds;
        var isInside: Bool = rect.contains(point);
        if(!isInside)
        {
            for view in self.subviews
            {
                isInside = view.frame.contains(point);
                if isInside
                {
                    break;
                }
            }
        }
        return isInside;
    }
}

class parameterizedTapGestureRecognizer:UITapGestureRecognizer {
    var tagForPass:String = ""
    var classTagForPass:String = ""
    var arrayTagForPass:[Any] = []
    var dictionaryTagForPass:NSMutableDictionary = [:]
    var IntTagForPass:Int = -1
}

class parameterizedTextfield:UITapGestureRecognizer {
    var tagForPass:String = ""
    var classTagForPass:String = ""
    var arrayTagForPass:[Any] = []
    var dictionaryTagForPass:NSMutableDictionary = [:]
    var IntTagForPass:Int = -1
}

class parameterizedLabel:UILabel {
    var tagForPass:String = ""
    var classTagForPass:String = ""
    var arrayTagForPass:[Any] = []
    var dictionaryTagForPass:NSMutableDictionary = [:]
    var IntTagForPass:Int = -1
}

class parameterizedButton:UIButton {
    var tagForPass:String = ""
    var classTagForPass:String = ""
    var arrayTagForPass:[Any] = []
    var dictionaryTagForPass:NSDictionary = [:]
    var IntTagForPass:Int = -1
    var associatedTrk:track_eApp?
}

class parameterizedTableView:UITableView {
    var tagForPass:String = ""
    var classTagForPass:String = ""
    var arrayTagForPass:[Any] = []
    var dictionaryTagForPass:NSDictionary = [:]
    var IntTagForPass:Int = -1
    var associatedTrk:track_eApp?
}

class parameterizedImageView:UIImageView {
    var tagForPass:String = ""
    var classTagForPass:String = ""
    var arrayTagForPass:[Any] = []
    var dictionaryTagForPass:NSDictionary = [:]
    var IntTagForPass:Int = -1
}

class parameterizedNSLayoutConstraint:NSLayoutConstraint {
    var tagForPass:String = ""
    var classTagForPass:String = ""
    var arrayTagForPass:[Any] = []
    var dictionaryTagForPass:NSDictionary = [:]
    var IntTagForPass:Int = -1
}

class parameterizedView:UIView {
    var tagForPass:String = ""
    var classTagForPass:String = ""
    var arrayTagForPass:[Any] = []
    var dictionaryTagForPass:NSDictionary = [:]
    var IntTagForPass:Int = -1
}

class parameterizedScrollView:UIScrollView {
    var tagForPass:String = ""
    var classTagForPass:String = ""
    var arrayTagForPass:[Any] = []
    var dictionaryTagForPass:NSDictionary = [:]
    var IntTagForPass:Int = -1
}

class parameterizedMKPolyline:MKPolyline{
    var color:UIColor = UIColor.blue
    var dashPattern:[NSNumber] = [5,0]
    var tagForPass:String = ""
    var classTagForPass:String = ""
    var arrayTagForPass:[Any] = []
    var dictionaryTagForPass:NSDictionary = [:]
    var IntTagForPass:Int = -1
    var transportType:MKDirectionsTransportType!
}

struct searchResult {
    let mainImage: UIImage!
    let name: String!
    let previewURL: String!
}


class track_eApp {
    
   
    var name: String? = "nil"
    var artistString: String? = "nil"
    var uri: String? = "nil"
    
    var isFromQueue: Bool! = false
    var isSuggestion: Bool! = false
    var suggestor:String? = "nil"
    
    var albumArtURL: String? = "nil"
    
    
    /*sourceType can either be
     "searchResult" = clicked on a track from the searchResults
     - contents of the playlist will be only the selected track
     "featuredContent" = clicked on a track from the home page/catTrks
     - contents of the playlist will be entire row of content
     "listeningMode" = track info fetched from database/from broadcaster feed
     - contents of the playlist will be non-existent
     "playlist"
     -
     */
    
    var sourceType: String? = "nil"
    var source_uri: String? = "nil"
    var source_name: String? = "nil"
    var source_owner: String? = "nil"
    var locationInSource: Int? = -1
    
    
    
    init(isFromQueue: Bool, isSuggestion: Bool, suggestor: String) {
        self.isFromQueue = isFromQueue
        self.isSuggestion = isSuggestion
        self.suggestor = suggestor
    }
    
}



class playlist_eApp {
    var name: String? = nil
    var uri: String? = nil
    var tracks: [track_eApp]! = []
    //  let numberOfTracks: Int?
}

class party_eApp {
    var partyName: String? = nil
    var queue_string: String? = nil
    var queue: [track_eApp]? = nil
    var partyPassword: String? = nil
    var broadcasterId: String? = nil
    var partyStatus: String? = nil
    var currentSong: String? = nil
    
    //  let numberOfTracks: Int?
}


