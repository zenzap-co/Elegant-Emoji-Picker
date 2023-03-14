//
//  CategoriesToolbar.swift
//  Demo
//
//  Created by Grant Oganyan on 3/10/23.
//

import Foundation
import UIKit

class CategoriesToolbar: UIView {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    let emojiPicker: ElegantEmojiPicker
    let padding = 8.0
    
    let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    let selectionBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    
    var selectionConstraint: NSLayoutConstraint?
    
    var categoryButtons = [CategoryButton]()
    
    init (emojiCategories: [EmojiCategory], emojiPicker: ElegantEmojiPicker) {
        self.emojiPicker = emojiPicker
        super.init(frame: .zero)
        
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.PopupShadow()
        
        blur.clipsToBounds = true
        self.addSubview(blur, anchors: LayoutAnchor.fullFrame)
        
        selectionBlur.clipsToBounds = true
        selectionBlur.backgroundColor = .label.withAlphaComponent(0.3)
        self.addSubview(selectionBlur, anchors: [.centerY(0)])
        
        selectionConstraint = selectionBlur.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        selectionConstraint?.isActive = true
        
        for category in emojiCategories {
            let button = CategoryButton(category, emojiPicker: emojiPicker)
            
            let prevButton: UIView? = categoryButtons.last
            
            self.addSubview(button, anchors: [.top(padding), .bottom(padding)])
            categoryButtons.append(button)

            button.leadingAnchor.constraint(equalTo: prevButton?.trailingAnchor ?? self.leadingAnchor, constant: prevButton != nil ? 0 : padding).isActive = true
            if let prevButton = prevButton { button.widthAnchor.constraint(equalTo: prevButton.widthAnchor).isActive = true }
        }
        
        if let lastButton = self.subviews.last {
            lastButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding).isActive = true
            
            selectionBlur.widthAnchor.constraint(equalTo: lastButton.widthAnchor).isActive = true
            selectionBlur.heightAnchor.constraint(equalTo: lastButton.heightAnchor).isActive = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blur.layer.cornerRadius = blur.frame.height*0.5
        selectionBlur.layer.cornerRadius = selectionBlur.frame.height*0.5
        
        UpdateCorrectSelection(animated: false)
    }
    
    func UpdateCorrectSelection (animated: Bool = true) {
        if !emojiPicker.isSearching { self.alpha = emojiPicker.config.categories.count <= 1 ? 0 : 1 }
        
        let posX = (categoryButtons.first(where: { $0.category == emojiPicker.focusedCategory })?.frame.origin.x)
        let safePos: CGFloat = posX ?? padding
        
        if animated {
            selectionConstraint?.constant = safePos
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
            return
        }
        
        selectionConstraint?.constant = safePos
    }
    
    class CategoryButton: UIView {
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        let imageView = UIImageView()
        
        let category: EmojiCategory
        let emojiPicker: ElegantEmojiPicker
        
        init (_ category: EmojiCategory, emojiPicker: ElegantEmojiPicker) {
            self.category = category
            self.emojiPicker = emojiPicker
            super.init(frame: .zero)
            
            self.heightAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            
            imageView.image = category.image
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemGray
            self.addSubview(imageView, anchors: LayoutAnchor.fullFrame(8))
            
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Tap)))
        }
        
        @objc func Tap () {
            emojiPicker.didSelectCategory(category)
        }
    }
}