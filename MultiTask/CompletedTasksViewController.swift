//
//  CompletedTasksViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/11/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class CompletedTasksViewController: BaseViewController, PersistentContainerDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var completedTasks: [Results<Task>]?
    var notificationToken: NotificationToken?
    static let storyboard_id = String(describing: CompletedTasksViewController.self)

    // MARK: - UICollectionView

    @IBOutlet weak var collectionView: UICollectionView!

    /**
     Reload the whole collectionView on a main thread.
     - warning: Reloading the whole collectionView is expensive. Only use this method for the initial reload at the first time collectionView is set at viewDidLoad.
     */
    private func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    private func setupCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.register(UINib(nibName: TaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: TaskCell.cell_id)
    }

    // MARK: - PersistentContainerDelegate

    var realmManager: RealmManager?

    private func setupPersistentContainerDelegate() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }

    func persistentContainer(_ manager: RealmManager, didFetch tasks: Results<Task>) {
        if self.completedTasks == nil {
            self.completedTasks = [Results<Task>]()
            self.completedTasks!.append(tasks)
        } else {
            self.completedTasks!.append(tasks)
        }
        self.reloadCollectionView()
    }

    func persistentContainer(_ manager: RealmManager, didUpdate object: Object) {
        // TODO: implement this
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupPersistentContainerDelegate()
        self.realmManager?.fetchTasks(predicate: Task.completedPredicate)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let itemsViewController = segue.destination as? ItemsViewController {

        }
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Segue.CompletedTaskCellToItemsViewController, sender: self)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.collectionView.frame.width
        let cellHeight: CGFloat = 128
        return CGSize(width: cellWidth, height: cellHeight)
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return completedTasks?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return completedTasks?[section].count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let completedTaskCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.cell_id, for: indexPath) as? TaskCell else {
            return BaseCollectionViewCell()
        }
        let task = completedTasks?[indexPath.section][indexPath.item]
        completedTaskCell.task = task
        return completedTaskCell
    }

}
