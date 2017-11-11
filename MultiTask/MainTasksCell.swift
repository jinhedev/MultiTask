//
//  MainTaskCell.swift
//  MultiTask
//
//  Created by rightmeow on 11/10/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class MainTasksCell: BaseCollectionViewCell {

    static let cell_id = String(describing: MainTasksCell.self)
    static let nibName = String(describing: MainTasksCell.self)

    // MARK: - UICollectionView

    @IBOutlet weak var collectionView: UICollectionView!

    private func setupCollectionView() {
        self.collectionView.backgroundColor = Color.inkBlack
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
