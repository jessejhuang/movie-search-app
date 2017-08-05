//
//  FavoritesViewController.swift
//  JesseHuang-Lab4
//
//  Created by Jesse Huang on 3/2/17.
//  Copyright © 2017 Jesse Huang. All rights reserved.
//
//Create button programmatically: http://stackoverflow.com/questions/24030348/how-to-create-a-button-programmatically

import UIKit

class FavoritesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    //@IBOutlet weak var tableView: UITableView!
    var tableView: UITableView!
    var myArray:[String] = []
        {
        didSet{
            //loadDatabase()
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myArray = []
        loadDatabase()
        print("View appeared")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupTableView()
        loadDatabase()
        let button = UIButton()
        button.frame = CGRect(x: self.view.frame.size.width/2 - 40, y: 60, width: 100, height: 50)
        //button.backgroundColor = UIColor.red
        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitle("Clear ", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    func buttonAction(sender: UIButton!) {
        print("Button tapped")
        let thepath = Bundle.main.path(forResource: "favorites", ofType: "db")
        let contactDB = FMDatabase(path: thepath)
        if !(contactDB?.open())! {
            print("Unable to open database")
            return
        } else {
            do{
                try contactDB?.executeUpdate("delete from faves", values: nil)
                
            } catch let error as NSError {
                print("failed \(error)")
            }
            contactDB?.close()
        }
        myArray=[]

    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.frame.offsetBy(dx: 0, dy: 50))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel!.text = myArray[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myArray.count
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            deleteFromDatabase(title: myArray[indexPath.row])
            myArray.remove(at: indexPath.row)
        }
    }
    
    func deleteFromDatabase(title: String){
        let thepath = Bundle.main.path(forResource: "favorites", ofType: "db")
        let contactDB = FMDatabase(path: thepath)
        if !(contactDB?.open())! {
            print("Unable to open database")
            return
        } else {
            do{
                let name = "\"\(title)\""
                let results = try contactDB?.executeQuery("select * from faves where name = \(name)", values: nil)
                while (results?.next())! {
                    let query = "delete from faves where uniqueid=?"
                    let someID = results?.string(forColumn: "uniqueid")
                    print("id is \(someID);")
                    try contactDB?.executeUpdate(query, values: [someID!])
                }
            } catch let error as NSError {
                print("failed \(error)")
            }
            contactDB?.close()
        }
    }
    
    func loadDatabase() {
        let thepath = Bundle.main.path(forResource: "favorites", ofType: "db")
        
        let contactDB = FMDatabase(path: thepath)
        
        if !(contactDB?.open())! {
            print("Unable to open database")
            return
        } else {
            do{
                let results = try contactDB?.executeQuery("select * from faves", values: nil)
                while (results?.next())! {
                    let someName = results?.string(forColumn: "name")
                    print("name is \(someName);")
                    myArray.append(someName!)
                }
                
            } catch let error as NSError {
                print("failed \(error)")
            }
            contactDB?.close()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Entered test method")
        let name = myArray[indexPath.row]
        
        var urlString = "http://www.omdbapi.com/?t=\(name)"
        urlString = urlString.replacingOccurrences(of: " ", with: "+")
        let json = getJSON(urlString)
        
        let urlLink = json["Poster"].stringValue
        print(urlLink)
        var url = URL(string: urlLink)
        if(url?.absoluteString == "N/A" || url == nil){
            url = URL(string: "https://upload.wikimedia.org/wikipedia/en/d/d1/Image_not_available.png")
        }
        print(urlLink)
        let data = try? Data(contentsOf: url!)
        
        var image = UIImage(data: try! Data(contentsOf: URL(string: "https://upload.wikimedia.org/wikipedia/en/d/d1/Image_not_available.png")!))
        if(data != nil){
            image = UIImage(data: data!)
        }
        
        let detailedVC = Detailed(nibName: "Detailed", bundle: nil)
        detailedVC.theImage = image
        detailedVC.theName = name
        
        navigationController?.pushViewController(detailedVC, animated: true)
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
