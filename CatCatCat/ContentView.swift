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
    @Binding var availableCatNum: Int
    @Binding var isInvitingProgress: Bool
    
    @AppStorage("blackName") var blackName: String = "Damiano"
    @AppStorage("greyName") var greyName: String = "Sherry"
    @AppStorage("orangeName") var orangeName: String = "Anya"
    @AppStorage("tigerName") var tigerName: String = "OMG"
    @AppStorage("whiteBlackName") var whiteBlackName: String = "Leon"
    @State var enabledCount: Int = 0
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State private var r:Double = 0

    var body: some View {
        if !isImmersiveSpaceShown {
            Button("Invite your cats!") {
                showImmersiveSpaceFromButton = true
            }
            .font(.title)
            .fontDesign(.monospaced)
            .frame(alignment: .center)
        } else if availableCatNum == -1 {
            VStack {
                Text("Now loading, please wait a moment!")
                    .font(.system(size: 20))
                    .bold()
                    .fontDesign(.monospaced)
                    .padding(EdgeInsets(
                        top: 30,
                        leading: 0,
                        bottom: 30,
                        trailing: 0
                    ))
                ProgressView()
            }
        } else {
            VStack {
                if availableCatNum < 3 {
                    Text("Name your cats and choose ones you want to invite! \nYour floor size allows you to invite \(availableCatNum) cats (Max 3 cats).")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 20))
                        .bold()
                        .fontDesign(.monospaced)
                        .padding(EdgeInsets(
                            top: 30,
                            leading: 0,
                            bottom: 30,
                            trailing: 0
                        ))
                } else {
                    Text("Name your cats and choose ones you want to invite! (Max 3 cats)")
                        .font(.system(size: 20))
                        .bold()
                        .fontDesign(.monospaced)
                        .padding(EdgeInsets(
                            top: 30,
                            leading: 0,
                            bottom: 30,
                            trailing: 0
                        ))
                }
                if isInvitingProgress && enabledCount > 0 {
                    VStack {
                        Text("Cats are getting ready!")
                            .font(.system(size: 20))
                            .bold()
                            .fontDesign(.monospaced)
                            .padding(EdgeInsets(
                                top: 10,
                                leading: 0,
                                bottom: 30,
                                trailing: 0
                            ))
                        ProgressView()
                    }
                }
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
                    
                    TextField("Name",text: $blackName)
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
                        .disabled(enabledCount >= availableCatNum && !isBlackEnabled)
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
                    TextField("Name",text: $greyName)
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
                        .disabled(enabledCount >= availableCatNum && !isGreyEnabled)
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
                    
                    TextField("Name",text: $orangeName)
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
                        .disabled(enabledCount >= availableCatNum && !isOrangeEnabled)
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
                    
                    TextField("Name",text: $tigerName)
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
                        .disabled(enabledCount >= availableCatNum && !isTigerEnabled)
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
                    
                    TextField("Name",text: $whiteBlackName)
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
                        .disabled(enabledCount >= availableCatNum && !isWhiteBlackEnabled)
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
            .onChange(of: availableCatNum) { _, _ in
                isBlackEnabled = false
                isGreyEnabled = false
                isOrangeEnabled = false
                isTigerEnabled = false
                isWhiteBlackEnabled = false
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    //ContentView(immersiveView: ImmersiveView(contentsModel: ContentsModel()))
}
