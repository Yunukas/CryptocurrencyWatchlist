//
//  ViewController.swift
//  TwoScreenApp
//
//  Created by Yunus Yurttagul on 13.01.2019.
//  Copyright © 2019 YJ. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var cryptoList = [Crypto]()
    
    
    /*
     the height constraint of the text field,
     this is required for mocing the bottom view
     when text field is activated and keyboard is presented
     */
    @IBOutlet weak var addCryptoTextFieldHeight: NSLayoutConstraint!
    // the table view that lists the selected cryptos
    @IBOutlet weak var cryptoTableView: UITableView!
    // the text field at the bottom of the view, used for adding new items
    @IBOutlet weak var addNewCryptoTextField: UITextField!
    
    @IBOutlet weak var emptyListLabel: UILabel!
    
    // update interval in seconds
    let updateInterval : Double = 5.0
    // URL of the API
    var URL = "https://min-api.cryptocompare.com/data/pricemultifull?fsyms="
    // additional params
    var PARAMS = "&tsyms=USD&api_key="
    // use your own api keys!
    var API_KEY = MY_API_KEY

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        cryptoList.append(Crypto(name: "ETH", price: "0.0"))
        cryptoTableView.dataSource = self

        addNewCryptoTextField.delegate = self
        
        // this tap gesture will be on the table
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        
        // add this gesture for hiding keyboard if outside of text field is tapped
        cryptoTableView.addGestureRecognizer(tapGesture)
        
        // register the custom cells with their identifier
        cryptoTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        emptyListLabel.text = "You have no cryptocurrency in your list. Add some! i.e. type: BTC"
        cryptoTableView.backgroundView = emptyListLabel
//        cryptoTableView.separatorColor = UIColor.red
        
//        cryptoTableView.rowHeight = UITableView.automaticDimension
//        cryptoTableView.estimatedRowHeight = 600
        // timer function to update the prices every specified updateInterval
        _ = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
//            print("timer fired \(Date())")
            self.updatePrices()
        }

    }
    // return the count of the rows we need to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("count: \(cryptoList.count)")
        if(cryptoList.count == 0){
            cryptoTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            cryptoTableView.backgroundView?.isHidden = false
            return 0
        }
        else {
            cryptoTableView.separatorStyle = UITableViewCell.SeparatorStyle.init(rawValue: 1)!
            cryptoTableView.separatorColor = UIColor.lightGray
            cryptoTableView.backgroundView?.isHidden = true
            return cryptoList.count
        }
    }
    // initialize the custom cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! TableViewCell
        
        let cellData = cryptoList[indexPath.row]
        
        cell.name.text = cellData.name
        cell.price.text = "\(cellData.price) $"
        cell.dailyChangePercentage.text = "\(cellData.dailyChangePercentage) %"
        cell.price.sizeToFit()
        return cell
    }
    
    // methods for swiping table cells to delete
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    // this function will delete the cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            // get the name of the crytocurrency at the selected row
            let currentCrypto = cryptoList[indexPath.row].name
            // search the name in cryptoNamesList array and remove the found index
            
            if let index = cryptoList.firstIndex(where: {$0.name == currentCrypto}){
                cryptoList.remove(at: index)
                let indexPath = IndexPath(row: index, section: 0)
                cryptoTableView.deleteRows(at: [indexPath], with: .left)
            }
            
//            for i in 0..<cryptoList.count {
//                if(cryptoList[i].name == currentCrypto) {
//                    cryptoList.remove(at: i)
//                    let indexPath = IndexPath(row: i, section: 0)
//                    cryptoTableView.deleteRows(at: [indexPath], with: .left)
//                    break
//                }
//            }

           // cryptoTableView.reloadData()
        }
    }

    // if user taps outside the text field before returning, hide the keyboard
    @objc func tableViewTapped()
    {
        if addNewCryptoTextField.isEditing {
            addNewCryptoTextField.endEditing(true)
        }
    }
    // when user starts editing the text field,
    // increase the height of the bottom view because the keyboard will be present
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.addCryptoTextFieldHeight.constant = 308
            self.view.layoutIfNeeded()
        }
        
    }
    // when editing is complete, revert the height of the bottom view
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.addCryptoTextFieldHeight.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    // after user enters the text and taps done, perform the action
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let newCrypto = addNewCryptoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
//                cryptoNamesList.append(newCrypto)
                addNewCryptoTextField.resignFirstResponder()

                addNewCryptoTextField.text = ""
                addPrice(cryptoName: newCrypto)

            }
        return true
    }
    // this function gets the price for a given crytocurrency
    func addPrice(cryptoName: String){
        // construct the parameters for the URL with coin names
        let cryptoParams = cryptoName
        
        let fullURL = URL + cryptoParams + PARAMS + API_KEY
        
        Alamofire.request(fullURL).responseJSON { response in
            
            if response.result.isSuccess {
                let json : JSON = JSON(response.result.value!)
                print(json)
                if(json["Response"] != "Error"){
//                    for (key, value) in json {
                    
                        let name : String = json["RAW"][cryptoName]["USD"]["FROMSYMBOL"].stringValue
                        let price : String = json["RAW"][cryptoName]["USD"]["PRICE"].stringValue
                        let dailyChangePercentage : String = json["DISPLAY"][cryptoName]["USD"]["CHANGEPCTDAY"].stringValue
                        self.cryptoList.append(Crypto(name: name, price: price, dailyChangePercentage: dailyChangePercentage))
                        print("name: \(name) price: \(price) daily: \(dailyChangePercentage)")
//                    }
                    // add the new crypto to the table
                    self.addNewCrypto()
                }
            }
        }
    }

    
    func addNewCrypto()
    {
        cryptoTableView.beginUpdates()
        cryptoTableView.insertRows(at: [IndexPath(row: (cryptoList.count-1) , section: 0)], with: .automatic)
        cryptoTableView.endUpdates()
    }
    
    // this function will query the API to update prices of coins in the cryptoList array
    func updatePrices(){
        
        // first get the name of all cryptos in the array to form the url parameters
        var cryptoParams = ""
        for i in 0..<cryptoList.count {
            cryptoParams += cryptoList[i].name
            
            if(i < cryptoList.count - 1){
                cryptoParams += ","
            }
            
        }
        // construct the full url
        let fullURL = URL + cryptoParams + PARAMS + API_KEY
        
        // get the bulk data from API
        Alamofire.request(fullURL).responseJSON { response in
            
            if response.result.isSuccess {
                let json : JSON = JSON(response.result.value!)
                print(json)
                if(json["Response"] != "Error"){
//                    for (key, value) in json {
                    for i in self.cryptoList {
                    let name : String = json["RAW"][i.name]["USD"]["FROMSYMBOL"].stringValue
                    let price : String = json["RAW"][i.name]["USD"]["PRICE"].stringValue
                    let dailyChangePercentage : String = json["DISPLAY"][i.name]["USD"]["CHANGEPCTDAY"].stringValue
//                    self.cryptoList.append(Crypto(name: name, price: price, dailyChangePercentage: dailyChangePercentage))
                    
                        // find the index of the coins whose price has changed
                        if let index = self.cryptoList.firstIndex(where: {$0.name == name && $0.price != price}){
                            
                            // update the array with the new price
                            self.cryptoList[index].price = price
                            self.cryptoList[index].dailyChangePercentage = dailyChangePercentage
                            // animate the updated coin's row
                            let indexPath = IndexPath(item: index, section: 0)
                            self.cryptoTableView.reloadRows(at: [indexPath], with: .top)
                        }
                    }
//                    }
                }
                //                print(json)
            }
        }
     
    }
    
}

