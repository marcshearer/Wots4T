//
//  Themes.swift
//  Contract Whist Scorecard
//
//  Created by Marc Shearer on 28/05/2020.
//  Copyright © 2020 Marc Shearer. All rights reserved.
//

import SwiftUI

enum ThemeAppearance: Int {
    case light = 1
    case dark = 2
    case device = 3
    
    public var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        default:
            return .unspecified
        }
    }
}

enum ThemeName: String, CaseIterable {
    case standard = "Default"
    case alternate = "Alternate"
    case red = "Red"
    case blue = "Blue"
    case green = "Green"
    
    public var description: String {
        switch self {
        case .standard:
            return "Default"
        case .alternate:
            return "Alternate"
        case .red:
            return "Red"
        case .blue:
            return "Blue"
        case .green:
            return "Green"
        }
    }
}

enum ThemeTextType: CaseIterable {
    case normal
    case contrast
    case strong
    case faint
    case theme
}

enum ThemeBackgroundColorName: CaseIterable {
    case banner
    case bannerButton
    case destructiveButton
    case background
    case alternate
    case tile
    case divider
    case separator
    case listButton
    case menuEntry
    case imagePlaceholder
    case disabledButton
    case enabledButton
    case input
}

enum ThemeTextColorSetName: CaseIterable {
    case darkBackground
    case midBackground
    case lightBackground
}

enum ThemeSpecificColorName: CaseIterable {
    case bannerBackButton
    case bannerMenuButton
}

class Theme {
    private var themeName: ThemeName
    private var textColorConfig: [ThemeTextColorSetName: ThemeTextColor] = [:]
    private var backgroundColor: [ThemeBackgroundColorName : UIColor] = [:]
    private var textColor: [ThemeBackgroundColorName : UIColor] = [:]
    private var contrastTextColor: [ThemeBackgroundColorName : UIColor] = [:]
    private var strongTextColor: [ThemeBackgroundColorName : UIColor] = [:]
    private var faintTextColor: [ThemeBackgroundColorName : UIColor] = [:]
    private var themeTextColor: [ThemeBackgroundColorName : UIColor] = [:]
    private var specificColor: [ThemeSpecificColorName : UIColor] = [:]
    private var _icon: String?
    public var icon: String? { self._icon }
    
    init(themeName: ThemeName) {
        self.themeName = themeName
        if let config = Themes.themes[themeName] {
            self._icon = config.icon
            self.defaultTheme(from: config, all: true)
            
            if let basedOn = config.basedOn,
                let basedOnTheme = Themes.themes[basedOn] {
                self.defaultTheme(from: basedOnTheme)
            }
            if config.basedOn != .standard && themeName != .standard {
                if let defaultTheme = Themes.themes[.standard] {
                    self.defaultTheme(from: defaultTheme)
                }
            }
        }
    }
    
    public func background(_ backgroundColorName: ThemeBackgroundColorName) -> UIColor {
        return self.backgroundColor[backgroundColorName] ?? UIColor.clear
    }
    
    public func text(_ backgroundColorName: ThemeBackgroundColorName, textType: ThemeTextType = .normal) -> UIColor {
        switch textType {
        case .contrast:
            return self.contrastText(backgroundColorName)
        case .strong:
            return self.strongText(backgroundColorName)
        case .faint:
            return self.faintText(backgroundColorName)
        case .theme:
            return self.themeText(backgroundColorName)
        default:
            return self.textColor[backgroundColorName] ?? UIColor.clear
        }
    }
    
    public func contrastText(_ backgroundColorName: ThemeBackgroundColorName) -> UIColor {
        return self.contrastTextColor[backgroundColorName] ?? UIColor.clear
    }
    
    public func strongText(_ backgroundColorName: ThemeBackgroundColorName) -> UIColor {
        return self.strongTextColor[backgroundColorName] ?? UIColor.clear
    }
    
    public func faintText(_ backgroundColorName: ThemeBackgroundColorName) -> UIColor {
        return self.faintTextColor[backgroundColorName] ?? UIColor.clear
    }
    
