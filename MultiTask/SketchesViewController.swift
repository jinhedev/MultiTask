//
//  BranchesViewController.swift
//  MultiTask
//
//  Created by rightmeow on 12/5/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift
import Amplitude

class SketchesViewController: BaseViewController {

    // MARK: - API

    var currentUser: User? {
        didSet {
            self.updateAvatarButton()
        }
    }

    var sketches: Results<Sketch>? { didSet { self.observeSketchesForChanges() } }
    var realmManager: RealmManager?
    var realmNotificationToken: NotificationToken?
    static let storyboard_id = String(describing: SketchesViewController.self)
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    lazy var avatarButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFill
        button.layer.borderColor = Color.lightGray.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleAvatar), for: UIControlEvents.touchUpInside)
        return button
    }()

    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "List"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleEdit))
        return button
    }()
    
    lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Delete"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleCancel(_:)))
        return button
    }()

    lazy var trashButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Trash"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleTrash))
        return button
    }()

    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Plus"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleAdd))
        return button
    }()

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // put navBar into edit mode
        self.addButton.isEnabled = !editing
        self.avatarButton.isEnabled = !editing
        self.collectionView?.allowsMultipleSelection = isEditing
        if editing {
            self.navigationItem.leftBarButtonItems?.append(trashButton)
            self.navigationItem.rightBarButtonItems?.remove(at: 1)
            self.navigationItem.rightBarButtonItems?.append(cancelButton)
        } else {
            self.navigationItem.leftBarButtonItems?.remove(at: 1)
            self.navigationItem.rightBarButtonItems?.remove(at: 1)
            self.navigationItem.rightBarButtonItems?.append(editButton)
        }
        // put all cells into edit mode
        guard let indexPaths = self.collectionView?.indexPathsForVisibleItems else { return }
        for indexPath in indexPaths {
            self.collectionView?.deselectItem(at: indexPath, animated: false)
            if let cell = self.collectionView?.cellForItem(at: indexPath) as? SketchCell {
                cell.isEditing = isEditing
            }
        }
    }
    
    @objc func editMode(notification: Notification) {
        if let isEditing = notification.userInfo?["isEditing"] as? Bool {
            self.isEditing = isEditing
        }
    }
    
    func observeSketchesForChanges() {
        realmNotificationToken = self.sketches?.observe({ [weak self] (changes) in
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
    
    func deleteSketches(indexPaths: [IndexPath]) {
        guard let unwrappedSketches = self.sketches, indexPaths.count > 0 else { return }
        // FIXME: is there a way to minimise the number of write operations to the db???
        for indexPath in indexPaths {
            let sketchToBeDeleted = unwrappedSketches[indexPath.item]
            sketchToBeDeleted.delete()
        }
    }

    // MARK: - NavigationBar

    @objc func handleAvatar() {
        self.performSegue(withIdentifier: Segue.AvatarButtonToSettingsViewController, sender: self)
    }

    @objc func handleAdd(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: Segue.AddButtonToSketchEditorViewController, sender: self)
    }
    
    @objc func handleCancel(_ sender: UIBarButtonItem) {
        self.postNotificationForEditMode(isEditing: false)
    }

    @objc func handleEdit(_ sender: UIBarButtonItem) {
        // toggling edit mode
        if self.isEditing == true {
            self.postNotificationForEditMode(isEditing: false)
        } else {
            self.postNotificationForEditMode(isEditing: true)
        }
    }

    @objc func handleTrash(_ sender: UIBarButtonItem) {
        self.postNotificationForCommitingTrash()
        self.postNotificationForEditMode(isEditing: false)
    }
    
    @objc func commitTrash() {
        if let selectedSketches = self.collectionView.indexPathsForSelectedItems {
            deleteSketches(indexPaths: selectedSketches)
        }
    }

    private func setupNavigationBar() {
        self.isEditing = false
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: avatarButton)]
        self.navigationItem.rightBarButtonItems = [addButton, editButton]
    }

    private func updateAvatarButton() {
        guard let user = self.currentUser else { return }
        let avatarName = user.avatar
        let avatar = UIImage(named: avatarName)
        self.avatarButton.setImage(avatar, for: UIControlState.normal)
    }

    // MARK: - Notifications
    
    func postNotificationForEditMode(isEditing: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name.EditMode, object: nil, userInfo: ["isEditing" : isEditing])
    }
    
    func postNotificationForCommitingTrash() {
        NotificationCenter.default.post(name: NSNotification.Name.CommitTrash, object: nil, userInfo: nil)
    }

    func observeNotificationForEditMode() {
        NotificationCenter.default.addObserver(self, selector: #selector(editMode(notification:)), name: NSNotification.Name.EditMode, object: nil)
    }
    
    func observeNotificationForCommitingTrash() {
        NotificationCenter.default.addObserver(self, selector: #selector(commitTrash), name: NSNotification.Name.CommitTrash, object: nil)
    }
    
    func removeNotificationForEditMode() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.EditMode, object: nil)
    }
    
    func removeNotificationForCommitingTrash() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.CommitTrash, object: nil)
    }

    // MARK: - UITabBar

    private func showTabBar() {
        if let baseTabBarController = self.tabBarController as? BaseTabBarController {
            baseTabBarController.tabBar.isHidden = false
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupCollectionView()
        self.setupUICollectionViewDelegate()
        self.setupUICollectionViewDataSource()
        self.setupBackgroundView()
        self.setupUICollectionViewDelegateFlowLayout()
        self.setupUIViewControllerPreviewingDelegate()
        self.setupPersistentContainerDelegate()
        // initial actions
        self.realmManager?.fetchExistingUsers()
        self.sketches = Sketch.all()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.observeNotificationForEditMode()
        self.observeNotificationForCommitingTrash()
        self.updateAvatarButton()
        self.showTabBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeNotificationForEditMode()
        self.removeNotificationForCommitingTrash()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Segue.AvatarButtonToSettingsViewController {
            guard let settingsViewController = segue.destination as? SettingsViewController else { return }
            settingsViewController.currentUser = self.currentUser
        } else if segue.identifier == Segue.AddButtonToSketchEditorViewController {
            guard let sketchEditorViewController = segue.destination as? SketchEditorViewController else { return }
            sketchEditorViewController.hidesBottomBarWhenPushed = true
            sketchEditorViewController.sketch = Sketch()
            sketchEditorViewController.sketchEditorAction = SketchEditorAction.AddNewSketch
        } else if segue.identifier == Segue.SketchCellToSketchEditorViewController {
            guard let sketchEditorViewController = segue.destination as? SketchEditorViewController else { return }
            guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else { return }
            sketchEditorViewController.sketch = self.sketches?[selectedIndexPath.item]
            sketchEditorViewController.sketchEditorAction = SketchEditorAction.UpdateExistingSketch
        }
    }
    
    // MARK: - BackgroundView
    
    private func setupBackgroundView() {
        if let view = UINib(nibName: PlaceholderBackgroundView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? PlaceholderBackgroundView {
            view.type = PlaceholderType.pendingTasks
            view.isHidden = true
            self.collectionView.backgroundView = view
        }
    }

    // MARK: - CollectionView

    private func setupCollectionView() {
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.register(UINib(nibName: SketchCell.nibName, bundle: nil), forCellWithReuseIdentifier: SketchCell.cell_id)
    }

}

extension SketchesViewController: PersistentContainerDelegate {
    
    private func setupPersistentContainerDelegate() {
        self.realmManager = RealmManager()
        self.realmManager!.delegate = self
    }
    
    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }
    
    func persistentContainer(_ manager: RealmManager, didFetchUsers users: Results<User>?) {
        guard let fetchedUser = users?.first else { return }
        self.currentUser = fetchedUser
    }
    
}

