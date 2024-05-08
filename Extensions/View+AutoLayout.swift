//
//  UIView+AutoLayout.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/4/24.
//

import UIKit

extension UIView {
    var screen: UIScreen? {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return self.window?.windowScene?.screen
        }
        return window.screen
    }
    
    /// Constrain 4 edges of `self` to specified `view`.
    func edges(
        to view: UIView,
        top: CGFloat = 0,
        left: CGFloat = 0,
        bottom: CGFloat = 0,
        right: CGFloat = 0
    ) {
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left),
            self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom)
        ])
    }
}

extension UIImage {
    /// Resize UIImage to new width keeping the image's aspect ratio.
    func resize(toWidth scaledToWidth: CGFloat) -> UIImage {
        let image = self
        let oldWidth = image.size.width
        let scaleFactor = scaledToWidth / oldWidth
        let newHeight = image.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        let scaledSize = CGSize(width:newWidth, height:newHeight)
        UIGraphicsBeginImageContextWithOptions(scaledSize, true, image.scale)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}
