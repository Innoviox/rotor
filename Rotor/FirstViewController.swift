//
//  FirstViewController.swift
//  Rotor
//
//  Created by Simon Chervenak on 4/2/18.
//  Copyright © 2018 Innoviox. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var control: UISegmentedControl!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var originalText: UITextField!
    
    var types = [String](arrayLiteral: "Pattern", "Anagram", "Build");
    var textFields = [UITextField]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // textFields.append(originalText);
        update(originalText)
        originalText.addTarget(self, action: #selector(FirstViewController.typed(_:)), for: UIControlEvents.editingChanged)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func typed(_ sender: Any) {
        for tf: UITextField in  self.textFields {
            print(tf.text!)
        }
    }
    
    @IBAction func `switch`(_ sender: Any) {
        print(self.types[self.control.selectedSegmentIndex])
    }
    
    @IBAction func add(_ sender: Any) {
        let frame = self.originalText.frame
        let h = frame.size.height
        let newField =  UITextField(frame: CGRect(x: frame.origin.x, y: CGFloat(frame.origin.y) + (5 + h) * CGFloat(self.textFields.count), width: frame.size.width, height: h))
        update(newField)
        newField.addTarget(self, action: #selector(FirstViewController.typed(_:)), for: UIControlEvents.editingChanged)
    }
    
    func update(_ field: UITextField) {
        field.placeholder = "Enter text here"
        field.font = UIFont.systemFont(ofSize: 15)
        field.borderStyle = UITextBorderStyle.roundedRect
        field.autocorrectionType = UITextAutocorrectionType.no
        field.keyboardType = UIKeyboardType.default
        field.returnKeyType = UIReturnKeyType.done
        field.clearButtonMode = UITextFieldViewMode.whileEditing;
        field.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        field.delegate = self as? UITextFieldDelegate
        self.view.addSubview(field)
        textFields.append(field)
    }
}

