//
//  ViewController.swift
//  inetwork
//
//  Created by Samuel MCDONALD on 1/31/17.
//  Copyright © 2017 Samuel MCDONALD. All rights reserved.
//

import UIKit

struct musicMusic {
    var artistName:String
    var albumName:String
    var songName:String
}

class ViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource{

    
    //let hostName = "www.moveablebytes.com"
    //let hostName = "http://itunes.apple.com/search?term=jack+johnson"
    var allMusic = [musicMusic]()
    var myArtistString:String = ""
    var mySearchString:String = ""
    //var count:Int = 0
    
    
    @IBOutlet var tableView    :UITableView!
    let hostName = "itunes.apple.com/"
    var reachability : Reachability?
    
    @IBOutlet var networkStatusLabel :UILabel!
    
     //MARK: - TextField Delegate Methods 
    @IBOutlet weak var myArtist      :UITextField!
    @IBAction func myAristPick(_ sender: UITextField) {
        guard let textFieldString = myArtist.text else {
            return
        }
        
    
       
        let myArtistString = textFieldString.replacingOccurrences(of: " ", with: "+")
        print("\(myArtistString)")
        mySearchString = "/search?term=\(myArtistString)"
        print("mySearchString \(mySearchString)")
    }
   
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: - Core Methods
    
    func parseJson(data: Data){
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
            //print ("JSON:\(jsonResult)")
            let resultsArray = jsonResult["results"] as! [[String:Any]]
                print("resultsArray")
          /*  for resultsDict in resultsArray {
                print("Results:\(resultsDict)")
            }        // This portion works , but is commented */
            for resultsDict in resultsArray {
                var artist = resultsDict["artistName"]
                if artist != nil {artist = (resultsDict["artistName"] as! String) } else {artist = "No artist name"}
                //allMusic.artistName.append(artist as! String)
                print ("\(artist!)")
                
                var album = resultsDict["collectionName"]
                if album != nil { album = (resultsDict["collectionName"] as! String)} else
                { album = " "}
                //allMusic[count].albumName.append(album as! String)
                print("        \(album!)")
                
                var song = resultsDict["trackName"]
                if song != nil {song = (resultsDict["trackName"] as! String) } else {song = " "}
                let newMusicMusic = musicMusic(artistName: artist as! String, albumName: album as! String, songName: song as! String)
                allMusic.append(newMusicMusic)
                //allMusic[count].songName.append(song as! String)
                print("        \(song!)")
                
               // count += 1
            }
        }catch { print("JSON Parsing Error")}
        print("Here!")
        DispatchQueue.main.async {
            // need to write a function to sort in the class 
            // for equivalence? ==
            //allMusic.sort()
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    
    
    func getFile(filename: String){
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let urlString = "https://\(hostName)\(filename)"
            let url = URL(string: urlString)!
            var request = URLRequest(url:url)
            request.timeoutInterval = 30
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                guard let recvData = data else {
                    print("No Data")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    return
                }
                if recvData.count > 0 && error == nil {
                    print("Got Data:\(recvData)")
                    let dataString = String.init(data: recvData, encoding: .utf8)
                    print("Got Data String:\(dataString)")
                    self.parseJson(data: recvData)
                }else{
                    print("Got Data of Length 0")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            task.resume()
        }
    
    
    
    
    
    //MARK: - Interactivity Methods
    
    @IBAction func getFilePressed(button: UIButton){
        
        guard let reach = reachability else {return}
        if reach.isReachable{
            //getFile(filename: "/classfiles/iOS_URL_Class_Get_File.txt")
            //getFile(filename: "/classfiles/flavors.json")
            getFile(filename: mySearchString)
        }else{
            print("Host Not Reachable. Turn on the Internet")
        }
        
        
    }
    
    //MARK: - tableView methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print ("allMusic count is \(allMusic.count)")
        
        return allMusic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath)
        //let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "td")
        cell.textLabel?.text = allMusic[indexPath.row].artistName
        cell.detailTextLabel?.text = allMusic[indexPath.row].albumName + ": "+allMusic[indexPath.row].songName
        
        return cell
    }
    
    //MARK: - Reachability Methods
    
    func setupReacability(hostName: String)  {
        reachability = Reachability(hostname: hostName)
        reachability!.whenReachable = { reachability in
            DispatchQueue.main.async {
                self.updateLabel(reachable: true, reachability: reachability)
            }
            
        }
        reachability!.whenUnreachable = {reachability in
            self.updateLabel(reachable: false, reachability: reachability)        }
    }
    
    func startReachability() {
        do{
            try reachability!.startNotifier()
        }catch{
            networkStatusLabel.text = "Unable to Start Notifier"
            networkStatusLabel.textColor = .red
            return
        }
    }
    
    func updateLabel(reachable: Bool, reachability: Reachability){
        if reachable {
            if reachability.isReachableViaWiFi{
            networkStatusLabel.textColor = .green}
            else {
            networkStatusLabel.textColor = .blue
            }
        }else{
            networkStatusLabel.textColor = .red
        }
        networkStatusLabel.text = reachability.currentReachabilityString
    }
    
    //Mark: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myArtist.delegate = self
        setupReacability(hostName: hostName)
        startReachability()
        //let screenSize:CGRect = UIScreen.main.bounds
        
        //tableView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        tableView.delegate      =   self
        tableView.dataSource    =   self
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
       //self.view.addSubview(self.tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }


}

