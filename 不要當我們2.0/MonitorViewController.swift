//
//  MonitorViewController.swift
//  不要當我們2.0
//
//  Created by Jim Wu on 2023/12/14.
//

import UIKit
import WebKit

class MonitorViewController: UIViewController, InputViewControllerDelegate {
    
    @IBOutlet weak var webView1: WKWebView!
    @IBOutlet weak var webView2: WKWebView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView1.image = UIImage(named: "SMPTE.jpg")
        imageView2.image = UIImage(named: "SMPTE.jpg")
    }
    
    private func loadWebView(webView: WKWebView, urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    @IBAction func barButtonItemTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let inputViewController = storyboard.instantiateViewController(withIdentifier: "InputViewController") as? InputViewController {
            inputViewController.delegate = self
            present(inputViewController, animated: true, completion: nil)
        }
    }
    
    func didEnterURL(url: String, selectedWebView: Int) {
        guard !url.isEmpty else {
            return
        }

        if let validURL = URL(string: url), validURL.scheme != nil {
            // URL is valid
            if selectedWebView == 0 {
                loadWebView(webView: webView1, urlString: url)
                imageView1.isHidden = true
            } else {
                loadWebView(webView: webView2, urlString: url)
                imageView2.isHidden = true
            }
        } else {
            print("Invalid URL")
        }
    }
    
    
    
    
    
}

