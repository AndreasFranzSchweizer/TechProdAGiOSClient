//
//  ViewController.swift
//  TechProdAGiOSClient
//
//  Created by Andreas Schweizer on 12.09.21.
//

import UIKit
import CocoaMQTT


class ViewController: UIViewController {
    var mqtt: CocoaMQTT?
    
    @IBOutlet weak var datareceived: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //1. Add observer for application life cycle
        NotificationCenter.default.addObserver(self, selector: #selector(didActivate), name: UIScene.didActivateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIScene.didEnterBackgroundNotification, object: nil)

        //2. Setup the mqtt connection and message handler
        setUpMQTT()

        //3. Set the delegate
        mqtt!.delegate = self
    }
    
    //Remove observer notification
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIScene.didActivateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIScene.didEnterBackgroundNotification, object: nil)
    }
    
    //Notification, when the App is activated, I restore the connection with Mqtt broker
    @objc func didActivate(){
        if mqtt!.connState == .disconnected {
            let _: Bool = mqtt!.connect()
        }
    }
    
    //Notification, when the App enters in background, I disconnect the mqtt Object
    @objc func didEnterBackground(){
        mqtt!.disconnect()
    }

    //Setup mqtt client
    func setUpMQTT() {
        var connected:Bool = false
        
        //1. Definition of the client Identificator
        let clientID = "CocoaMQTT"

        //2. Definition of mqtt broker connection
        mqtt = CocoaMQTT(clientID: clientID, host: "5d01c8fd6867425abfd9bd41ea2ac19d.s2.eu.hivemq.cloud", port: 8883)
        
        //3. Setup the username and password if supported otherwise do not set
        mqtt!.username = "TechprodAG"
        mqtt!.password = "TechprodAG2021"
        
        //4. Definition of will message topic and connection
        mqtt!.willMessage = CocoaMQTTWill(topic: "/sensors/temperature", message: "dieout")
        mqtt!.keepAlive = 60
        
        mqtt!.enableSSL = true
        
        mqtt!.logLevel = .debug
        
        mqtt!.cleanSession = true
        
        connected = mqtt!.connect()
        if connected{
            print("Connected to the broker")
        }
        else{
            print("Not connected to the broker")
        }
    }
}

extension ViewController: CocoaMQTTDelegate {
    
    //1. Connection with Broker, time to subscribe to a topic
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        //mqtt.subscribe("testtopic/#")
        //print("subscribed")
        //mqtt.publish(CocoaMQTTMessage(topic: "testtopic/test", string: "message", qos: .qos2))
    }

    //2. Reception of mqtt message in the topic "/sensors/temperature"
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ){
        datareceived.text = message.string!
        print("received")
    }
    
    // Other required methods for CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {}
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {print(host); print(port);print("ok")}
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {}
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {}
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {}
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {}
    func mqttDidPing(_ mqtt: CocoaMQTT) {}
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {}
    func _console(_ info: String) {}
}

