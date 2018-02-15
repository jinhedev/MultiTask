//
//  ItemEditorView.swift
//  MultiTask
//
//  Created by rightmeow on 11/12/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import Amplitude
import RealmSwift

class ItemEditorViewController: BaseViewController {

    var parentTask: Task?
    var selectedItem: Item?
    static let storyboard_id = String(describing: ItemEditorViewController.self)
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!

    @IBAction func handleSave(_ sender: UIButton) {
        self.titleTextView.resignFirstResponder()
        // if selectedItem is nil, that means this MVC is segued from the AddButton, else it is initiated with peek and pop
        if self.selectedItem != nil {
            self.selectedItem!.title = self.titleTextView.text
            self.selectedItem!.save()
        } else {
            let newItem = self.create()
            self.append(newItem: newItem)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // update an existing item
    func update(item: Item, keyedValues: [String : Any]) {
        do {
            try defaultRealm.write {
                item.setValuesForKeys(keyedValues)
                defaultRealm.add(item, update: true)
            }
        } catch let err {
            print(err.localizedDescription)
            Amplitude.instance().logEvent(LogEventType.realmError)
        }
    }
    
    // append a item to the items list array
    func append(newItem: Item) {
        if newItem.isValid() {
            do {
                try defaultRealm.write {
                    self.parentTask!.is_completed = false
                    self.parentTask!.items.append(newItem)
                }
            } catch let err {
                print(err.localizedDescription)
                Amplitude.instance().logEvent(LogEventType.realmError)
            }
        } else {
            print("invalid format for item")
        }
    }
    
    // create a new item
    func create() -> Item {
        let item = Item(title: titleTextView.text)
        return item
    }

    private func setupView() {
        self.view.backgroundColor = Color.inkBlack
        self.scrollView.backgroundColor = Color.clear
        self.scrollView.delaysContentTouches = false
        self.containerView.backgroundColor = Color.clear
        self.contentContainerView.backgroundColor = Color.inkBlack
        self.titleLabel.backgroundColor = Color.clear
        self.titleLabel.textColor = Color.white
        self.titleLabel.text = self.selectedItem == nil ? "Add a new item" : "Edit an item"
        self.subtitleLabel.backgroundColor = Color.clear
        self.subtitleLabel.textColor = Color.lightGray
        self.titleTextView.backgroundColor = Color.midNightBlack
        self.titleTextView.textColor = Color.white
        self.titleTextView.layer.cornerRadius = 8
        self.titleTextView.clipsToBounds = true
        self.titleTextView.delegate = self
        self.titleTextView.tintColor = Color.mandarinOrange
        self.titleTextView.text = self.selectedItem == nil ? "" : selectedItem!.title
        self.saveButton.setTitle("Save", for: UIControlState.normal)
        self.saveButton.layer.cornerRadius = 8
        self.saveButton.backgroundColor = Color.seaweedGreen
        self.saveButton.setTitleColor(Color.inkBlack, for: UIControlState.disabled)
        self.saveButton.setTitleColor(Color.white, for: UIControlState.normal)
        self.saveButton.isEnabled = false
        if self.selectedItem == nil {
            self.subtitleLabel.isHidden = true
        } else {
            self.subtitleLabel.text = "Hash. " + selectedItem!.id
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.titleTextView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.titleTextView.resignFirstResponder()
    }

}

extension ItemEditorViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.saveButton.isEnabled = textView.text.count > 2 ? true : false
    }
    
}
