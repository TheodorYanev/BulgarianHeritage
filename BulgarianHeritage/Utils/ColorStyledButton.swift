//
//  ColorStyledButton.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 26.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit

class ColorStyledButton: UIButton {
    private var backgroundColors = [UIControl.State.RawValue: UIColor] ()

    override var isEnabled: Bool {
        didSet {
            let color = backgroundColors[state.rawValue] ?? backgroundColors[UIControl.State.normal.rawValue]
            backgroundColor = color
        }
    }

    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        backgroundColors[state.rawValue] = color
        let color = backgroundColors[self.state.rawValue] ?? backgroundColors[UIControl.State.normal.rawValue]
        backgroundColor = color
    }

}

extension ColorStyledButton {
    func applyMainButtonStyle(theme: Theme) {
        setBackgroundColor(theme.mainButtonBackgroundColor, for: .normal)
        setBackgroundColor(theme.mainButtonDisabledBackgroundColor, for: .disabled)
        setTitleColor(theme.mainButtonTextColor, for: .normal)
        setTitleColor(theme.mainButtonDisabledTextColor, for: .disabled)
    }
}
