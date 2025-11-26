//
//  IMChatController.swift
//  IMCreate
//
//  Created by mac密码1234 on 2025/11/25.
//


import UIKit

enum PanelType {
    case none
    case keyboard
    case function
    case emoji
}

class IMChatController: IMBaseViewController {
    private let tableView = UITableView()
    private let inputBar = IMInputBar()
    private let functionPanel = IMFunctionPanel()
    private let emojiPanel = IMEmojiPanel()
    private var messages: [IMMessageType] = []
    private let panelHeight: CGFloat = 276
    private var currentPanelType: PanelType = .none
    private let bottomSafeAreaView = UIView()
    private var inputBarBottomConstraint: NSLayoutConstraint!
    private var inputBarBottomToSafeArea: NSLayoutConstraint!
    private var inputBarBottomToBottom: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        loadInitialMessages()
        self.gk_navTitle = "聊天"
        NotificationCenter.default.addObserver(self, selector: #selector(insertEmoji(_:)), name: NSNotification.Name("IMEmojiPanelDidSelectEmoji"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(delEmoji(_:)), name: NSNotification.Name("IMEmojiPanelDidTapDelete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendEmoji(_:)), name: NSNotification.Name("IMEmojiPanelDidTapSend"), object: nil)


    }
    
    @objc func delEmoji (_ notification: Notification){
        // 删除最后一个字符
        inputBar.textField.text = String((inputBar.textField.text ?? "").dropLast())
    }
    
    @objc func sendEmoji (_ notification: Notification){
        if inputBar.textField.text == "" {
            return
        }
        let message = IMMessageType(text: inputBar.textField.text ?? "")
        messages.append(message)
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
        inputBar.textField.text = ""
    }


    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F7F7F7")
//        let navBar = IMChatNavBar()
//        view.addSubview(navBar)
//        navBar.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            navBar.topAnchor.constraint(equalTo: view.topAnchor),
//            navBar.leftAnchor.constraint(equalTo: view.leftAnchor),
//            navBar.rightAnchor.constraint(equalTo: view.rightAnchor),
//            navBar.heightAnchor.constraint(equalToConstant: 44)
//        ])

