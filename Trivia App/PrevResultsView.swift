//
//  PrevResultsView.swift
//  Trivia App
//
//  Created by Sam Reed on 4/19/20.
//
import Foundation
import SwiftUI
import ComposableArchitecture
import GoogleMobileAds
import SwiftData

public struct PrevResultsView: View {
    
    @EnvironmentObject var views: Views
    private let adUnitID = "ca-app-pub-4151998780971734/2286845814"
    
    var cNum: Int
    var qNum: Int
    var shareString: String
    
    public init(
    ) {
        @AppStorage("score_saved") var scoreSaved: Bool = false
        @AppStorage("saved_cNum") var savedcNum: Int = 0
        @AppStorage("saved_qNum") var savedqNum: Int = 0
        @AppStorage("saved_shareString") var savedShareString: String = ""
        
        self.shareString = savedShareString
        self.cNum = savedcNum
        self.qNum = savedqNum
    }
    
    public var body: some View {
        
        NavigationView {
            VStack{
                GeometryReader { g in
                    if g.size.width < g.size.height {
                        self.verticalContent(geometry: g)
                    }
                }
                
                
                
                
                Spacer()
            }
            .background(Image("Background Image").resizable().scaledToFill().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
        .onAppear {
//            loadInterstitialAd()
        }
    }
    
    func verticalContent(
        geometry g: GeometryProxy
    ) -> some View {
        
        return VStack {
            Spacer()
            
            HStack{
                Spacer()
                Text("Results")
                    .font(.custom("Helvetica Neue", size: 50).weight(.bold))
                //Avenir Black
                //Futura Medium
                //Galvji Bold
                //Grantha Sangam MN Bold
                Spacer()
            }
            
            Spacer()
            
            VStack{
                Text("Correct Answers: ")
                    .font(.system(size: 35))
                Text("\(cNum)")
                    .font(.system(size: 100))
                    .padding(.vertical, 30)
                
            }
            .padding(.vertical, 10)
            .font(.title)
            
            HStack{
                Spacer()
                Text("Total Questions: ")
                Spacer()
                Text("\(qNum)")
                Spacer()
            }
            .padding(.vertical, 5)
            .font(.title)
            
            Spacer()
            
            HStack{
                
                Spacer()
                
                VStack {
                    Button("", systemImage: "house") {
                        self.views.stacked = false
                        self.views.dailyStacked = false
                        self.views.categoriesStacked = false
                        self.views.customStacked = false
                        self.views.resultsViewShown = false
                        self.views.prevResults = false
                        self.views.isGearPresented = true
                    }
                    .font(.system(size: 40))
                    .minimumScaleFactor(0.01)
                    .frame(height: 50, alignment:.bottom)
                    
                    Text("Home")
                        .font(.system(size: 25))
                        .minimumScaleFactor(0.01)
                }
                .frame(width: 100)
                
                Spacer()
                
                VStack {
                    
                    ShareLink(item: shareString){
                        Label("", systemImage: "square.and.arrow.up")
                            .font(.system(size: 40))
                            .minimumScaleFactor(0.01)
                            .frame(height: 50, alignment:.bottom)
                    }
                    .font(.largeTitle)
                    Text("Share")
                        .font(.system(size: 25))
                        .minimumScaleFactor(0.01)
                }
                .frame(width: 100)
                
                Spacer()
                
            }
            .frame(width: 400)
            .padding(.top, 70)
            
            Spacer()
        }
        .foregroundStyle(Color.white)
        .fontWeight(.heavy)
    }
}

#Preview {
    return PrevResultsView()
}
