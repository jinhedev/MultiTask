//
//  SketchEditorViewController.swift
//  MultiTask
//
//  Created by rightmeow on 12/21/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

protocol SketchEditorViewControllerDelegate: NSObjectProtocol {
    func sketchEditorViewController(_ viewController: SketchEditorViewController, didUpdateSketch sketch: Sketch)
}

class SketchEditorViewController: BaseViewController, PersistentContainerDelegate, SaveDataViewControllerDelegate, UIViewControllerTransitioningDelegate {

    // MARK: - API

    var sketch: Sketch?
    var realmManager: RealmManager?
    weak var delegate: SketchEditorViewControllerDelegate?
    var slideTransitionCoordinator: UIViewControllerSlideTransitionCoordinator?

    var lastPoint = CGPoint.zero
    var red: CGFloat = 200 / 255
    var green: CGFloat = 200 / 255
    var blue: CGFloat = 200 / 255
    var brushWidth: CGFloat = 10.0
    var swiped = false

    lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "FloppyDisk"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleSave(_:)))
        return button
    }()

    lazy var shareButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Share"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleShare(_:)))
        return button
    }()

    lazy var importButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Import"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleImport(_:)))
        return button
    }()

    static let storyboard_id = String(describing: SketchEditorViewController.self)

    @IBOutlet weak var toolboxView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!

    @IBOutlet weak var whiteButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var eraserButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!

    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        // 1
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.width, height: mainImageView.frame.height))
        // 2
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        // 3
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context?.setBlendMode(CGBlendMode.normal)
        // 4
        context?.strokePath()
        // 5
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: mainImageView)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: mainImageView)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // this will draw a single dot/point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        self.mainImageView.image = mainImageView.imageWithCurrentContext()
    }

    // MARK: - ToolboxView

    private func setupToolboxView() {
        self.toolboxView.backgroundColor = Color.inkBlack
        // whiteButton
        self.whiteButton.frame.size = CGSize(width: 22, height: 22)
        self.whiteButton.layer.cornerRadius = 11
        self.whiteButton.clipsToBounds = true
        self.whiteButton.tintColor = Color.offWhite
        // blueButton
        self.blueButton.frame.size = CGSize(width: 22, height: 22)
        self.blueButton.layer.cornerRadius = 11
        self.blueButton.clipsToBounds = true
        self.blueButton.tintColor = Color.miamiBlue
        // redButton
        self.redButton.frame.size = CGSize(width: 22, height: 22)
        self.redButton.layer.cornerRadius = 11
        self.redButton.clipsToBounds = true
        self.redButton.tintColor = Color.roseScarlet
        // eraserButton
        self.eraserButton.frame.size = CGSize(width: 22, height: 22)
        self.eraserButton.clipsToBounds = true
        // clearButton
        self.clearButton.frame.size = CGSize(width: 22, height: 22)
        self.clearButton.clipsToBounds = true
    }

    @IBAction func handleWhiteColor(_ sender: UIButton) {
        self.red = 200 / 255
        self.green = 200 / 255
        self.blue = 200 / 255
    }

    @IBAction func handleBlueColor(_ sender: UIButton) {
        self.red = 0 / 255
        self.green = 134 / 255
        self.blue = 249 / 255
    }

    @IBAction func handleRedColor(_ sender: UIButton) {
        self.red = 143 / 255
        self.green = 50 / 255
        self.blue = 55 / 255
    }

    @IBAction func handleEraser(_ sender: UIButton) {
        self.red = 15 / 255
        self.green = 15 / 255
        self.blue = 15 / 255
    }

    @IBAction func handleClear(_ sender: UIButton) {
        self.mainImageView.image = nil
    }

    // MARK: - UINavigationBar

    private func setupUINavigationBar() {
        navigationItem.rightBarButtonItems = [saveButton, shareButton]
    }

    @objc func handleSave(_ sender: UIBarButtonItem) {
        // transition to saveDataViewController
        if let saveDataViewController = self.storyboard?.instantiateViewController(withIdentifier: SaveDataViewController.storyboard_id) as? SaveDataViewController {
            saveDataViewController.transitioningDelegate = self
            saveDataViewController.delegate = self
            saveDataViewController.sketch = self.sketch
            self.present(saveDataViewController, animated: true, completion: nil)
        }
    }

    @objc func handleShare(_ sender: UIBarButtonItem) {
        UIGraphicsBeginImageContext(self.mainImageView.bounds.size)
        let image = self.mainImageView.imageWithCurrentContext()
        if let image = image {
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
    }

    @objc func handleImport(_ sender: UIBarButtonItem) {
        print(123)
    }

    // MARK: - PersistentContainerDelegate

    private func setupPersistentContainerDelegate() {
        self.realmManager = RealmManager()
        self.realmManager!.delegate = self
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }

    func persistentContainer(_ manager: RealmManager, didUpdateObject object: Object) {
        if let sketch = object as? Sketch {
            self.delegate?.sketchEditorViewController(self, didUpdateSketch: sketch)
        }
    }

    // MARK: - MainImageView

    private func setupMainImageView() {
        if let unwrappedSketch = self.sketch {
            self.mainImageView.image = UIImage(data: unwrappedSketch.imageData! as Data)
        } else {
            self.mainImageView.image = self.draw(withColor: Color.inkBlack)
        }
    }

    func draw(withColor: UIColor) -> UIImage? {
        // TODO: refactor this into an extension or something
        let rect = CGRect(x: 0, y: 0, width: self.mainImageView.frame.width, height: self.mainImageView.frame.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(withColor.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    // MARK: - SaveDataViewControllerDelegate

    func saveDataViewController(_ viewController: SaveDataViewController, didTapCancel button: UIButton) {
        viewController.dismiss(animated: true, completion: nil)
    }

    func saveDataViewController(_ viewController: SaveDataViewController, didTapSave button: UIButton, withTitle: String) {
        let imageData = UIImagePNGRepresentation(self.mainImageView.imageWithCurrentContext()!) as NSData?
        if self.sketch == nil {
            self.sketch = Sketch(title: withTitle)
            self.realmManager?.updateObject(object: self.sketch!, keyedValues: ["imageData" : imageData!])
        } else {
            self.realmManager?.updateObject(object: self.sketch!, keyedValues: ["imageData" : imageData!, "title" : withTitle])
        }
        viewController.dismiss(animated: true, completion: nil)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMainImageView()
        self.setupUINavigationBar()
        self.setupToolboxView()
        self.setupUIViewControllerTransitioningDelegate()
        self.setupPersistentContainerDelegate()
    }

    // MAKR: - UIViewControllerTransitioningDelegate

    private func setupUIViewControllerTransitioningDelegate() {
        self.slideTransitionCoordinator = UIViewControllerSlideTransitionCoordinator(transitioningDirection: UIViewControllerTransitioningDirection.top)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.slideTransitionCoordinator?.isPresenting = true
        return slideTransitionCoordinator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.slideTransitionCoordinator?.isPresenting = false
        return slideTransitionCoordinator
    }

}
