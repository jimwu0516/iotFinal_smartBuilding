//
//  InputViewController.swift
//  不要當我們2.0
//
//  Created by Jim Wu on 2023/12/16.
//

// InputViewController.swift

import UIKit

protocol InputViewControllerDelegate: AnyObject {
    func didEnterURL(url: String, selectedWebView: Int)
}

class InputViewController: UIViewController {
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var webViewSelector: UISegmentedControl!
    
    weak var delegate: InputViewControllerDelegate?
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        guard let url = urlTextField.text, !url.isEmpty else {
            showErrorMessage(message: "URL is empty")
            return
        }
        
        let selectedWebView = webViewSelector.selectedSegmentIndex
        delegate?.didEnterURL(url: url, selectedWebView: selectedWebView)
        dismiss(animated: true, completion: nil)
    }
    
    func showErrorMessage(message: String) {
        let alertController = UIAlertController(title: "🤬🤬🤬", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
