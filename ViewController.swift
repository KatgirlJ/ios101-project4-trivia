//
//  ViewController.swift
//  Trivia
//
//  Created by Katrinna Jones on 9/16/26.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var questionNumLabel: UILabel!
    @IBOutlet weak var typeWithSubLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet var answerButtons: [UIButton]!
    
    let api = Questions()
    var triviaArr: [Questions.Trivia] = []
    var questionIndex = 0
    var score = 0
    var choices: [String] = []
    var totalQuestions: Int = 0
    var needReset: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectingData()
        
    }
    
    // MARK: - Game UI Update
    func displayCurrentQuestion() {
        // Ensure array is populated and your index is inside the array bounds
        guard !triviaArr.isEmpty, questionIndex < triviaArr.count else { return }
        
        guard let numLabel = questionNumLabel,
              let types = typeWithSubLabel,
              let questions = questionLabel,
              let buttons = answerButtons else { return }
        
        let currentQuestion = triviaArr[questionIndex]
        
        choices = currentQuestion.wrongAnswers
        choices.append(currentQuestion.correctAnswer)
        choices.shuffle()
        
        //let strLabel: String = "Question \(questionIndex+1)/\(triviaArr)"

        let strLabel: String = "Question \(questionIndex + 1)/\(totalQuestions)"
        numLabel.text = strLabel

        //numLabel.text = "Question \(questionIndex + 1)/\(triviaArr.count)"
        //numLabel.text = "Question \(questionIndex + 1)/\(totalQuestions)"
        //numLabel.text = "Question \(questionIndex + 1) / 10"
        //numLabel.text = strLabel
        types.text = decodeHTMLString(currentQuestion.category)
        questions.text = decodeHTMLString(currentQuestion.question)
        
        
        for (index, button) in buttons.enumerated() {
            if index >= choices.count {
                button.isHidden = true
            } else {
                button.isHidden = false
                //button.setTitle(decodeHTMLString(choices[index]), for: .normal)
                button.setTitle(choices[index], for: .normal)
            }
        }
    }
        @IBAction func buttonPressed(_ sender: UIButton) {
            if(needReset == true){
                resetFunction()
                return
            }
        guard questionIndex < triviaArr.count else { return }
        
        let currentQuestion = triviaArr[questionIndex]
        
        guard let buttonIndex = answerButtons.firstIndex(of: sender),
              buttonIndex < choices.count else { return }
        
        let selectedAnswer = choices[buttonIndex]
        
        if selectedAnswer == currentQuestion.correctAnswer {
            score += 1
        }
        questionIndex += 1
        
        if questionIndex < triviaArr.count {
            displayCurrentQuestion()
        } else {
            showTotalScore()
        }
    }
    
    func showTotalScore() {
        questionLabel.text = "Congratulations! Your final score is \(score)/\(triviaArr.count)"
        typeWithSubLabel.text = ""
        questionNumLabel.text = "Game Over"
        //questionNumLabel.text = "\(questionIndex)/\(totalQuestions)"
        for (index, button) in answerButtons.enumerated() {
            button.isHidden = true
            if(index != 0){
                button.isHidden = true
            }
            else{
                button.isHidden = false
                button.setTitle("Play Again with New Questions", for: .normal)
            }
        }
        needReset = true
    }
    func resetFunction(){
        questionIndex = 0
        score = 0
        totalQuestions = 0
        self.triviaArr.removeAll()
        
        connectingData()
        displayCurrentQuestion()
        needReset = false
    }
    
    func decodeHTMLString(_ htmlString: String) -> String {
        guard let data = htmlString.data(using: .utf8),
              let attributedString = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
              ) else {
            return htmlString // Fallback to raw string if it fails
        }
        return attributedString.string
    }
    
    func connectingData(){
        api.connectWithTrivia(trivia: "") { [weak self] downloadedTrivia in
            guard let self = self else { return }
        
            DispatchQueue.main.async {
                if let downloadedTrivia = downloadedTrivia {
                    self.triviaArr = downloadedTrivia
                    self.totalQuestions = downloadedTrivia.count
                    self.displayCurrentQuestion()
                }
            }
        }
        for (_, button) in answerButtons.enumerated(){
            button.isHidden = true
        }
    }
}
