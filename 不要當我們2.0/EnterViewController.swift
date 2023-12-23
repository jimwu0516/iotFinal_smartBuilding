//
//  EnterViewController.swift
//  不要當我們2.0
//
//  Created by Jim Wu on 2023/12/14.
//

import UIKit

class EnterViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let originalY = imageView.frame.origin.y
        imageView.frame.origin.y = self.view.frame.height
        UIView.animate(withDuration: 2.5){
            self.imageView.frame.origin.y = originalY
        }
        
        
    }
    
    
    @IBAction func imageViewTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // 使用 Storyboard ID 獲取 UITabBarController 實例
        if let secondTabBarController = storyboard.instantiateViewController(withIdentifier: "wbkhwbdkhwb") as? UITabBarController {
            // 切換到第二個 UITabBarController
            secondTabBarController.modalPresentationStyle = .fullScreen
            present(secondTabBarController, animated: true, completion: nil)
        }
    }
    
    
}
