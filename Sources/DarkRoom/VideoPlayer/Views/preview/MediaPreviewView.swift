//
//  MediaPreviewView.swift
//  DarkRoomTest
//
//  Created by 엑소더스이엔티 on 2023/10/16.
//

import UIKit

class MediaPreviewView: UIView {
    let collectionview: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = 8
        
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.isPagingEnabled = false
        collectionview.showsVerticalScrollIndicator = false
        collectionview.backgroundColor = .clear
        collectionview.bounces = true
        collectionview.isScrollEnabled = false
        return collectionview
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }
    
    private func prepare() {
        prepareBackgroundView()
        prepareCollectionView()
        prepareLabel()
    }
    
    private func prepareBackgroundView() {
        let darkBackground = UIView()
        darkBackground.translatesAutoresizingMaskIntoConstraints = false
        darkBackground.backgroundColor = .black
        darkBackground.alpha = 0.7
        addSubview(darkBackground)
        
        NSLayoutConstraint.activate([
            darkBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            darkBackground.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            darkBackground.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            darkBackground.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
    
    private func prepareCollectionView() {
        addSubview(collectionview)
        
        NSLayoutConstraint.activate([
            collectionview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            collectionview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            collectionview.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            collectionview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
        
        collectionview.register(PreviewCell.self, forCellWithReuseIdentifier: "PreviewCell")
    }
    
    private func prepareLabel() {
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: collectionview.bottomAnchor, constant: 4),
            label.centerXAnchor.constraint(equalTo: collectionview.centerXAnchor)
        ])
    }
    
    func scrollToItem(index: Int) {
        let numberOfItem = collectionview.numberOfItems(inSection: 0)
        guard index >= 0,
              numberOfItem > index else { return }
        let idp = IndexPath(item: index, section: 0)
        DispatchQueue.main.async {
            self.collectionview.layoutIfNeeded()
            self.collectionview.scrollToItem(at: idp, at: .centeredHorizontally, animated: false)
            self.updateBottomLabel(index: index, allCount: numberOfItem)
        }
    }
    
    private func updateBottomLabel(index: Int, allCount: Int) {
        label.text = "( \(index+1) / \(allCount) )"
    }
}
