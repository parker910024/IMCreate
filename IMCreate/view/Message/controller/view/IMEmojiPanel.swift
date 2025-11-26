//
//  IMEmojiPanel.swift
//  IMCreate
//
//  Created by mac密码1234 on 2025/11/25.
//

import UIKit

// 文件：`IMCreate/view/Message/controller/view/IMEmojiPanel.swift`

import UIKit

class IMEmojiPanel: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let emojis: [String] = [
        "😀","😃","😄","😁","😆","😅","😂","🤣","😊","😇",
        "🙂","🙃","😉","😌","😍","🥰","😘","😗","😙","😚",
        "😋","😛","😜","🤪","😝","🤑","🤗","🤭","🤫","🤔",
        "🤐","😐","😑","😶","😏","😒","🙄","😬","🤥","😌",
        "😔","😪","🤤","😴","😷","🤒","🤕","🤢","🤮","🤧",
        "🥵","🥶","🥴","😵","🤯","🤠","🥳","😎","🤓","🧐",
        "😕","😟","🙁","☹️","😮","😯","😲","😳","🥺","😦",
        "😧","😨","😰","😥","😢","😭","😱","😖","😣","😞",
        "😓","😩","😫","🥱","😤","😡","😠","🤬","😈","👿",
        "💀","☠️","🤡","👹","👺","👻","👽","👾","🤖","😺",
        "😸","😹","😻","😼","😽","🙀","😿","😾"
    ]
    private let itemSize: CGFloat = 40
       private let itemSpacing: CGFloat = 10
       private let panelPadding: CGFloat = 10

       private var itemsPerRow: Int = 1
       private let collectionView: UICollectionView
       private let buttonFloatView = UIView()
       private let deleteButton = UIButton(type: .system)
       private let sendButton = UIButton(type: .system)

       override init(frame: CGRect) {
           let layout = UICollectionViewFlowLayout()
           layout.scrollDirection = .vertical
           collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
           super.init(frame: frame)
           setupUI()
       }
       required init?(coder: NSCoder) {
           let layout = UICollectionViewFlowLayout()
           layout.scrollDirection = .vertical
           collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
           super.init(coder: coder)
           setupUI()
       }

       override func layoutSubviews() {
           super.layoutSubviews()
           let availableWidth = bounds.width - panelPadding * 2
           itemsPerRow = max(Int(floor((availableWidth + itemSpacing) / (itemSize + itemSpacing))), 1)
           let usedWidth = CGFloat(itemsPerRow) * itemSize + CGFloat(itemsPerRow - 1) * itemSpacing
           let horizontalInset = max((bounds.width - usedWidth) / 2, panelPadding)

           let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
           layout?.itemSize = CGSize(width: itemSize, height: itemSize)
           layout?.minimumLineSpacing = itemSpacing
           layout?.minimumInteritemSpacing = itemSpacing
           layout?.sectionInset = UIEdgeInsets(top: panelPadding, left: horizontalInset, bottom: panelPadding, right: horizontalInset)

           // 悬浮按钮区布局
           let floatWidth: CGFloat = 120
           let floatHeight: CGFloat = 56
           buttonFloatView.frame = CGRect(
               x: bounds.width - floatWidth - 16,
               y: bounds.height - floatHeight - 16,
               width: floatWidth,
               height: floatHeight
           )
       }

       private func setupUI() {
           addSubview(collectionView)
           addSubview(buttonFloatView)

           collectionView.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               collectionView.topAnchor.constraint(equalTo: topAnchor),
               collectionView.leftAnchor.constraint(equalTo: leftAnchor),
               collectionView.rightAnchor.constraint(equalTo: rightAnchor),
               collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
           ])
           collectionView.dataSource = self
           collectionView.delegate = self
           collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
           collectionView.backgroundColor = UIColor(hex: "#F7F7F7")
           collectionView.showsVerticalScrollIndicator = false
           collectionView.isPagingEnabled = false

           // 悬浮按钮区样式
           buttonFloatView.backgroundColor = .white
           buttonFloatView.layer.cornerRadius = 16
           buttonFloatView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
           buttonFloatView.layer.shadowOpacity = 1
           buttonFloatView.layer.shadowOffset = CGSize(width: 0, height: 2)
           buttonFloatView.layer.shadowRadius = 8
           buttonFloatView.isUserInteractionEnabled = true

           // 删除按钮
           deleteButton.setImage(UIImage(systemName: "delete.left"), for: .normal)
           deleteButton.tintColor = .darkGray
           deleteButton.backgroundColor = .clear
           deleteButton.layer.cornerRadius = 12
           deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

           // 发送按钮
           sendButton.setTitle("发送", for: .normal)
           sendButton.backgroundColor = UIColor(red: 0, green: 0.8, blue: 0.4, alpha: 1)
           sendButton.setTitleColor(.white, for: .normal)
           sendButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
           sendButton.layer.cornerRadius = 12
           sendButton.layer.masksToBounds = true
           sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

           // 按钮区布局
           buttonFloatView.addSubview(deleteButton)
           buttonFloatView.addSubview(sendButton)
           deleteButton.translatesAutoresizingMaskIntoConstraints = false
           sendButton.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               deleteButton.leftAnchor.constraint(equalTo: buttonFloatView.leftAnchor, constant: 12),
               deleteButton.centerYAnchor.constraint(equalTo: buttonFloatView.centerYAnchor),
               deleteButton.widthAnchor.constraint(equalToConstant: 32),
               deleteButton.heightAnchor.constraint(equalToConstant: 32),

               sendButton.leftAnchor.constraint(equalTo: deleteButton.rightAnchor, constant: 16),
               sendButton.centerYAnchor.constraint(equalTo: buttonFloatView.centerYAnchor),
               sendButton.widthAnchor.constraint(equalToConstant: 56),
               sendButton.heightAnchor.constraint(equalToConstant: 32)
           ])
       }

       @objc private func deleteTapped() {
           NotificationCenter.default.post(name: NSNotification.Name("IMEmojiPanelDidTapDelete"), object: nil)
       }
       @objc private func sendTapped() {
           NotificationCenter.default.post(name: NSNotification.Name("IMEmojiPanelDidTapSend"), object: nil)
       }

       func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return emojis.count }
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
           cell.label.text = emojis[indexPath.item]
           return cell
       }
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           NotificationCenter.default.post(name: NSNotification.Name("IMEmojiPanelDidSelectEmoji"), object: emojis[indexPath.item])
       }
   }

   class EmojiCell: UICollectionViewCell {
       let label: UILabel = {
           let lbl = UILabel()
           lbl.font = .systemFont(ofSize: 32)
           lbl.textAlignment = .center
           lbl.translatesAutoresizingMaskIntoConstraints = false
           return lbl
       }()
       override init(frame: CGRect) {
           super.init(frame: frame)
           contentView.addSubview(label)
           NSLayoutConstraint.activate([
               label.topAnchor.constraint(equalTo: contentView.topAnchor),
               label.leftAnchor.constraint(equalTo: contentView.leftAnchor),
               label.rightAnchor.constraint(equalTo: contentView.rightAnchor),
               label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
           ])
       }
       required init?(coder: NSCoder) {
           super.init(coder: coder)
           contentView.addSubview(label)
           NSLayoutConstraint.activate([
               label.topAnchor.constraint(equalTo: contentView.topAnchor),
               label.leftAnchor.constraint(equalTo: contentView.leftAnchor),
               label.rightAnchor.constraint(equalTo: contentView.rightAnchor),
               label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
           ])
       }
   }
