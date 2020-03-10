//
//  OpenProjectViewController.swift
//  DeviceConnect
//
//  Created by Charles Yorke on 8/7/19.
//  Copyright © 2019 Tobias Kaulich. All rights reserved.
//

import UIKit

class OpenProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //let projects =  DataService.shared.queryAllProject()
    var projects: [Project] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Assigned Projects", comment: "Assigned Projects")
        createArray()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier:"ProjectCell", for: indexPath) as! OpenProjectCell
        var project = projects[indexPath.row];
        
        myCell.address?.text = "Address: " + project.Address
        myCell.cityZip?.text = "City: "  + project.City  + ", "  + project.State  + project.ZIPCode
        myCell.status?.text = "Status: " + project.Status2
        myCell.note.text = "Note: " + "No Comments"
        if(project.Completed=="Yes"){
            myCell.completed.setOn(true, animated: false)
        }
        else{
            myCell.completed.setOn(false, animated: false)
        }
        myCell.completed.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        myCell.completed.tag = project.Id
        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var p = projects[indexPath.row];
        //performSegue(withIdentifier: "ProjectListToCommands", sender: self)
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        let id = mySwitch.tag
        for  p in projects{
            if(p.Id==id){
                if(value){
                    p.Completed = "Yes"
                }
                else{
                    p.Completed = "No"
                }
                //DataService.shared.updateProject(_Id: p.Id, project:p)
                break
            }
        }
    }
    func createArray(){
        projects.removeAll()
        for i in 0..<5{
            let newProject = Project(Id: -1,
                             ProjectId:i,
                             Address:"45231 Blue Spruce Ct",
                             City:"Shelby Township",
                             ZIPCode: "48317",
                             State : "MI",
                             Status: 0,
                             Status2: "Created",
                             Notes: "No Comment",
                             Completed: "Note")
                projects.append(newProject)
        }
    }
}

