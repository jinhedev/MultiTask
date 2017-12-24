//
//  BranchesViewController.swift
//  MultiTask
//
//  Created by rightmeow on 12/5/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class SketchesViewController: BaseViewController, PersistentContainerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerPreviewingDelegate, SketchEditorViewControllerDelegate {

    // MARK: - API

    var currentUser: User? {
        didSet {
            self.updateAvatarButton()
        }
    }

    var sketches: [Results<Sketch>]?
    var realmManager: RealmManager?
    var notificationToken: NotificationToken?
    static let storyboard_id = String(describing: SketchesViewController.self)

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

    lazy var trashButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Trash"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleTrash))
        return button
    }()

    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Plus"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleAdd))
        return button
    }()

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.addButton.isEnabled = !editing
        self.avatarButton.isEnabled = !editing
        self.editButton.image = editing ? #imageLiteral(resourceName: "Delete") : #imageLiteral(resourceName: "List") // <<-- image literal
        if editing {
            self.navigationItem.leftBarButtonItems?.append(trashButton)
        } else {
            self.navigationItem.leftBarButtonItems?.remove(at: 1)
        }
        // put all cells into edit mode
        self.collectionView?.allowsMultipleSelection = isEditing
        guard let indexPaths = self.collectionView?.indexPathsForVisibleItems else { return }
        for indexPath in indexPaths {
            self.collectionView?.deselectItem(at: indexPath, animated: false)
            if let cell = self.collectionView?.cellForItem(at: indexPath) as? SketchCell {
                cell.isEditing = isEditing
            }
        }
    }

    @objc func enableEditingMode() {
        self.isEditing = true
    }

    // MARK: - NavigationBar

    @objc func handleAvatar() {
        self.performSegue(withIdentifier: Segue.AvatarButtonToSettingsViewController, sender: self)
    }

    @objc func handleAdd(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: Segue.AddButtonToSketchEditorViewController, sender: self)
    }

    @objc func handleEdit(_ sender: UIBarButtonItem) {
        // toggling edit mode
        if self.isEditing == true {
            self.isEditing = false
        } else {
            self.isEditing = true
        }
    }

    @objc func handleTrash(_ sender: UIBarButtonItem) {
        if self.isEditing == true {
            guard let unwrappedSketches = self.sketches else { return }
            var sketchesToBeDeleted = [Sketch]()
            if let indexPaths = self.collectionView.indexPathsForSelectedItems {
                for indexPath in indexPaths {
                    let sketchToBeDeleted = unwrappedSketches[indexPath.section][indexPath.item]
                    sketchesToBeDeleted.append(sketchToBeDeleted)
                }
                self.realmManager?.deleteSketches(sketches: sketchesToBeDeleted)
            }
        } else {
            print(trace(file: #file, function: #function, line: #line))
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

    // MARK: - PersistentContainerDelegate

    private func setupPersistentContainerDelegate() {
        self.realmManager = RealmManager()
        self.realmManager!.delegate = self
    }

    private func setupRealmNotificationsForCollectionView() {
        notificationToken = self.sketches!.first?.observe({ [weak self] (changes) in
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

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }

    func persistentContainer(_ manager: RealmManager, didFetchSketches sketches: Results<Sketch>?) {
        if let fetchedSketches = sketches, !fetchedSketches.isEmpty {
            self.collectionView.backgroundView?.isHidden = true
            self.sketches = [Results<Sketch>]()
            self.sketches!.append(fetchedSketches)
            self.setupRealmNotificationsForCollectionView()
        } else {
            self.collectionView.backgroundView?.isHidden = false
        }
    }

    func persistentContainer(_ manager: RealmManager, didDeleteSketches sketches: [Sketch]?) {
        if self.isEditing == true {
            // exit edit mode
            self.isEditing = false
        }
    }

    func persistentContainer(_ manager: RealmManager, didFetchUsers users: Results<User>?) {
        guard let fetchedUser = users?.first else { return }
        self.currentUser = fetchedUser
    }

    @objc func performInitialFetch(notification: Notification?) {
        if self.sketches == nil || self.sketches?.isEmpty == true {
            self.realmManager?.fetchSketches(sortedBy: Sketch.createdAtKeyPath, ascending: false)
        }
    }

    // MARK: - SketchEditorViewControllerDelegate

    func sketchEditorViewController(_ viewController: SketchEditorViewController, didUpdateSketch sketch: Sketch) {
        if let navController = self.navigationController as? BaseNavigationController {
            navController.popViewController(animated: true)
            self.performInitialFetch(notification: nil)
        }
    }

    // MARK: - Notifications

    func observeNotificationForEditingMode() {
        NotificationCenter.default.addObserver(self, selector: #selector(enableEditingMode), name: NSNotification.Name(rawValue: NotificationKey.SketchCellEditingMode), object: nil)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupCollectionView()
        self.setupUICollectionViewDelegateFlowLayout()
        self.setupUIViewControllerPreviewingDelegate()
        self.setupPersistentContainerDelegate()
        self.observeNotificationForEditingMode()
        // initial fetches
        self.realmManager?.fetchExistingUsers()
        self.performInitialFetch(notification: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateAvatarButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let settingsViewController = segue.destination as? SettingsViewController {
            settingsViewController.currentUser = self.currentUser
        } else if segue.identifier == Segue.AddButtonToSketchEditorViewController {
            if let sketchEditorViewController = segue.destination as? SketchEditorViewController {
                sketchEditorViewController.hidesBottomBarWhenPushed = true
                sketchEditorViewController.delegate = self
            }
        } else if segue.identifier == Segue.SketchCellToSketchEditorViewController {
            if let sketchEditorViewController = segue.destination as? SketchEditorViewController {
                sketchEditorViewController.hidesBottomBarWhenPushed = true
                sketchEditorViewController.delegate = self
                if let selectedIndex = self.collectionView.indexPathsForSelectedItems?.first {
                    sketchEditorViewController.sketch = self.sketches?[selectedIndex.section][selectedIndex.item]
                }
            }
        }
    }

    // MARK: - UIViewControllerPreviewingDelegate

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
        sketchEditorViewController?.delegate = self
        sketchEditorViewController?.sketch = sketches?[indexPath.section][indexPath.row]
        // setting the peeking cell's animation
        if let selectedCell = self.collectionView.cellForItem(at: indexPath) as? SketchCell {
            previewingContext.sourceRect = selectedCell.frame
        }
        return sketchEditorViewController
    }

    // MARK: - CollectionView

    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.register(UINib(nibName: SketchCell.nibName, bundle: nil), forCellWithReuseIdentifier: SketchCell.cell_id)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

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

    // MARK: - UICollectionViewDelegate

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

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: SketchCell.cell_id, for: indexPath) as? SketchCell {
            cell.sketch = self.sketches?[indexPath.section][indexPath.item]
            return cell
        } else {
            return BaseCollectionViewCell()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sketches?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sketches?[section].count ?? 0
    }

}
