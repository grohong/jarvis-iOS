//
//  EncyclopediaTemplateCollectionCell.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 16..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import UIKit
import AlamofireImage

class EncyclopediaTemplateCollectionCell: UICollectionViewCell {
    @IBOutlet var mainLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func putCellContent(json: [String:Any]) {
        if let thumbImageUrl = json["thumbImageUrl"] as? [String:Any] {
            var imageSize = CGSize(width: 100, height: 100)
            var imageOrigin = CGPoint(x: 40, y: self.bounds.size.height/2 - imageSize.height/2)
            var thumbImage = UIImageView(frame: CGRect(origin: imageOrigin, size: imageSize))
            
            var url = thumbImageUrl["value"] as? String
            thumbImage.af_setImage(withURL: URL(fileURLWithPath: url!))
            self.addSubview(thumbImage)
        }
        
        if let mainText = json["mainText"] as? [String:Any] {
            mainLabel.text = mainText["value"] as? String
        }
        
    }
}
