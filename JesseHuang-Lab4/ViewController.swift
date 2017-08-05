//
//  ViewController.swift
//  JesseHuang-Lab4
//
//  Created by Jesse Huang on 3/1/17.
//  Copyright © 2017 Jesse Huang. All rights reserved.
//
//Search implementation from https://www.youtube.com/watch?v=TMo7PuggHlc

import UIKit

class ViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {

    var theData: [Info] = []
        {
        didSet{
            tableView.reloadData()
        }
    }
    var tableView: UITableView!
    var theImageCache: [UIImage] = []
    var searchText: String = ""
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var timer = Timer()
    
    private func searchBarSetup(){
        let searchbar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70) )
        //searchbar.showsScopeBar = true;
        //searchbar.scopeButtonTitles = ["Title","Year"]
        searchbar.delegate = self
        
        self.tableView.tableHeaderView = searchbar
        view.bringSubview(toFront: spinner)
        
    }
   
    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer.invalidate() 
        self.searchText = searchText
        self.spinner.startAnimating()
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(reload), userInfo: nil, repeats: false)
    }
    
    @objc private func reload(){
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchDataForTableView()
            self.cacheImages()
            self.tableView.reloadData()
            self.spinner.stopAnimating()
            
            
            DispatchQueue.main.async {
                

            }
            
            
        }
    }
    
    private func setupTableView() {
        
        tableView = UITableView(frame: view.frame.offsetBy(dx: 0, dy: 50))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        
    }
    
    private func fetchDataForTableView() {
        self.theData = []
        let urlString = "http://www.omdbapi.com/?s=\(searchText)"    //+ searchText
        let json = getJSON(urlString)
        for result in json["Search"].arrayValue {
            let name = result["Title"].stringValue
            let year = result["Year"].stringValue
            let url = result["Poster"].stringValue
            self.theData.append(Info(name: name, year: year, url: url))
        }
        let secondPage = "http://www.omdbapi.com/?s=\(searchText)&page=2"
        let json2 = getJSON(secondPage)
        for result in json2["Search"].arrayValue {
            let name2 = result["Title"].stringValue
            let year2 = result["Year"].stringValue
            let url2 = result["Poster"].stringValue
            self.theData.append(Info(name: name2, year: year2, url: url2))
            
        }
    
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
    
    private func cacheImages() {
        self.theImageCache = []
        for item in theData {
            var url = URL(string: item.url)
            if(url?.absoluteString == "N/A"){
                url = URL(string: "https://upload.wikimedia.org/wikipedia/en/d/d1/Image_not_available.png")
            }
            
            let data = try? Data(contentsOf: url!)
            var image = UIImage(data: try! Data(contentsOf: URL(string: "https://upload.wikimedia.org/wikipedia/en/d/d1/Image_not_available.png")!))
            if(data != nil){
                image = UIImage(data: data!)
            }
            
            self.theImageCache.append(image!)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel!.text = theData[indexPath.row].name
        cell.detailTextLabel?.text = theData[indexPath.row].year
        //print(indexPath.row)
        cell.imageView?.image = theImageCache[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theData.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailedVC = Detailed(nibName: "Detailed", bundle: nil)
        
        detailedVC.theImage = theImageCache[indexPath.row]
        detailedVC.theName = theData[indexPath.row].name
        
        
        navigationController?.pushViewController(detailedVC, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        self.searchBarSetup()
        self.title = "Movies"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