        view.addSubview(tableView)
        view.addSubview(inputBar)
        view.addSubview(functionPanel)
        view.addSubview(emojiPanel)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        functionPanel.translatesAutoresizingMaskIntoConstraints = false
        emojiPanel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: AppConfig.topBarHeight),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor)
        ])

        inputBarBottomToSafeArea = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        inputBarBottomToBottom = inputBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        inputBarBottomToSafeArea.isActive = true // 默认激活安全区约束
        inputBarBottomToBottom.isActive = false
        
        
        inputBarBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        inputBarBottomConstraint.isActive = true

        NSLayoutConstraint.activate([
            inputBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            inputBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            inputBar.heightAnchor.constraint(equalToConstant: 55)
        ])

        NSLayoutConstraint.activate([
            functionPanel.leftAnchor.constraint(equalTo: view.leftAnchor),
            functionPanel.rightAnchor.constraint(equalTo: view.rightAnchor),
            functionPanel.topAnchor.constraint(equalTo: inputBar.bottomAnchor),
            functionPanel.heightAnchor.constraint(equalToConstant: panelHeight)
        ])
        functionPanel.isHidden = true

        NSLayoutConstraint.activate([
            emojiPanel.leftAnchor.constraint(equalTo: view.leftAnchor),
            emojiPanel.rightAnchor.constraint(equalTo: view.rightAnchor),
            emojiPanel.topAnchor.constraint(equalTo: inputBar.bottomAnchor),
            emojiPanel.heightAnchor.constraint(equalToConstant: panelHeight)
        ])
        emojiPanel.isHidden = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(IMTextMessageCell.self, forCellReuseIdentifier: "IMTextMessageCell")
        tableView.register(IMImageMessageCell.self, forCellReuseIdentifier: "IMImageMessageCell")
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset

        inputBar.delegate = self
        functionPanel.delegate = self

        view.addSubview(bottomSafeAreaView)
        bottomSafeAreaView.translatesAutoresizingMaskIntoConstraints = false
        bottomSafeAreaView.backgroundColor = UIColor(hex: "#F7F7F7")
        NSLayoutConstraint.activate([
            bottomSafeAreaView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomSafeAreaView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomSafeAreaView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomSafeAreaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTableViewTap))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTableViewTap() {
        view.endEditing(true)
        showPanel(.none)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo,
              let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        currentPanelType = .keyboard
        activateInputBarBottom(toSafeArea: false, offset: -frame.height) // 间距10
        functionPanel.isHidden = true
        emojiPanel.isHidden = true
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    private func activateInputBarBottom(toSafeArea: Bool, offset: CGFloat = 0) {
        inputBarBottomToSafeArea.isActive = toSafeArea
        inputBarBottomToBottom.isActive = !toSafeArea
        if toSafeArea {
            inputBarBottomToSafeArea.constant = offset
        } else {
            inputBarBottomToBottom.constant = offset
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let info = notification.userInfo,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        activateInputBarBottom(toSafeArea: true, offset: 0)
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    private func showPanel(_ type: PanelType) {
        currentPanelType = type
        switch type {
        case .none:
            inputBarBottomConstraint.constant = 0
            functionPanel.isHidden = true
            emojiPanel.isHidden = true
        case .keyboard:
            inputBarBottomConstraint.constant = 0
            functionPanel.isHidden = true
            emojiPanel.isHidden = true
            inputBar.textField.becomeFirstResponder()
        case .function:
            inputBarBottomConstraint.constant = -panelHeight
            functionPanel.isHidden = false
            emojiPanel.isHidden = true
            view.endEditing(true)
        case .emoji:
            inputBarBottomConstraint.constant = -panelHeight
            functionPanel.isHidden = true
            emojiPanel.isHidden = false
            view.endEditing(true)
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    private func loadInitialMessages() {
        messages = []
        tableView.reloadData()
    }

    @objc private func insertEmoji(_ notification: Notification) {
        if let emoji = notification.object as? String {
            inputBar.textField.text = (inputBar.textField.text ?? "") + emoji
        }
    }
}

extension IMChatController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if message.img == true , let urls = message.imageUrls {
            let cell = tableView.dequeueReusableCell(withIdentifier: IMImageMessageCell.reuseIdentifier, for: indexPath) as! IMImageMessageCell
            cell.configure(urls: urls, isOutgoing: message.isOutgoing, avatar: nil, readStatus: message.isOutgoing ? "未读" : nil)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: IMTextMessageCell.reuseIdentifier, for: indexPath) as! IMTextMessageCell
            cell.configure(text: message.text ?? "", isOutgoing: message.isOutgoing, avatar: nil, time: nil, contentColor: UIColor(hex: "#333333"), bubbleImage: nil)
            return cell
        }
    }
}

extension IMChatController: IMInputBarDelegate, IMFunctionPanelDelegate {
    func inputBarDidTapEmoji() {
        if currentPanelType == .emoji {
            showPanel(.none)
        } else if currentPanelType == .keyboard {
            emojiPanel.isHidden = false
            functionPanel.isHidden = true
            inputBarBottomConstraint.constant = -panelHeight
            UIView.animate(withDuration: 0.01) { self.view.layoutIfNeeded() }
            currentPanelType = .emoji
            view.endEditing(true)
        } else {
            showPanel(.emoji)
        }
    }

    func inputBarDidTapFunction() {
        if currentPanelType == .function {
            showPanel(.none)
        } else if currentPanelType == .keyboard {
            functionPanel.isHidden = false
            emojiPanel.isHidden = true
            inputBarBottomConstraint.constant = -panelHeight
            UIView.animate(withDuration: 0.01) { self.view.layoutIfNeeded() }
            currentPanelType = .function
            view.endEditing(true)
        } else {
            showPanel(.function)
        }
    }

    func inputBarDidSendText(_ text: String) {
        let message = IMMessageType(text: text)
        messages.append(message)
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
    }

    func functionPanelDidSelectItem(_ item: IMFunctionItem) {
        // 处理功能点击
        if item.title == "相册" {
            var message = IMMessageType(text: "")
            message.img = true
            message.imageUrls = [
                URL(string: "https://picsum.photos/100/100")!,
                URL(string: "https://picsum.photos/100/100")!,
                URL(string: "https://picsum.photos/600/400")!
            ]
            messages.append(message)
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    // 捕获 return 键：收起键盘并恢复面板
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        showPanel(.none)
        return true
    }
}
