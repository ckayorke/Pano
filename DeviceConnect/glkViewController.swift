//  Converted to Swift 5.1 by Swiftify v5.1.26565 - https://objectivec2swift.com/
/*
 * Copyright Ricoh Company, Ltd. All rights reserved.
 */

import Foundation
import GLKit
import UIKit

//#if !ricoh_theta_sample_for_ios_glkViewController_h
//#define ricoh_theta_sample_for_ios_glkViewController_h
/**
 * Controller class for OpenGL view generation
 */


class GlkViewController: GLKViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(_ rect: CGRect, image imageData: NSMutableData?, width: Int, height: Int, yaw: Float, roll: Float, pitch: Float) {
        self.init()
        glRenderView = GLRenderView(frame: rect)
        glRenderView?.setTexture(imageData, width: Int32(width), height: Int32(height), yaw: yaw, pitch: pitch, roll: roll)
        view = glRenderView
    }
    
    

    var glRenderView: GLRenderView?

    /**
     * gateway method for GLView settings
     * @param rect Rectangle of display area
     * @param imageData Image data
     * @param width Image width
     * @param height Image height
     * @param yaw Yaw of zenith correction data
     * @param roll Roll of zenith correction data
     * @param pitch Pitch of zenith correction data
     */
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glRenderView?.draw()
    }

    override func viewDidDisappear(_ animated: Bool) {
        if nil != glRenderView {
            glRenderView?.tearDown()
        }

        super.viewDidDisappear(animated)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
