//
//  Questions.swift
//  Trivia
//
//  Created by Katrinna Jones on 9/16/26.
//

import UIKit

struct QuestionsandAnswers {
    let question: String
    let questionType: String
    let questionSubType: String
    let answers: [String: Bool]
}

class Questions {
    // Part 2
    func createURLForTrivia(trivia: String) -> URL? {
        let urlString: String = "https://opentdb.com/api.php"
        var urlLink = URLComponents(string: urlString)
        
        let queryItem = URLQueryItem(name: "amount", value: "10")
        urlLink?.queryItems = [queryItem]
        
        return urlLink?.url
    }
    
    func connectWithTrivia(trivia: String, completion: @escaping ([Trivia]?) -> Void) {
        guard let url = createURLForTrivia(trivia: trivia) else {
            print("URL is nil")
            completion(nil) // Ensure completion is called if URL fails
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                print("Error fetching data")
                completion(nil) // Ensure completion is called if network fails
                return
            }
            guard let data = data else {
                completion(nil)
                return
            }
            
            if let triviaResult = self.convertDataTrivia(data: data) {
                // Fixed: Let the ViewController handle thread dispatching, or only call it once here.
                // We keep it off the background thread context safely.
                completion(triviaResult.trivia)
            } else {
                print("Failed to decode JSON data")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func convertDataTrivia(data: Data) -> TriviaResult? {
        let jsonDecoder = JSONDecoder()
        let result = try? jsonDecoder.decode(TriviaResult.self, from: data)
        return result
    }

    struct Trivia: Codable {
        enum Difficulties: String, Codable {
            case easy = "easy"
            case medium = "medium"
            case hard = "hard"
        }
        let type: String
        let difficulty: Difficulties
        let category: String
        let question: String
        let correctAnswer: String
        let wrongAnswers: [String]
        
        enum CodingKeys: String, CodingKey {
            case type = "type"
            case difficulty = "difficulty"
            case category = "category"
            case question = "question"
            case correctAnswer = "correct_answer"
            case wrongAnswers = "incorrect_answers"
        }
    }
    
    struct TriviaResult: Codable {
        let trivia: [Trivia]?
        
        enum CodingKeys: String, CodingKey {
            case trivia = "results"
        }
    }
}
