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
    @Binding var isImmersiveSpaceShown: Bool
    @Binding var showImmersiveSpaceFromButton: Bool
    
    @Binding var isBlackEnabled: Bool
    @Binding var isGreyEnabled: Bool
    @Binding var isOrangeEnabled: Bool
    @Binding var isTigerEnabled: Bool
    @Binding var isWhiteBlackEnabled: Bool
    
    @State private var blackName: String = "Black"
    @State private var greyName: String = "Grey"
    @State private var orangeName: String = "Orange"
    @State private var tigerName: String = "Tiger"
    @State private var whiteBlackName: String = "White Black"
    @State var enabledCount: Int = 0
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State private var r:Double = 0

    var body: some View {
        VStack {
            Text("Name your cats and choose ones you want to invite! (up to 3 cats)")
                .font(.system(size: 30))
                .bold()
                .fontDesign(.monospaced)
                .padding(EdgeInsets(
                    top: 30,
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
                    .disabled(enabledCount >= 3 && !isBlackEnabled)
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
                    .disabled(enabledCount >= 3 && !isGreyEnabled)
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
                    .disabled(enabledCount >= 3 && !isOrangeEnabled)
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
                    .disabled(enabledCount >= 3 && !isTigerEnabled)
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
                    .disabled(enabledCount >= 3 && !isWhiteBlackEnabled)
            }.padding(EdgeInsets(
                top: 10,
                leading: 0,
                bottom: 10,
                trailing: 0
            ))
            
            if !isImmersiveSpaceShown {
                Button("Invite your cats!") {
                    showImmersiveSpaceFromButton = true
                }
                .font(.title)
                .fontDesign(.monospaced)
                .padding(EdgeInsets(
                    top: 20,
                    leading: 0,
                    bottom: 10,
                    trailing: 0
                ))
            }
        }
        .padding(EdgeInsets(
            top: 10,
            leading: 0,
            bottom: 50,
            trailing: 0
        ))
        .onChange(of: isBlackEnabled) { _, newValue in
            enabledCount = newValue ? enabledCount + 1 : enabledCount - 1
        }
        .onChange(of: isGreyEnabled) { _, newValue in
            enabledCount = newValue ? enabledCount + 1 : enabledCount - 1
        }
        .onChange(of: isOrangeEnabled) { _, newValue in
            enabledCount = newValue ? enabledCount + 1 : enabledCount - 1
        }
        .onChange(of: isTigerEnabled) { _, newValue in
            enabledCount = newValue ? enabledCount + 1 : enabledCount - 1
        }
        .onChange(of: isWhiteBlackEnabled) { _, newValue in
            enabledCount = newValue ? enabledCount + 1 : enabledCount - 1
        }
    }
}

#Preview(windowStyle: .automatic) {
    //ContentView(immersiveView: ImmersiveView(contentsModel: ContentsModel()))
}
