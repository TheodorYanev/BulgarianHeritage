//
//  Theme.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 26.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import UIColor_Hex_Swift

protocol Theme {

    //tabBarColors
    var tabBarBackgroundColor: UIColor { get }
    var tabBarTintColor: UIColor { get }

    //navigationBarColors
    var navigationBarBackgroundColor: UIColor { get }
    var navigationBarTintColor: UIColor { get }
    var navigationBarTitleColor: UIColor { get }

    //mainButtonColors
    var mainButtonTextColor: UIColor { get }
    var mainButtonBackgroundColor: UIColor { get }
    var mainButtonDisabledTextColor: UIColor { get }
    var mainButtonDisabledBackgroundColor: UIColor { get }

    //LabelColor
    var hintLabelColor: UIColor { get }
    var mainLabelColor: UIColor { get }

    //textFieldColors
    var errorColor: UIColor { get }
    var errorTextColor: UIColor { get }

    var selectedTitleColor: UIColor { get }
    var selectedLineColor: UIColor { get }
    
    var titleColor: UIColor { get }
    var lineColor: UIColor { get }
    var textColor: UIColor { get }
    
    var placeHolderTextColor: UIColor { get }

    //logOutButtonColors
    var logOutButtonTintColor: UIColor { get }
    var logoutButtonBorderColor: UIColor { get }
    var logoutButtonTitleShadowColor: UIColor { get }

    //tableViewColors
    var tableViewBackgroundColor: UIColor { get }
    var tableViewCellTextColor: UIColor { get }
    var tableViewCellTextShadowColor: UIColor { get }
    var tableViewCellBackgroundColor: UIColor { get }
    var tableViewCellButtonBackgroundColor: UIColor { get }

    
    //viewColor
    var mainViewBackgroundColor: UIColor { get }
    
    //footerViewColor
    var footerViewbackgroundColor: UIColor { get }
    var footerViewLineColor: UIColor { get }
    var footerViewButtonTintColor: UIColor { get }
    var footerViewTextColor: UIColor { get }
}

struct StandardTheme: Theme {

    //tabBarColors
    var tabBarBackgroundColor = UIColor.white
    var tabBarTintColor = UIColor.red

    //navigationBarColors
    var navigationBarBackgroundColor = UIColor.white
    var navigationBarTintColor = UIColor.red
    var navigationBarTitleColor = UIColor.red

    //mainButtonColors
    var mainButtonTextColor = UIColor.white
    var mainButtonBackgroundColor = UIColor("#29493a")
    var mainButtonDisabledTextColor = UIColor.white.withAlphaComponent(0.8)
    var mainButtonDisabledBackgroundColor = UIColor("#29493a").withAlphaComponent(0.8)

    //LabelColor
    var hintLabelColor = UIColor("#29493a").withAlphaComponent(0.6)
    var mainLabelColor = UIColor("#29493a")

    //textFieldColors
    var errorColor = UIColor.red
    var errorTextColor = UIColor.red

    var selectedTitleColor = UIColor("#29493a")
    var selectedLineColor = UIColor("#29493a")
    
    var titleColor = UIColor("#29493a").withAlphaComponent(0.8)
    var lineColor = UIColor("#29493a").withAlphaComponent(0.8)
    var textColor = UIColor("#29493a")
    
    var placeHolderTextColor = UIColor("#29493a").withAlphaComponent(0.6)

    //logOutButtonColors
    var logOutButtonTintColor = UIColor.white
    var logoutButtonBorderColor = UIColor.white
    var logoutButtonTitleShadowColor = UIColor.black

    //tableViewColors
    var tableViewBackgroundColor = UIColor.clear
    var tableViewCellTextColor = UIColor.white
    var tableViewCellTextShadowColor = UIColor.black
    var tableViewCellBackgroundColor = UIColor.clear
    var tableViewCellButtonBackgroundColor = UIColor("#29493a")

    //viewColor
    var mainViewBackgroundColor = UIColor.white
    
    //footerViewColor
    var footerViewbackgroundColor = UIColor.white
    var footerViewLineColor = UIColor.lightGray
    var footerViewButtonTintColor = UIColor.red
    var footerViewTextColor = UIColor.red
}
