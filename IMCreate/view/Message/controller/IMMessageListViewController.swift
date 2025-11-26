//
//  IMMessageListViewController.swift
//  IMCreate
//
//  Created by admin on 2025/11/24.
//

import UIKit

class IMMessageListViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var miniApps: [IMMiniApp] = []
    private var messages: [IMMessage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "消息"

        setupTableView()
        loadMockData()
        setupNavigationItems()
    }
    
    private func makeNavBarButton(imageName: String, action: Selector) -> UIBarButtonItem {
        let btn = UIButton(type: .system)
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = image
            // 使用对称的 contentInsets，避免额外的右侧间距
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            btn.configuration = config

            btn.configurationUpdateHandler = { button in
                // 模拟不因高亮改变图片的效果
                button.alpha = 1.0
                button.tintAdjustmentMode = .normal
            }
        } else {
            btn.setImage(image, for: .normal)
            btn.adjustsImageWhenHighlighted = false
            // 使用对称的 contentEdgeInsets
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }

        btn.imageView?.contentMode = .scaleAspectFit
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.widthAnchor.constraint(equalToConstant: 44),
            btn.heightAnchor.constraint(equalToConstant: 44)
        ])

        btn.addTarget(self, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }

    private func setupNavigationItems() {
        if let navBar = navigationController?.navigationBar {
            var margins = navBar.layoutMargins
            margins.right = 15
            navBar.layoutMargins = margins
        }

        let item1 = makeNavBarButton(imageName: "searchIcon", action: #selector(didTapNavButton1))
        let item2 = makeNavBarButton(imageName: "editIcon", action: #selector(didTapNavButton2))

        // 在两个按钮中间插入固定间距，宽度为 22
        let middleSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        middleSpace.width = 0

        // 顺序：第一个数组元素位于最右侧
        navigationItem.rightBarButtonItems = [item2, middleSpace, item1]
    }

    @objc private func didTapNavButton1() {
        // 按钮1 事件
        print("导航按钮1 被点击")
    }

    @objc private func didTapNavButton2() {
        // 按钮2 事件
        print("导航按钮2 被点击")
    }
   
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor,constant: 15),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(IMMiniAppContainerTableViewCell.self, forCellReuseIdentifier: IMMiniAppContainerTableViewCell.reuseIdentifier)
        tableView.register(IMMessageTableViewCell.self, forCellReuseIdentifier: IMMessageTableViewCell.reuseIdentifier)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 120
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
    }

    private func loadMockData() {
        miniApps = [
            IMMiniApp(id: "1", name: "元友红包", color: UIColor(red:1, green:0.6, blue:0.2, alpha:1)),
            IMMiniApp(id: "2", name: "betahub尝鲜派", color: .systemPink),
            IMMiniApp(id: "3", name: "进击的巨人", color: .lightGray),
            IMMiniApp(id: "4", name: "Apple", color: .systemGray2),
            IMMiniApp(id: "5", name: "iCloud", color: .systemGray3),
            IMMiniApp(id: "6", name: "学习", color: .systemBlue),
            IMMiniApp(id: "2", name: "betahub尝鲜派", color: .systemPink),
            IMMiniApp(id: "3", name: "进击的巨人", color: .lightGray),
            IMMiniApp(id: "4", name: "Apple", color: .systemGray2),
            IMMiniApp(id: "5", name: "iCloud", color: .systemGray3),
            IMMiniApp(id: "6", name: "学习", color: .systemBlue)
        ]

        messages = [
            IMMessage(id: "m1", name: "萤火虫", lastText: "[位置]嗯，有空就过来找我玩吧", timeText: "02:30", avatarColor: .systemBlue),
            IMMessage(id: "m2", name: "追风筝的人", lastText: "追风筝的人领取了你的红包", timeText: "昨天 18:15", avatarColor: .systemOrange),
            IMMessage(id: "m3", name: "古灵精怪", lastText: "[图片]加你VX了哈，可视频验证本人", timeText: "6/8 19:20", avatarColor: .systemPurple),
            IMMessage(id: "m4", name: "小跟班", lastText: "[红包]很高兴认识你", timeText: "2021/12/28 01:00", avatarColor: .systemRed),
            IMMessage(id: "m5", name: "古灵精怪", lastText: "[图片]加你VX了哈，可视频验证本人", timeText: "6/8 19:20", avatarColor: .systemGreen),
            IMMessage(id: "m6", name: "古灵精怪", lastText: "[图片]加你VX了哈，可视频验证本人", timeText: "6/8 19:20", avatarColor: .systemPurple),
            IMMessage(id: "m1", name: "萤火虫", lastText: "[位置]嗯，有空就过来找我玩吧", timeText: "02:30", avatarColor: .systemBlue),
            IMMessage(id: "m2", name: "追风筝的人", lastText: "追风筝的人领取了你的红包", timeText: "昨天 18:15", avatarColor: .systemOrange),
            IMMessage(id: "m3", name: "古灵精怪", lastText: "[图片]加你VX了哈，可视频验证本人", timeText: "6/8 19:20", avatarColor: .systemPurple),
            IMMessage(id: "m4", name: "小跟班", lastText: "[红包]很高兴认识你", timeText: "2021/12/28 01:00", avatarColor: .systemRed),
            IMMessage(id: "m5", name: "古灵精怪", lastText: "[图片]加你VX了哈，可视频验证本人", timeText: "6/8 19:20", avatarColor: .systemGreen),
            IMMessage(id: "m6", name: "古灵精怪", lastText: "[图片]加你VX了哈，可视频验证本人", timeText: "6/8 19:20", avatarColor: .systemPurple)
        ]

        tableView.reloadData()
    }
}

extension IMMessageListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 140
        }
        return 68
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: IMMiniAppContainerTableViewCell.reuseIdentifier, for: indexPath) as! IMMiniAppContainerTableViewCell
            cell.configure(with: miniApps)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: IMMessageTableViewCell.reuseIdentifier, for: indexPath) as! IMMessageTableViewCell
            let model = messages[indexPath.row]
            cell.configure(with: model)
            return cell
        }
    }

    // 可选：调整 header 高度让视觉更接近截图
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 8.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 选择逻辑（留空或实现跳转）
        tableView.deselectRow(at: indexPath, animated: true)

        
        if indexPath.row == 0 {
            
            let items = ["说球帝-体育", "说球帝-体育", "说球帝-体育"]
            let icons: [UIImage]? = [UIImage(named: "tempIcon"), UIImage(named: "tempIcon"), UIImage(named: "tempIcon")].compactMap { $0 }
            IMFloatManager.shared.loadAll(items: items, icons: icons)
            
        }else if indexPath.row == 1 {
            let item = TopBannerItem(title: "分享奖励到账+200元", subtitle: "向往开心生活", icon: UIImage(named: "tempIcon"), duration: 3.0)
            IMTopBannerManager.shared.setSoundEnabled(true)
            IMTopBannerManager.shared.push(item: item)
        } else if indexPath.row == 2 {
            let videoURL = URL(string: "https://v7.slv525627.com/20251123/87gbPlZO/index.m3u8")!
            // 使用默认尺寸 178x107，默认右下角位置
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
            IMFloatManager.shared.loadVideo(in: window, url: videoURL)
        }else {
            let chat = IMChatController()
            chat.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chat, animated: true)
        }
    }
}
