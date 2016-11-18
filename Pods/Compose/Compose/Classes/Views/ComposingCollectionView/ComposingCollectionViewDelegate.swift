//
//  ComposingCollectionViewDelegate.swift
//  Compose
//
//  Created by Bruno Bilescky on 04/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

class ComposingCollectionViewDelegate: NSObject, UICollectionViewDelegateFlowLayout {

    let source: ComposingDataSource
    var direction: ComposingContainerDirection
    
    
    private var visibleContainers: [UIScrollView:CGFloat] = [:]
    private var thresholdFound: Bool = false
    
    var scrollDidChangeCallback: ((CGFloat)-> Void)?
    
    init(with source: ComposingDataSource, direction: ComposingContainerDirection = .vertical) {
        self.source = source
        self.direction = direction
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let unit = source[indexPath.item]
        let collectionSize = collectionView.frame.size
        var size = (collectionViewLayout as? UICollectionViewFlowLayout).map { (layout) -> (horizontal: CGFloat, vertical: CGFloat) in
            let horizontal = layout.sectionInset.horizontalInsets
            let vertical = layout.sectionInset.verticalInsets
            return (horizontal, vertical)
        }.map { (horizontal, vertical) -> CGSize in
            return CGSize(width: collectionSize.width - horizontal, height: collectionSize.height - vertical)
        } ?? collectionSize
        
        let spaces: (item: CGFloat, line: CGFloat) = (collectionViewLayout as? UICollectionViewFlowLayout).map { (layout) -> (item: CGFloat, line: CGFloat) in
            let itemSpace = layout.minimumInteritemSpacing
            let lineSpace = layout.minimumLineSpacing
            return (itemSpace, lineSpace)
        } ?? (0.0, 0.0)
        
        switch direction {
        case let .verticalGrid(columns):
            let totalSeparator = CGFloat(max(columns - 1, 0)) * spaces.item
            size.width = floor((size.width - totalSeparator) / CGFloat(columns))
            fallthrough
        case .vertical:
            size.height = unit.heightUnit.value(for: size)
        case let .horizontalGrid(rows):
            let totalSeparator = CGFloat(max(rows - 1, 0)) * spaces.item
            size.height = floor((size.height - totalSeparator) / CGFloat(rows))
            fallthrough
        case .horizontal:
            size.width = unit.widthUnit.value(for: size)
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let unit = source[indexPath.item]
        if let viewableUnit = unit as? TwoStepDisplayUnit {
            viewableUnit.beforeDisplay(view: cell)
        }
        if let container = unit as? ContainerUnit {
            let scrollView = container.scrollviewFrom(view: cell)
            scrollView.isScrollEnabled = false
            scrollView.bounces = false
            if cell.frame.height > collectionView.frame.height {
                visibleContainers[scrollView] = cell.frame.origin.y
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item < source.state.endIndex else {
            return
        }
        let unit = source[indexPath.item]
        if let viewableUnit = unit as? TwoStepDisplayUnit {
            if let wrapCell = cell as? ComposingUnitCollectionViewCell {
                viewableUnit.afterDisplay(view: wrapCell.innerView)
            }
            else {
                viewableUnit.afterDisplay(view: cell)
            }
        }
        if let container = unit as? ContainerUnit {
            let scrollView = container.scrollviewFrom(view: cell)
            visibleContainers.removeValue(forKey: scrollView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let unit = source[indexPath.item]
        if let selectableUnit = unit as? SelectableUnit {
            return selectableUnit.shouldSelect()
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let unit = source[indexPath.item]
        if let selectableUnit = unit as? SelectableUnit {
            selectableUnit.didSelect()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let unit = source[indexPath.item]
        return unit is HighlightableUnit
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let unit = source[indexPath.item]
        if let hightlightableUnit = unit as? HighlightableUnit {
            hightlightableUnit.didHightlight()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let unit = source[indexPath.item]
        if let hightlightableUnit = unit as? HighlightableUnit {
            hightlightableUnit.didUnhightlight()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        scrollDidChangeCallback?(offset)
        innerScrollVisibleContainers(offset: offset, parent: scrollView)
    }
    
    private func innerScrollVisibleContainers(offset: CGFloat, parent parentScrollView: UIScrollView) {
        for (scrollView, origin) in visibleContainers {
            guard let cell = scrollView.superview?.superview else { continue }
            let maxY = cell.frame.maxY
            thresholdFound = offset >= origin && offset <= maxY
            guard thresholdFound else {
                if offset < origin {
                    scrollView.frame.origin.y = 0
                    scrollView.contentOffset.y = 0
                }
                else if offset > maxY {
                    scrollView.frame.origin.y = maxY  - scrollView.frame.height
                    scrollView.contentOffset.y = scrollView.frame.origin.y
                }
                return
            }
            let innerOffset = offset - origin
            scrollView.frame.origin.y = innerOffset
            scrollView.contentOffset.y = innerOffset
        }
    }
    
}
