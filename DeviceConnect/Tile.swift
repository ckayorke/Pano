import Foundation
import UIKit
class Tile: CustomStringConvertible {
    let X: Int
    let Y: Int
    let Id : Int
    var RoomRoom : String
    let mRectSquare: UIView
    let mSquareColor: CGColor
    
    init(X: Int,Y: Int, Id:Int, RoomRoom:String, mRectSquare: UIView, mSquareColor:CGColor){
        self.X = X
        self.Y = Y
        self.Id = Id
        self.RoomRoom = RoomRoom
        self.mRectSquare = mRectSquare
        self.mSquareColor = mSquareColor
    }
    var description: String{
        return "Id = \(self.Id)"
    }
}


