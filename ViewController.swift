//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
    
    @IBOutlet weak var optionLabel: UILabel!
    let sentimentClassifier = TweetSentimentClassifier()
    
    let swifter =  Swifter(consumerKey: "QlO3OHGIpMPQAfhBo18AhuHKe", consumerSecret: "kvlHC4g2cOk51FS3BYhH7iMdhnwaZ27fkZ7FjMojFr8JLX9Ia3")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textField.delegate = self
        
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){

              self.view.endEditing(true)
      }

     func textFieldShouldReturn(_ textField: UITextField) -> Bool{
                 textField.resignFirstResponder()
                 return (true)
      }

    @IBAction func predictPressed(_ sender: Any) {
       
    fetchTweet()
        textField.text = ""
        sentimentLabel.text = ""
        optionLabel.text = ""
    }
    
    
    func fetchTweet(){
        
        if let searchText = textField.text{
            
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended , success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string{
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                self.makePrediction(with: tweets)
                
                
            }) { (error) in
                print("There was an error with the Twitter API request,\(error)")
            }
        }
        
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]){
       
        do{
            let predictions =   try self.sentimentClassifier.predictions(inputs: tweets)
            var sentimentScore = 0
            
            for prediction in predictions{
                let sentiment = prediction.label
                if sentiment == "Pos"{
                    sentimentScore += 1
                }else if sentiment == "Neg"{
                    sentimentScore -= 1
                }
            }
            
            
            updateUI(with: sentimentScore)
            
            
        }catch{
            print("There was an error with making a prediction")
        }
        
    }
    
    func updateUI(with sentimentScore: Int){
        
        // print(sentimentScore)
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
            self.optionLabel.text = "Very Good"
        }else if sentimentScore > 10 {
            self.sentimentLabel.text = "😃"
            self.optionLabel.text = "Good"
        }else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
            self.optionLabel.text = "Pretty Much Ok"
        }else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
            self.optionLabel.text = "Neutral"
        }else if sentimentScore > -10 {
            self.sentimentLabel.text = "☹️"
            self.optionLabel.text = "Bad"
        }else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
            self.optionLabel.text = "Don't ask me"
        }else{
            self.sentimentLabel.text = "🤮"
            self.optionLabel.text = "Disgusting"
        }
        
    }
}

