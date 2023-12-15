//
//  ViewController.swift
//  iotproject
//
//  Created by Jim Wu on 2023/12/9.
//

import UIKit
import CocoaMQTT

class ViewController: UIViewController {
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var total_peopleLabel: UILabel!
    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var emergency_exitLabel: UILabel!
    
    var mqtt: CocoaMQTT!
    var isLightOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let clientID = "iotapp"
        mqtt = CocoaMQTT(clientID: clientID, host: "test.mosquitto.org", port: 1883)
        
        mqtt.didConnectAck = { mqtt, ack in
            if ack == .accept {
                print("Connected to MQTT broker")
                mqtt.subscribe("jim/ntub/tem")
                mqtt.subscribe("jim/ntub/hum")
                mqtt.subscribe("jim/ntub/total_people")
                mqtt.subscribe("jim/ntub/emergency_exit")
            }
        }
        
        mqtt.didReceiveMessage = { mqtt, message, id in
            if let data = message.string {
                DispatchQueue.main.async {
                    if message.topic == "jim/ntub/tem" {
                        self.temperatureLabel.text = "\(data)"
                    } else if message.topic == "jim/ntub/hum" {
                        self.humidityLabel.text = "\(data)"
                    }else if message.topic == "jim/ntub/total_people" {
                        self.total_peopleLabel.text = "\(data)"
                    }else if  message.topic == "jim/ntub/emergency_exit" {
                        self.update_emergency_exitLabel(with: data)
                    }
                }
            }
        }
        
        mqtt.connect()
        setupButtonAppearance()
    }
    
    func setupButtonAppearance() {
        lightButton.clipsToBounds = true
        updateButtonAppearance()
        lightButton.setTitle("Turn on", for: .normal)
        lightButton.backgroundColor = .clear
    }
    
    func updateButtonAppearance() {
        let color: UIColor = isLightOn ? .clear : .purple
        lightButton.backgroundColor = color
        let title = isLightOn ? "Turn on" : "Turn off"
        lightButton.setTitle(title, for: .normal)
    }
    
    @IBAction func lightButtonTapped(_ sender: Any) {
        let topic = "jim/ntub/light_control"
        let message = isLightOn ? "turn_off" : "turn_on"
        mqtt.publish(topic, withString: message, qos: .qos1, retained: false)
        isLightOn.toggle()
        updateButtonAppearance()
    }
    
    func update_emergency_exitLabel(with data: String) {
        if let emergency_exit = Int(data), emergency_exit == 1 {
            emergency_exitLabel.text = "Close"
        } else if let emergency_exit = Int(data), emergency_exit == 0 {
            emergency_exitLabel.text = "Open"
        }
    }
    
    deinit {
        mqtt.disconnect()
    }
    
    
    
}

