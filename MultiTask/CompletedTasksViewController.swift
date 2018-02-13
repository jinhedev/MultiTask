//
//  CompletedTasksViewController.swift
//  MultiTask
//
//  Created by sudofluff on 2/10/18.
//  Copyright © 2018 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class CompletedTasksViewController: BaseViewController {
    
    var completedTasks: Results<Task>? { didSet { self.observeTasksForChanges() } }
    static let storyboard_id = String(describing: CompletedTasksViewController.self)
    weak var mainTasksViewController: MainTasksViewController?
    var realmNotificationToken: NotificationToken?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.collectionView.allowsMultipleSelection = isEditing
        let indexPaths = self.collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            self.collectionView.deselectItem(at: indexPath, animated: false)
            if let cell = self.collectionView.cellForItem(at: indexPath) as? CompletedTaskCell {
                cell.isEditing = isEditing
            }
        }
    }
    
    func observeTasksForChanges() {
        realmNotificationToken = self.completedTasks?.observe({ [weak self] (changes) in
            guard let collectionView = self?.collectionView else { return }
            switch changes {
            case .initial:
                collectionView.reloadData()
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                collectionView.applyChanges(deletions: deletions, insertions: insertions, updates: modifications)
            case .error(let err):
                print(trace(file: #file, function: #function, line: #line))
                print(err.localizedDescription)
            }
        })
    }
    
    private func setupBackgroundView() {
        if let view = UINib(nibName: PlaceholderBackgroundView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? PlaceholderBackgroundView {
            view.type = PlaceholderType.completedTasks
            view.isHidden = true
            self.collectionView.backgroundView = view
        }
    }
    
    private func setupUICollectionView() {
        self.collectionView.indicatorStyle = .white
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.scrollsToTop = true
        self.collectionView.register(UINib(nibName: CompletedTaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: CompletedTaskCell.cell_id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackgroundView()
        self.setupUICollectionView()
        self.setupMainTasksViewControllerDelegate()
        self.setupUICollectionViewDelegate()
        self.setupUICollectionViewDataSource()
        self.setupUICollectionViewDelegateFlowLayout()
        self.completedTasks = Task.completed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let tasks = self.completedTasks {
            if tasks.count <= 0 {
                self.collectionView.backgroundView?.isHidden = false
            } else {
                self.collectionView.backgroundView?.isHidden = true
            }
        }
    }
    
}

extension CompletedTasksViewController: MainTasksViewControllerDelegate {
    
    private func setupMainTasksViewControllerDelegate() {
        self.mainTasksViewController?.delegate = self
    }
    
    func mainTasksViewController(_ viewController: MainTasksViewController, didTapEdit button: UIBarButtonItem, isEditing: Bool) {
        self.isEditing = isEditing
    }
    
    func mainTasksViewController(_ viewController: MainTasksViewController, didTapTrash button: UIBarButtonItem) {
        self.isEditing = false
    }
    
}

extension CompletedTasksViewController: UICollectionViewDelegate {
    
    private func setupUICollectionViewDelegate() {
        self.collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let highlightedCell = self.collectionView.cellForItem(at: indexPath) as? CompletedTaskCell {
            highlightedCell.isHighlighted = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let highlightedCell = self.collectionView.cellForItem(at: indexPath) as? CompletedTaskCell {
            highlightedCell.isHighlighted = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isEditing == false {
            if let itemsViewController = UIStoryboard(name: "TasksTab", bundle: nil).instantiateViewController(withIdentifier: ItemsViewController.storyboard_id) as? ItemsViewController, let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first {
                itemsViewController.selectedTask = self.completedTasks?[selectedIndexPath.item]
                self.mainTasksViewController?.navigationController?.pushViewController(itemsViewController, animated: true)
            }
        } else {
            if let selectedCell = self.collectionView.cellForItem(at: indexPath) as? CompletedTaskCell {
                selectedCell.isSelected = true
            }
        }
    }
    
}

extension CompletedTasksViewController: UICollectionViewDataSource {
    
    private func setupUICollectionViewDataSource() {
        self.collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CompletedTaskCell.cell_id, for: indexPath) as? CompletedTaskCell {
            let task = self.completedTasks?[indexPath.item]
            cell.completedTask = task
            return cell
        } else {
            return BaseCollectionViewCell()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.completedTasks?.count ?? 0
    }
    
}

extension CompletedTasksViewController: UICollectionViewDelegateFlowLayout {
    
    private func setupUICollectionViewDelegateFlowLayout() {
        self.collectionViewFlowLayout.scrollDirection = .vertical
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (self.collectionView.frame.width / 2) - 16 - 8 // cell leading & cell trailling space to offset (collectionView.insets + interItemSpacing)
        let cellHeight: CGFloat = 16 + (0) + 8 + 15 + 15 + 15 + 16
        return CGSize(width: cellWidth, height: cellHeight + 22) // 44 is the estimated minimum height for titleLabel
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
}
