//
//  Miscellanous.swift
//  Wots4T
//
//  Created by Marc Shearer on 02/03/2021.
//

import SwiftUI

struct AboutWots4TView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        ZStack {
            Palette.background.background
                .ignoresSafeArea()
            HStack {
                VStack {
                    Spacer()
                    Image("AppIcon")
                    Spacer()
                }
                VStack {
                    Spacer().frame(height: 20)
                    Text("Wots4T").font(.largeTitle)
                    Text("Version \(Version.current.version) (\(Version.current.build))")
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
