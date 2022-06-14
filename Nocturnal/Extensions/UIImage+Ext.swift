//
//  UIImage+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit

enum Img: String {
    case imageNameFromAsset
    
    var obj: UIImage {
        return UIImage(named: rawValue)!
    }
}

extension UIImage {
  var scaledToSafeUploadSize: UIImage? {
    let maxImageSideLength: CGFloat = 480

    let largerSide: CGFloat = max(size.width, size.height)
    let ratioScale: CGFloat = largerSide > maxImageSideLength ? largerSide / maxImageSideLength : 1
    let newImageSize = CGSize(
      width: size.width / ratioScale,
      height: size.height / ratioScale)

    return image(scaledTo: newImageSize)
  }

  func image(scaledTo size: CGSize) -> UIImage? {
    defer {
      UIGraphicsEndImageContext()
    }

    UIGraphicsBeginImageContextWithOptions(size, true, 0)
    draw(in: CGRect(origin: .zero, size: size))

    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
