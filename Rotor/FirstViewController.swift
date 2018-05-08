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


extension Array
{
    public func permutations(of group:Int? = nil) -> [[Element]]
    {
        let group       = group ?? count
        var result      : [[Element]] = []
        var permutation : [Element]   = []
        
        func permute(from baseIndex:Int)
        {
            if baseIndex == permutation.count - 1
            {
                result.append(permutation)
                return
            }
            
            permute(from:baseIndex+1)
            
            for index in baseIndex+1..<permutation.count
            {
                permutation.swapAt(baseIndex, index)
                permute(from:baseIndex+1)
            }
            let baseElement = permutation[baseIndex]
            permutation.remove(at:baseIndex)
            permutation.append(baseElement)
        }
        
        var comboIndexes = (0..<group).map{$0}
        
        let fullCombo   = group - 1
        let indexLimit  = count - fullCombo
        
        var carry = fullCombo
        
        while carry >= 0
        {
            if carry == fullCombo
            {
                permutation = comboIndexes.map{self[$0]}
                permute(from:0)
            }
            
            comboIndexes[carry] += 1
            
            if comboIndexes[carry] == carry + indexLimit
            { carry -= 1 ; continue }
            
            while carry < fullCombo
            {
                carry += 1
                comboIndexes[carry] = comboIndexes[carry-1] + 1
            }
        }
        
        return result
    }
}

class FirstViewController: UIViewController {
    
    @IBOutlet weak var control: UISegmentedControl!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var originalText: UITextField!
    @IBOutlet weak var label: UITextView!
    
