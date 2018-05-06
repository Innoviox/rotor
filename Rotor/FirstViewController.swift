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
    let alph = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    var textFields = [UITextField]();
    var minusButtons = [UIButton]();
    var controls = [UISegmentedControl]();
    var dictionaries = [String: Set<String>]()
    var cached = [String: [String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loading")
        
        field_set(originalText)
        originalText.addTarget(self, action: #selector(FirstViewController.typed(_:)), for: UIControlEvents.editingChanged)
        
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
        
        label.text = ""
        label.font = UIFont(name: "Courier New", size: UIFont.systemFontSize)
        
        print("Loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    @IBAction func typed(_ sender: Any) {
        update()
    }
    
    @IBAction func change(_ sender: Any) {
        update()
    }
    
    @IBAction func add(_ sender: Any) {
        if (self.textFields.count < 5) {
            var frame = self.originalText.frame
            var h = frame.size.height
            
            let control = UISegmentedControl(items: ["P", "A", "B"])
            control.frame = CGRect(x: frame.origin.x, y: CGFloat(frame.origin.y) + (5 + h) * CGFloat(self.textFields.count), width: 50, height: h)
            control.selectedSegmentIndex = 0
            control.addTarget(self, action: #selector(FirstViewController.change(_:)), for:.valueChanged)
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
            
            let h = self.addButton.frame.size.height
            let frame = self.label.frame
            self.label.frame = CGRect(x: frame.origin.x, y: frame.origin.y - h - 5, width: frame.size.width, height: frame.size.height + h + 5)
            
            self.update()
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
        field.autocapitalizationType = .allCharacters
        field.delegate = self as? UITextFieldDelegate
        self.view.addSubview(field)
        textFields.append(field)
    }
    
    // MARK: Logic
    func update() {
        do {
            var mode = types[control.selectedSegmentIndex], text = originalText!.text!
            var cache_text = mode + text
            var words = try search(mode: mode, text: text, cache_text: cache_text)
            for (c, t) in zip(controls, textFields[1..<textFields.count]) {
                mode = types[c.selectedSegmentIndex]
                text = t.text!
                cache_text += mode + text
                words = try search(mode: mode, text: text, cache_text: cache_text, dict: words)
            }
            label.text = words.joined(separator: "\n")
        } catch (SearchError.IllegalCharacter) {
            label.text = "Illegal Character in Identifier"
        } catch {
            label.text = "Unknown processing error: \(error)"
        }
    }
    
    func search(mode: String, text: String, cache_text: String, dict: [String] = [String]()) throws -> [String] {
        print(cache_text)
        if (text.count < 2) { return [String]() }
        if (cached[cache_text] != nil) { return cached[cache_text]! }
        
        var ret = Set<String>()
        if mode == self.types[0] {
            let pattern = "^" + text.uppercased() + "$"
            func re_search(dict: Set<String>) {
                for word in dict {
                    if word.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                        ret.insert(word)
                    }
                }
            }
            
            if dict.count == 0 {
                for set in self.dictionaries.values {
                    re_search(dict: set)
                }
            } else {
                re_search(dict: Set<String>(dict))
            }
        } else {
            if !containsOnlyLetters(input: text) {
                throw SearchError.IllegalCharacter
            }
            let perms: Set<String>
            if mode == self.types[1] {
                perms = Set<String>(permute(items: text).map { String($0) })
            } else {
                perms = combinations(list: text.map { String($0) })
            }
            for word in perms {
                for bWord in blanks(word) {
                    if check(word: bWord, dict: dict) {
                        ret.insert(blankPrint(word: word, bWord: bWord))
                    }
                }
            }
        }
        cached[cache_text] = Array(ret).sorted {
                                if ($0.count == $1.count) { return $0 < $1 }
                                return $0.count > $1.count
                             }
        return cached[cache_text]!
    }
    
    func blanks(_ word: String) -> [String] {
        if word.contains(".") {
            var ret = [String]()
            let idx = word.index(of: ".")
            for char in self.alph {
                ret.append(contentsOf: self.blanks(word.replacingCharacters(in: idx!...idx!, with: String(char))))
            }
            return ret
        }
        return [word]
    }
    
    func check(word: String, dict: [String] = [String]()) -> Bool {
        if (dict.count == 0) {
            let pref = dictionaries[String(word[..<word.index(word.startIndex, offsetBy: 2)])]
            return pref != nil && pref!.contains(word)
        }
        return dict.contains(word)
    }
    
    func combinations(list: [String]) -> Set<String> {
        func permute(fromList: [String], toList: [String], set: inout Set<String>) {
            if toList.count >= 2 {
                set.insert(toList.joined(separator: ""))
            }
            if !fromList.isEmpty {
                for (index, item) in fromList.enumerated() {
                    var newFrom = fromList
                    newFrom.remove(at: index)
                    permute(fromList: newFrom, toList: toList + [item], set: &set)
                }
            }
        }
        
        var set = Set<String>()
        permute(fromList: list, toList:[], set: &set)
        return set
    }
    
    func permute<C: Collection>(items: C) -> [[C.Iterator.Element]] {
        var scratch = Array(items)
        var result: [[C.Iterator.Element]] = []
        
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
        
        heap(scratch.count)
        
        return result
    }
    
    func containsOnlyLetters(input: String) -> Bool {
        for chr in input {
            if (chr != "." && !(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                return false
            }
        }
        return true
    }
    
    func blankPrint(word: String, bWord: String) -> String {
        var text = ""
        var cases = [Character: Bool]()
        for letter in bWord {
            cases[letter] = false
        }
        
        for letter in bWord {
            if bWord.components(separatedBy: String(letter)).count - 1 >
               word.components(separatedBy: String(letter)).count - 1 {
                if cases[letter]! {
                    text += String(letter).uppercased()
                } else {
                    text += String(letter).lowercased()
                    cases[letter] = true
                }
            } else {
                text += String(letter).uppercased()
            }
        }
        return text
    }
    
    /*
    def blankPrint(word, rack):
    text = ''
    cases = {letter: True for letter in rack}
    ncases = {letter: True for letter in word}
    for letter in word:
        if word.count(letter) > rack.count(letter):
            if cases.get(letter):
                text += letter.upper()
                cases[letter] = False
            elif ncases.get(letter) and letter not in cases.keys():
                text += letter.lower()
            else:
                text += letter.lower()
                cases[letter] = False
        else:
            text += letter.upper()
            cases[letter] = False
    
    return ''.join(hooks(word.upper(), 'f')), text, ''.join(hooks(word.upper(), 'b'))
 
     def hooks(word, side):
     hooks = []
     for letter in string.ascii_uppercase:
     for word2 in getSomeWords([word[:2], letter+word[0]][side == 'f'], len(word)+1):
     if [word + letter, letter + word][side == 'f'] == word2:
     yield letter
    */
    
    enum SearchError: Error {
        case IllegalCharacter
    }
}

