//
//  UIColor+PhotoPicker.swift
//  UnsplashPhotoPicker
//
//  Created by Olivier Collet on 2019-10-07.
//  Copyright © 2019 Unsplash. All rights reserved.
//

struct PhotoPickerColors {
    var background: NativeColor {
#if os(macOS)
        return .white
#else
        if #available(iOS 13.0, *) { return .systemBackground }
        return .white
#endif
    }
    var titleLabel: NativeColor {
#if os(macOS)
        return .labelColor
#else
        if #available(iOS 13.0, *) { return .label }
        return .black
#endif
    }
    var subtitleLabel: NativeColor {
#if os(macOS)
        return .secondaryLabelColor
#else
        if #available(iOS 13.0, *) { return .secondaryLabel }
        return .gray
#endif
    }
}

extension NativeColor {
    static let photoPicker = PhotoPickerColors()
}
