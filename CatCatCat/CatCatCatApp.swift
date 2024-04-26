//
//  CatCatCatApp.swift
//  CatCatCat
//
//  Created by Saki Okubo on 4/16/24.
//

import SwiftUI

@main
struct CatCatCatApp: App {
    private var immersiveView: ImmersiveView = ImmersiveView(contentsModel: ContentsModel())
    var body: some Scene {
        WindowGroup {
            ContentView(immersiveView: immersiveView)
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            immersiveView
        }
    }
}
