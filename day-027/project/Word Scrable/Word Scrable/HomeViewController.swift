//
//  ViewController.swift
//  Word Scrable
//
//  Created by Brian Sipple on 1/17/19.
//  Copyright © 2019 Brian Sipple. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {
    var allWords: [String] = []
    var usedWords: [String] = []
    
    var currentSubject = "" {
        didSet {
            title = "Anagrams of \"\(currentSubject)\""
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadWords()
        startGame()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        
        cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }
    
    
    func loadWords() {
        if let pathToStartWords = Bundle.main.path(forResource: "starting-words", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: pathToStartWords) {
                allWords = startWords.components(separatedBy: "\n")
            } else {
                loadDefaultWords()
            }
        } else {
            loadDefaultWords()
        }
    }
    
    
    func startGame() {
        guard let subject = allWords.randomElement() else {
            fatalError("Failed to load words for game")
        }
        
        currentSubject = subject
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    
    /**
        Shows a UIAlertController with space for the user to enter an answer.
     
        When the user clicks Submit to that alert controller,
        the answer is checked to make sure it's valid.
     */
    @IBAction func promptForAnswer() {
        let alertController = UIAlertController(
            title: "Enter an anagram for \(currentSubject)",
            message: nil,
            preferredStyle: .alert
        )
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] _ in
            guard let answer = alertController?.textFields?[0].text else {
                return
            }
         
            self?.handleSubmit(answer)
        }
        
        alertController.addTextField()
        alertController.addAction(submitAction)
        
        present(alertController, animated: true)
    }
    
    
    @IBAction func restartTapped(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Are you sure?",
            message: "Restarting the game will remove your answers and generate a new subject.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
            self?.startGame()
        })
        
        present(alertController, animated: true)
    }
    
    /*
     Given a subject word, we check that an answer:
         - Hasn't already been used by the player
         - Can be made from the letters of the subject
         - Is a valid English word (i.e., not gibberish)
     */
    func handleSubmit(_ input: String) -> Void {
        let answer = input.lowercased()
        print("Handling answer of \"\(answer)\"")
        
        if answer.isEmpty {
            return showSubmissionError(title: "Oops", message: "Your answer can't be empty.")
        }
        
        if answer.count == 1 {
            return showSubmissionError(title: "We'll need a bit more than that.", message: "Your answer must be at least 2 letters.")
        }

        if answer == currentSubject {
            return showSubmissionError(title: "Mix it up!", message: "Your answer shouldn't match the original word")
        }

        if !isOriginal(word: answer) {
            return showSubmissionError(
                title: "Be original!",
                message: "You've already used \"\(answer)\" as an anagram for \"\(currentSubject)\""
            )
        }

        if !isValidEnglish(word: answer) {
            return showSubmissionError(title: "Unknown word", message: "\"\(answer)\" wasn't recognized as a valid English word")
        }
        
        if !isValidAnagram(subject: currentSubject, answer: answer) {
            return showSubmissionError(title: "Try again!", message: "\"\(answer)\" is not a valid anagram for \"\(currentSubject)\"")
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        usedWords.insert(answer, at: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    
    func isValidAnagram(subject: String, answer: String) -> Bool {
        guard answer.count <= subject.count else { return false }
        
        let sortedSubjectLetters = String(subject.sorted())
        var sortedAnswerLetters = String(answer.sorted())
        
        while !sortedAnswerLetters.isEmpty {
            let charToMatch = sortedAnswerLetters.first!
            
            if !sortedSubjectLetters.contains(charToMatch) {
                return false
            }
            
            let numCharsToDrop = sortedAnswerLetters.lastIndex(of: charToMatch)!.encodedOffset + 1
            
            sortedAnswerLetters = String(sortedAnswerLetters.dropFirst(numCharsToDrop))
        }
        return true
    }
    
    
    func isValidEnglish(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(
            in: word,
            range: range,
            startingAt: 0,
            wrap: false,
            language: "en"
        )
        
        return misspelledRange.location == NSNotFound
    }
    
    
    func showSubmissionError(title: String, message: String) -> Void {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    
    func loadDefaultWords() {
        allWords = ["silkworm"]
    }
}

