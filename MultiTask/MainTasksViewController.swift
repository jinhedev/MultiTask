//
//  MainTasksViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/10/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class MainTasksViewController: BaseViewController {

    // MARK: - API

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

    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Plus"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleAdd(_:)))
        return button
    }()

    lazy var trashButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Trash"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleTrash(_:)))
        return button
    }()

    /// editButton can be toggled to become a cancel button when in edit mode
    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "List"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleEdit(_:)))
        return button
    }()
    
    lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Delete"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleCancel(_:)))
        return button
    }()

    var currentUser: User? { didSet { self.updateAvatarButton() } }
    var realmManager: RealmManager?
    static let storyboard_id = String(describing: MainTasksViewController.self)
    let searchController = UISearchController(searchResultsController: nil)
    let popTransitionAnimator = PopTransitionAnimator()
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pendingContainerView: UIView!
    @IBOutlet weak var completedContainerView: UIView!
    @IBOutlet weak var menuView: UIView!

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.addButton.isEnabled = !editing
        self.avatarButton.isEnabled = !editing
        self.segmentedControl.isEnabled = !editing
        if editing {
            self.navigationItem.rightBarButtonItems?.remove(at: 1)
            self.navigationItem.rightBarButtonItems?.append(cancelButton)
            self.navigationItem.leftBarButtonItems?.append(trashButton)
        } else {
            self.navigationItem.leftBarButtonItems?.remove(at: 1)
            self.navigationItem.rightBarButtonItems?.append(editButton)
            self.navigationItem.rightBarButtonItems?.remove(at: 1)
        }
    }
    
    @objc func editMode(notification: Notification) {
        if let isEditing = notification.userInfo?["isEditing"] as? Bool {
            self.isEditing = isEditing
        }
    }
    
    @IBAction func segmentedControl_tapped(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.15, animations: {
                self.pendingContainerView.alpha = 1
                self.completedContainerView.alpha = 0
            })
        } else if sender.selectedSegmentIndex == 1 {
            UIView.animate(withDuration: 0.15, animations: {
                self.pendingContainerView.alpha = 0
                self.completedContainerView.alpha = 1
            })
        }
    }
    
    private func setupMenuView() {
        self.menuView.backgroundColor = Color.clear
    }
    
    private func setupSegmentedControl() {
        self.segmentedControl.selectedSegmentIndex = 0
    }

    // MARK: - NavigationBar

    private func setupNavigationBar() {
        // setup barButtons after the isEditting is set, otherwise setEditing get called.
        self.navigationItem.rightBarButtonItems = [addButton, editButton]
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: avatarButton)]
    }

    private func updateAvatarButton() {
        guard let user = self.currentUser else { return }
        let avatarName = user.avatar
        let avatar = UIImage(named: avatarName)
        self.avatarButton.setImage(avatar, for: UIControlState.normal)
    }

    @objc func handleAvatar() {
        self.performSegue(withIdentifier: Segue.AvatarButtonToSettingsViewController, sender: self)
    }

    @objc func handleAdd(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: Segue.AddButtonToTaskEditorViewController, sender: self)
    }

    @objc func handleTrash(_ sender: UIBarButtonItem) {
        self.postNotificationForEditMode(isEditing: false)
        self.postNotificationForCommitingTrash()
    }

    @objc func handleEdit(_ sender: UIBarButtonItem) {
        self.postNotificationForEditMode(isEditing: true)
    }
    
    @objc func handleCancel(_ sender: UIBarButtonItem) {
        self.postNotificationForEditMode(isEditing: false)
    }
    
    // MARK: - Notification
    
    func postNotificationForEditMode(isEditing: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name.EditMode, object: nil, userInfo: ["isEditing" : isEditing])
    }
    
    func postNotificationForCommitingTrash() {
        NotificationCenter.default.post(name: NSNotification.Name.CommitTrash, object: nil, userInfo: nil)
    }

    func observeNotificationForEditMode() {
        NotificationCenter.default.addObserver(self, selector: #selector(editMode(notification:)), name: NSNotification.Name.EditMode, object: nil)
    }
    
    func removeNotificationForEditMode() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.EditMode, object: nil)
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupMenuView()
        self.setupSegmentedControl()
        self.setupPersistentContainerDelegate()
        self.realmManager?.fetchExistingUsers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateAvatarButton()
        self.observeNotificationForEditMode()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeNotificationForEditMode()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let settingsViewController = segue.destination as? SettingsViewController {
            settingsViewController.currentUser = self.currentUser
        }
    }

}

extension MainTasksViewController: PersistentContainerDelegate {
    
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

extension MainTasksViewController: UIViewControllerTransitioningDelegate {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.view.alpha = (size.width > size.height) ? 0.25 : 0.55
        }, completion: nil)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let addButtonView = self.addButton.value(forKey: "view") as? UIView {
            let barButtonFrame = addButtonView.frame
            popTransitionAnimator.originFrame = barButtonFrame
            popTransitionAnimator.isPresenting = true
            return popTransitionAnimator
        } else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // TODO: - implement this
        popTransitionAnimator.isPresenting = false
        return popTransitionAnimator
    }
    
}
