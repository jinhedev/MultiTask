//
//  SketchEditorViewController.swift
//  MultiTask
//
//  Created by rightmeow on 12/21/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class SketchEditorViewController: BaseViewController {

    // MARK: - API

    var sketch: Sketch?
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false

    lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "FloppyDisk"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleSave(_:)))
        button.isEnabled = false
        return button
    }()

    lazy var clearButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "SketchPad"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleClear(_:)))
        return button
    }()

    lazy var shareButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Share"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleShare(_:)))
        return button
    }()

    lazy var redButton: UIBarButtonItem? = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        button.backgroundColor = Color.roseScarlet
        button.layer.cornerRadius = 11
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }()

    lazy var whiteButton: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        button.backgroundColor = Color.candyWhite
        button.layer.cornerRadius = 11
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }()

    lazy var blueButton: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        button.backgroundColor = Color.miamiBlue
        button.layer.cornerRadius = 11
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }()

    static let storyboard_id = String(describing: SketchEditorViewController.self)

    @IBOutlet weak var materialToolBar: UIToolbar!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!

    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        // 2
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        // 3
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(Color.white.cgColor)
        context?.setBlendMode(CGBlendMode.normal)
        // 4
        context?.strokePath()
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: view)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.saveButton.isEnabled == false {
            self.saveButton.isEnabled = true
        }
        if !swiped {
            // this will draw a single dot/point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        // merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndPDFContext()
        tempImageView.image = nil
    }

    // MARK: - UIToolBar

    private func setupMaterialToolBar() {
        self.materialToolBar.tintColor = Color.mandarinOrange
        self.materialToolBar.barTintColor = Color.midNightBlack
        self.materialToolBar.barStyle = .black
        self.materialToolBar.isTranslucent = false
    }

    private func setupDividerView() {
        self.dividerView.backgroundColor = Color.darkGray
    }

    // MARK: - UINavigationBar

    private func setupUINavigationBar() {
        navigationItem.rightBarButtonItems = [saveButton, shareButton]
    }

    @objc func handleSave(_ sender: UIBarButtonItem) {
        print(123)
    }

    @objc func handleClear(_ sender: UIBarButtonItem) {
        self.mainImageView.image = nil
    }

    @objc func handleShare(_ sender: UIBarButtonItem) {
        UIGraphicsBeginImageContext(self.mainImageView.bounds.size)
        self.mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = image {
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUINavigationBar()
        self.setupDividerView()
        self.setupMaterialToolBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

}
