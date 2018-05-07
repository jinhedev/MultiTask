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
    var tasks: Results<Task>? { didSet { self.observeTasksForChanges() } }
    var realmNotificationToken: NotificationToken?
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var placeholderBackgroundView: PlaceholderBackgroundView = {
        let view = UINib(nibName: PlaceholderBackgroundView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as! PlaceholderBackgroundView
        view.setView(isHidden: false, type: PlaceholderType.pendingTasks)
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
    
    // MARK: - Realm
    
    private func observeTasksForChanges() {
        realmNotificationToken = self.tasks?.observe({ [weak self] (changes) in
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
    
    // MARK: - Setups
    
    private func setupCollectionView() {
        collectionView.backgroundColor = Color.inkBlack
        collectionView.indicatorStyle = .white
        collectionView.alwaysBounceVertical = true
        collectionView.scrollsToTop = true
    }
    
    private func registerCells() {
        collectionView.register(UINib(nibName: CompletedTaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: CompletedTaskCell.cell_id)
        collectionView.register(UINib(nibName: PendingTaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: PendingTaskCell.cell_id)
        // TODO: Adds segmented control as a complimentary view
    }
    
    private func setupNavigationBar() {
        self.navigationItem.rightBarButtonItems = [addButton, editButton]
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: avatarButton)]
    }
    
    private func registerSupplementaryViews() {
        collectionView.register(UINib(nibName: TasksHeaderView.nibName, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: TasksHeaderView.viewId)
    }
    
    // MARK: - Background PlaceholderView
    
    private func addBackgroundViewToCollectionView() {
        collectionView.backgroundView = placeholderBackgroundView
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupCollectionView()
        self.addBackgroundViewToCollectionView()
        self.setupUICollectionViewDelegateFlowLayout()
        self.setupUICollectionViewDelegate()
        self.setupUICollectionViewDataSource()
        self.registerSupplementaryViews()
        self.registerCells()
        self.tasks = Task.pending()
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
    
    private func setupUICollectionViewDelegateFlowLayout() {
        collectionViewFlowLayout.sectionHeadersPinToVisibleBounds = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.collectionView.frame.width
        let cellHeight: CGFloat = 8 + 16 + (0) + 8 + 15 + 15 + 16 + 8
        // REMARK: containerViewTopMargin + titleLabelTopMargin + (titleLabelHeight) + titleLabelBottomMargin + subtitleLabelHeight + dateLabelHeight + dateLabelBottomMargin + containerViewBottomMargin (see TaskCell.xib for references)
        if let task = self.tasks?[indexPath.item] {
            let titleWidth: CGFloat = cellWidth - 16 - 16 - 16 - 16
            let estimateHeightForTitle = task.title.heightForText(systemFont: 15, width: titleWidth) // (the container's leading margin to View's leading == 16) + (titleLabel's leading margin to container's leading == 16), same for the trailling
            return CGSize(width: cellWidth, height: estimateHeightForTitle + cellHeight)
        }
        return CGSize(width: cellWidth, height: cellHeight + 44) // 44 is the estimated minimum height for titleLabel when none is provided
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.width
        let height: CGFloat = 56
        return CGSize(width: width, height: height)
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
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: PendingTaskCell.cell_id, for: indexPath) as? PendingTaskCell {
            let task = self.tasks?[indexPath.item]
            cell.pendingTask = task
            return cell
        } else {
            return BaseCollectionViewCell()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TasksHeaderView.viewId, for: indexPath) as! TasksHeaderView
            view.delegate = self
            return view
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tasks?.count ?? 0
    }
}

extension TasksViewController: TasksHeaderViewDelegate {
    
    func headerView(_ sender: UISegmentedControl, fromView: TasksHeaderView) {
        // TODO: implement this
    }
    
}
