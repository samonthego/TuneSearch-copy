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

