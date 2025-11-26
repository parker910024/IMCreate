//
//  IMInputBar.swift
//  IMCreate
//
//  Created by mac密码1234 on 2025/11/25.
//

import UIKit

protocol IMInputBarDelegate: AnyObject {
    func inputBarDidSendText(_ text: String)
    func inputBarDidTapFunction()
    func inputBarDidTapEmoji()
}

class IMInputBar: UIView {
    weak var delegate: IMInputBarDelegate?
    private let voiceButton = UIButton(type: .custom)
    public let textField = UITextField()
    private let emojiButton = UIButton(type: .custom)
    private let functionButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor(hex: "#F7F7F7")

        voiceButton.setImage(UIImage(named: "micIcon"), for: .normal)
        emojiButton.setImage(UIImage(named: "faceIcon.smiling"), for: .normal)
        functionButton.setImage(UIImage(named: "addPlusIcon"), for: .normal)
        textField.placeholder = "输入消息"
        textField.font = .systemFont(ofSize: 16)
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 4
        textField.layer.masksToBounds = true
        textField.leftView = UIView.init(frame: CGRectMake(0, 0, 5, 1))
        textField.leftViewMode = .always

        addSubview(voiceButton)
        addSubview(functionButton)
        addSubview(emojiButton)
        addSubview(textField)

        voiceButton.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        emojiButton.translatesAutoresizingMaskIntoConstraints = false
        functionButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            voiceButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            voiceButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            voiceButton.widthAnchor.constraint(equalToConstant: 30),
            voiceButton.heightAnchor.constraint(equalToConstant: 30),


            functionButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            functionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            functionButton.widthAnchor.constraint(equalToConstant: 30),
            functionButton.heightAnchor.constraint(equalToConstant: 30),
            
            emojiButton.rightAnchor.constraint(equalTo: functionButton.leftAnchor, constant: -6),
            emojiButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            emojiButton.widthAnchor.constraint(equalToConstant: 30),
            emojiButton.heightAnchor.constraint(equalToConstant: 30),
            
            
            textField.leftAnchor.constraint(equalTo: voiceButton.rightAnchor, constant: 9),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 40),
            textField.rightAnchor.constraint(equalTo: emojiButton.leftAnchor, constant: -9),

        ])
        textField.rightAnchor.constraint(equalTo: emojiButton.leftAnchor, constant: -8).isActive = true

        textField.addTarget(self, action: #selector(textFieldShouldReturn), for: .editingDidEndOnExit)
        functionButton.addTarget(self, action: #selector(functionTapped), for: .touchUpInside)
        emojiButton.addTarget(self, action: #selector(emojiTapped), for: .touchUpInside)
    }

    @objc private func textFieldShouldReturn() {
        guard let text = textField.text, !text.isEmpty else { return }
        delegate?.inputBarDidSendText(text)
        textField.text = ""
    }

    @objc private func functionTapped() {
        delegate?.inputBarDidTapFunction()
    }

    @objc private func emojiTapped() {
        delegate?.inputBarDidTapEmoji()
    }
}
