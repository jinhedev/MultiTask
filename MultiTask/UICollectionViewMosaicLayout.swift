//
//  UICollectionViewMosaicLayout.swift
//  MultiTask
//
//  Created by rightmeow on 11/24/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

protocol UICollectionViewDelegateMosaicLayout {
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat
}

class UICollectionViewMosaicLayoutAttributes: UICollectionViewLayoutAttributes {

    var height: CGFloat = 0

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! UICollectionViewMosaicLayoutAttributes
        copy.height = height
        return copy
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? UICollectionViewMosaicLayoutAttributes {
            if attributes.height == height {
                return super.isEqual(object)
            }
        }
        return false
    }

}

class UICollectionViewMosaicLayout: UICollectionViewLayout {

    var delegate: UICollectionViewDelegateMosaicLayout!
    var numberOfColumns = 0
    var cellPadding: CGFloat = 0

    fileprivate var cache = [UICollectionViewMosaicLayoutAttributes]()
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var contentWidth: CGFloat {
        get {
            let insets = collectionView!.contentInset
            return collectionView!.bounds.width - (insets.left + insets.right)
        }
    }

    override class var layoutAttributesClass: AnyClass {
        return UICollectionViewMosaicLayoutAttributes.self
    }

    override var collectionViewContentSize : CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        if cache.isEmpty {
            guard numberOfColumns > 0 else {
                super.prepare()
                return
            }
            let columnWidth = contentWidth / CGFloat(numberOfColumns)

            var xOffsets = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffsets.append(CGFloat(column) * columnWidth)
            }

            var yOffsets = [CGFloat](repeating: 0, count: numberOfColumns)

            var column = 0
            for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let width = columnWidth - (2 * cellPadding) // left padding and right padding
                let height = cellPadding + delegate.collectionView(collectionView!, heightForItemAtIndexPath: indexPath) + cellPadding
                let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: width, height: height)
                let insettedFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                let attributes = UICollectionViewMosaicLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insettedFrame
                cache.append(attributes)
                contentHeight = max(contentHeight, frame.maxY)
                yOffsets[column] = yOffsets[column] + height
                column = column >= (numberOfColumns - 1) ? 0 : column + 1
            }
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }

}
















