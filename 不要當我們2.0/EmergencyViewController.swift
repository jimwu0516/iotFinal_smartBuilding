import UIKit
import UserNotifications
import CocoaMQTT

class EmergencyViewController: UIViewController {
    
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var emergency_image: UIImageView!
    
    var mqtt: CocoaMQTT!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emergency_image.image = UIImage(named: "warning.png")
        self.toggleSwitch.isOn = false
        
        let clientID = "iotapp"
        mqtt = CocoaMQTT(clientID: clientID, host: "test.mosquitto.org", port: 1883)
        
        // local notification
        mqtt.didConnectAck = { mqtt, ack in
            if ack == .accept {
                print("Connected to MQTT broker")
                mqtt.subscribe("jim/ntub/emergency_button")
            }
        }
        mqtt.didReceiveMessage = { mqtt, message, id in
            if let data = message.string {
                DispatchQueue.main.async {
                    if data == "on" {
                        self.sendNotification()
                    }
                }
            }
        }
        
        mqtt.connect()
        
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            showAlert()
        } else {
            publishMessageToTopic(message: "false", topic: "jim/ntub/emergency_state")
        }
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "🚨Warning", message: "Are you sure you want to enable emergency state?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.toggleSwitch.isOn = false
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.publishMessageToTopic(message: "true", topic: "jim/ntub/emergency_state")
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func publishMessageToTopic(message: String, topic: String) {
        let message = CocoaMQTTMessage(topic: topic, string: message)
        mqtt.publish(message)
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "不要當我們2.0"
        content.body = "緊急狀況，快逃啊😱"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "emergencyNotification", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
    
}
