//
//  PinCodeInputView.swift
//  PinCodeInputView
//
//  Created by Jinsei Shima on 2018/11/06.
//  Copyright © 2018 Jinsei Shima. All rights reserved.
//

import UIKit

public class PinCodeInputView: UIControl, UITextInputTraits, UIKeyInput {
    
    // MARK: - Properties
    
    private(set) public var text: String = "" {
        didSet {
            if let handler = changeTextHandler {
                handler(text)
            }
            updateText()
        }
    }
    
    public var isEmpty: Bool {
        return text.isEmpty
    }
    
    public var isFilled: Bool {
        return text.count == digit
    }
    
    private let digit: Int
    private var changeTextHandler: ((String) -> ())? = nil
    private let items: [ItemType & UIView]
    private let stackView: UIStackView = .init()
    
    // MARK: - Initializers
    
//    public init(_items: [ItemType & UIView]) {
//
//        self.digit = _items.count
//        self.items = _items
//
//        super.init(frame: .zero)
//
//        items.enumerated().forEach { (index, item) in
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
//            item.addGestureRecognizer(tapGesture)
//            stackView.addArrangedSubview(item)
//        }
//        stackView.axis = .horizontal
//        stackView.distribution = .fillEqually
//    }
    
    public init(digit: Int) {
        
        self.digit = digit
        self.items = (0..<digit).map { _ in ItemView() }
        
        super.init(frame: .zero)
        
        addSubview(stackView)
        
        items.enumerated().forEach { (index, item) in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
            item.addGestureRecognizer(tapGesture)
            stackView.addArrangedSubview(item)
        }
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions

    override public func layoutSubviews() {
        super.layoutSubviews()
        stackView.frame = bounds
    }
    
    override public var intrinsicContentSize: CGSize {
        return self.bounds.size
    }

    public func set(text: String) {
        if text.isPinCode(digit: digit) {
            self.text = text
        }
    }

    public func set(changeTextHandler: @escaping (String) -> ()) {
        self.changeTextHandler = changeTextHandler
    }
        
    public func set(appearance: Appearance) {
        items.forEach { $0.set(appearance: appearance) }
        stackView.spacing = appearance.spacing
    }
    
    @objc
    private func didTap() {
        updateCursor()
        becomeFirstResponder()
    }
    
    private func updateText() {
        
        items.enumerated().forEach { (index, item) in
            if (0..<text.count).contains(index) {
                let _index = text.index(text.startIndex, offsetBy: index)
                item.text = text[_index]
            } else {
                item.text = nil
            }
        }
        updateCursor()
    }
    
    private func updateCursor() {
        
        let cursorPosition = text.count
        items.enumerated().forEach { (index, item) in
            item.isHiddenCursor = (index == cursorPosition) ? false : true
        }
    }
    
    private func hiddenCursor() {
        
        items.forEach { $0.isHiddenCursor = true }
    }
    
    // MARK: - UIKeyInput
    
    public var hasText: Bool {
        return !(text.isEmpty)
    }
    
    public func insertText(_ textToInsert: String) {
        if isEnabled && text.count + textToInsert.count <= digit && textToInsert.isOnlyNumeric() {
            text.append(textToInsert)
            sendActions(for: .editingChanged)
        }
    }
    
    public func deleteBackward() {
        if isEnabled && !text.isEmpty {
            text.removeLast()
            sendActions(for: .editingChanged)
        }
    }
    
    // MARK: - UITextInputTraits
    
    public var autocapitalizationType = UITextAutocapitalizationType.none
    public var autocorrectionType = UITextAutocorrectionType.no
    public var spellCheckingType = UITextSpellCheckingType.no
    public var keyboardType = UIKeyboardType.numberPad
    public var keyboardAppearance = UIKeyboardAppearance.default
    public var returnKeyType = UIReturnKeyType.done
    public var enablesReturnKeyAutomatically = true
    
    // MARK: - UIResponder
    
    override public var canBecomeFirstResponder: Bool {
        return true
    }

    @discardableResult
    override public func resignFirstResponder() -> Bool {
        hiddenCursor()
        return super.resignFirstResponder()
    }
    
}

public struct Appearance {
    
    // struct ItemAppearance
    
    public let font: UIFont
    public let textColor: UIColor
    public let backgroundColor: UIColor
    public let cursorColor: UIColor
    public let cornerRadius: CGFloat
    
    // general appearance
    
    public let spacing: CGFloat
    
    public init(
        font: UIFont,
        textColor: UIColor,
        backgroundColor: UIColor,
        cursorColor: UIColor,
        cornerRadius: CGFloat,
        spacing: CGFloat
        ) {
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.cursorColor = cursorColor
        self.cornerRadius = cornerRadius
        self.spacing = spacing
    }
}

public protocol ItemType: class {
    var text: Character? { get set }
    var isHiddenCursor: Bool { get set }
    var label: UILabel { get }
    var cursor: UIView { get }
    func set(appearance: Appearance)
}

public class ItemView: UIView, ItemType {
    
    public var text: Character? = nil {
        didSet {
            guard let text = text else {
                label.text = nil
                return
            }
            label.text = String(text)
        }
    }
    
    public var isHiddenCursor: Bool = true {
        didSet {
            cursor.isHidden = isHiddenCursor
        }
    }
    
    public let label: UILabel = .init()
    public let cursor: UIView = .init()
    
    init() {
        
        super.init(frame: .zero)
        
        addSubview(label)
        addSubview(cursor)
        
        clipsToBounds = true
        
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        
        cursor.isHidden = true
        
        UIView.animateKeyframes(
            withDuration: 1.6,
            delay: 0.8,
            options: [.repeat],
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.2,
                    animations: {
                        self.cursor.alpha = 0
                })
                UIView.addKeyframe(
                    withRelativeStartTime: 0.8,
                    relativeDuration: 0.2,
                    animations: {
                        self.cursor.alpha = 1
                })
        },
            completion: nil
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = bounds
        
        let width: CGFloat = 2
        let height: CGFloat = bounds.height * 0.6
        
        cursor.frame = CGRect(
            x: (bounds.width - width) / 2,
            y: (bounds.height - height) / 2,
            width: width,
            height: height
        )
    }
    
    public func set(appearance: Appearance) {
        label.font = appearance.font
        label.textColor = appearance.textColor
        cursor.backgroundColor = appearance.cursorColor
        backgroundColor = appearance.backgroundColor
        layer.cornerRadius = appearance.cornerRadius
    }
}
