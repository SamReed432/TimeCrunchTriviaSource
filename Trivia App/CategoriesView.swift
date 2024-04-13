//
//  CategoriesView.swift
//  Trivia App
//
//  Created by Sam Reed on 1/9/24.
//
//

import Foundation
import SwiftUI
import ComposableArchitecture


public struct CategoriesView: View {
    
    @EnvironmentObject var views: Views
    public var cats = ["Arts & Literature", "Film & TV", "Food & Drink", "General Knowledge", "Geography", "History", "Music", "Science", "Society & Culture", "Sport & Leisure"]
    
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
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
            
            HStack {
                
                Spacer().overlay {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.custom("Helvetica Neue", size: 30).weight(.bold))
                            .frame(maxWidth: 0.3 * g.size.width)
                            .foregroundStyle(Color(.white))
                            .padding(.bottom, 20)
                            .padding(.top, 10)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                        
                    }
                }

                
                Text("Categories")
                    .font(.custom("Helvetica Neue", size: 400).weight(.bold))
                    .frame(maxWidth: 0.7 * g.size.width)
                    .foregroundStyle(Color(.white))
                    .padding(.bottom, 20)
                    .padding(.top, 10)
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    
                
                Spacer()
            }
            
            Spacer()
            
            ScrollView {
                Spacer()
                
                ForEach(cats, id: \.self) { cat in
                    HStack{
                        Spacer()
                        NavigationLink(destination: {
                            CustomChallengeView(currCat: cat)
                        }, label: {
                            Text("\(cat)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 0.9 * g.size.width)
                                .padding(.vertical, 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white, lineWidth: 4.0)
                                )
                                .background(Color("accent").opacity(0.60))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(radius: 4.0, y: 5)
                                .padding(.vertical, 5)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                            
                        })
                        .contentShape(RoundedRectangle(cornerRadius: 15.0))
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                }
            }
        }
    }
    
    func horizontalContent(
        geometry g: GeometryProxy
    ) -> some View {
        HStack {
        }
    }
}

#Preview {
    CategoriesView()
}
