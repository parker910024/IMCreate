//
//  IMMineViewController.swift
//  IMCreate
//
//  Created by admin on 2025/11/24.
//

import UIKit

class IMMineViewController: IMBaseViewController {

    private let tableView = UITableView(frame: .zero)

    private let headerView = IMMineHeaderView()

    private enum Section: Int, CaseIterable {
        case profileControls
        case miniApps
        case others
    }

    private let miniApps: [(icon: UIImage?, title: String)] = [
        (UIImage(named: "tempIcon"), "袋鼠-体育"),
        (UIImage(named: "tempIcon"), "betahub烘焙派"),
        (UIImage(named: "tempIcon"), "进击的巨人"),
        (UIImage(named: "tempIcon"), "Apple"),
        (UIImage(named: "tempIcon"), "iCloud"),
        (UIImage(named: "tempIcon"), "Apple"),
        (UIImage(named: "tempIcon"), "iCloud")
    ]

    private let imageCache = NSCache<NSURL, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()
        gk_navTitle = "我的"
        view.backgroundColor = UIColor(hex: "#F6F7FB")
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.gk_navLineHidden = true
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: AppConfig.topBarHeight + 15),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        tableView.backgroundColor = UIColor(hex: "#F6F7FB")
        // 恢复分隔线并设置内边距与风格
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = nil

        // 注册自定义 cell
        tableView.register(IMMiniAppsCell.self, forCellReuseIdentifier: IMMiniAppsCell.reuseIdentifier)
        tableView.register(IMProfileControlsCell.self, forCellReuseIdentifier: "IMProfileControlsCell")
        tableView.register(IMOtherItemCell.self, forCellReuseIdentifier: "IMOtherItemCell")

        headerView.delegate = self
        headerView.configure(name: "猪猪", id: "ID：24234234", avatarURL: nil, badgeImage: UIImage(named: "vipIcon"))
    }

    // 简单异步图片加载（示例）
    private func loadImage(from url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else { completion(nil); return }
        if let cached = imageCache.object(forKey: url as NSURL) {
            completion(cached)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                self.imageCache.setObject(img, forKey: url as NSURL)
                DispatchQueue.main.async { completion(img) }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }

    // 自定义 miniApps header
    private func makeMiniAppsHeaderView() -> UIView {
        let container = UIView()
        container.backgroundColor = .white

        let titleLabel = UILabel()
        titleLabel.text = "我的小程序"
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = UIColor(hex: "#5C5D61")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let seeAllButton = UIButton(type: .system)
        seeAllButton.setTitle("查看全部", for: .normal)
        seeAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        seeAllButton.setTitleColor(UIColor(hex: "#8A8B90"), for: .normal)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor(hex: "#C0C1C4")
        chevron.translatesAutoresizingMaskIntoConstraints = false

        seeAllButton.addTarget(self, action: #selector(didTapSeeAll), for: .touchUpInside)

        container.addSubview(titleLabel)
        container.addSubview(seeAllButton)
        container.addSubview(chevron)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 10),
            chevron.heightAnchor.constraint(equalToConstant: 16),

            seeAllButton.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -6),
            seeAllButton.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    @objc private func didTapSeeAll() {
        // 点击查看全部小程序的处理
    }
}

// MARK: - UITableViewDataSource / Delegate
extension IMMineViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let s = Section(rawValue: section) else { return 0 }
        switch s {
        case .profileControls: return 1 // 合并为一个自定义 cell
        case .miniApps: return 1
        case .others: return 4
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Section(rawValue: indexPath.section) == .miniApps { return 110 }
        if Section(rawValue: indexPath.section) == .profileControls { return 136 } // 与 IMProfileControlsCell 固定高度一致
        return 44
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let s = Section(rawValue: section) else { return nil }
        switch s {
        case .profileControls:
            return headerView
        case .miniApps:
            return makeMiniAppsHeaderView()
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let s = Section(rawValue: section) else { return 0 }
        switch s {
        case .profileControls:
            return 71
        case .miniApps:
            return 40
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch Section(rawValue: indexPath.section) {
        case .profileControls:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "IMProfileControlsCell", for: indexPath) as? IMProfileControlsCell else {
                return UITableViewCell()
            }
            // 配置初始开关状态（根据业务替换真实值）
            cell.configure(levelOn: true, notifyOn: true)
            cell.onLevelSwitchChanged = { isOn in
                // 在后台持久化等级/气泡偏好
                DispatchQueue.global(qos: .background).async {
                    // persist level preference
                    // e.g. UserDefaults.standard.set(isOn, forKey: "levelOn")
                }
                // 需要时在主线程更新 UI
                DispatchQueue.main.async {
                    // 更新界面（如提示）
                }
            }
            cell.onNotifySwitchChanged = { isOn in
                // 更新通知偏好
                // e.g. 更新本地设置或调用系统权限接口
            }
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = .clear
            return cell

        case .miniApps:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: IMMiniAppsCell.reuseIdentifier, for: indexPath) as? IMMiniAppsCell else {
                return UITableViewCell()
            }
            cell.configure(items: miniApps)
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = .clear
            return cell

        case .others:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: IMOtherItemCell.reuseIdentifier, for: indexPath) as? IMOtherItemCell else {
                return UITableViewCell()
            }
            switch indexPath.row {
            case 0:
                cell.configure(title: "我的动态")
            case 1:
                let verLabel = UILabel()
                verLabel.text = "V1.0"
                verLabel.font = UIFont.systemFont(ofSize: 12)
                verLabel.textColor = UIColor(hex: "#AAAAAA")
                verLabel.sizeToFit()
                cell.configure(title: "当前版本", accessory: .none, accessoryView: verLabel)
            case 2:
                cell.configure(title: "意见反馈")
            case 3:
                cell.configure(title: "注销账户")
            default:
                cell.configure(title: "", accessory: .none)
            }
            cell.contentView.backgroundColor = .clear
            return cell


        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if Section(rawValue: indexPath.section) == .others {
            switch indexPath.row {
            case 0:
                // push 我的动态
                break
            case 2:
                // 意见反馈
                break
            case 3:
                // 注销账户
                break
            default:
                break
            }
        }
    }
}

// MARK: - Actions
extension IMMineViewController {
    @objc private func levelSwitchChanged(_ s: UISwitch) {
        DispatchQueue.global(qos: .background).async {
            // persist
        }
    }

    @objc private func notifySwitchChanged(_ s: UISwitch) {
        // 更新本地偏好
    }
}

// MARK: - Header delegate
extension IMMineViewController: IMMineHeaderViewDelegate {
    func mineHeaderTappedProfile(_ header: IMMineHeaderView) {
        // 打开个人资料
    }

    func mineHeaderDidTapEdit(_ header: IMMineHeaderView) {
        // 编辑
    }
}
