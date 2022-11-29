//
//  ContentView.swift
//  BelayApp
//
//  Created by Christopher Zhang on 10/30/22.
//

import SwiftUI

func getFeedbackString(bleController: BLEController) -> String {
    return "Belay state: \(bleController.belayMessage)\nVoltage: \(String(bleController.belayVoltage))"
}
public struct ContentView: View {
    @StateObject var bleController = BLEController()
    public var body: some View {
        NavigationView{
            ZStack(alignment: .bottom){
                GeometryReader{ geo in
                    Image("Background")
                        .resizable()
                        .scaledToFit()
                        .offset(y:-geo.size.height / 12)
                    
                }
                GeometryReader{ geo in
                    VStack(){
                        Spacer()
                        Text("Belay App")
                            .font(.title)
                        Text("Team 24")
                            .padding(.bottom)
                        if !bleController.isConnected {
                            // bluetooth connect button
                            Button(action: bleController.connectPeripheral) {
                                HStack() {
                                    Image("bluetooth")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding([.bottom, .top], 5)
                                        .frame(maxHeight:geo.size.height/16)
                                    Text("Connect")
                                        .padding([.trailing], 10)
                                    
                                }.frame(width:geo.size.width/2, height: geo.size.height/8)
                                    .background(Color.green)
                                    .foregroundColor(Color.white)
                                    .buttonStyle(BorderlessButtonStyle())
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                        else {
                            Text(getFeedbackString(bleController: bleController))
                                .frame(width:geo.size.width/2, height: geo.size.height/8)
                                .background(Color(red: 0x7F/255, green: 0xFF/255, blue: 0x7C/255))
                                .border(.green, width:10)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        
                        // climb / lower button
                        Button() {
                            print("Climb/Lower pressed")
                            bleController.writeToBelayDevice(bleController.belayMessage == "climb" ? "lower" : "climb")
                        } label: {
                            Text(bleController.belayMessage == "climb" ? "Lower" : "Climb")
                                .frame(width:geo.size.width/2, height:geo.size.height/12)
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .buttonStyle(BorderlessButtonStyle())
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }

                        
                        // rest button
                        Button() {
                            print("Lower button pressed")
                            bleController.writeToBelayDevice("lower")
                        } label: {
                            Text("Rest")
                                .frame(width:geo.size.width/2, height:geo.size.height/12)
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .buttonStyle(PlainButtonStyle())
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }

                        
                        //panic button
                        Button() {
                            print("Panic button pressed")
                            bleController.writeToBelayDevice("stop")
                        } label: {
                            Text("STOP")
                                .font(.system(size:30))
                                .fontWeight(.bold)
                                .frame(width:geo.size.width/2, height:geo.size.height/6)
                                .background(Color.red)
                                .foregroundColor(Color.white)
                                .buttonStyle(BorderlessButtonStyle())
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }

                        

                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }.padding(.bottom)
            }
            .environmentObject(bleController)
        }

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

