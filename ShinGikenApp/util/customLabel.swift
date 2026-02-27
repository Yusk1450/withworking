//
//  customLabel.swift
//  ShinGikenApp
//
//  Created by ichinose-PC on 2026/02/27.
//

import UIKit

class CustomLabel: UILabel {

    var textInsets = UIEdgeInsets(top: 4, left: 7, bottom: 4, right: 7)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        return CGSize(
            width: superSize.width + textInsets.left + textInsets.right,
            height: superSize.height + textInsets.top + textInsets.bottom
        )
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSize = super.sizeThatFits(size)
        return CGSize(
            width: superSize.width + textInsets.left + textInsets.right,
            height: superSize.height + textInsets.top + textInsets.bottom
        )
    }
}
