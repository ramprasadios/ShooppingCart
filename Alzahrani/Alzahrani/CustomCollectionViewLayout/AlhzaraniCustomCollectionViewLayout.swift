//
//  AlhzaraniCustomCollectionViewLayout.swift
//  Alzahrani
//
//  Created by Hardwin on 21/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class AlhzaraniCustomCollectionViewLayout: UICollectionViewFlowLayout {
    
    var numberOfColumns = 2
    var cellPadding: CGFloat = 2.0
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    fileprivate var contentHeight: CGFloat {
        let insets = collectionView?.contentInset
        return collectionView!.bounds.height - (insets!.top + insets!.bottom)
    }
    fileprivate var contentWidth: CGFloat {
        let insets = collectionView?.contentInset
        return collectionView!.bounds.width - (insets!.top + insets!.bottom)
    }
    fileprivate var updatedColumnWidth: CGFloat = 0.0
    fileprivate var xOffsetValue: CGFloat?
    
    override func prepare() {
		super.prepare()
		if AppManager.languageType() == .arabic {
			
			self.collectionView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
			self.collectionView?.semanticContentAttribute = .forceRightToLeft
		} else {
			self.collectionView?.semanticContentAttribute = .forceLeftToRight
		}
		
        self.scrollDirection = .horizontal
        let columnWidth = contentWidth * 0.7
//        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0..<collectionView!.numberOfItems(inSection: 0) {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        //self.updatedColumnWidth = xOffset.last!
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: collectionView!.numberOfItems(inSection: 0))
        
        for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
    
            if item == 0 {
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: contentHeight)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                cache.append(attributes)
                
                yOffset[column] = yOffset[column] + cellPadding * 2
                column = column >= ((collectionView!.numberOfItems(inSection: 0)) - 1) ? 0 : column + 1
                self.xOffsetValue = xOffset[column]
            } else {
                if ((item % 2) != 0) {
                    let frame = CGRect(x: self.xOffsetValue!, y: yOffset[column], width: columnWidth * 0.5, height: contentHeight / 2)
                    let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = insetFrame
                    cache.append(attributes)
                    
                    yOffset[column] = yOffset[column] + cellPadding * 2
                    
                } else {
                    let frame = CGRect(x: self.xOffsetValue!, y: self.contentHeight / 2, width: columnWidth * 0.5, height: contentHeight / 2)
                    let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = insetFrame
                    cache.append(attributes)
                    
                    yOffset[column] = yOffset[column] + cellPadding * 2
                    self.xOffsetValue = self.xOffsetValue! + ((contentWidth / 2) * 0.7)
                }
                column = column >= ((collectionView!.numberOfItems(inSection: 0)) - 1) ? 0 : column + 1
            }
        }
        if self.xOffsetValue != nil {
            self.xOffsetValue = self.xOffsetValue! + ((contentWidth / 2) * 0.7)
        }
        
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.xOffsetValue ?? 0.0 + contentWidth / 2 ,height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
//            if attributes.frame.intersects(rect) {
//                layoutAttributes.append(attributes)
//            }
            layoutAttributes.append(attributes)
        }
        return layoutAttributes
    }
}
