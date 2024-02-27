//
//  ResultsView.swift
//  Trivia App
//
//  Created by Sam Reed on 12/29/23.
//
import Foundation
import SwiftUI
import ComposableArchitecture
import GoogleMobileAds

public struct ResultsView: View {
    
    @EnvironmentObject var views: Views
    
    let store: StoreOf<QuestionsModel>
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910"
    
    let shareString: String
    
    @State private var interstitial: GADInterstitialAd?
    private let interstitialDelegate = InterstitialDelegate()
    
    public init(
            store: StoreOf<QuestionsModel>,
            shareString: String
        ) {
            self.store = store
            self.shareString = shareString
        }

    public var body: some View {
        
        NavigationView {
            VStack{
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
        .onAppear {
                    loadInterstitialAd()
                }
    }

    func verticalContent(
        geometry g: GeometryProxy
    ) -> some View {
        
        return VStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
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
                    Text("\(viewStore.state.cNum)")
                        .font(.system(size: 100))
                        .padding(.vertical, 30)

                }
                    .padding(.vertical, 10)
                    .font(.title)
                
                HStack{
                    Spacer()
                    Text("Total Questions: ")
                    Spacer()
                    Text("\(viewStore.state.qNum)")
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
                            
                            if let interstitial = interstitial {
                                interstitial.present(fromRootViewController: UIApplication.shared.windows.first?.rootViewController)
                            } else {
                                print("Interstitial ad wasn't ready")
                            }
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
        }//.font(Font.custom("Lao Sangam MN Bold", size: 35))
            .foregroundStyle(Color.white)
            .fontWeight(.heavy)
    }

    func horizontalContent(
        geometry g: GeometryProxy
    ) -> some View {
        HStack {
        }
    }
    
    private func loadInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self.interstitialDelegate
        }
    }
}
   

class InterstitialDelegate: NSObject, GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // Implement this method to handle when the interstitial ad is dismissed
        print("Interstitial ad dismissed")
    }
}




#Preview {
    let previewState = QuestionsModel.State(totalTime: 60, daily: false, category: "")
    return ResultsView(
        store: Store(
            initialState: previewState,
            reducer: QuestionsModel.init
        ),
        shareString: "ShareString"
    )
}
