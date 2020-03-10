
import Foundation
import SQLite3

class SqliteDbStore {
    static let shared:SqliteDbStore = SqliteDbStore()
    public var myConnectedDevice:MMBluetoothDevice!
    public var projectErrors = [ProjectError]()
    public var dName = ""
    public var object: TableCellObject?
    //private let db: Connection?
    public var _Name:String?;
    public var _Pass:String?;
    public var _Level:Level?;
    public var _Room:Room?;
    public var _LevelCount:Int = 0;
    public var _RoomCount:Int = 0;
    public var _con = [Project]()
    public var _Project:Project?;
    public var _size: CGSize?
    public var StartNewRoomName = ""
    public var StartNewRoom = false
    public var StartNewRoomId = -1
    public var projectStatus = 0
    
    public var fromSelected = 1
    
    let dbURL: URL
    var db2: OpaquePointer?
    //=========================================
    var insertEntryStmt: OpaquePointer?
    var readEntryStmt: OpaquePointer?
    var readAllEntryStmt: OpaquePointer?
    var updateEntryStmt: OpaquePointer?
    var deleteEntryStmt: OpaquePointer?
     //=========================================
    
    
    var insertUserStmt: OpaquePointer?
    var readUserStmt: OpaquePointer?
    var readAllUserStmt: OpaquePointer?
    var updateUserStmt: OpaquePointer?
    var deleteUserStmt: OpaquePointer?
    
    //=========================================
    
    var insertProjectStmt: OpaquePointer?
    var readProjectStmt: OpaquePointer?
    var readAllProjectStmt: OpaquePointer?
    var updateProjectStmt: OpaquePointer?
    var deleteProjectStmt: OpaquePointer?
    
    //=========================================
    
    
    var insertLevelStmt: OpaquePointer?
    var readLevelStmt: OpaquePointer?
    var readAllLevelStmt: OpaquePointer?
    var updateLevelStmt: OpaquePointer?
    var deleteLevelStmt: OpaquePointer?
    
    //=========================================
    
    
    var insertRoomStmt: OpaquePointer?
    var readRoomStmt: OpaquePointer?
    var readAllRoomStmt: OpaquePointer?
    var updateRoomStmt: OpaquePointer?
    var deleteRoomStmt: OpaquePointer?
    
    //=========================================
    init() {
        do {
            do {
                dbURL = try FileManager.default
                    .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent("integration.db")
                let msg = String(format: "URL: %s", dbURL.absoluteString)
                print(msg)
            }
            catch {
                print("Some error occurred. Returning empty path.")
                dbURL = URL(fileURLWithPath: "")
                return
            }
            
            try openDB()
            try createTables()
            }
            catch {
                print("Some error occurred. Returning.")
                return
            }
    }
    
    func openDB() throws {
        if sqlite3_open(dbURL.path, &db2) != SQLITE_OK {
            let msg = String(format: "error opening database at %s",  dbURL.absoluteString)
            print(msg)
//            deleteDB(dbURL: dbURL)
            throw SqliteError(message: "error opening database \(dbURL.absoluteString)")
        }
    }
    
    func deleteDB(dbURL: URL) {
        print("removing db")
        do {
            try FileManager.default.removeItem(at: dbURL)
        }
        catch {
            let msg = String(format: "exception while removing db %s", error.localizedDescription)
            print(msg)
        }
    }
    
    func createTables() throws {
        let emp =  sqlite3_exec(db2, "CREATE TABLE IF NOT EXISTS Records (id INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT, Name TEXT NOT NULL, EmployeeID TEXT UNIQUE NOT NULL, Designation TEXT NOT NULL)", nil, nil, nil)
        if (emp != SQLITE_OK) {
            logDbErr("Error creating db table - Records")
            throw SqliteError(message: "unable to create table Records")
        }
        
        let users =  sqlite3_exec(db2, "CREATE TABLE IF NOT EXISTS Users (Id INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT, Email TEXT NOT NULL, Pass TEXT NOT NULL)", nil, nil, nil)
        if (users != SQLITE_OK) { 
            logDbErr("Error creating db table - USERS")
            throw SqliteError(message: "unable to create table USERS")
        }
        
        let projects =  sqlite3_exec(db2, "CREATE TABLE IF NOT EXISTS Projects (Id INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT,ProjectId TEXT UNIQUE NOT NULL, Address TEXT NOT NULL, City TEXT NOT NULL, ZIPCode TEXT NOT NULL, State TEXT NOT NULL, Status TEXT NOT NULL, Status2 TEXT NOT NULL, Notes TEXT NOT NULL, Completed TEXT NOT NULL, OutsidePictures TEXT NOT NULL, Resolution TEXT NOT NULL, Outside3DPictures TEXT NOT NULL)", nil, nil, nil)
        if (projects != SQLITE_OK) { // corrupt database.
            logDbErr("Error creating db table - PROJECTS")
            throw SqliteError(message: "unable to create table PROJECTS")
        }
        
        
        let levels =  sqlite3_exec(db2, "CREATE TABLE IF NOT EXISTS Levels (Id INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT,LevelId TEXT NOT NULL,ProjectId TEXT  NOT NULL, Name TEXT NOT NULL, Status TEXT NOT NULL, Status2 TEXT NOT NULL, PicName TEXT NOT NULL)", nil, nil, nil)
        if (levels != SQLITE_OK) { // corrupt database.
            logDbErr("Error creating db table - LEVELS")
            throw SqliteError(message: "unable to create table LEVELS")
        }
        
        let rooms =  sqlite3_exec(db2, "CREATE TABLE IF NOT EXISTS Rooms(Id INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT, RoomId TEXT, ProjectId TEXT, LevelId TEXTL, Name TEXT, LevelName TEXT, Address TEXT, State TEXT, City TEXT, ZIP TEXT, PictureName TEXT, RoomLength TEXT, RoomWidth TEXT, Connectors TEXT, CenterX TEXT, CenterY TEXT, ScaleX TEXT, ScaleY TEXT, Rotation TEXT, Shape TEXTL, Fliped TEXT)", nil, nil, nil)
        if (rooms != SQLITE_OK) { // corrupt database.
            logDbErr("Error creating db table - ROOMS")
            throw SqliteError(message: "unable to create table ROOMS")
        }
    }
    
    func logDbErr(_ msg: String) {
        let errmsg = String(cString: sqlite3_errmsg(db2)!)
        let msg = String(format: "ERROR %s : %s",  msg, errmsg)
        print(msg)
    }
}

class SqliteError : Error {
    var message = ""
    var error = SQLITE_ERROR
    init(message: String = "") {
        self.message = message
    }
    init(error: Int32) {
        self.error = error
    }
}
