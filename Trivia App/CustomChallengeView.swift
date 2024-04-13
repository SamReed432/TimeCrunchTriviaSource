//
//  CustomeChallengeView.swift
//  Trivia App
//
//  Created by Sam Reed on 1/10/24.
//
//

import Foundation
import SwiftUI
import ComposableArchitecture


public struct CustomChallengeView: View {
    
    @State private var selectedMinutes = 1
    @State private var selectedSeconds = 00
    
//    @Environment(\.dismiss) private var dismiss
    
    public var currCat: String
    
    let timeIntervals = [30, 60, 120, 180, 240, 300]
    
    public init(currCat: String) {
        self.currCat = currCat
    }
    
    public var body: some View {
        
        NavigationView {
            VStack{
                Spacer()
                GeometryReader { g in
                    if g.size.width < g.size.height {
                        self.verticalContent(geometry: g)
                    } else {
                        self.horizontalContent(geometry: g)
                    }
                }
                Spacer()
            }
            .background(Image("Background Image").resizable().scaledToFill().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
    
    func verticalContent(
        geometry g: GeometryProxy
    ) -> some View  {
        
        VStack {
            Spacer()
            
            Text("Custom")
                .font(.custom("Helvetica Neue", size: 300).weight(.bold))
                .frame(width: g.size.width * 0.7)
                .foregroundColor(Color.white)
                .minimumScaleFactor(0.01)
            
            Text("Challenge")
                .font(.custom("Helvetica Neue", size: 300).weight(.bold))
                .frame(width: g.size.width * 0.7)
                .foregroundColor(Color.white)
                .minimumScaleFactor(0.01)
            
            Spacer()
            
            Text("\(currCat)")
                .font(.custom("Helvetica Neue", size: 60).weight(.bold))
                .foregroundColor(Color("accent"))
                .frame(width: g.size.width * 0.7)
                .minimumScaleFactor(0.01)
            
            HStack (spacing: 0) {
                
                Spacer()
                
                Picker(selection: $selectedMinutes, label: Text("Minutes")) {
                    ForEach(0..<10) { minute in
                        Text("\(minute)")
                            .tag(minute)
                            .foregroundColor(.white)
                            .font(.custom("Helvetica Neue", size: 300).weight(.bold))
                            .frame(width: g.size.width * 0.2, height: g.size.height * 0.07)
                            .minimumScaleFactor(0.01)
                            .padding(5)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: g.size.width * 0.3, height: g.size.height * 0.3)
                
                Text(":")
                    .foregroundColor(.white)
                    .font(.custom("Helvetica Neue", size: 40).weight(.bold))
                    .frame(width: 10)
                
                Picker(selection: $selectedSeconds, label: Text("Seconds")) {
                    ForEach(0..<60) { second in
                        Text("\(formattedSeconds(from: second))")
                            .tag(second)
                            .foregroundColor(.white)
                            .font(.custom("Helvetica Neue", size: 300).weight(.bold))
                            .frame(width: g.size.width * 0.2, height: g.size.height * 0.07)
                            .minimumScaleFactor(0.01)
                            .padding(5)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: g.size.width * 0.3, height: g.size.height * 0.3)
                
                Spacer()
                
            }
            
            HStack {
                
// CODE FOR BACK BUTTON BREAKS TIMERS (BUG)
//                Spacer()
//                
//                Button {
//                    dismiss()
//                } label: {
//                    Image(systemName: "chevron.backward")
//                        .foregroundStyle(Color(.white))
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .padding(.bottom, 7)
//                }
                
                Spacer()
                
                NavigationLink {
                    QuestionsView(
                        store: Store(initialState: QuestionsModel.State(totalTime: selectedMinutes * 60 + selectedSeconds, daily: false, category: currCat)) {
                            QuestionsModel()
                        }
                    )
                } label: {
                    Text("GO!")
                        .foregroundColor(.white)
                        .font(.custom("Helvetica Neue", size: 300).weight(.bold))
                        .foregroundColor(.white)
                        .padding(12)
                        .frame(width: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12.0)
                                .stroke(Color.white.opacity(0.6), lineWidth: 3)
                        )
                        .minimumScaleFactor(0.01)
                }
                
                Spacer()
                
            }
            
            
            Spacer()
        }
    }
    
    func horizontalContent(
        geometry g: GeometryProxy
    ) -> some View {
        HStack {
        }
    }
}

func formattedMinutes(from seconds: Int) -> String {
    let minutes = seconds / 60
    return String(format: "%02d", minutes)
}

func formattedSeconds(from seconds: Int) -> String {
    let remainingSeconds = seconds % 60
    return String(format: "%02d", remainingSeconds)
}

#Preview {
    CustomChallengeView(currCat: "Film & TV")
}
