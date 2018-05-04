//
//  TasksViewController.swift
//  MultiTask
//
//  Created by sudofluff on 5/4/18.
//  Copyright © 2018 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class TasksViewController: BaseViewController {
    
    static let storyboardId = String(describing: TasksViewController.self)
    var tasks: Results<Task>?
    var realmNotificationToken: NotificationToken?
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var placeholderBackgroundView: PlaceholderBackgroundView = {
        let view = UINib(nibName: PlaceholderBackgroundView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as! PlaceholderBackgroundView
        return view
    }()
    
    lazy var avatarButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFill
        button.layer.borderColor = Color.lightGray.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(avatarButtonTapped), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Plus"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addButtonTapped))
        return button
    }()
    
    lazy var trashButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Trash"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(trashButtonTapped))
        return button
    }()
    
    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Edit"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(editButtonTapped))
        return button
    }()
    
    lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Delete"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelButtonTapped))
        return button
    }()
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.isEditing = true
    }
    
    @objc private func avatarButtonTapped() {
        
    }
    
    @objc private func addButtonTapped() {
        
    }
    
    @objc private func trashButtonTapped() {
        
    }
    
    @objc private func editButtonTapped() {
    
    }
    
    @objc private func cancelButtonTapped() {
        
    }
    
    // MARK: - Setups
    
    private func setupCollectionView() {
        collectionView.backgroundColor = Color.inkBlack
        collectionView.indicatorStyle = .white
        collectionView.alwaysBounceVertical = true
        collectionView.scrollsToTop = true
    }
    
    private func registerCellsToCollectionView() {
        collectionView.register(UINib(nibName: CompletedTaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: CompletedTaskCell.cell_id)
        collectionView.register(UINib(nibName: PendingTaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: PendingTaskCell.cell_id)
        // TODO: Adds segmented control as a complimentary view
    }
    
    private func setupNavigationBar() {
        self.navigationItem.rightBarButtonItems = [addButton, editButton]
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: avatarButton)]
    }
    
    // MARK: - Background PlaceholderView
    
    private func addBackgroundViewToCollectionView() {
        collectionView.backgroundView = placeholderBackgroundView
    }
    
    private func setBackgroundView(isHidden: Bool, type: PlaceholderType) {
        placeholderBackgroundView.isHidden = isHidden
        placeholderBackgroundView.type = type
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupCollectionView()
        self.addBackgroundViewToCollectionView()
        self.setBackgroundView(isHidden: false, type: PlaceholderType.pendingTasks)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
}

extension TasksViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.zero
    }
    
}

extension TasksViewController: UICollectionViewDelegate {
    
    private func setupUICollectionViewDelegate() {
        collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        
    }
    
}

extension TasksViewController: UICollectionViewDataSource {
    
    private func setupUICollectionViewDataSource() {
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return BaseCollectionViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tasks?.count ?? 0
    }
}