    public func themeText(_ backgroundColorName: ThemeBackgroundColorName) -> UIColor {
        return self.themeTextColor[backgroundColorName] ?? UIColor.clear
    }
    
    public func textColor(textColorSetName: ThemeTextColorSetName, textType: ThemeTextType) -> UIColor? {
        return self.textColorConfig[textColorSetName]?.color(textType)?.uiColor
    }
    
    public func specific(_ specificColorName: ThemeSpecificColorName) -> UIColor {
        return self.specificColor[specificColorName] ?? UIColor.black
    }
    
    private func defaultTheme(from: ThemeConfig, all: Bool = false) {
        // Default in any missing text colors
        for (name, themeTextColor) in from.textColor {
            if all || self.textColorConfig[name] == nil {
                self.textColorConfig[name] = themeTextColor
            }
        }
        
        // Iterate background colors filling in detail
        for (name, themeBackgroundColor) in from.backgroundColor {
            var anyTextColorName: ThemeTextColorSetName
            var darkTextColorName: ThemeTextColorSetName
            if all || self.backgroundColor[name] == nil {
                self.backgroundColor[name] = themeBackgroundColor.backgroundColor.uiColor
            }
            anyTextColorName = themeBackgroundColor.anyTextColorName
            darkTextColorName = themeBackgroundColor.darkTextColorName ?? anyTextColorName
            if let anyTextColor = self.textColorConfig[anyTextColorName] {
                let darkTextColor = self.textColorConfig[darkTextColorName]
                if all || self.textColor[name] == nil {
                    self.textColor[name] = self.color(any: anyTextColor, dark: darkTextColor, .normal)
                }
                if all || self.contrastTextColor[name] == nil {
                    self.contrastTextColor[name] = self.color(any: anyTextColor, dark: darkTextColor, .contrast)
                }
                if all || self.strongTextColor[name] == nil {
                    self.strongTextColor[name] = self.color(any: anyTextColor, dark: darkTextColor, .strong)
                }
                if all || self.faintTextColor[name] == nil {
                    self.faintTextColor[name] = self.color(any: anyTextColor, dark: darkTextColor, .faint)
                }
                if all || self.themeTextColor[name] == nil {
                    self.themeTextColor[name] = self.color(any: anyTextColor, dark: darkTextColor, .theme)
                }
            }
        }
        for (name, themeSpecificColor) in from.specificColor {
            if all || self.specificColor[name] == nil {
                self.specificColor[name] = themeSpecificColor.uiColor
            }
        }
    }
    
    private func color(any anyTextColor: ThemeTextColor, dark darkTextColor: ThemeTextColor?, _ textType: ThemeTextType) -> UIColor {
        let anyTraitColor = anyTextColor.color(textType) ?? anyTextColor.normal!
        
        if let darkTraitColor = darkTextColor?.color(textType) {
            let darkColor = darkTraitColor.darkColor ?? darkTraitColor.anyColor
            return self.traitColor(anyTraitColor.anyColor, darkColor)
        } else {
            return anyTraitColor.uiColor
        }
    }

    private func traitColor(_ anyColor: UIColor, _ darkColor: UIColor?) -> UIColor {
        if let darkColor = darkColor {
            return UIColor(dynamicProvider: { (traitCollection) in
                traitCollection.userInterfaceStyle == .dark ? darkColor : anyColor
                
                })
        } else {
            return anyColor
        }
    }
}

class ThemeTraitColor {
    fileprivate let anyColor: UIColor
    fileprivate let darkColor: UIColor?
    
    init(_ anyColor: UIColor, _ darkColor: UIColor? = nil) {
        self.anyColor = anyColor
        self.darkColor = darkColor
    }
    
    public var uiColor: UIColor {
        UIColor(dynamicProvider: { (traitCollection) in
            if traitCollection.userInterfaceStyle == .dark {
                return self.darkColor ?? self.anyColor
            } else {
                return self.anyColor
            }
        })
    }
}

class ThemeColor {
    fileprivate let backgroundColor: ThemeTraitColor
    fileprivate let anyTextColorName: ThemeTextColorSetName
    fileprivate let darkTextColorName: ThemeTextColorSetName?
    
