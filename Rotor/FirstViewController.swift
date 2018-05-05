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
    @IBOutlet weak var label: UITextView!
    
    var types = ["Pattern", "Anagram", "Build"];
    
    var textFields = [UITextField]();
    var minusButtons = [UIButton]();
    var controls = [UISegmentedControl]();
    var dictionaries = [String: Set<String>]()
    let alph = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        field_set(originalText)
        originalText.addTarget(self, action: #selector(FirstViewController.typed(_:)), for: UIControlEvents.editingChanged)
        print("Loading")
        
        let filePath = Bundle.main.resourcePath!
        for char1 in alph {
            for char2 in alph {
                let diphth = String(char1) + String(char2)
                dictionaries[diphth] = Set<String>();
                let reader = StreamReader(path: filePath + "/" + diphth + ".txt")
                while let line = reader?.nextLine() {
                    dictionaries[diphth]?.insert(line)
                }
            }
        }
        
        print(dictionaries["GJ"]!)
        label.text = ""
        print("loaded")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func update() {
        let words = search(mode: types[control.selectedSegmentIndex], text: originalText!.text!)
        label.text = words.joined(separator: "\n")
    }
    
    @IBAction func typed(_ sender: Any) {
        for tf: UITextField in  self.textFields {
            // print(tf.text!)
            tf.text = tf.text?.uppercased()
        }
        update()
    }
    
    @IBAction func `switch`(_ sender: Any) {
        print(self.types[self.control.selectedSegmentIndex])
        update()
    }
    
    @IBAction func add(_ sender: Any) {
        if (self.textFields.count < 5) {
            var frame = self.originalText.frame
            var h = frame.size.height
            
            let control = UISegmentedControl(items: ["P", "A", "B"])
            control.frame = CGRect(x: frame.origin.x, y: CGFloat(frame.origin.y) + (5 + h) * CGFloat(self.textFields.count), width: 50, height: h)
            control.selectedSegmentIndex = 0
            self.view.addSubview(control)
            self.controls.append(control)
            
            let newField = UITextField(frame: CGRect(x: frame.origin.x + 50, y: CGFloat(frame.origin.y) + (5 + h) * CGFloat(self.textFields.count), width: frame.size.width - 50, height: h))
            field_set(newField)
            newField.addTarget(self, action: #selector(FirstViewController.typed(_:)), for: UIControlEvents.editingChanged)
        
            frame = self.addButton.frame
            h = frame.size.height
            let newButton = UIButton(frame: CGRect(x: frame.origin.x, y: CGFloat(frame.origin.y) + (5 + h) * (CGFloat(self.minusButtons.count) + 1), width: frame.size.width, height: h))
            newButton.setImage(UIImage(named: "minus"), for: .normal)
            newButton.addTarget(self, action: #selector(self.deleteLine(_:)), for: .touchUpInside)
            self.view.addSubview(newButton)
            self.minusButtons.append(newButton)
            
            frame = self.label.frame
            self.label.frame = CGRect(x: frame.origin.x, y: frame.origin.y + h + 5, width: frame.size.width, height: frame.size.height - h - 5)
        }
    }
    
    @objc func deleteLine(_ button: UIButton) {
        let idx = self.minusButtons.index(of: button)
        if (idx != nil) {
            let ti = idx!+1
            self.textFields[ti].removeFromSuperview()
            self.textFields.remove(at: ti)
            for i in ti..<self.textFields.count {
                let e = self.textFields[i]
                let f = e.frame
                let h = f.size.height
                e.frame = CGRect(x: f.origin.x, y: CGFloat(self.originalText.frame.origin.y) + (5 + h) * CGFloat(i), width: f.size.width, height: h)
            }
            
            self.minusButtons[idx!].removeFromSuperview()
            for i in idx!..<self.minusButtons.count {
                let e = self.minusButtons[i]
                let f = e.frame
                let h = f.size.height
                e.frame = CGRect(x: f.origin.x, y: CGFloat(self.originalText.frame.origin.y) + (5 + h) * CGFloat(i), width: f.size.width, height: h)
            }
            self.minusButtons.remove(at: idx!)
            
            self.controls[idx!].removeFromSuperview()
            for i in idx!..<self.controls.count {
                let e = self.controls[i]
                let f = e.frame
                let h = f.size.height
                e.frame = CGRect(x: f.origin.x, y: CGFloat(self.originalText.frame.origin.y) + (5 + h) * CGFloat(i), width: 50, height: h)
            }
            self.controls.remove(at: idx!)
        }
    }
    
    func field_set(_ field: UITextField) {
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
    
    func search(mode: String, text: String) -> [String] {
        if (text.count < 2) { return [String]() }
        var ret = [String]()
        if mode == self.types[0] {
            let pattern = "^" + text.uppercased() + "$"
            for (_, set) in self.dictionaries {
                for word in set {
                    if word.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                        ret.append(word)
                    }
                }
            }
        } else if mode == self.types[1] {
            let perms = permute(items: text)
            for word in perms.map({ String($0) }) {
                for bWord in blanks(word) {
                    if check(word: bWord) {
                        ret.append(bWord)
                    }
                }
            }
        }
        
        return ret.sorted()
    }
    
    func check(word: String) -> Bool {
        let index = word.index(word.startIndex, offsetBy: 2)
        return dictionaries[String(word[..<index])]!.contains(word)
    }
    
    // Takes any collection of T and returns an array of permutations
    func permute<C: Collection>(items: C) -> [[C.Iterator.Element]] {
        var scratch = Array(items) // This is a scratch space for Heap's algorithm
        var result: [[C.Iterator.Element]] = [] // This will accumulate our result
        
        // Heap's algorithm
        func heap(_ n: Int) {
            if n == 1 {
                result.append(scratch)
                return
            }
            
            for i in 0..<n-1 {
                heap(n-1)
                let j = (n%2 == 1) ? 0 : i
                scratch.swapAt(j, n-1)
            }
            heap(n-1)
        }
        
        // Let's get started
        heap(scratch.count)
        
        // And return the result we built up
        return result
    }
    
    func blanks(_ word: String) -> [String] {
        print("recieving \(word)")
        var ret = [String]()
        if word.count > 6 {return ret}
        if word.contains(".") {
            let idx = word.index(of: ".")
            for char in self.alph {
                // if (int_idx == 0) {
                //     ret.append(contentsOf: self.blanks(String(char) + word.suffix(1)))
                // } else if (int_idx == word.count - 1) {
                //     ret.append(contentsOf: self.blanks(word.prefix(word.count - 1) + String(char)))
                // } else {
                    ret.append(contentsOf: self.blanks(word.replacingCharacters(in: idx!...idx!, with: String(char))))
                // }
            }
        } else {
            ret.append(word)
        }
        return ret
    }
}

