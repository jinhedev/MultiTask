//
//  MainTasksViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/10/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

protocol MainTasksViewControllerDelegate: NSObjectProtocol {
    func mainTasksViewController(_ viewController: MainTasksViewController, didTapTrash button: UIBarButtonItem)
    func editModeDidChange(_ viewController: MainTasksViewController, isEditing: Bool)
}

class MainTasksViewController: BaseViewController {

    var currentUser: User? { didSet { self.updateAvatarButton() } }

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

    var realmManager: RealmManager?
    weak var delegate: MainTasksViewControllerDelegate?
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
        self.editButton.image = editing ? #imageLiteral(resourceName: "Delete") : #imageLiteral(resourceName: "List") // <<-- image literal
        self.segmentedControl.isEnabled = !editing
        if editing {
            self.navigationItem.leftBarButtonItems?.append(trashButton)
        } else {
            self.navigationItem.leftBarButtonItems?.remove(at: 1)
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
        self.isEditing = false
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
        if self.isEditing == true {
            self.isEditing = false
            self.delegate?.mainTasksViewController(self, didTapTrash: sender)
            self.delegate?.editModeDidChange(self, isEditing: false)
        } else {
            print(trace(file: #file, function: #function, line: #line))
        }
    }

    @objc func handleEdit(_ sender: UIBarButtonItem) {
        // toggling edit mode
        if self.isEditing == true {
            // if already in editMode, exit editMode
            self.isEditing = false
            self.delegate?.editModeDidChange(self, isEditing: false)
        } else {
            // if not in editMode, enter editMode
            self.isEditing = true
            self.delegate?.editModeDidChange(self, isEditing: true)
        }
    }

    func observeNotificationForEditingMode() {
        NotificationCenter.default.addObserver(self, selector: #selector(editMode(notification:)), name: NSNotification.Name.PendingTaskCellEditingMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editMode(notification:)), name: NSNotification.Name.CompletedTaskCellEditingMode, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupMenuView()
        self.setupSegmentedControl()
        self.setupPersistentContainerDelegate()
        self.observeNotificationForEditingMode()
        self.realmManager?.fetchExistingUsers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateAvatarButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let settingsViewController = segue.destination as? SettingsViewController {
            settingsViewController.currentUser = self.currentUser
        }
        if segue.identifier == Segue.PendingContainerViewToPendingTasksViewController {
            if let pendingTasksViewController = segue.destination as? PendingTasksViewController {
                pendingTasksViewController.mainTasksViewController = self
            }
        }
        if segue.identifier == Segue.CompletedContainerViewToPendingTasksViewController {
            if let completedTasksViewController = segue.destination as? CompletedTasksViewController {
                completedTasksViewController.mainTasksViewController = self
            }
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
