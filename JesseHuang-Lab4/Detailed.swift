//
//  Detailed.swift
//  AwesomeDemo
//
//  Created by Todd Sproull on 2/22/17. edited lots by Jesse Huang
//  Copyright © 2017 Todd Sproull. All rights reserved.
//Creating dynamic plot label:
//http://stackoverflow.com/questions/31228831/how-to-give-dynamic-height-to-uilabel-programatically-in-swift


import UIKit

class Detailed: UIViewController {

    var theImage: UIImage!
    var theName: String!
    var urlString : String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theImageView.image = theImage
        theLabel.text = "Title: " + theName
        fetchData()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var theLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var plotLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    @IBOutlet weak var theImageView: UIImageView!
    @IBOutlet weak var websiteLink: UIButton!
    
    
    private func fetchData() {
        
        var urlString = "http://www.omdbapi.com/?t=\(theName!)"
        urlString = urlString.replacingOccurrences(of: " ", with: "+")
        let json = getJSON(urlString)
        
        let year = json["Year"].stringValue
        let plot = json["Plot"].stringValue
        let rating = json["Rated"].stringValue
        let genre = json["Genre"].stringValue
        let webString = json["imdbID"].stringValue
        if(webString == "N/A"){
            websiteLink.removeFromSuperview()
        }else{
            self.urlString = "http://www.imdb.com/title/\(webString)/"
            websiteLink.setTitle("IMDB", for: .normal)
        }
        
        yearLabel.text = "Year: " +  year
        ratingLabel.text = "Rated: " + rating
        genreLabel.text = "Genre: " + genre
        plotLabel.text = "Plot: " + plot
        plotLabel.numberOfLines = 10
        plotLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        plotLabel.sizeToFit()
    
    }
    
    @IBAction func goToWebsite(_ sender: Any) {
        UIApplication.shared.open(URL(string: self.urlString)!, options: [:], completionHandler: nil)
    }
    private func getJSON(_ url: String) -> JSON {
        
        if let url = URL(string: url){
            if let data = try? Data(contentsOf: url) {
                let json = JSON(data: data)
                return json
            } else {
                return JSON.null
            }
        } else {
            return JSON.null
        }
        
        
    }
    @IBAction func addToFavorites(_ sender: Any) {
        let thepath = Bundle.main.path(forResource: "favorites", ofType: "db")
        let contactDB = FMDatabase(path: thepath)
        if !(contactDB?.open())! {
            print("Unable to open database")
            return
        } else {
            do{
                let query = "insert into faves(name) values(?)"
                try contactDB?.executeUpdate(query, values: [theName])
                print(theName + " was inserted into the database.")
            } catch let error as NSError {
                print("failed \(error)")
            }
            contactDB?.close()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
