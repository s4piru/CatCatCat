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
    @State var toggleUpdate: Bool = false
    @Environment(PlaneDetectionModel.self) var model
    
    var body: some View {
        RealityView { content in
            isImmersiveSpaceShown = true
            contentsModel.registerContent(content: content)
            content.add(model.setupContentEntity())
            for catNameTexture in catNameTextureList {
                await contentsModel.showCat(catName: catNameTexture.key)
            }
            subscriptions = contentsModel.getSubscriptions()
        }
        /*
        .task {
            await model.runSession()
        }
        .task {
            await model.processPlaneDetectionUpdates()
        }
        .task {
            await model.monitorSessionEvents()
        }*/

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
