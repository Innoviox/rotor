//
//  FirstViewController.swift
//  Rotor
//
//  Created by Simon Chervenak on 4/2/18.
//  Copyright © 2018 Innoviox. All rights reserved.
//

import UIKit

func + (left:Character, right:Character) -> String {
    return "\(left)\(right)"
}

func + (left:String, right:Character) -> String {
    return "\(left)\(right)"
}

func + (left:Character, right:String) -> String {
    return "\(left)\(right)"
}

class FirstViewController: UIViewController {
    
    @IBOutlet weak var control: UISegmentedControl!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var originalText: UITextField!
    
    @IBOutlet weak var words: UITextView!
    
    var types = ["Pattern", "Anagram", "Build"];
    let alph = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    let largeFont = UIFont(name: "Arial", size: UIFont.systemFontSize)
    let smallFont = UIFont(name: "Arial", size: 12)
    
    var textFields   = [UITextField]()
    var minusButtons = [UIButton]()
    var controls     = [UISegmentedControl]()
    var dictionaries = [String: Set<String>]()
    var cached       = [String: [String]]()
    var c_hooks      = [Side: [String: String]]()
    
    // var prefixes = ["[A": "AEIOU", "[^": "BCDFGHJKLMNPQRSTVWXYZ", "." : "."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loading")
        
        field_set(originalText)
        
        let filePath = Bundle.main.resourcePath!
        for char1 in alph {
            // prefixes[String(char1)] = String(char1)
            for char2 in alph {
                let diphth = char1 + char2
                dictionaries[diphth] = Set<String>();
                let reader = StreamReader(path: filePath + "/" + diphth + ".txt")
                while let line = reader?.nextLine() {
                    dictionaries[diphth]?.insert(line)
                }
            }
        }
        
        c_hooks[Side.Front] = [String: String]()
        c_hooks[Side.Back] = [String: String]()
        
        words.text = ""
        
