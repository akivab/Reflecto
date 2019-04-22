//
//  ViewController.swift
//  Reflecto
//
//  Created by Akiva Bamberger on 4/21/19.
//  Copyright © 2019 Akiva Bamberger. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    var titleLabel: UILabel!
    var changeFont: UIButton!
    var changeBackground: UIButton!
    var editText: UITextView!
    var backgroundView: UIImageView!
    var captureButton: UIButton!
    var nameIndex: Int = 0
    var bgIndex: Int = 0
    var avc: UIActivityViewController!
    var done: Bool = false
    var keyboardHeight: CGFloat = 0
    let names: [String] = [
        "Zapfino",
        "Trebuchet MS",
        "Chalkduster",
        "COPPERPLATE",
        "American Typewriter"
    ]
    let startingText = "Type here!"
    var mainView: UIView!

    func nextName() -> String {
        nameIndex = (nameIndex + 1) % names.count
        return names[nameIndex]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.text = "Reflecto"
        titleLabel.font = UIFont(name: "Zapfino", size: 18)
        self.view.addSubview(titleLabel)

        titleLabel.sizeToFit()
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.centerX.equalTo(self.view)
            make.width.equalTo(titleLabel.frame.width)
            make.height.equalTo(titleLabel.frame.height)
        }
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressLogo)))
        changeFont = UIButton()
        changeFont.setTitle("Aa", for: .normal)
        changeFont.addTarget(self, action: #selector(handleFontChange), for: .touchUpInside)
        changeFont.layer.cornerRadius = 4
        changeFont.layer.borderColor = UIColor.white.cgColor
        changeFont.layer.borderWidth = 2
        changeBackground = UIButton(type: .custom)
        changeBackground.backgroundColor = UIColor.white
        changeBackground.addTarget(self, action: #selector(handleBackgroundChange), for: .touchUpInside)

        let imagePath =  Bundle.main.path(forResource: "landscape", ofType: "png")!
        let image = UIImage(contentsOfFile: imagePath)!
        changeBackground.setImage(image, for: .normal)
        changeBackground.imageView?.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        changeBackground.imageView?.contentMode = .scaleAspectFill
        captureButton = UIButton(type: .system)
        captureButton.setTitle("Send", for: .normal)
        captureButton.titleLabel?.textColor = .white
        captureButton.titleLabel?.font = UIFont(name: "Trebubuchet MS", size: 24)
        captureButton.addTarget(self, action: #selector(sendNote), for: .touchUpInside)

        self.view.addSubview(captureButton)
        self.view.addSubview(changeFont)
        self.view.addSubview(changeBackground)

        changeFont.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.width.height.equalTo(50)
            make.left.equalTo(self.view).offset(20)
        }
        changeBackground.layer.borderWidth = 2
        changeBackground.layer.backgroundColor = UIColor.white.cgColor
        changeBackground.layer.cornerRadius = 4
        changeBackground.clipsToBounds = true
        changeBackground.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.width.height.equalTo(50)
            make.right.equalTo(self.view).inset(20)
        }
        
        captureButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.width.equalTo(self.view)
            make.height.equalTo(48)
        }
        
        backgroundView = UIImageView()
        backgroundView.backgroundColor = UIColor.white
        editText = UITextView()
        editText.text = startingText
        editText.textColor = UIColor.lightGray
        editText.delegate = self
        editText.autocapitalizationType = .sentences
        mainView = UIView()
        mainView.addSubview(backgroundView)
        mainView.addSubview(editText)
        self.view.addSubview(mainView)
        editText.snp.makeConstraints { make in
            make.edges.equalTo(mainView)
        }
        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(mainView)
        }
        editText.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)

        mainView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalTo(captureButton.snp.top)
            make.right.left.equalTo(self.view)
        }
        
        setNextFont()
        setNextBackground()
    }
    
    private func image(with view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    func setNextFont() {
        let nextFont = UIFont(name: nextName(), size: 24)
        changeFont.titleLabel?.font = nextFont
        editText.font = nextFont
    }
    
    func setNextBackground() {
        editText.backgroundColor = UIColor(white: 1, alpha: 0.2)
        backgroundView.alpha = 0.2
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: "bg\(bgIndex)", ofType: "jpg")!)!
        bgIndex = (bgIndex + 1) % 4
    }
    
    @objc func handleBackgroundChange() {
        setNextBackground()
    }
    @objc func handleFontChange() {
        setNextFont()
    }
    @objc func didPressLogo() {
        editText.resignFirstResponder()
    }
    @objc func sendNote() {
        print("Sending note")
        if done {
            editText.resignFirstResponder()
            moveToSend()
            return
        }
        guard let url = saveImage(image: self.image(with: mainView)!) else {
            return
        }
        let objectsToShare = [url]
        
        avc = UIActivityViewController(activityItems: objectsToShare as [Any], applicationActivities: [])
        
        self.present(avc, animated: true, completion: nil)
    }
    func saveImage(image: UIImage) -> URL? {
        guard let data = image.pngData() else {
            return nil
        }
        do {
            let temp = URL(fileURLWithPath: NSTemporaryDirectory().appending(UUID().uuidString + ".png"))
            try data.write(to: temp)
            return temp
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    private func moveToDone(_ keyboardSize: CGRect) {
        keyboardHeight = keyboardSize.height > keyboardHeight ? keyboardSize.height : keyboardHeight
        print("keyboardSize: \(keyboardHeight)")
        if done {
            print("Not moving to done")
            return
        }
        print("Moving to done")
        done = !done
        self.captureButton.snp.remakeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(keyboardHeight)
            make.width.equalTo(self.view)
            make.height.equalTo(24)
        }
        self.captureButton.setTitle("Done", for: .normal)
    }
    private func moveToSend() {
        if !done {
            print("Not moving to send")
            return
        }
        print("Moving to send")
        done = !done
        self.captureButton.snp.remakeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.width.equalTo(self.view)
            make.height.equalTo(48)
        }
        self.captureButton.setTitle("Send", for: .normal)
    }
        
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.moveToDone(keyboardSize)
        }
        
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = startingText
            textView.textColor = UIColor.lightGray
        }
    }
}