    init(_ anyColor: UIColor, _ darkColor: UIColor? = nil, _ anyTextColorName: ThemeTextColorSetName, _ darkTextColorName: ThemeTextColorSetName? = nil) {
        self.backgroundColor = ThemeTraitColor(anyColor, darkColor)
        self.anyTextColorName = anyTextColorName
        self.darkTextColorName = darkTextColorName
    }
}

class ThemeTextColor {
    fileprivate var normal: ThemeTraitColor?
    fileprivate var contrast: ThemeTraitColor?
    fileprivate var strong: ThemeTraitColor?
    fileprivate var faint: ThemeTraitColor?
    fileprivate var theme: ThemeTraitColor?

    init(normal normalAny: UIColor, _ normalDark: UIColor? = nil, contrast contrastAny: UIColor? = nil, _ contrastDark: UIColor? = nil, strong strongAny: UIColor? = nil, _ strongDark: UIColor? = nil, faint faintAny: UIColor? = nil, _ faintDark: UIColor? = nil, theme themeAny: UIColor? = nil, _ themeDark: UIColor? = nil) {
        self.normal = self.traitColor(normalAny, normalDark)!
        self.contrast = self.traitColor(contrastAny, contrastDark)
        self.strong = self.traitColor(strongAny, strongDark)
        self.faint = self.traitColor(faintAny, faintDark)
        self.theme = self.traitColor(themeAny, themeDark)
    }
    
    fileprivate func color(_ textType: ThemeTextType) -> ThemeTraitColor? {
        switch textType {
        case .normal:
            return self.normal
        case .contrast:
            return self.contrast
        case .strong:
            return self.strong
        case .faint:
            return self.faint
        case .theme:
            return self.theme
        }
    }
    
    private func traitColor(_ anyColor: UIColor?, _ darkColor: UIColor? = nil) -> ThemeTraitColor? {
        if let anyColor = anyColor {
            return ThemeTraitColor(anyColor, darkColor)
        } else {
            return nil
        }
    }
}

class ThemeConfig {
    
    let basedOn: ThemeName?
    let icon: String?
    var backgroundColor: [ThemeBackgroundColorName: ThemeColor]
    var textColor: [ThemeTextColorSetName: ThemeTextColor]
    var specificColor: [ThemeSpecificColorName: ThemeTraitColor]
    
    init(basedOn: ThemeName? = nil, icon: String? = nil, background backgroundColor: [ThemeBackgroundColorName : ThemeColor], text textColor: [ThemeTextColorSetName : ThemeTextColor], specific specificColor: [ThemeSpecificColorName: ThemeTraitColor] = [:]) {
        self.basedOn = basedOn
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.specificColor = specificColor
    }
}


class Themes {

    public static var currentTheme: Theme!
    