        print("Loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    @IBAction func typed(_ sender: Any) {
        for tf in textFields { tf.text = tf.text!.uppercased() }
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
            
            for tv in [words] {
                frame = (tv?.frame)!
                tv?.frame = CGRect(x: frame.origin.x, y: frame.origin.y + h + 5, width: frame.size.width, height: frame.size.height - h - 5)
            }
            
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
            for tv in [words] {
                let frame = (tv?.frame)!
                tv?.frame = CGRect(x: frame.origin.x, y: frame.origin.y - h - 5, width: frame.size.width, height: frame.size.height + h + 5)
            }
            
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
        field.addTarget(self, action: #selector(FirstViewController.typed(_:)), for: UIControlEvents.editingChanged)
        self.view.addSubview(field)
        textFields.append(field)
    }
    
    // MARK: Logic
    func update() {
        do {
            var mode = String(types[control.selectedSegmentIndex]).lowercased(), text = originalText!.text!
            var cache_text = mode[mode.startIndex] + text
            var result = try search(mode: mode, text: text, cache_text: cache_text)
            for (c, t) in zip(controls, textFields[1..<textFields.count]) {
                mode = types[c.selectedSegmentIndex]
                text = t.text!
                cache_text += String(mode[mode.startIndex]).lowercased() + text
                result = try search(mode: mode, text: text, cache_text: cache_text, dict: result, new: true)
            }

            let fwb: [[String]] = result.map { (word) -> [String] in
                                    if c_hooks[Side.Front]![word] == nil {
                                        c_hooks[Side.Front]![word] = String(hooks(word: word, side: Side.Front))
                                        c_hooks[Side.Back]![word] = String(hooks(word: word, side: Side.Back))
                                    }
                                    return [c_hooks[Side.Front]![word]!, " \(word) ", c_hooks[Side.Back]![word]!]
                                 }
            words.text = fwb.map { $0.joined(separator: " ") }.joined(separator: "\n")
            /*
            // var ft = "\n", wt = "\(result.count) result" + (result.count == 1 ? "" : "s") + " found.\n", bt = "\n"
            // var attrText = NSMutableAttributedString()
            for l in fwb {
                print(l)
                // ft += l[0] + "\n"
                // wt += l[1] + "\n"
                // bt += l[2] + "\n"
                print("HI")
                let textString = "\(l[0]) \(l[1]) \(l[2])\n"
                // let attrText = NSMutableAttributedString(string: textString)
                // attrText += textString
                print("HI")
                //  Convert textString to NSString because attrText.addAttribute takes an NSRange.
                let fRange = (textString as NSString).range(of: l[0])
                let wRange = (textString as NSString).range(of: l[1])
                let bRange = (textString as NSString).range(of: l[2])
                print("HI")
                print(textString)
                print(fRange, wRange, bRange)
                if l[0] != "" {
                    attrText.addAttribute(kCTFontAttributeName as NSAttributedStringKey, value: smallFont!, range: fRange)
                }
                print("BY")
                attrText.addAttribute(kCTFontAttributeName as NSAttributedStringKey, value: largeFont!, range: wRange)
                print("BY2")
                if l[2] != "" {
                    attrText.addAttribute(kCTFontAttributeName as NSAttributedStringKey, value: smallFont!, range: bRange)
                }
                print("HI")
            }
            // words.text = wt
            words.attributedText = attrText
            */
            /*
            let htmlString = "<font color=\"red\">This is  </font> <font color=\"blue\"> some text!</font>"
            
            let encodedData = htmlString.data(using: String.Encoding.utf8)!
            let attributedOptions = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
            do {
                let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
                label.attributedText = attributedString
 
            } catch _ {
                print("Cannot create attributed String")
            }
            */
            //<center>
            /*
            var s = "<h5>\(result.count) result" + (result.count == 1 ? "" : "s") + " found.</h5><br>"
            for l in fwb {
                s += "<small>\(l[0])</small> \(l[1]) <small>\(l[2])</small><br>"
            }
            //s += "</center>"
            let encodedData = s.data(using: String.Encoding.utf8)!
            let attributedOptions = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
            do {
                let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
                words.attributedText = attributedString
                
            } catch _ {
                print("Cannot create attributed String")
            }
            */
        } catch (SearchError.IllegalCharacter) {
            words.text = "Illegal Character in Identifier"
        } catch {
            words.text = "Unknown processing error: \(error)"
        }
        

    }

    func search(mode: String, text: String, cache_text: String, dict: [String] = [String](), new: Bool = false) throws -> [String] {
        print(cache_text)
        
        if (mode != self.types[0] && !containsOnlyLetters(input: text)) { throw SearchError.IllegalCharacter }
        if (text.count < 2) { return [String]() }
        if (cached[cache_text] != nil) { return cached[cache_text]! }
        
        var ret = Set<String>()
        
        if mode == self.types[0].lowercased() {
            let pattern = text.uppercased().replacingOccurrences(of: "?", with: ".").replacingOccurrences(of: "@", with: ".*").replacingOccurrences(of: "\\V", with: "[AEIOUaeiou]").replacingOccurrences(of: "\\C", with: "[^AEIOUaeiou]")
            func re_search(dict: Set<String>) {
                // ret = ret.union(dict.filter { $0.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil })
                for word in dict {
                    if word.range(of: "^" + pattern + "$", options: .regularExpression) != nil {
                        ret.insert(word)
                    }
                }
            }
            
            if !new && dict.count == 0 {
                let prefix = get_prefix(word: pattern)
                if containsOnlyLetters(input: prefix) {
                    for bPref in blanks(prefix) {
                        re_search(dict: dictionaries[bPref]!)
                    }
                } else {
                    for dict in self.dictionaries.values {
                        re_search(dict: dict)
                    }
                }
            } else {
                re_search(dict: Set<String>(dict))
            }
        } else {
            if !containsOnlyLetters(input: text) {
                throw SearchError.IllegalCharacter
            }

            for word in mode == self.types[1].lowercased() ?
                combinations(str: text, min: text.count) :
                combinations(str: text, min: 2) {
                    ret = ret.union(blanks(word).filter { check(word: $0, dict: dict) }.map { blankPrint(word: word, bWord: $0) })
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
    
    func get_prefix(word: String, offset: Int = 2) -> String {
        return String(word[..<word.index(word.startIndex, offsetBy: offset)])
    }
    
    func check(word: String, dict: [String] = [String]()) -> Bool {
        if (dict.count == 0) {
            let pref = dictionaries[get_prefix(word: word)]
            return pref != nil && pref!.contains(word)
        }
        return dict.contains(word)
    }
    
    func combinations(str: String, min: Int) -> Set<String> {
        func permute(fromList: [String], toList: [String], set: inout Set<String>) {
            if toList.count >= min {
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
        permute(fromList: str.map { String($0) }, toList:[], set: &set)
        return set
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
    
    func hooks(word: String, side: Side) -> [Character] {
        var hooks = [Character]()
        
        for letter in alph {
            let d = dictionaries[((side == Side.Front) ? (letter + word[word.startIndex]) : get_prefix(word: word)).uppercased()]!
            if (d.contains(((side == Side.Front) ? (letter + word) : (word + letter)).uppercased())) {
                hooks.append(letter)
            }
        }
        
        return hooks
    }
    
    private func maxLength(arr: [String]) -> Int {
        return arr.map { $0.count }.max()!
    }
    
    private func pad(str: String, pad: Int) -> String {
        return " " + str.padding(toLength: pad, withPad: " ", startingAt: 0) + " "
    }
    
    enum SearchError: Error {
        case IllegalCharacter
    }
    
    enum Side {
        case Front
        case Back
    }
}
