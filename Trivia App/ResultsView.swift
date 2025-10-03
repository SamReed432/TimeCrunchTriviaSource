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
import SwiftData

struct GameResult: Codable, Identifiable {
    let id: UUID
    let date: Date
    let correctAnswers: Int
    let totalQuestions: Int
    let isDaily: Bool
    let category: String
}


public struct ResultsView: View {
    
    @EnvironmentObject var views: Views
    
    @AppStorage("game_results") private var gameResultsData: Data = Data()

    private var gameResults: [GameResult] {
        guard !gameResultsData.isEmpty,
              let decoded = try? JSONDecoder().decode([GameResult].self, from: gameResultsData) else {
            return []
        }
        return decoded
    }

    private func updateGameResults(_ newValue: [GameResult]) {
        if let encoded = try? JSONEncoder().encode(newValue) {
            gameResultsData = encoded
        }
    }

    private func saveGameResult(correctAnswers: Int, totalQuestions: Int, isDaily: Bool, category: String) {
        let newResult = GameResult(
            id: UUID(),
            date: Date(),
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions,
            isDaily: isDaily,
            category: category
        )
        var results = gameResults
        results.append(newResult)
        updateGameResults(results)
    }

    let store: StoreOf<QuestionsModel>
    private let adUnitID = "ca-app-pub-6778163388475279/3010101593"
    
    let shareString: String
    @AppStorage("dailies_played") var dailiesPlayed: Int = 0
    @AppStorage("total_daily_score") var total_daily_score: Int = 0
 
    @State private var interstitial: GADInterstitialAd?
    private let interstitialDelegate = InterstitialDelegate()
    
    public init(
            store: StoreOf<QuestionsModel>,
            shareString: String
        ) {
            self.store = store
            self.shareString = shareString
            
            dailiesPlayed += 1;
            
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
                requestNotificationPermissions()
                cancelNotificationIfNeeded()
                fetchTomorrowCategory()
                loadInterstitialAd()
                }
    }
    
    // Request notification permissions
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchTomorrowCategory() {
        guard let url = URL(string: "https://tct.reedserver.com/get_tomorrow_cat") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch tomorrow's category: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(catResponse.self, from: data)
                let tomorrowCategory = decoded.catName
                    .replacingOccurrences(of: "_", with: " ")
                    .capitalized
                print("Tomorrow's category:", tomorrowCategory)
                scheduleNotificationForNextDay(category: tomorrowCategory)
            } catch {
                print("Failed to decode tomorrow's category:", error)
            }
        }

        task.resume()
    }

        
    private func scheduleNotificationForNextDay(category: String) {
        // Calculate the date for the next day at 9 AM
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        dateComponents.hour = 9
        dateComponents.minute = 0
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "A New Daily Challenge Is Waiting!"
        content.body = "Today's category: \(category)"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "NextDayNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for the next day: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleNotificationForSameDay(category: String) {
        // Get the current date
        let currentDate = Date()
        
        // Get the components of the current date
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: currentDate)
        
        // Set the hour, minute, and second components for 10:05 PM
        dateComponents.hour = 22 // 10 PM
        dateComponents.minute = 10 // 05 minutes past the hour
        dateComponents.second = 0
        
        // Create a trigger for the notification
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "A New Daily Challenge Is Waiting!"
        content.body = "Today's category: \(formatCategoryName(category))"
        content.sound = .default
        
        // Create the notification request
        let request = UNNotificationRequest(identifier: "SameDayNotification", content: content, trigger: trigger)
        
        // Add the notification request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for the same day: \(error.localizedDescription)")
            }
        }
    }
    
    private func cancelNotificationIfNeeded() {
            let currentDate = Date()
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: currentDate)
            
            guard currentHour < 9 else {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["NextDayNotification"])
                print("Notification canceled because the game was played before 9:00 AM.")
                return
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
                
                
                if (viewStore.state.daily) {
                    HStack {
                        HStack {
                            Text("Daily Average: \(((total_daily_score / 10) / dailiesPlayed))")
                                .onAppear{
                                    total_daily_score += viewStore.state.cNum
                                }
                                .font(.system(size: 40))
                        }
                    }
                }
                
                HStack{
                    
                    Spacer()
                    
                    VStack {
                        Button("", systemImage: "house") {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                if let rootViewController = window.rootViewController {
                                    if let interstitial = interstitial {
                                        interstitial.present(fromRootViewController: rootViewController)
                                    } else {
                                        print("Interstitial ad wasn't ready")
                                    }
                                }
                            } else {
                                print("No window scene found")
                            }
                            self.views.stacked = false
                            self.views.dailyStacked = false
                            self.views.categoriesStacked = false
                            self.views.customStacked = false
                            self.views.resultsViewShown = false
                            self.views.isGearPresented = true
                            self.views.statIconShown = true
                            self.views.isQuestionPresented = true
                            self.views.instructionsShown = false
                            self.views.firstDailyInstr = false
                        }
                        .font(.system(size: 40))
                        .minimumScaleFactor(0.01)
                        .frame(height: 50, alignment:.bottom)
                        .onAppear{
                            
                            if (viewStore.state.daily) {
                                @AppStorage("score_saved") var scoreSaved: Bool = false
                                @AppStorage("saved_cNum") var savedcNum: Int = 0
                                @AppStorage("saved_qNum") var savedqNum: Int = 0
                                @AppStorage("saved_shareString") var savedShareString: String = ""
                                
                                savedcNum = viewStore.state.cNum
                                savedqNum = viewStore.state.qNum
                                scoreSaved = true
                                savedShareString = self.shareString
                            }
                            
                            saveGameResult(correctAnswers: viewStore.state.cNum, totalQuestions: viewStore.state.qNum, isDaily: viewStore.state.daily, category: viewStore.state.category)
                            
                        }
                        
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
    let previewState = QuestionsModel.State(totalTime: 60, daily: true, category: "")
    return ResultsView(
        store: Store(
            initialState: previewState,
            reducer: QuestionsModel.init
        ),
        shareString: "ShareString"
    )
}
