//
//  BlurView.swift
//  Billboardoo
//
//  Created by yongbeomkwak on 2022/09/14.
//

import SwiftUI

struct BlurView: UIViewRepresentable {

    func makeUIView(context: Context) -> some UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))

        return view
    }

    func  updateUIView(_ uiView: UIViewType, context: Context) {

    }

}
