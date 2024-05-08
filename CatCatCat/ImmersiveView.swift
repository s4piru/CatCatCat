//
//  ImmersiveView.swift
//  CatCatCat
//
//  Created by Saki Okubo on 4/16/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State var contentsModel: ContentsModel
    @State var subscriptions: [EventSubscription] = []
    @Binding var isImmersiveSpaceShown: Bool
    @Binding var isBlackEnabled: Bool
    @Binding var isGreyEnabled: Bool
    @Binding var isOrangeEnabled: Bool
    @Binding var isTigerEnabled: Bool
    @Binding var isWhiteBlackEnabled: Bool
    @Binding var availableCatNum: Int
    @State var toggleUpdate: Bool = false
    @StateObject var physicsModel: VisionPhysicsViewModel  = VisionPhysicsViewModel()
    
    var body: some View {
        RealityView { content in
            content.add(physicsModel.setupContentEntity())
            contentsModel.registerContent(content: content)
            physicsModel.setUpMatrix()
        }
        .task {
            try? await Task.sleep(for: .seconds(10))
            let planeMatrix = physicsModel.getPlaneMatrix()
            self.availableCatNum = contentsModel.getNumCat(planeMatrix: planeMatrix)
            for catNameTexture in catNameTextureList {
                await contentsModel.showCat(catName: catNameTexture.key)
            }
            subscriptions = contentsModel.getSubscriptions()
        }
        .task {
            await physicsModel.runSession()
            await physicsModel.processReconstructionUpdates()
        }
        .onAppear {
            isImmersiveSpaceShown = true
            self.availableCatNum = -1
        }
        .onDisappear {
            contentsModel.closeImmersiveView()
            isImmersiveSpaceShown = false
        }
        .onChange(of: isBlackEnabled) { _, newValue in
            contentsModel.updateCharacterEnable(catName: "Black", isEnabled: newValue)
            self.toggleUpdate = !toggleUpdate
        }
        .onChange(of: isGreyEnabled) { _, newValue in
            contentsModel.updateCharacterEnable(catName: "Grey", isEnabled: newValue)
            self.toggleUpdate = !toggleUpdate
        }
        .onChange(of: isOrangeEnabled) { _, newValue in
            contentsModel.updateCharacterEnable(catName: "Orange", isEnabled: newValue)
            self.toggleUpdate = !toggleUpdate
        }
        .onChange(of: isTigerEnabled) { _, newValue in
            contentsModel.updateCharacterEnable(catName: "Tiger", isEnabled: newValue)
            self.toggleUpdate = !toggleUpdate
        }
        .onChange(of: isWhiteBlackEnabled) { _, newValue in
            contentsModel.updateCharacterEnable(catName: "White_Black", isEnabled: newValue)
            self.toggleUpdate = !toggleUpdate
        }
        .gesture(
           SpatialTapGesture()
               .targetedToAnyEntity()
               .onEnded { value in
                   contentsModel.handleTouchedAnimation(entity: value.entity)
               }
       )
    }
}

#Preview(immersionStyle: .mixed) {
    //ImmersiveView()
}