extension SketchesViewController: UIViewControllerPreviewingDelegate {
    
    private func setupUIViewControllerPreviewingDelegate() {
        self.registerForPreviewing(with: self, sourceView: self.collectionView)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let navController = self.navigationController as? BaseNavigationController {
            viewControllerToCommit.hidesBottomBarWhenPushed = true
            navController.pushViewController(viewControllerToCommit, animated: true)
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.collectionView.indexPathForItem(at: location) else { return nil }
        let sketchEditorViewController = storyboard?.instantiateViewController(withIdentifier: SketchEditorViewController.storyboard_id) as? SketchEditorViewController
        sketchEditorViewController?.sketch = sketches?[indexPath.item]
        sketchEditorViewController?.sketchEditorAction = SketchEditorAction.UpdateExistingSketch
        // setting the peeking cell's animation
        if let selectedCell = self.collectionView.cellForItem(at: indexPath) as? SketchCell {
            previewingContext.sourceRect = selectedCell.frame
        }
        return sketchEditorViewController
    }
    
}

extension SketchesViewController: UICollectionViewDelegateFlowLayout {
    
    private func setupUICollectionViewDelegateFlowLayout() {
        self.collectionViewFlowLayout.minimumLineSpacing = 16
        self.collectionViewFlowLayout.minimumInteritemSpacing = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (self.collectionView.frame.width / 2) - 8 - 16
        let cellHeight: CGFloat = cellWidth + 8 + (22) + 16
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}

extension SketchesViewController: UICollectionViewDelegate {
    
    private func setupUICollectionViewDelegate() {
        self.collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isEditing == false {
            performSegue(withIdentifier: Segue.SketchCellToSketchEditorViewController, sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let highlightedCell = self.collectionView.cellForItem(at: indexPath) as? SketchCell {
            highlightedCell.isHighlighted = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let highlightedCell = self.collectionView.cellForItem(at: indexPath) as? SketchCell {
            highlightedCell.isHighlighted = false
        }
    }
    
}

extension SketchesViewController: UICollectionViewDataSource {
    
    private func setupUICollectionViewDataSource() {
        self.collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: SketchCell.cell_id, for: indexPath) as? SketchCell {
            cell.sketch = self.sketches?[indexPath.item]
            return cell
        } else {
            return BaseCollectionViewCell()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sketches?.count ?? 0
    }
    
}
