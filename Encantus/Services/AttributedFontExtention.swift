//
//  AttributedFontExtention.swift
//  Encantus
//
//  Created by Ankit Yadav on 02/07/21.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    func regular(_ value:String,_ fontSize: CGFloat = 14,_ foregroundColor: UIColor = UIColor.white) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: fontSize),
            .foregroundColor : foregroundColor
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    func bold(_ value:String,_ fontSize: CGFloat = 14) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font : UIFont.boldSystemFont(ofSize: fontSize),
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    /* Other styling methods */
    func orangeHighlight(_ value:String,_ fontSize: CGFloat = 14) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  UIFont.systemFont(ofSize: fontSize),
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.orange
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func blackHighlight(_ value:String,_ fontSize: CGFloat = 14) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  UIFont.systemFont(ofSize: fontSize),
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.black
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func underlined(_ value:String,_ fontSize: CGFloat = 14) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  UIFont.systemFont(ofSize: fontSize),
            .underlineStyle : NSUnderlineStyle.single.rawValue
            
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}
