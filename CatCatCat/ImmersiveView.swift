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
    @State var contentsModel: ContentsModel = ContentsModel()
    
    var body: some View {
        RealityView { content in
            contentsModel.registerContent(content: content)
            
            for catNameTexture in catNameTextureList {
                await contentsModel.showCat(catName: catNameTexture.key)
            }
        }
        .onDisappear {
            contentsModel.close()
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
    ImmersiveView()
}
