//
//  ViewController.swift
//  inetwork
//
//  Created by Samuel MCDONALD on 1/31/17.
//  Copyright © 2017 Samuel MCDONALD. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    let hostName = "www.moveablebytes.com"
    var reachability : Reachability?
    
    @IBOutlet var networkStatusLabel :UILabel!
    
    
    
    
    //MARK: - Core Methods
    
    func parseJson(data: Data){
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
            print ("JSON:\(jsonResult)")
            let flavorsArray = jsonResult["flavors"] as! [[String:Any]]
            for flavorDict in flavorsArray {
            print("Flavor:\(flavorDict)")
            }
            for flavorDict in flavorsArray {
            print ("Flavor:\(flavorDict["name"])")
            }
        }catch { print("JSON Parsing Error")}
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    
    
    func getFile(filename: String){
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let urlString = "http://\(hostName)\(filename)"
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
            getFile(filename: "/classfiles/flavors.json")
        }else{
            print("Host Not Reachable. Turn on the Internet")
        }
        
        
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
        setupReacability(hostName: hostName)
        startReachability()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }


}

