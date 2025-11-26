//
//  IMBaseViewController.swift
//  IMCreate
//
//  Created by admin on 2025/11/24.
//

import UIKit

class IMBaseViewController: GKNavigationBarViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.gk_navBackgroundColor = UIColor.init(hex: "#F6F7FB")
        self.gk_navLineHidden = false
        self.view.backgroundColor = UIColor(hex: "#F6F7FB")
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.gk_backStyle = .black
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