    var types = ["Pattern", "Anagram", "Build"];
    let alph = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    var textFields   = [UITextField]()
    var minusButtons = [UIButton]()
    var controls     = [UISegmentedControl]()
    var dictionaries = [String: Set<String>]()
    var cached       = [String: [String]]()
    var c_hooks      = [Side: [String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loading")
        
        field_set(originalText)
        
        let filePath = Bundle.main.resourcePath!
        for char1 in alph {
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
        field.addTarget(self, action: #selector(FirstViewController.typed(_:)), for: UIControlEvents.editingChanged)
        self.view.addSubview(field)
        textFields.append(field)
    }
    
    // MARK: Logic
    func update() {
        do {
            var mode = types[control.selectedSegmentIndex], text = originalText!.text!
            var cache_text = mode[mode.startIndex] + text
            var cache_text = String(mode[mode.startIndex]).lowercased() + text
            var words = try search(mode: mode, text: text, cache_text: cache_text)
            for (c, t) in zip(controls, textFields[1..<textFields.count]) {
                mode = types[c.selectedSegmentIndex]
                text = t.text!
                cache_text += mode[mode.startIndex] + text
                words = try search(mode: mode, text: text, cache_text: cache_text, dict: words, new: true)
            }

            label.text = "\(words.count) result" + (words.count == 1 ? "" : "s") + " found.\n" + 
                         words.map {
                            if c_hooks[Side.Front]![$0] == nil {
                                c_hooks[Side.Front]![$0] = String(hooks(word: $0, side: Side.Front))
                                c_hooks[Side.Back]![$0] = String(hooks(word: $0, side: Side.Back))
                            }
                            return c_hooks[Side.Front]![$0]! + " \($0) " + c_hooks[Side.Back]![$0]!
                         }.joined(separator: "\n")
        } catch (SearchError.IllegalCharacter) {
            label.text = "Illegal Character in Identifier"
        } catch {
            label.text = "Unknown processing error: \(error)"
        }
        

    }
    
    func search(mode: String, text: String, cache_text: String, dict: [String] = [String](), new: Bool = false) throws -> [String] {
        print(cache_text)
        
        if (mode != self.types[0] && !containsOnlyLetters(input: text)) { throw SearchError.IllegalCharacter }
        if (text.count < 2) { return [String]() }
        if (cached[cache_text] != nil) { return cached[cache_text]! }
        
        var ret = Set<String>()
        if mode == self.types[0] {
            let pattern = "^" + text.uppercased().replacingOccurrences(of: "@", with: ".*").replacingOccurrences(of: "\\V", with: "[AEIOUaeiou]").replacingOccurrences(of: "\\C", with: "[^AEIOUaeiou]") + "$"

            func re_search(dict: Set<String>) {
                ret = ret.union(dict.filter { $0.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil })
            }
            
            if !new && dict.count == 0 {
                for dict in self.dictionaries.values {
                    re_search(dict: dict)
                }
            } else {
                re_search(dict: Set<String>(dict))
            }
        } else {
            if !containsOnlyLetters(input: text) {
                throw SearchError.IllegalCharacter
            }
            
            for word in mode == self.types[1] ?
                permute(str: text, min: text.count) :
                permute(str: text, min: 2) {
                ret = ret.union(blanks(word).filter { check(word: $0, dict: dict) })
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
    
    func get_prefix(word: String) -> String {
        return String(word[..<word.index(word.startIndex, offsetBy: 2)])
    }
    
    func check(word: String, dict: [String] = [String]()) -> Bool {
        if (dict.count == 0) {
            let pref = dictionaries[get_prefix(word: word)]
            return pref != nil && pref!.contains(word)
        }
        return dict.contains(word)
    }
    
    /*
    func permute(str: String, min: Int) -> Set<String> {
        print(str, min)
        func permute(fromList: [String], toList: [String], set: inout Set<String>) {
            print(fromList, toList, set)
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
    */
    
    /*
    func permute(str: String) -> Set<String> {
        var scratch = Array(str)
        var result = Set<String>()
        
        func heap(_ n: Int) {
            print(scratch, n, result)
            if n == 1 {
                result.insert(String(scratch))
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
    */
    
    func permute(str: String, min: Int) -> Set<String> {
        print(str, min)
        func _permute(prefix: String, input: String) -> Set<String> {
            print(prefix, input)
            let prefixCharacters = Array(prefix)
            var inputCharacters = Array(input)
            var result = Set<String>()
            let n = inputCharacters.count
            
            if n == min {
                result.insert(prefix)
            } else {
                for i in min..<n {
                    let prefixAndCharacterAtIndex = String(prefixCharacters) + String(inputCharacters[i])
                    let subStringBeforeIndex = String(inputCharacters[0..<i])
                    let subStringAfterIndex =  String(inputCharacters [i+1..<n])
                    result = result.union(_permute(prefix: prefixAndCharacterAtIndex, input: subStringBeforeIndex + subStringAfterIndex))
                }
            }
            
            return result
        }
        
        return _permute(prefix: "", input: str)
    }
    
    /*
    func permute(_ str: String) -> Set<String> {
        func _permute(_ str: String, prefix: String, set: inout Set<String>) {
            if str.count == 0 {
                set.insert(prefix)
            }
            
            for i in str.indices {
                if str[i] != "." {
                    let left    = str[...i]
                    let right   = str[i...]
                    
                    let rem = left + right
                    _permute(String(rem), prefix: prefix + String(str[i]), set: &set)
                }
            }
        }
        
        var set = Set<String>()
        
        _permute(str, prefix: "", set: &set)
        
        return set
    }
    */
    
    /*
    func permute(str: String, range: CountableRange<Int>) -> Set<String> {
        var set = Set<String>()
        
        func _permute(_ n: Int, _ a: inout Array<Character>) {
            if n == 1 {set.insert(String(a)); return}
            for i in 0..<n-1 {
                _permute(n-1,&a)
                a.swapAt(n-1, (n%2 == 1) ? 0 : i)
            }
            _permute(n-1,&a)
        }
        
        var arr = Array(str)
        for i in range {
            _permute(i, &arr)
        }
        
        return set
    }
    */
    
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
    
    enum SearchError: Error {
        case IllegalCharacter
    }
    
    enum Side {
        case Front
        case Back
    }
    
    enum Mode {
        case Pattern
        case Anagram
        case Build
    }
}
