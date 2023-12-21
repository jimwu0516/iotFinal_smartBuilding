//
//  MessageViewController.swift
//  不要當我們2.0
//
//  Created by Jim Wu on 2023/12/14.
//

import UIKit
import CocoaMQTT

class MessageViewController: UIViewController {
    
    let mqttClient = CocoaMQTT(clientID: "iOS Device", host: "mqtt.eclipse.org", port: 1883)
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var mqtt: CocoaMQTT!
    
    var messages: [String] = ["老者風華展新顏","師者榜樣指前行","不忘初心勇向前","要活真實心自然","當世風雲變莫測","我心深處夢翩翩","們心相伴願成真","二度奮鬥志昂揚","點燃星火激希望", "零散辛勞換豐收"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        let clientID = "iotapp"
        mqtt = CocoaMQTT(clientID: clientID, host: "test.mosquitto.org", port: 1883)
        mqtt.connect()
    }
    
    
    @IBAction func sendToLineNotify(_ sender: UIButton) {
        guard let message = textField.text, !message.isEmpty else {
            showEmptyTextFieldAlert()
            return
        }
        
        messages.insert(message, at: 0)
        tableView.reloadData()
        sendLineNotify(message: message)
        self.publishMessageToTopic(message: message, topic: "jim/ntub/announce")
        textField.text = ""
        view.endEditing(true)
        
    }
    
    
    func showEmptyTextFieldAlert() {
        let alert = UIAlertController(title: "🤬🤬🤬", message: "Enter sth.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func sendLineNotify(message: String) {
        let url = URL(string: "https://notify-api.line.me/api/notify")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer 9KsY2IARkPBjefvy6wcmFNUtD6ZX9JEP9hYYaMJq3IC", forHTTPHeaderField: "Authorization")
        
        let postData = "message=\(message)".data(using: .utf8)
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("Response: \(responseString ?? "")")
            }
        }
        
        task.resume()
    }
    
    func publishMessageToTopic(message: String, topic: String) {
        let message = CocoaMQTTMessage(topic: topic, string: message)
        mqtt.publish(message)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

extension MessageViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension MessageViewController:UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

