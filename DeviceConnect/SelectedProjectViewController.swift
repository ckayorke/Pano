//
//  SelectedProjectViewController.swift
//  DeviceConnect
//
//  Created by Charles Yorke on 8/9/19.
//  Copyright © 2019 Tobias Kaulich. All rights reserved.
//

import UIKit

class SelectedProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return floors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = floors[indexPath.row]
        return cell
    }
    
    
    var floors:[String] = []
    override func viewDidLoad() {
        floors.append("Basement")
        floors.append( "First Floor");
        floors.append("Second Floor");
        floors.append( "Third Floor");
        floors.append("Fourth Floor");
        super.viewDidLoad()
    }
    
    //func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return floors.count
   // }
    
    //func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //    let cell = UITableViewCell()
     //   cell.textLabel?.text = floors[indexPath.row]
      //  return cell
    //}
}
