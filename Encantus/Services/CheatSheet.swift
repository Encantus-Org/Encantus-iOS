//
//  CheatSheet.swift
//  Encantus
//
//  Created by Ankit Yadav on 30/06/21.
//

import UIKit
import Foundation

class CheatSheet {
    
    static let window = UIApplication.shared.keyWindow!

    //MARK:- Screen sizes
    static let screenSize = UIScreen.main.bounds
    static let screenWidth = screenSize.width
    static let screenHeight = screenSize.height
    static let currentDevice = UIDevice.current.userInterfaceIdiom
    
    static let shared = CheatSheet()
    
    func simpleAlert(title: String, message: String, actionTitle: String) -> UIAlertController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .cancel, handler: nil)
        
        alertController.view.tintColor = UIColor(named: "lightPurpleColor")
        
        alertController.addAction(defaultAction)
        return alertController
    }
}
