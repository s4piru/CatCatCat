//
//  CatCatCatApp.swift
//  CatCatCat
//
//  Created by Saki Okubo on 4/16/24.
//

import SwiftUI

@main
@MainActor
struct CatCatCatApp: App {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    
    @State private var isImmersiveSpaceShown: Bool = false
    @State private var immersionStyle: ImmersionStyle = .mixed
    @State private var showImmersiveSpaceFromButton = false
    
    @State private var isBlackEnabled = false
    @State private var isGreyEnabled = false
    @State private var isOrangeEnabled = false
    @State private var isTigerEnabled = false
    @State private var isWhiteBlackEnabled = false
    @State private var availableCatNum: Int = 3
    private var contentsModel = ContentsModel()
    
    var body: some Scene {
        WindowGroup(id: "FirstWindow") {
            ContentView(isImmersiveSpaceShown: $isImmersiveSpaceShown, showImmersiveSpaceFromButton: $showImmersiveSpaceFromButton, isBlackEnabled: $isBlackEnabled, isGreyEnabled: $isGreyEnabled, isOrangeEnabled: $isOrangeEnabled, isTigerEnabled: $isTigerEnabled, isWhiteBlackEnabled: $isWhiteBlackEnabled, availableCatNum: $availableCatNum)
                .onAppear() {
                    Task {
                        await openImmersiveSpace(id: "ImmersiveSpace")
                    }
                }
                .onChange(of: showImmersiveSpaceFromButton) { _, newValue in
                    if newValue {
                        Task {
                            await openImmersiveSpace(id: "ImmersiveSpace")
                            showImmersiveSpaceFromButton = false
                        }
                    }
                }
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(contentsModel: contentsModel, isImmersiveSpaceShown: $isImmersiveSpaceShown, isBlackEnabled: $isBlackEnabled, isGreyEnabled: $isGreyEnabled, isOrangeEnabled: $isOrangeEnabled, isTigerEnabled: $isTigerEnabled, isWhiteBlackEnabled: $isWhiteBlackEnabled, availableCatNum: $availableCatNum)
        }
    }
}
