//
//  Message.swift
//  Flash Chat
//
//  This is the model class that represents the blueprint for a message

class Message {
    
    //TODO: Messages need a messageBody and a sender variable
    var sender  = ""
    var body = ""
    
    init(senderEmail:String,message:String) {
        sender = senderEmail
        body = message
    }
}
