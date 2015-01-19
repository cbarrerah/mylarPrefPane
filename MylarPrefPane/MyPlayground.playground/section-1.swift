// Playground - noun: a place where people can play

import Cocoa
import  Foundation
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely()

let kMylarPrefPaneSavedPrefs = "MylarPrefPaneTestMessage"
let kServerIP = "ServerIP"
let kServerPort = "ServerPort"


//var ServerIP    =   "172.16.1.20"
//var ServerPort  =   "8090"



//var defaults = NSUserDefaults.standardUserDefaults()
var myDictionary : [NSObject : AnyObject ] = [
    kServerIP : "piccolo.pelayoworld.com" ,
    kServerPort : "8090"
]

myDictionary[kServerIP]
myDictionary[kServerPort]

var responseString : NSString = NSString()


var query = "http://\(myDictionary[kServerIP]!):\(myDictionary[kServerPort]!)/home"

println(query)

let url = NSURL(string: query)

//let url = NSURL(string: "http://www.stackoverflow.com")

let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
    //println(NSString(data: data, encoding: NSUTF8StringEncoding))
    responseString = NSString(data: data, encoding: NSUTF8StringEncoding)!
    var test = responseString.rangeOfString("<title>Mylar - Home</title>")
    
    if ( responseString.rangeOfString("<title>Mylar - Home</title>").length > 0 )
    {
        println("Success")
    }
    else
    {
        println("nobody home")
    }
    
}

task.resume()




NSUserDefaults.standardUserDefaults().setObject(myDictionary, forKey: kMylarPrefPaneSavedPrefs);


//println(NSUserDefaults.standardUserDefaults().objectForKey(kMylarPrefPaneSavedPrefs))

//var newMylarSavedPrefs  = NSUserDefaults.standardUserDefaults().objectForKey(kMylarPrefPaneSavedPrefs) as? [Dictionary<String , String>]
if let data0 = NSUserDefaults.standardUserDefaults().dictionaryForKey(kMylarPrefPaneSavedPrefs) {
    println(data0)
}
else
{
    println("not saved")
}

