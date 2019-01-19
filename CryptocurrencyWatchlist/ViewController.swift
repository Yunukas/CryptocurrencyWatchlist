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
    var cryptoNamesList : [String] = ["ETH","BTC","LTC"]
    
    
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
    
    
    // URL of the API
    var URL = "https://min-api.cryptocompare.com/data/pricemulti?fsyms="
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
        
        getPrice(cryptoName: "ETH")
    }
    // return the count of the rows we need to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("count: \(cryptoList.count)")
        if(cryptoList.count == 0){
            emptyListLabel.text = "You have no cryptocurrency in your list. Add some!"
            emptyListLabel.isHidden = false
            self.cryptoTableView.backgroundView = emptyListLabel
            return 0
        }
        else {
            emptyListLabel.text = ""
            emptyListLabel.isHidden = true
            return cryptoList.count
        }
    }
    // initialize the custom cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! TableViewCell
        
        let cellData = cryptoList[indexPath.row]
        
        cell.name.text = cellData.name
        cell.price.text = cellData.price
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
            for i in 0..<cryptoList.count {
                if(cryptoList[i].name == currentCrypto) {
                    cryptoList.remove(at: i)
                    break
                }
            }
            // after the operation, update the list
//            getCryptos()
            cryptoTableView.reloadData()
        }
    }
    
    // get cryptocurrency data with the help of Alamofire
    func getCryptos()
    {
        // check if the name array has some elements, so we would make a proper api call
        if(!cryptoList.isEmpty){
            // clear the objects because we query them again and refresh the cells
            //cryptoList.removeAll()
            
            // clear list is empty message each time
            emptyListLabel.text = ""
            
            // construct the parameters for the URL with coin names
            var cryptoParams = ""
            
            for i in 0..<cryptoList.count {
                cryptoParams += cryptoList[i].name
                
                if(i < cryptoList.count - 1){
                    cryptoParams += ","
                }
                
            }
            
            let fullURL = URL + cryptoParams + PARAMS + API_KEY
        
            Alamofire.request(fullURL).responseJSON { response in
            
                if response.result.isSuccess {
                    let json : JSON = JSON(response.result.value!)
                    
                    for (key, value) in json {
                        let name : String = key
                        let price : String = value["USD"].stringValue
                        self.cryptoList.append(Crypto(name: name, price: price))
                    }
                }
                // reload the table
                self.cryptoTableView.reloadData()
            }
        }
    }
    // if user taps outside the text field before returning, hide the keyboard
    @objc func tableViewTapped()
    {
        addNewCryptoTextField.endEditing(true)
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
                getPrice(cryptoName: newCrypto)

            }
        return true
    }
    // this function gets the price for a given crytocurrency
    func getPrice(cryptoName: String){
        // construct the parameters for the URL with coin names
        let cryptoParams = cryptoName
        
        let fullURL = URL + cryptoParams + PARAMS + API_KEY
        
        Alamofire.request(fullURL).responseJSON { response in
            
            if response.result.isSuccess {
                let json : JSON = JSON(response.result.value!)
                if(json["Response"] != "Error"){
                    for (key, value) in json {
                        let name : String = key
                        let price : String = value["USD"].stringValue
                        self.cryptoList.append(Crypto(name: name, price: price))
                        
                    }
                    // add the new crypto to the table
                    self.addNewCrypto()
                }
//                print(json)

            }
        }
    }

    
    func addNewCrypto()
    {
        print("here")
        cryptoTableView.beginUpdates()
//                    for i in cryptoList {
//                        print(i.name)
//                    }
        cryptoTableView.insertRows(at: [IndexPath(row: (cryptoList.count-1) , section: 0)], with: .automatic)
        
        cryptoTableView.endUpdates()
    }
    
}