    fileprivate static let themes: [ThemeName : ThemeConfig] = [
        .standard : ThemeConfig(
            background: [
                .banner                      : ThemeColor(#colorLiteral(red: 0.999904573, green: 1, blue: 0.9998808503, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), .lightBackground, .darkBackground),
                .bannerButton                : ThemeColor(#colorLiteral(red: 0.0166248735, green: 0.4766505957, blue: 0.9990670085, alpha: 1), nil, .darkBackground),
                .destructiveButton           : ThemeColor(#colorLiteral(red: 0.9981788993, green: 0.2295429707, blue: 0.1891850233, alpha: 1), nil, .darkBackground),
                .background                  : ThemeColor(#colorLiteral(red: 0.999904573, green: 1, blue: 0.9998808503, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), .lightBackground, .darkBackground),
                .alternate                   : ThemeColor(#colorLiteral(red: 0.999904573, green: 1, blue: 0.9998808503, alpha: 1), #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), .lightBackground, .darkBackground),
                .tile                        : ThemeColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1), .lightBackground, .darkBackground),
                .divider                     : ThemeColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.6286649108, green: 0.6231410503, blue: 0.6192827821, alpha: 1), .darkBackground,  .lightBackground),
                .separator                   : ThemeColor(#colorLiteral(red: 0.493078649, green: 0.4981283545, blue: 0.4939036965, alpha: 1), nil, .midBackground),
                .listButton                  : ThemeColor(#colorLiteral(red: 0.5560679436, green: 0.5578243136, blue: 0.5773752928, alpha: 1), nil, .midBackground),
                .menuEntry                   : ThemeColor(#colorLiteral(red: 0.9569241405, green: 0.9567349553, blue: 0.9526277184, alpha: 1), #colorLiteral(red: 0.999904573, green: 1, blue: 0.9998808503, alpha: 1), .darkBackground,  .lightBackground),
                .imagePlaceholder            : ThemeColor(#colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1), #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), .midBackground),
                .disabledButton              : ThemeColor(#colorLiteral(red: 0.6666069031, green: 0.6667050123, blue: 0.6665856242, alpha: 1), nil, .midBackground),
                .enabledButton               : ThemeColor(#colorLiteral(red: 0.5560679436, green: 0.5578243136, blue: 0.5773752928, alpha: 1), nil, .midBackground),
                .input                       : ThemeColor(#colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1), #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), .lightBackground, .darkBackground),
                ],

            text: [
                .lightBackground             : ThemeTextColor(normal: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), contrast: #colorLiteral(red: 0.337254902, green: 0.4509803922, blue: 0.4549019608, alpha: 1), strong: #colorLiteral(red: 0.9981788993, green: 0.2295429707, blue: 0.1891850233, alpha: 1), faint: #colorLiteral(red: 0.6235294118, green: 0.6235294118, blue: 0.6235294118, alpha: 1), theme: #colorLiteral(red: 0.0166248735, green: 0.4766505957, blue: 0.9990670085, alpha: 1)) ,
                .midBackground               : ThemeTextColor(normal: #colorLiteral(red: 0.999904573, green: 1, blue: 0.9998808503, alpha: 1), contrast: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), strong: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), theme: #colorLiteral(red: 0.0166248735, green: 0.4766505957, blue: 0.9990670085, alpha: 1)) ,
                .darkBackground              : ThemeTextColor(normal: #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1), contrast: #colorLiteral(red: 0.6286649108, green: 0.6231410503, blue: 0.6192827821, alpha: 1), strong: #colorLiteral(red: 0.9981788993, green: 0.2295429707, blue: 0.1891850233, alpha: 1), faint: #colorLiteral(red: 0.4705882353, green: 0.4705882353, blue: 0.4705882353, alpha: 1), theme: #colorLiteral(red: 0.0166248735, green: 0.4766505957, blue: 0.9990670085, alpha: 1))] ,
            specific: [
                .bannerBackButton            : ThemeTraitColor(#colorLiteral(red: 0.0166248735, green: 0.4766505957, blue: 0.9990670085, alpha: 1), #colorLiteral(red: 0.0166248735, green: 0.4766505957, blue: 0.9990670085, alpha: 1)),
                .bannerMenuButton            : ThemeTraitColor(#colorLiteral(red: 0.07842033356, green: 0.07843840867, blue: 0.07841635495, alpha: 1), #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)),
                ]
            )
    ]
    
    public static func selectTheme(_ themeName: ThemeName, changeIcon: Bool = false) {
        let oldIcon = Themes.currentTheme?.icon
        Themes.currentTheme = Theme(themeName: themeName)
        let newIcon = Themes.currentTheme.icon
        if UIApplication.shared.supportsAlternateIcons && changeIcon && oldIcon != newIcon {
            Themes.setApplicationIconName(Themes.currentTheme.icon)
        }
    }
    
    private static func setApplicationIconName(_ iconName: String?) {
        if UIApplication.shared.responds(to: #selector(getter: UIApplication.supportsAlternateIcons)) && UIApplication.shared.supportsAlternateIcons {
            
            typealias setAlternateIconName = @convention(c) (NSObject, Selector, NSString?, @escaping (NSError) -> ()) -> ()
            
            let selectorString = "_setAlternateIconName:completionHandler:"
            
            let selector = NSSelectorFromString(selectorString)
            let imp = UIApplication.shared.method(for: selector)
            let method = unsafeBitCast(imp, to: setAlternateIconName.self)
            method(UIApplication.shared, selector, iconName as NSString?, { _ in })
        }
    }
}
