//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework


class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {
    
    
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName:"MessageCell",bundle:nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        
        retrieveMessages()
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellView = tableView.dequeueReusableCell(withIdentifier: "customMessageCell",for:indexPath) as! CustomMessageCell
        cellView.messageBody.text = messageArray[indexPath.row].body
        cellView.senderUsername.text = messageArray[indexPath.row].sender
        cellView.avatarImageView.image = UIImage(named:"egg")
        
        if cellView.senderUsername.text == Auth.auth().currentUser?.email as String! {
            cellView.avatarImageView.backgroundColor = UIColor.flatMint()
            cellView.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        } else {
            cellView.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cellView.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cellView
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods

    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
         self.heightConstraint.constant = 50
         self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        SVProgressHUD.show()
        //TODO: Send the message to Firebase and save it in our database
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        
        let messageDictionary = ["Sender":Auth.auth().currentUser?.email,"MessageBody":messageTextfield.text]
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error,reference) in
            if (error == nil) {
                print("message saved succesfully")
                SVProgressHUD.dismiss()
                self.messageTextfield.isEnabled = true;
                self.sendButton.isEnabled = true;
                self.messageTextfield.text = ""
            } else {
                print(error)
            }
        }
        
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        SVProgressHUD.show()
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded) {
            (snapshot) in
            let snapshotvalue  = snapshot.value as! Dictionary<String,String>
            let text = snapshotvalue["MessageBody"]!
            let sender = snapshotvalue["Sender"]!
            let message : Message = Message(senderEmail:sender,message:text)
            self.messageArray.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("error, there was a problem signing out")
        }
        
        
    }
    


}
