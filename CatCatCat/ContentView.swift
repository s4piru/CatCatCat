//
//  ContentView.swift
//  CatCatCat
//
//  Created by Saki Okubo on 4/16/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var showImmersiveSpace = false
    
    @State private var isBlackEnabled = false
    @State private var isGreyEnabled = false
    @State private var isOrangeEnabled = false
    @State private var isTigerEnabled = false
    @State private var isWhiteBlackEnabled = false
    
    @State private var blackName: String = "Black"
    @State private var greyName: String = "Grey"
    @State private var orangeName: String = "Orange"
    @State private var tigerName: String = "Tiger"
    @State private var whiteBlackName: String = "White Black"

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State private var r:Double = 0

    var body: some View {
        VStack {
            Text("Name your cats and choose ones you want to call!")
                .font(.largeTitle)
                .bold()
                .fontDesign(.monospaced)
                .padding(EdgeInsets(
                    top: 10,
                    leading: 0,
                    bottom: 30,
                    trailing: 0
                ))
            HStack {
                Model3D(named: "black_sample") { model in
                    model
                        .resizable()
                        .scaledToFit()
                        .rotation3DEffect(.degrees(r), axis: (x: 0.0, y: 1.0, z: 0.0))
                        .onReceive(timer) { _ in
                                       self.r+=0.2
                               }
                } placeholder: {
                    ProgressView()
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 50
                ))
                .frame(alignment: .center)
                
                TextField("Black",text: $blackName)
                    .font(.title)
                    .fontDesign(.monospaced)
                    .frame(width: 300, alignment: .center)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 30
                    ))
                Toggle("", isOn: $isBlackEnabled)
                    .frame(width: 10, alignment: .center)
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0
                    ))
            }.padding(EdgeInsets(
                top: 10,
                leading: 0,
                bottom: 10,
                trailing: 0
            ))
                
            HStack {
                Model3D(named: "grey_sample") { model in
                    model
                        .resizable()
                        .scaledToFit()
                        .rotation3DEffect(.degrees(r), axis: (x: 0.0, y: 1.0, z: 0.0))
                } placeholder: {
                    ProgressView()
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 50
                ))
                TextField("Grey",text: $greyName)
                    .font(.title)
                    .fontDesign(.monospaced)
                    .frame(width: 300, alignment: .center)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 30
                    ))
                Toggle("", isOn: $isGreyEnabled)
                    .frame(width: 10, alignment: .center)
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0
                    ))
            }.padding(EdgeInsets(
                top: 10,
                leading: 0,
                bottom: 10,
                trailing: 0
            ))
                
            HStack {
                Model3D(named: "orange_sample") { model in
                    model
                        .resizable()
                        .scaledToFit()
                        .rotation3DEffect(.degrees(r), axis: (x: 0.0, y: 1.0, z: 0.0))
                } placeholder: {
                    ProgressView()
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 50
                ))
                .frame(alignment: .center)
                
                TextField("Orange",text: $orangeName)
                    .font(.title)
                    .fontDesign(.monospaced)
                    .frame(width: 300, alignment: .center)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 30
                    ))
                Toggle("", isOn: $isOrangeEnabled)
                    .frame(width: 10, alignment: .center)
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0
                    ))
            }.padding(EdgeInsets(
                top: 10,
                leading: 0,
                bottom: 10,
                trailing: 0
            ))
                
            HStack {
                Model3D(named: "tiger_sample") { model in
                    model
                        .resizable()
                        .scaledToFit()
                        .rotation3DEffect(.degrees(r), axis: (x: 0.0, y: 1.0, z: 0.0))
                } placeholder: {
                    ProgressView()
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 50
                ))
                .frame(alignment: .center)
                
                TextField("Tiger",text: $tigerName)
                    .font(.title)
                    .fontDesign(.monospaced)
                    .frame(width: 300, alignment: .center)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 30
                    ))
                Toggle("", isOn: $isTigerEnabled)
                    .frame(width: 10, alignment: .center)
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0
                    ))
            }.padding(EdgeInsets(
                top: 10,
                leading: 0,
                bottom: 10,
                trailing: 0
            ))
                
            HStack {
                Model3D(named: "white_black_sample") { model in
                    model
                        .resizable()
                        .scaledToFit()
                        .rotation3DEffect(.degrees(r), axis: (x: 0.0, y: 1.0, z: 0.0))
                } placeholder: {
                    ProgressView()
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 50
                ))
                .frame(alignment: .center)
                
                TextField("White Black",text: $whiteBlackName)
                    .font(.title)
                    .fontDesign(.monospaced)
                    .frame(width: 300, alignment: .center)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 30
                    ))
                Toggle("", isOn: $isWhiteBlackEnabled)
                    .frame(width: 10, alignment: .center)
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0
                    ))
            }.padding(EdgeInsets(
                top: 10,
                leading: 0,
                bottom: 10,
                trailing: 0
            ))
        }
        .padding(EdgeInsets(
            top: 10,
            leading: 0,
            bottom: 50,
            trailing: 0
        ))
        .onAppear {
            Task{
                await openImmersiveSpace(id: "ImmersiveSpace")
            }
        }
        /*.onChange(of: isBlackEnabled) { _, newValue in
            immersiveView.contentsModel.updateCharacterEnable(catName: "Black", isEnabled: newValue)
        }
        .onChange(of: isGreyEnabled) { _, newValue in
            immersiveView.contentsModel.updateCharacterEnable(catName: "Grey", isEnabled: newValue)
        }
        .onChange(of: isOrangeEnabled) { _, newValue in
            immersiveView.contentsModel.updateCharacterEnable(catName: "Orange", isEnabled: newValue)
        }
        .onChange(of: isTigerEnabled) { _, newValue in
            immersiveView.contentsModel.updateCharacterEnable(catName: "Tiger", isEnabled: newValue)
        }
        .onChange(of: isWhiteBlackEnabled) { _, newValue in
            immersiveView.contentsModel.updateCharacterEnable(catName: "WhiteBlack", isEnabled: newValue)
        }*/
    }
}

#Preview(windowStyle: .automatic) {
    //ContentView(immersiveView: ImmersiveView(contentsModel: ContentsModel()))
}
