

import Foundation
import SQLite3

extension SqliteDbStore {
    func create(record: Record2) {
        guard self.prepareInsertEntryStmt() == SQLITE_OK else { return }
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.insertEntryStmt)
        }

        //Inserting name in insertEntryStmt prepared statement
        if sqlite3_bind_text(self.insertEntryStmt, 1, (record.name as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        //Inserting employeeID in insertEntryStmt prepared statement
        if sqlite3_bind_text(self.insertEntryStmt, 2, (record.employeeId as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        //Inserting designation in insertEntryStmt prepared statement
        if sqlite3_bind_text(self.insertEntryStmt, 3, (record.designation as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        //executing the query to insert values
        let r = sqlite3_step(self.insertEntryStmt)
        if r != SQLITE_DONE {
            logDbErr("sqlite3_step(insertEntryStmt) \(r)")
            return
        }
    }
    
    //"SELECT * FROM Records WHERE EmployeeID = ? LIMIT 1"
    func read(employeeID: String) throws -> Record2 {
        // ensure statements are created on first usage if nil
        guard self.prepareReadEntryStmt() == SQLITE_OK else { throw SqliteError(message: "Error in prepareReadEntryStmt") }
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.readEntryStmt)
        }
        
        //Inserting employeeID in readEntryStmt prepared statement
        if sqlite3_bind_text(self.readEntryStmt, 1, (employeeID as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(readEntryStmt)")
            throw SqliteError(message: "Error in inserting value in prepareReadEntryStmt")
        }
        
        //executing the query to read value
        if sqlite3_step(readEntryStmt) != SQLITE_ROW {
            logDbErr("sqlite3_step COUNT* readEntryStmt:")
            throw SqliteError(message: "Error in executing read statement")
        }
        
        return Record2(name: String(cString: sqlite3_column_text(readEntryStmt, 1)),
                      employeeId: String(cString: sqlite3_column_text(readEntryStmt, 2)),
                      designation: String(cString: sqlite3_column_text(readEntryStmt, 3)))
    }
    
    func readAll() throws -> [Record2] {
         var records = [Record2]()
        guard self.prepareReadAllEntryStmt() == SQLITE_OK else { throw SqliteError(message: "Error in prepareReadAllEntryStmt") }
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.readAllEntryStmt)
        }
        
        //executing the query to read value
        //if sqlite3_step(readAllEntryStmt) != SQLITE_ROW {
         //   logDbErr("sqlite3_step COUNT* readAllEntryStmt:")
          //  throw SqliteError(message: "Error in executing read statement")
        //}
        
        //executing the query to read value
       while sqlite3_step(readAllEntryStmt) == SQLITE_ROW {
           let rec = Record2(name: String(cString: sqlite3_column_text(readAllEntryStmt, 1)),
           employeeId: String(cString: sqlite3_column_text(readAllEntryStmt, 2)),
           designation: String(cString: sqlite3_column_text(readAllEntryStmt, 3)))
           records.append(rec)
          // logDbErr("sqlite3_step COUNT* readUserStmt:")
          // throw SqliteError(message: "Error in executing read statement")
       }
        return records
    }
    
    
    
    
    
    //"UPDATE Records SET Name = ?, Designation = ? WHERE EmployeeID = ?"
    func update(record: Record2) {
        // ensure statements are created on first usage if nil
        guard self.prepareUpdateEntryStmt() == SQLITE_OK else { return }
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.updateEntryStmt)
        }
        
        //Inserting name in updateEntryStmt prepared statement
        if sqlite3_bind_text(self.updateEntryStmt, 1, (record.name as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateEntryStmt)")
            return
        }
        
        //Inserting designation in updateEntryStmt prepared statement
        if sqlite3_bind_text(self.updateEntryStmt, 2, (record.designation as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateEntryStmt)")
            return
        }
        
        //Inserting employeeID in updateEntryStmt prepared statement
        if sqlite3_bind_text(self.updateEntryStmt, 3, (record.employeeId as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateEntryStmt)")
            return
        }
        
        //executing the query to update values
        let r = sqlite3_step(self.updateEntryStmt)
        if r != SQLITE_DONE {
            logDbErr("sqlite3_step(updateEntryStmt) \(r)")
            return
        }
    }
    
    //"DELETE FROM Records WHERE EmployeeID = ?"
    func delete(employeeId: String) {
        // ensure statements are created on first usage if nil
        guard self.prepareDeleteEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.deleteEntryStmt)
        }
        
        //Inserting name in deleteEntryStmt prepared statement
        if sqlite3_bind_text(self.deleteEntryStmt, 1, (employeeId as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(deleteEntryStmt)")
            return
        }
        
        //executing the query to delete row
        let r = sqlite3_step(self.deleteEntryStmt)
        if r != SQLITE_DONE {
            logDbErr("sqlite3_step(deleteEntryStmt) \(r)")
            return
        }
    }
    
    // INSERT/CREATE operation prepared statement
    func prepareInsertEntryStmt() -> Int32 {
        guard insertEntryStmt == nil else { return SQLITE_OK }
        let sql = "INSERT INTO Records (Name, EmployeeID, Designation) VALUES (?,?,?)"
        //preparing the query
        let r = sqlite3_prepare(db2, sql, -1, &insertEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare insertEntryStmt")
        }
        return r
    }
    
    // READ operation prepared statement
    func prepareReadEntryStmt() -> Int32 {
        guard readEntryStmt == nil else { return SQLITE_OK }
        let sql = "SELECT * FROM Records WHERE EmployeeID = ? LIMIT 1"
        //preparing the query
        let r = sqlite3_prepare(db2, sql, -1, &readEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare readEntryStmt")
        }
        return r
    }
    
    // READ operation prepared statement
    func prepareReadAllEntryStmt() -> Int32 {
        guard readAllEntryStmt == nil else { return SQLITE_OK }
        let sql = "SELECT * FROM Records"
        //preparing the query
        let r = sqlite3_prepare(db2, sql, -1, &readAllEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare readAllEntryStmt")
        }
        return r
    }
    
    // UPDATE operation prepared statement
    func prepareUpdateEntryStmt() -> Int32 {
        guard updateEntryStmt == nil else { return SQLITE_OK }
        let sql = "UPDATE Records SET Name = ?, Designation = ? WHERE EmployeeID = ?"
        //preparing the query
        let r = sqlite3_prepare(db2, sql, -1, &updateEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare updateEntryStmt")
        }
        return r
    }
    
    // DELETE operation prepared statement
    func prepareDeleteEntryStmt() -> Int32 {
        guard deleteEntryStmt == nil else { return SQLITE_OK }
        let sql = "DELETE FROM Records WHERE EmployeeID = ?"
        //preparing the query
        let r = sqlite3_prepare(db2, sql, -1, &deleteEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare deleteEntryStmt")
        }
        return r
    }
    
    
    
    //=======================================================================
    func addUser(_Iuser: IUser) {
        guard self.prepareInsertUserStmt() == SQLITE_OK else { return }
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.insertUserStmt)
        }

        //Inserting name in insertUserStmt prepared statement
        if sqlite3_bind_text(self.insertUserStmt, 1, (_Iuser.Email as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertUserStmt)")
            return
        }
        
        //Inserting employeeID in insertUserStmt prepared statement
        if sqlite3_bind_text(self.insertUserStmt, 2, (_Iuser.Pass as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertUserStmt)")
            return
        }
        
        //Inserting designation in insertEntryStmt prepared statement
        //if sqlite3_bind_text(self.insertEntryStmt, 3, (record.designation as NSString).utf8String, -1, nil) != SQLITE_OK {
           // logDbErr("sqlite3_bind_text(insertEntryStmt)")
           // return
        //}
        
        //executing the query to insert values
        let r = sqlite3_step(self.insertUserStmt)
        if r != SQLITE_DONE {
            logDbErr("sqlite3_step(insertUserStmt) \(r)")
            return
        }
    }
    
   
    
    func queryUsers()-> [IUser] {
         var users = [IUser]()
        guard self.prepareReadAllUserStmt() == SQLITE_OK else {
            return users
        }
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.readAllUserStmt)
        }
        
        //executing the query to read value
        //if sqlite3_step(readAllEntryStmt) != SQLITE_ROW {
         //   logDbErr("sqlite3_step COUNT* readAllEntryStmt:")
          //  throw SqliteError(message: "Error in executing read statement")
        //}
        
        //executing the query to read value
       while sqlite3_step(readAllUserStmt) == SQLITE_ROW {
        
        let id = Int(sqlite3_column_int(readAllUserStmt, 0))
        let email = String(cString: sqlite3_column_text(readAllUserStmt, 1))
        let pass = String(cString: sqlite3_column_text(readAllUserStmt, 2))
        let user = IUser(_Id: id,_Email: email,_Pass: pass)
          users.append(user)
       }
        return users
    }
    
    func updateUser(_IUser: IUser) -> Bool  {
        // ensure statements are created on first usage if nil
        guard self.prepareUpdateUserStmt() == SQLITE_OK else { return false}
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.updateUserStmt)
        }
        
        //Inserting name in updateUserStmt prepared statement
        if sqlite3_bind_text(self.updateUserStmt, 1, (_IUser.Email as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateUserStmt)")
            return false
        }
        
        //Inserting designation in updateUserStmt prepared statement
        if sqlite3_bind_text(self.updateUserStmt, 2, (_IUser.Pass as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateUserStmt)")
            return false
        }
        
        //Inserting employeeID in updateUserStmt prepared statement
        let id = String(_IUser.Id)
        if sqlite3_bind_text(self.updateUserStmt, 3, (id as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateUserStmt)")
            return false
        }
        
        //executing the query to update values
        let r = sqlite3_step(self.updateUserStmt)
        if r != SQLITE_DONE {
            logDbErr("sqlite3_step(updateUserStmt) \(r)")
            return false
        }
        return true
    }
    
    
    // INSERT/CREATE operation prepared statement
    func prepareInsertUserStmt() -> Int32 {
        guard insertUserStmt == nil else { return SQLITE_OK }
        let sql = "INSERT INTO Users (Email, Pass) VALUES (?,?)"
        //preparing the query
        let r = sqlite3_prepare(db2, sql, -1, &insertUserStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare insertUserStmt")
        }
        return r
    }
    
    // READ operation prepared statement
    func prepareReadUserStmt() -> Int32 {
        guard readUserStmt == nil else { return SQLITE_OK }
        let sql = "SELECT * FROM Users WHERE Id = ? LIMIT 1"
        //preparing the query
        let r = sqlite3_prepare(db2, sql, -1, &readUserStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare readUserStmt")
        }
        return r
    }
    
    // READ operation prepared statement
    func prepareReadAllUserStmt() -> Int32 {
        guard readAllUserStmt == nil else { return SQLITE_OK }
        let sql = "SELECT * FROM Users"
        //preparing the query
        let r = sqlite3_prepare(db2, sql, -1, &readAllUserStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare readAllUserStmt")
        }
        return r
    }
    
    // UPDATE operation prepared statement
    func prepareUpdateUserStmt() -> Int32 {
        guard updateUserStmt == nil else { return SQLITE_OK }
        let sql = "UPDATE Users SET Email = ?, Pass = ? WHERE Id = ?"
        //preparing the query
        let r = sqlite3_prepare(db2, sql, -1, &updateUserStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare updateUserStmt")
        }
        return r
    }
    
    // DELETE operation prepared statement
    func prepareDeleteUserStmt() -> Int32 {
        guard deleteUserStmt == nil else { return SQLITE_OK }
        let sql = "DELETE FROM Users WHERE Id = ?"
        //preparing the query
        let r = sqlite3_prepare(db2, sql, -1, &deleteUserStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare deleteUserStmt")
        }
        return r
    }
    
    
    
    
    //=======================================================================
     func addProject(project: Project) {
         guard self.prepareInsertProjectStmt() == SQLITE_OK else { return }
         defer {
             // reset the prepared statement on exit.
             sqlite3_reset(self.insertProjectStmt)
         }

         //Inserting name in insertProjectStmt prepared statement
        if sqlite3_bind_text(self.insertProjectStmt, 1, (String(project.ProjectId) as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertProjectStmt)")
             return
         }
         
         //Inserting employeeID in insertProjectStmt prepared statement
         if sqlite3_bind_text(self.insertProjectStmt, 2, (project.Address as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertProjectStmt)")
             return
         }
        
        //Inserting employeeID in insertProjectStmt prepared statement
        if sqlite3_bind_text(self.insertProjectStmt, 3, (project.City as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertProjectStmt)")
            return
        }
        
        //Inserting employeeID in insertProjectStmt prepared statement
        if sqlite3_bind_text(self.insertProjectStmt, 4, (project.ZIPCode as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertProjectStmt)")
            return
        }
        
        //Inserting employeeID in insertProjectStmt prepared statement
        if sqlite3_bind_text(self.insertProjectStmt, 5, (project.State as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertProjectStmt)")
            return
        }
        
        //Inserting employeeID in insertProjectStmt prepared statement
        if sqlite3_bind_text(self.insertProjectStmt, 6, (String(project.Status) as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertProjectStmt)")
            return
        }
        
        //Inserting employeeID in insertProjectStmt prepared statement
        if sqlite3_bind_text(self.insertProjectStmt, 7, (project.Status2 as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertProjectStmt)")
            return
        }
        
        //Inserting employeeID in insertProjectStmt prepared statement
        if sqlite3_bind_text(self.insertProjectStmt, 8, (project.Notes as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertProjectStmt)")
            return
        }
        
        //Inserting employeeID in insertProjectStmt prepared statement
        if sqlite3_bind_text(self.insertProjectStmt, 9, (project.Completed as NSString).utf8String, -1, nil) != SQLITE_OK {
           logDbErr("sqlite3_bind_text(insertProjectStmt)")
           return
        }
        
        //Inserting employeeID in insertProjectStmt prepared statement
        if sqlite3_bind_text(self.insertProjectStmt, 10, (project.OutsidePictures as NSString).utf8String, -1, nil) != SQLITE_OK {
          logDbErr("sqlite3_bind_text(insertProjectStmt)")
          return
        }
        
        //Inserting employeeID in insertProjectStmt prepared statement
        if sqlite3_bind_text(self.insertProjectStmt, 11, (String(project.Resolution) as NSString).utf8String, -1, nil) != SQLITE_OK {
          logDbErr("sqlite3_bind_text(insertProjectStmt)")
          return
        }
        
        //Inserting employeeID in insertProjectStmt prepared statement
        if sqlite3_bind_text(self.insertProjectStmt, 12, (project.Outside3DPictures as NSString).utf8String, -1, nil) != SQLITE_OK {
          logDbErr("sqlite3_bind_text(insertProjectStmt)")
          return
        }
        
         
         //executing the query to insert values
         let r = sqlite3_step(self.insertProjectStmt)
         if r != SQLITE_DONE {
             logDbErr("sqlite3_step(insertProjectStmt) \(r)")
             return
         }
     }
     
     func queryAllProject() -> [Project] {
          var projects = [Project]()
         guard self.prepareReadAllProjectStmt() == SQLITE_OK else {
            return projects
        }
         defer {
             // reset the prepared statement on exit.
             sqlite3_reset(self.readAllProjectStmt)
         }
         
         //executing the query to read value
        while sqlite3_step(readAllProjectStmt) == SQLITE_ROW {
             let id = Int(sqlite3_column_int(readAllProjectStmt, 0))
             let newProject = Project(Id: id,
                                      ProjectId:Int(String(cString: sqlite3_column_text(readAllProjectStmt, 1)))!,
                                     Address:String(cString: sqlite3_column_text(readAllProjectStmt, 2)),
                                     City:String(cString: sqlite3_column_text(readAllProjectStmt, 3)),
                                     ZIPCode: String(cString: sqlite3_column_text(readAllProjectStmt, 4)),
                                     State : String(cString: sqlite3_column_text(readAllProjectStmt, 5)),
                                     Status: Int(String(cString: sqlite3_column_text(readAllProjectStmt, 6)))!,
                                     Status2: String(cString: sqlite3_column_text(readAllProjectStmt, 7)),
                                     Notes:String(cString: sqlite3_column_text(readAllProjectStmt, 8)),
                                     Completed: String(cString: sqlite3_column_text(readAllProjectStmt, 9)),
                                     OutsidePictures: String(cString: sqlite3_column_text(readAllProjectStmt, 10)),
                                     Resolution: Int(String(cString: sqlite3_column_text(readAllProjectStmt, 11)))!,
                                     Outside3DPictures: String(cString: sqlite3_column_text(readAllProjectStmt, 12)))
            projects.append(newProject)
        }
         return projects
     }
    
    func queryAllProject2() -> [Project] {
         var projects2 = [Project]()
         let projs = queryAllProject()
         print(projectStatus)
         for p in projs{
            if(p.Status == projectStatus){
                projects2.append(p)
            }
         }
        return projects2
    }
    
    
    
     func updateProject(_Id:Int, project: Project)  {
         // ensure statements are created on first usage if nil
         guard self.prepareUpdateProjectStmt() == SQLITE_OK else { return }
         defer {
             // reset the prepared statement on exit.
             sqlite3_reset(self.updateProjectStmt)
         }
        
          //Inserting name in updateProjectStmt prepared statement
           if sqlite3_bind_text(self.updateProjectStmt, 1, (String(project.ProjectId) as NSString).utf8String, -1, nil) != SQLITE_OK {
                logDbErr("sqlite3_bind_text(updateProjectStmt)")
                return
            }
            
            //Inserting employeeID in updateProjectStmt prepared statement
            if sqlite3_bind_text(self.updateProjectStmt, 2, (project.Address as NSString).utf8String, -1, nil) != SQLITE_OK {
                logDbErr("sqlite3_bind_text(updateProjectStmt)")
                return
            }
           
           //Inserting employeeID in updateProjectStmt prepared statement
           if sqlite3_bind_text(self.updateProjectStmt, 3, (project.City as NSString).utf8String, -1, nil) != SQLITE_OK {
               logDbErr("sqlite3_bind_text(updateProjectStmt)")
               return
           }
           
           //Inserting employeeID in updateProjectStmt prepared statement
           if sqlite3_bind_text(self.updateProjectStmt, 4, (project.ZIPCode as NSString).utf8String, -1, nil) != SQLITE_OK {
               logDbErr("sqlite3_bind_text(updateProjectStmt)")
               return
           }
           
           //Inserting employeeID in updateProjectStmt prepared statement
           if sqlite3_bind_text(self.updateProjectStmt, 5, (project.State as NSString).utf8String, -1, nil) != SQLITE_OK {
               logDbErr("sqlite3_bind_text(updateProjectStmt)")
               return
           }
           
           //Inserting employeeID in updateProjectStmt prepared statement
           if sqlite3_bind_text(self.updateProjectStmt, 6, (String(project.Status) as NSString).utf8String, -1, nil) != SQLITE_OK {
               logDbErr("sqlite3_bind_text(updateProjectStmt)")
               return
           }
           
           //Inserting employeeID in updateProjectStmt prepared statement
           if sqlite3_bind_text(self.updateProjectStmt, 7, (project.Status2 as NSString).utf8String, -1, nil) != SQLITE_OK {
               logDbErr("sqlite3_bind_text(updateProjectStmt)")
               return
           }
           
           //Inserting employeeID in updateProjectStmt prepared statement
           if sqlite3_bind_text(self.updateProjectStmt, 8, (project.Notes as NSString).utf8String, -1, nil) != SQLITE_OK {
               logDbErr("sqlite3_bind_text(updateProjectStmt)")
               return
           }
           
           //Inserting employeeID in updateProjectStmt prepared statement
           if sqlite3_bind_text(self.updateProjectStmt, 9, (project.Completed as NSString).utf8String, -1, nil) != SQLITE_OK {
              logDbErr("sqlite3_bind_text(updateProjectStmt)")
              return
           }
           
           //Inserting employeeID in updateProjectStmt prepared statement
           if sqlite3_bind_text(self.updateProjectStmt, 10, (project.OutsidePictures as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(updateProjectStmt)")
             return
           }
           
           //Inserting employeeID in updateProjectStmt prepared statement
           if sqlite3_bind_text(self.updateProjectStmt, 11, (String(project.Resolution) as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(updateProjectStmt)")
             return
           }
        
           //Inserting employeeID in updateProjectStmt prepared statement
           if sqlite3_bind_text(self.updateProjectStmt, 12, (project.Outside3DPictures as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(updateProjectStmt)")
             return
           }
        
        if sqlite3_bind_text(self.updateProjectStmt, 13, (String(project.ProjectId) as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateProjectStmt)")
            return
        }
        
        //executing the query to update values
        let r = sqlite3_step(self.updateProjectStmt)
        if r != SQLITE_DONE {
            logDbErr("sqlite3_step(updateProjectStmt) \(r)")
            return 
        }
        
         return
     }
    
    func deleAllProjects(){
        let projs = queryAllProject()
        for p in projs{
            deleteProject(_Id: p.Id)
        }
    }
    
    //"DELETE FROM Records WHERE EmployeeID = ?"
       func deleteProject(_Id: Int) {
           // ensure statements are created on first usage if nil
           guard self.prepareDeleteProjectStmt() == SQLITE_OK else { return }
           
           defer {
               // reset the prepared statement on exit.
               sqlite3_reset(self.deleteProjectStmt)
           }
           
           //Inserting name in deleteProjectStmt prepared statement
           if sqlite3_bind_text(self.deleteProjectStmt, 1, (String(_Id) as NSString).utf8String, -1, nil) != SQLITE_OK {
               logDbErr("sqlite3_bind_text(deleteProjectStmt)")
               return
           }
           
           //executing the query to delete row
           let r = sqlite3_step(self.deleteProjectStmt)
           if r != SQLITE_DONE {
               logDbErr("sqlite3_step(deleteProjectStmt) \(r)")
               return
           }
       }
     
     
     // INSERT/CREATE operation prepared statement
     func prepareInsertProjectStmt() -> Int32 {
         guard insertProjectStmt == nil else { return SQLITE_OK }
         let sql = "INSERT INTO Projects (ProjectId, Address, City, ZIPCode, State, Status, Status2, Notes, Completed, OutsidePictures, Resolution, Outside3DPictures) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)"
         //preparing the query
         let r = sqlite3_prepare(db2, sql, -1, &insertProjectStmt, nil)
         if  r != SQLITE_OK {
             logDbErr("sqlite3_prepare insertProjectStmt")
         }
         return r
     }
     
    
     // READ operation prepared statement
     func prepareReadAllProjectStmt() -> Int32 {
         guard readAllProjectStmt == nil else { return SQLITE_OK }
         let sql = "SELECT * FROM Projects"
         //preparing the query
         let r = sqlite3_prepare(db2, sql, -1, &readAllProjectStmt, nil)
         if  r != SQLITE_OK {
             logDbErr("sqlite3_prepare readAllProjectStmt")
         }
         return r
     }
     
     // UPDATE operation prepared statement
     func prepareUpdateProjectStmt() -> Int32 {
         guard updateProjectStmt == nil else { return SQLITE_OK }
         let sql = "UPDATE Projects SET  ProjectId = ?, Address = ?, City = ?, ZIPCode = ?, State = ?, Status = ?, Status2 = ?, Notes = ?, Completed = ?, OutsidePictures = ?, Resolution = ?, Outside3DPictures = ? WHERE ProjectId = ?"

         //preparing the query
         let r = sqlite3_prepare(db2, sql, -1, &updateProjectStmt, nil)
         if  r != SQLITE_OK {
             logDbErr("sqlite3_prepare updateProjectStmt")
         }
         return r
     }
     
     // DELETE operation prepared statement
     func prepareDeleteProjectStmt() -> Int32 {
         guard deleteProjectStmt == nil else { return SQLITE_OK }
         let sql = "DELETE FROM Projects WHERE ProjectId = ?"
         //preparing the query
         let r = sqlite3_prepare(db2, sql, -1, &deleteProjectStmt, nil)
         if  r != SQLITE_OK {
             logDbErr("sqlite3_prepare deleteProjectStmt")
         }
         return r
     }
    
    
    func addlevel(level: Level) {
        addlevel1(level: level)
        let levs = queryAllLevel2()
        for var l in levs{
            l.LevelId = l.Id
            _ = updateLevel(_Id: l.Id, level: l)
        }
    }
    //=======================================================================
     func addlevel1(level: Level) {
         guard self.prepareInsertLevelStmt() == SQLITE_OK else { return }
         defer {
             // reset the prepared statement on exit.
             sqlite3_reset(self.insertLevelStmt)
         }
        
        //Inserting name in insertLevelStmt prepared statement
        if sqlite3_bind_text(self.insertLevelStmt, 1, (String(level.LevelId) as NSString).utf8String, -1, nil) != SQLITE_OK {
                logDbErr("sqlite3_bind_text(insertLevelStmt)")
                return
            }

         //Inserting name in insertLevelStmt prepared statement
        if sqlite3_bind_text(self.insertLevelStmt, 2, (String(level.ProjectId) as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertLevelStmt)")
             return
         }
         
         //Inserting employeeID in insertLevelStmt prepared statement
        if sqlite3_bind_text(self.insertLevelStmt, 3, (level.Name as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertLevelStmt)")
             return
         }
        
        
        //Inserting employeeID in insertLevelStmt prepared statement
        if sqlite3_bind_text(self.insertLevelStmt, 4, (String(level.Status) as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertLevelStmt)")
            return
        }
        
        //Inserting employeeID in insertLevelStmt prepared statement
        if sqlite3_bind_text(self.insertLevelStmt, 5, (level.Status2 as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertLevelStmt)")
            return
        }
        
        //Inserting employeeID in insertLevelStmt prepared statement
        if sqlite3_bind_text(self.insertLevelStmt, 6, (level.PicName as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertLevelStmt)")
            return
        }
        
         //executing the query to insert values
         let r = sqlite3_step(self.insertLevelStmt)
         if r != SQLITE_DONE {
             logDbErr("sqlite3_step(insertLevelStmt) \(r)")
             return
         }
     }
    
    func queryAllLevel2() -> [Level] {
        var levels = [Level]()
         guard self.prepareReadAllLevelStmt() == SQLITE_OK else {
            return levels
        }
         defer {
             // reset the prepared statement on exit.
             sqlite3_reset(self.readAllLevelStmt)
         }
         
         //executing the query to read value
        while sqlite3_step(readAllLevelStmt) == SQLITE_ROW {
             let id = Int(sqlite3_column_int(readAllLevelStmt, 0))
            let newLevel = Level(Id: id,
                                     LevelId:Int(String(cString: sqlite3_column_text(readAllLevelStmt, 1)))!,
                                     ProjectId:Int(String(cString: sqlite3_column_text(readAllLevelStmt, 2)))!,
                                     Name:String(cString: sqlite3_column_text(readAllLevelStmt, 3)),
                                     Status: Int(String(cString: sqlite3_column_text(readAllLevelStmt, 4)))!,
                                     Status2: String(cString: sqlite3_column_text(readAllLevelStmt, 5)),
                                     PicName: String(cString: sqlite3_column_text(readAllLevelStmt, 6)))
            levels.append(newLevel)
        }
         return levels
    }

     func queryAllLevel(_Id:Int) -> [Level] {
          var levels = [Level]()
          let p = queryAllLevel2()
        for i in p{
            if(i.ProjectId == _Id){
                levels.append(i)
            }
        }
          return levels
     }

    func updateLevel(_Id:Int, level: Level) -> Bool {
         // ensure statements are created on first usage if nil
         guard self.prepareUpdateLevelStmt() == SQLITE_OK else { return  false}
         defer {
             // reset the prepared statement on exit.
             sqlite3_reset(self.updateLevelStmt)
         }
        
          //Inserting name in updateLevelStmt prepared statement
        if sqlite3_bind_text(self.updateLevelStmt, 1, (String(level.LevelId) as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateLevelStmt)")
            return false
        }
        
           if sqlite3_bind_text(self.updateLevelStmt, 2, (String(level.ProjectId) as NSString).utf8String, -1, nil) != SQLITE_OK {
                logDbErr("sqlite3_bind_text(updateLevelStmt)")
                return false
            }
            
            //Inserting employeeID in updateLevelStmt prepared statement
           if sqlite3_bind_text(self.updateLevelStmt,3, (level.Name as NSString).utf8String, -1, nil) != SQLITE_OK {
                logDbErr("sqlite3_bind_text(updateLevelStmt)")
                return false
            }
           
           //Inserting employeeID in updateLevelStmt prepared statement
           if sqlite3_bind_text(self.updateLevelStmt, 4, (String(level.Status) as NSString).utf8String, -1, nil) != SQLITE_OK {
               logDbErr("sqlite3_bind_text(updateLevelStmt)")
               return false
           }
           
           //Inserting employeeID in updateLevelStmt prepared statement
           if sqlite3_bind_text(self.updateLevelStmt, 5, (level.Status2 as NSString).utf8String, -1, nil) != SQLITE_OK {
               logDbErr("sqlite3_bind_text(updateLevelStmt)")
               return false
           }
           
           //Inserting employeeID in updateLevelStmt prepared statement
        if sqlite3_bind_text(self.updateLevelStmt, 6, (level.PicName as NSString).utf8String, -1, nil) != SQLITE_OK {
               logDbErr("sqlite3_bind_text(updateLevelStmt)")
               return false
           }
        if sqlite3_bind_text(self.updateLevelStmt, 7, (String(level.Id) as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateLevelStmt)")
            return false
        }
        
        //executing the query to update values
       let r = sqlite3_step(self.updateLevelStmt)
       if r != SQLITE_DONE {
           logDbErr("sqlite3_step(updateLevelStmt) \(r)")
           return false
       }
         return true
     }
    
    
    func deleteAllLevels(){
        let levs = queryAllLevel2();
        for l in levs{
           _ =  deleteLevel(_Id: l.Id)
        }
    }
    
    //"DELETE FROM Records WHERE EmployeeID = ?"
    func deleteLevel(_Id: Int) -> Bool {
           // ensure statements are created on first usage if nil
           guard self.prepareDeleteLevelStmt() == SQLITE_OK else { return false}
           
           defer {
               // reset the prepared statement on exit.
               sqlite3_reset(self.deleteLevelStmt)
           }
           
           //Inserting name in deleteProjectStmt prepared statement
           if sqlite3_bind_text(self.deleteLevelStmt, 1, (String(_Id) as NSString).utf8String, -1, nil) != SQLITE_OK {
               logDbErr("sqlite3_bind_text(deleteLevelStmt)")
               return false
           }
           
           //executing the query to delete row
           let r = sqlite3_step(self.deleteLevelStmt)
           if r != SQLITE_DONE {
               logDbErr("sqlite3_step(deleteLevelStmt) \(r)")
               return false
           }
        return true
       }
     
     
     // INSERT/CREATE operation prepared statement
     func prepareInsertLevelStmt() -> Int32 {
         guard insertLevelStmt == nil else { return SQLITE_OK }
         let sql = "INSERT INTO Levels (LevelId, ProjectId, Name, Status, Status2, PicName) VALUES (?,?,?,?,?,?)"
         //preparing the query
         let r = sqlite3_prepare(db2, sql, -1, &insertLevelStmt, nil)
         if  r != SQLITE_OK {
             logDbErr("sqlite3_prepare insertLevelStmt")
         }
         return r
     }
     
    
     // READ operation prepared statement
     func prepareReadAllLevelStmt() -> Int32 {
         guard readAllLevelStmt == nil else { return SQLITE_OK }
         let sql = "SELECT * FROM Levels"
         //preparing the query
         let r = sqlite3_prepare(db2, sql, -1, &readAllLevelStmt, nil)
         if  r != SQLITE_OK {
             logDbErr("sqlite3_prepare readAllLevelStmt")
         }
         return r
     }
     
     // UPDATE operation prepared statement
     func prepareUpdateLevelStmt() -> Int32 {
         guard updateLevelStmt == nil else { return SQLITE_OK }
         let sql = "UPDATE Levels SET  LevelId = ?, ProjectId = ?, Name = ?, Status = ?, Status2 = ?, PicName = ? WHERE Id = ?"

         //preparing the query
         let r = sqlite3_prepare(db2, sql, -1, &updateLevelStmt, nil)
         if  r != SQLITE_OK {
             logDbErr("sqlite3_prepare updateLevelStmt")
         }
         return r
     }
     
     // DELETE operation prepared statement
     func prepareDeleteLevelStmt() -> Int32 {
         guard deleteLevelStmt == nil else { return SQLITE_OK }
         let sql = "DELETE FROM Levels WHERE Id = ?"
         //preparing the query
         let r = sqlite3_prepare(db2, sql, -1, &deleteLevelStmt, nil)
         if  r != SQLITE_OK {
             logDbErr("sqlite3_prepare deleteLevelStmt")
         }
         return r
     }
    
    //=======================================
    func addData(){
        //deleAllProjects()
        //deleteAllLevels()
        //deleteAllRooms()
        let projects = queryAllProject();
        if(projects.count<1){
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
                                         Completed: "Note",
                                         OutsidePictures: "",
                                         Resolution: 1,
                                         Outside3DPictures: "")
                addProject(project: newProject)
            }
        }
    }

    func createArray()->[Project]{
        var projects :[Project] = []
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
                                     Completed: "Note",
                                     OutsidePictures: "",
                                     Resolution: 1,
                                     Outside3DPictures: "")
            projects.append(newProject)
        }
        return projects
    }
    
    func getRoomNames() ->[RoomName]{
        var items = ["Attic", "Basement", "Master Bathroom", "Bathroom 1",
                     "Bathroom 2", "Bathroom 3",  "Bathroom 4", "Bathroom 5", "Bathroom 6", "Master Bedroom",
                     "Bedroom 1",  "Bedroom 2", "Bedroom 3",  "Bedroom 4","Bedroom 5", "Bedroom 6",
                     "Bedroom 7", "Bedroom 8", "Deck",  "Den", "Dining Room", "Front Yard", "Back Yard",
                     "Right Side Yard", "Left Side Yard",  "Garage",  "Hallway", "Kitchen","Laundry",
                     "Porch","Play Room", "Patio","Pantry","Office","Living Room","Family Room","Staircase",
                     "Study","Sun Room","TV Room","Workshop","Craft Room","Classroom"];
        items.sort()
        var items2 = [RoomName]()
        for name in items{
            let p = RoomName(RoomId: -1, LevelId: -1, ProjectId: -1, Name: name)
            items2.append(p)
        }
        return items2
    }

  ///=====================================================================
    func addRoom(room: Room){
        addRoom1(room: room)
        let rooms = queryAllRooms()
        for var l in rooms{
            l.RoomId = l.Id
            _ = updateRoom(_Id: l.Id, room: l)
        }
    }
    func addRoom1(room: Room){
         guard self.prepareInsertRoomStmt() == SQLITE_OK else { return }
         defer {
             // reset the prepared statement on exit.
             sqlite3_reset(self.insertRoomStmt)
         }

        
         //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 1, (String(room.RoomId) as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        //Inserting name in insertRoomStmt prepared statement
       if sqlite3_bind_text(self.insertRoomStmt, 2, (String(room.ProjectId) as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertRoomStmt)")
            return
        }
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 3, (String(room.LevelId) as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
         
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 4, (room.Name as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 5, (room.LevelName as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        //Inserting name in insertRoomStmt prepared statement
       if sqlite3_bind_text(self.insertRoomStmt, 6, (room.Address as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertRoomStmt)")
            return
        }
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 7, (room.State as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 8, (room.City as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
         
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 9, (room.ZIP as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 10, (room.PictureName as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 11, (room.RoomLength as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 12, (room.RoomWidth as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 13, (room.Connectors as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 14, (room.CenterX as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 15, (room.CenterY as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 16, (room.ScaleX as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 17, (room.ScaleY as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 18, (room.Rotation as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 19, (room.Shape as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
        
        //Inserting name in insertRoomStmt prepared statement
        if sqlite3_bind_text(self.insertRoomStmt, 20, (room.Fliped as NSString).utf8String, -1, nil) != SQLITE_OK {
             logDbErr("sqlite3_bind_text(insertRoomStmt)")
             return
         }
         
         //executing the query to insert values
         let r = sqlite3_step(self.insertRoomStmt)
         if r != SQLITE_DONE {
             logDbErr("sqlite3_step(insertRoomStmt) \(r)")
             return
         }
     }
     
        
     func queryAllRooms() -> [Room] {
          var rooms = [Room]()
         guard self.prepareReadAllRoomStmt() == SQLITE_OK else {
            return rooms
        }
         defer {
             // reset the prepared statement on exit.
             sqlite3_reset(self.readAllRoomStmt)
         }
         
         //executing the query to read value
        while sqlite3_step(readAllRoomStmt) == SQLITE_ROW {
             let id = Int(sqlite3_column_int(readAllRoomStmt, 0))
             let newRoom = Room(Id: id,
                                     RoomId:Int(String(cString: sqlite3_column_text(readAllRoomStmt, 1)))!,
                                     ProjectId:Int(String(cString: sqlite3_column_text(readAllRoomStmt, 2)))!,
                                     LevelId:Int(String(cString: sqlite3_column_text(readAllRoomStmt, 3)))!,
                                     Name:String(cString: sqlite3_column_text(readAllRoomStmt, 4)),
                                     LevelName:String(cString: sqlite3_column_text(readAllRoomStmt, 5)),
                                     Address:String(cString: sqlite3_column_text(readAllRoomStmt, 6)),
                                     State : String(cString: sqlite3_column_text(readAllRoomStmt, 7)),
                                     City:String(cString: sqlite3_column_text(readAllRoomStmt, 8)),
                                     ZIP: String(cString: sqlite3_column_text(readAllRoomStmt, 9)),
                                     PictureName : String(cString: sqlite3_column_text(readAllRoomStmt, 10)),
                                     RoomLength:String(cString: sqlite3_column_text(readAllRoomStmt, 11)),
                                     RoomWidth : String(cString: sqlite3_column_text(readAllRoomStmt, 12)),
                                     Connectors: String(cString: sqlite3_column_text(readAllRoomStmt, 13)),
                                     CenterX: String(cString: sqlite3_column_text(readAllRoomStmt, 14)),
                                     CenterY:String(cString: sqlite3_column_text(readAllRoomStmt, 15)),
                                     ScaleX: String(cString: sqlite3_column_text(readAllRoomStmt, 16)),
                                     ScaleY: String(cString: sqlite3_column_text(readAllRoomStmt, 17)),
                                     Rotation: String(cString: sqlite3_column_text(readAllRoomStmt, 18)),
                                     Shape:String(cString: sqlite3_column_text(readAllRoomStmt, 19)),
                                     Fliped: String(cString: sqlite3_column_text(readAllRoomStmt, 20)))
            rooms.append(newRoom)
        }
         return rooms
     }
        
    func queryAllRoomsByProjectId(_pId:Int) -> [Room] {
           var rooms = [Room]()
           let rooms2 = queryAllRooms()
           for r in rooms2{
               if(r.ProjectId == _pId){
                rooms.append(r)
               }
           }
           return rooms
    }
       
    func queryAllRoomsByProjectIdAndLevelId(_pId:Int, _lId:Int) -> [Room] {
           var rooms = [Room]()
           let rooms2 = queryAllRooms()
           for r in rooms2{
            if(r.ProjectId == _pId && _lId == r.LevelId){
                rooms.append(r)
               }
           }
           return rooms
    }
       
    
    func updateRoom(_Id:Int, room: Room) -> Bool {
         // ensure statements are created on first usage if nil
         guard self.prepareUpdateRoomStmt() == SQLITE_OK else { return  false}
         defer {
             // reset the prepared statement on exit.
             sqlite3_reset(self.updateRoomStmt)
         }
        
        
        if sqlite3_bind_text(self.updateRoomStmt, 1, (String(room.RoomId) as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 2, (String(room.ProjectId) as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 3, (String(room.LevelId) as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 4, (room.Name as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 5, (room.LevelName as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 6, (room.Address as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 7, (room.State as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 8, (room.City as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 9, (room.ZIP as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 10, (room.PictureName as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 11, (room.RoomLength as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 12, (room.RoomWidth as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 13, (room.Connectors as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 14, (room.CenterX as NSString).utf8String, -1, nil) != SQLITE_OK {
           logDbErr("sqlite3_bind_text(updateRoomStmt)")
           return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 15, (room.CenterY as NSString).utf8String, -1, nil) != SQLITE_OK {
              logDbErr("sqlite3_bind_text(updateRoomStmt)")
              return false
           }
        
        if sqlite3_bind_text(self.updateRoomStmt, 16, (room.ScaleX as NSString).utf8String, -1, nil) != SQLITE_OK {
              logDbErr("sqlite3_bind_text(updateRoomStmt)")
              return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 17, (room.ScaleY as NSString).utf8String, -1, nil) != SQLITE_OK {
           logDbErr("sqlite3_bind_text(updateRoomStmt)")
           return false
        }
        
        
        if sqlite3_bind_text(self.updateRoomStmt, 18, (room.Rotation as NSString).utf8String, -1, nil) != SQLITE_OK {
              logDbErr("sqlite3_bind_text(updateRoomStmt)")
              return false
           }
        
        if sqlite3_bind_text(self.updateRoomStmt, 19, (room.Shape as NSString).utf8String, -1, nil) != SQLITE_OK {
              logDbErr("sqlite3_bind_text(updateRoomStmt)")
              return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 20, (room.Fliped as NSString).utf8String, -1, nil) != SQLITE_OK {
           logDbErr("sqlite3_bind_text(updateRoomStmt)")
           return false
        }
        
        if sqlite3_bind_text(self.updateRoomStmt, 21, (String(room.Id) as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateRoomStmt)")
            return false
        }
        
        let r = sqlite3_step(self.updateRoomStmt)
              if r != SQLITE_DONE {
                  logDbErr("sqlite3_step(updateRoomStmt) \(r)")
                  return false
              }
        
         return true
     }
    

    func deleteRoom(_Id: Int) -> Bool {
           // ensure statements are created on first usage if nil
             guard self.prepareDeleteRoomStmt() == SQLITE_OK else { return  false}
        
             defer {
                 // reset the prepared statement on exit.
                 sqlite3_reset(self.deleteRoomStmt)
             }
             
             //Inserting name in deleteRoomStmt prepared statement
             if sqlite3_bind_text(self.deleteRoomStmt, 1, (String(_Id) as NSString).utf8String, -1, nil) != SQLITE_OK {
                 logDbErr("sqlite3_bind_text(deleteRoomStmt)")
                 return false
             }
             
             //executing the query to delete row
             let r = sqlite3_step(self.deleteRoomStmt)
             if r != SQLITE_DONE {
                 logDbErr("sqlite3_step(deleteRoomStmt) \(r)")
                 return false
             }
            return true
       }
       
       func deleteAllRooms(){
           let rooms = queryAllRooms();
           for r in rooms{
               _ = deleteRoom(_Id: r.Id)
           }
       }
       
     // INSERT/CREATE operation prepared statement
     func prepareInsertRoomStmt() -> Int32 {
         guard insertRoomStmt == nil else {
            return SQLITE_OK
        }
        
        
         let sql = "INSERT INTO Rooms(RoomId, ProjectId, LevelId, Name, LevelName, Address, State, City, ZIP, PictureName, RoomLength, RoomWidth, Connectors, CenterX, CenterY, ScaleX, ScaleY, Rotation, Shape, Fliped) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
        
        
        
         //preparing the query
         let r = sqlite3_prepare(db2, sql, -1, &insertRoomStmt, nil)
         if  r != SQLITE_OK {
             logDbErr("sqlite3_prepare insertRoomStmt")
         }
         return r
     }
     
     // READ operation prepared statement
     func prepareReadAllRoomStmt() -> Int32 {
         guard readAllRoomStmt == nil else { return SQLITE_OK }
         let sql = "SELECT * FROM Rooms"
         //preparing the query
         let r = sqlite3_prepare(db2, sql, -1, &readAllRoomStmt, nil)
         if  r != SQLITE_OK {
             logDbErr("sqlite3_prepare readAllRoomStmt")
         }
         return r
     }
     
     // UPDATE operation prepared statement
     func prepareUpdateRoomStmt() -> Int32 {
         guard updateRoomStmt == nil else { return SQLITE_OK }
         let sql = "UPDATE Rooms SET RoomId = ?, ProjectId = ?, LevelId = ?,   Name = ?, LevelName = ?, Address = ?, State = ?, City = ?, ZIP = ?,  PictureName = ?, RoomLength = ?, RoomWidth = ?, Connectors = ?, CenterX = ?, CenterY = ?, ScaleX = ?, ScaleY = ?, Rotation = ?, Shape = ?, Fliped = ?  WHERE Id = ?"
         //preparing the query
         let r = sqlite3_prepare(db2, sql, -1, &updateRoomStmt, nil)
         if  r != SQLITE_OK {
             logDbErr("sqlite3_prepare updateRoomStmt")
         }
         return r
     }
     
     // DELETE operation prepared statement
     func prepareDeleteRoomStmt() -> Int32 {
         guard deleteRoomStmt == nil else { return SQLITE_OK }
         let sql = "DELETE FROM Rooms WHERE Id = ?"
         //preparing the query
         let r = sqlite3_prepare(db2, sql, -1, &deleteRoomStmt, nil)
         if  r != SQLITE_OK {
             logDbErr("sqlite3_prepare deleteRoomStmt")
         }
         return r
     }
}
