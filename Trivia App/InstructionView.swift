//  InstructionView.swift
//  Time Crunch Trivia
//
//  Created by Sam Reed on 5/12/24.
//

import SwiftUI

public struct InstructionView: View {
    
    @EnvironmentObject var views: Views
    
    public init() {
        @AppStorage("seen_instructions") var seenInstructions: Bool = false
        seenInstructions = true
    }
    
    public var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    BackgroundImageView()
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        
                        Text("Daily Challenge!")
                            .underline()
                            .font(.custom("Helvetica Neue", size: 100).weight(.bold))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: 0.85 * geometry.size.width, maxHeight: 0.15 * geometry.size.height)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)

                        
                        VStack(spacing: 20) {
                            // Daily Challenge
                            VStack(alignment: .leading, spacing: 10) {
                                
                                Text("✅ Everyone receives the same 10 questions based on a new category each day.")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                
                                Text("✅ You have just 1 minute to answer as many as you can.")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                
                                Text("✅ Ready to test your knowledge? Share your score to compete with other players!")
                                    .font(.system(size:30, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                Button {
                                    views.firstDailyInstr = false
//                                    views.dailyStacked = true
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text("Let's Play!")
                                            .font(.custom("Helvetica Neue", size: 50).weight(.bold))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
    //                                        .frame(maxWidth: 0.8 * g.size.width)
                                            .padding(.vertical, 20)
                                            .padding(.horizontal, 20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.white, lineWidth: 4.0)
                                            )
                                            .background(Color("AccentColor").opacity(0.52))
                                            .clipShape(RoundedRectangle(cornerRadius: 15.0))
                                            .shadow(color: .black, radius: 4, x: 0, y: 4)
                                            .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                        Spacer()
                                    }
                                    .padding(.top, 30)
                                }
                                .contentShape(RoundedRectangle(cornerRadius: 15.0))

                            }
                            .padding(.vertical, 10)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct BackgroundImageView: View {
    var body: some View {
        Image("Background Image")
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionView()
    }
}
#endif
