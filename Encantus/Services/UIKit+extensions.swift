//
//  UIKit+extensions.swift
//  Encantus
//
//  Created by Ankit Yadav on 29/06/21.
//

import Foundation
import UIKit
import CoreMedia
import AVFoundation

extension UIView {
    
    func addBackground(imageName: String = "bg-image", contentMode: UIView.ContentMode = .scaleToFill) {
        // setup the UIImageView
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.contentMode = contentMode
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backgroundImageView)
        sendSubviewToBack(backgroundImageView)

        // adding NSLayoutConstraints
        let leadingConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)

        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius

        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    func fadeAnimation(_ delegate: CAAnimationDelegate) {
        let animation = CATransition()
        animation.delegate = delegate
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = .fade
        self.layer.add(animation, forKey: nil)
    }
}

extension TimeInterval{

    func minutes() -> String {
        let time = NSInteger(self)

//        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
//        let hours = (time / 3600)

        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension CMTime {
    var minutes:String {
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds % 3600 / 60)
        let seconds:Int = Int((totalSeconds % 3600) % 60)

        if hours > 0 {
            return String(format: "%i:%02i:%02i", minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

extension UIButton {
    func play() {
        self.setImage(UIImage(named: "play-icon"), for: .normal)
    }
    func pause() {
        self.setImage(UIImage(named: "pause-icon"), for: .normal)
    }
}

extension UIImageView {
    func shrink(_ by: CGFloat) {
        UIView.animate(withDuration: 0.6,
            animations: {
                self.transform = CGAffineTransform(scaleX: by, y: by)
            },
            completion: nil)
    }
    func toIdentity(_ by: CGFloat) {
        UIView.animate(withDuration: 0.6,
            animations: {
                self.transform = CGAffineTransform(scaleX: by, y: by)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.transform = CGAffineTransform.identity
                }
            })
    }
}
