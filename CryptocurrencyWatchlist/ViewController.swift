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
    // URL of the API
    var URL = "https://min-api.cryptocompare.com/data/pricemulti?fsyms="
    // additional params
    var PARAMS = "&tsyms=USD&api_key="
    // 
    var API_KEY = MY_API_KEY

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cryptoTableView.dataSource = self

        addNewCryptoTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))

        cryptoTableView.addGestureRecognizer(tapGesture)

        cryptoTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        getCryptos()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count: \(cryptoList.count)")
        return cryptoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! TableViewCell
        
        let cellData = cryptoList[indexPath.row]
        
        cell.name.text = cellData.name
        cell.price.text = cellData.price
        cell.price.sizeToFit()
        return cell
    }
    
    // get cryptocurrency data with Alamofire
    func getCryptos()
    {
        cryptoList.removeAll()
        var cryptoParams = ""
        
        for i in 0..<cryptoNamesList.count {
            cryptoParams += cryptoNamesList[i]
            
            if(i < cryptoNamesList.count - 1){
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
            self.cryptoTableView.reloadData()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.addCryptoTextFieldHeight.constant = 308
            self.view.layoutIfNeeded()
        }
        
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.addCryptoTextFieldHeight.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let newCrypto = addNewCryptoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
            cryptoNamesList.append(newCrypto)
            addNewCryptoTextField.resignFirstResponder()
//            for i in cryptoNamesList {
//                print(i)
//            }
            addNewCryptoTextField.text = ""
            getCryptos()
        }
        return true
    }
    
    @objc func tableViewTapped()
    {
        addNewCryptoTextField.endEditing(true)
    }
}

