//
//  IMMainTabBarController.swift
//  IMCreate
//
//  Created by admin on 2025/11/24.
//


import UIKit

class IMMainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupViewControllers()
    }

    private func setupAppearance() {
        // 选中颜色
        tabBar.tintColor = AppConfig.tabbarSelected
        // 未选中颜色（iOS13+）
        if #available(iOS 13.0, *) {
            tabBar.unselectedItemTintColor = AppConfig.tabbarUnselected
        } else {
            // 兼容旧 iOS
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: AppConfig.tabbarUnselected], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: AppConfig.tabbarSelected], for: .selected)
        }
        // 可根据需要设置背景色
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
    }

    private func setupViewControllers() {
        let messageVC = IMMessageListViewController()
        messageVC.title = "消息"
        let messageItem = UITabBarItem(title: "消息",
                                  image: UIImage(named: "icon_tab_messge_normal")?.withRenderingMode(.alwaysOriginal),
                                  selectedImage: UIImage(named: "icon_tab_message_selected")?.withRenderingMode(.alwaysOriginal))
        messageVC.tabBarItem = messageItem
        
        let personVC = IMContactListViewController()
        personVC.view.backgroundColor = .white
        personVC.title = "联系"
        let personItem = UITabBarItem(title: "联系",
                                   image: UIImage(named: "icon_tab_fridend_normal")?.withRenderingMode(.alwaysOriginal),
                                   selectedImage: UIImage(named: "icon_tab_fridend_selected")?.withRenderingMode(.alwaysOriginal))
        personVC.tabBarItem = personItem

        let groupVC = IMGroupListViewController()
        groupVC.view.backgroundColor = .white
        groupVC.title = "群组"
        let groupItem = UITabBarItem(title: "群组",
                                   image: UIImage(named: "icon_tab_group_chat_normal")?.withRenderingMode(.alwaysOriginal),
                                   selectedImage: UIImage(named: "icon_tab_group_chat_selected")?.withRenderingMode(.alwaysOriginal))
        groupVC.tabBarItem = groupItem

        let mineVC = IMMineViewController()
        mineVC.view.backgroundColor = .white
        mineVC.title = "我的"
        let mineItem = UITabBarItem(title: "我的",
                                   image: UIImage(named: "icon_tab_my_normal")?.withRenderingMode(.alwaysOriginal),
                                   selectedImage: UIImage(named: "icon_tab_my_selected")?.withRenderingMode(.alwaysOriginal))
        mineVC.tabBarItem = mineItem

        let nav1 = UINavigationController(rootViewController: messageVC)
        let nav2 = UINavigationController(rootViewController: personVC)
        let nav3 = UINavigationController(rootViewController: groupVC)
        let nav4 = UINavigationController(rootViewController: mineVC)

        viewControllers = [nav1, nav2,nav3,nav4]
    }
}
