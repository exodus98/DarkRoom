//
//  PreviewCell.swift
//  DarkRoomTest
//
//  Created by 엑소더스이엔티 on 2023/10/16.
//

import UIKit

class PreviewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // UICollectionViewCell에 UIImageView를 추가합니다.
        contentView.addSubview(imageView)

        // UIImageView를 셀의 크기와 동일하게 설정합니다.
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2).isActive = true
        
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateBorderColor(color: CGColor) {
        imageView.layer.borderColor = color
    }
}
