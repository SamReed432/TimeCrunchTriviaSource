//
//  HomeView.swift
//  Trivia App
//
//  Created by Sam Reed on 12/29/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import SwiftData
import Combine
import AVFoundation
import GoogleMobileAds


class Views: ObservableObject {
    @Published var stacked = false
    @Published var dailyStacked = false
    @Published var categoriesStacked = false
    @Published var customStacked = false
    @Published var dailyCategory = ""
    @Published var resultsViewShown = false
    @Published var isSheetPresented = false
    @Published var isGearPresented = true
    @Published var isQuestionPresented = true
    @Published var prevResults = false
    @Published var instructionsShown = false
    @Published var firstDailyInstr = false
    @Published var statsShown = false
    @Published var statIconShown = true
}

enum HomeCancelID {
    case dailyTimer
}

struct BannerAdView: UIViewRepresentable {
    var adUnitID: String = "ca-app-pub-3940256099942544/2934735716" // Test ad unit ID provided by Google

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = adUnitID
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
        }
        
        bannerView.delegate = context.coordinator
        bannerView.load(GADRequest())
        return bannerView
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}

    class Coordinator: NSObject, GADBannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("Banner loaded successfully")
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("Failed to load banner ad with error: \(error.localizedDescription)")
        }
    }
}


class SoundManager: ObservableObject {
    
    static let shared = SoundManager()
    
    @Published var select = AVAudioPlayer()
    @Published var correct = AVAudioPlayer()
    @Published var wrong = AVAudioPlayer()
    @Published var game_over = AVAudioPlayer()
    
    let select_url = URL(fileURLWithPath: Bundle.main.path(forResource: "select", ofType: ".mp3")!)
    let correct_url = URL(fileURLWithPath: Bundle.main.path(forResource: "correct1", ofType: ".mp3")!)
    let wrong_url = URL(fileURLWithPath: Bundle.main.path(forResource: "wrong", ofType: ".mp3")!)
    let game_over_url = URL(fileURLWithPath: Bundle.main.path(forResource: "game_over", ofType: ".mp3")!)
    
    public init () {
        do {
            select = AVAudioPlayer()
            select = try AVAudioPlayer(contentsOf: select_url)
            select.prepareToPlay()
            
            correct = AVAudioPlayer()
            correct = try AVAudioPlayer(contentsOf: correct_url)
            correct.prepareToPlay()
            
            wrong = AVAudioPlayer()
            wrong = try AVAudioPlayer(contentsOf: wrong_url)
            wrong.prepareToPlay()
            
            game_over = AVAudioPlayer()
            game_over = try AVAudioPlayer(contentsOf: game_over_url)
            game_over.prepareToPlay()
        } catch {
            print(error)
        }
    }
}


public struct HomeView: View {
    @ObservedObject var views = Views()
    @ObservedObject var sounds = SoundManager.shared
    
    let store: StoreOf<HomeViewModel>
    
    @AppStorage("seenDailyInstrs") var seenDailyInstrs: Bool = false
    
    
    public init(store: StoreOf<HomeViewModel>) {
        self.store = store
        
        Task { [self] in
            do {
                let fetchedCatName = try await fetchDailyCat()
                DispatchQueue.main.async {
                    views.dailyCategory = formatCategoryName(fetchedCatName.capitalized)
                }
            } catch {
                // Handle the error
            }
        }
    }
    
    public var body: some View {
        
        NavigationView {
            ZStack{
    
                GeometryReader { g in
                    if g.size.width < g.size.height {
                        self.verticalContent(geometry: g)
                    } else {
                        self.horizontalContent(geometry: g)
                    }
                    
                    if views.isQuestionPresented {
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color.clear)
                                .frame(width: 50, height: 50)
                                .position(x: g.size.width * 0.15, y: g.size.height * 0.04)
                                .onTapGesture {
                                    sounds.select.play()
                                    views.instructionsShown = true
                                }
                            Image(systemName: "questionmark.circle")
                                .position(x: g.size.width * 0.15, y: g.size.height * 0.04)
                                .font(.largeTitle)
                                .foregroundColor(Color.gray)
                                .opacity(0.5)
                                .onTapGesture {
                                    sounds.select.play()
                                    views.instructionsShown = true
                                }
                                .fullScreenCover(isPresented: $views.instructionsShown) {
                                    PopUpInstrs(geometry: g)
                                }
                        }
                    }
                    
                    if views.statIconShown {
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color.clear)
                                .frame(width: 50, height: 50)
                                .position(x: g.size.width * 0.15, y: g.size.height * 0.04)
                                .onTapGesture {
                                    sounds.select.play()
                                    views.instructionsShown = true
                                }
                            Image(systemName: "chart.bar.xaxis")
                                .position(x: g.size.width * 0.30, y: g.size.height * 0.04)
                                .font(.largeTitle)
                                .foregroundColor(Color.gray)
                                .opacity(0.5)
                                .onTapGesture {
                                    sounds.select.play()
                                    views.statsShown = true
                                }
                                .fullScreenCover(isPresented: $views.statsShown) {
                                    StatsView()
                                }
                        }
                    }

                    if views.isGearPresented {
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color.clear)
                                .frame(width: 50, height: 50)
                                .position(x: g.size.width * 0.85, y: g.size.height * 0.04)
                                .onTapGesture {
                                    sounds.select.play()
                                    views.isSheetPresented = true
                                }
                            
                            Image(systemName: "gear")
                                .position(x: g.size.width * 0.85, y: g.size.height * 0.04)
                                .font(.largeTitle)
                                .foregroundColor(Color.gray)
                                .opacity(0.5)
                                .onTapGesture {
                                    sounds.select.play()
                                    views.isSheetPresented = true
                                }
                                .fullScreenCover(isPresented: $views.isSheetPresented) {
                                    PopUpView(geometry: g)
                                }
                        }
                        VStack {
                            Spacer()
                            BannerAdView(adUnitID: "ca-app-pub-6778163388475279/9998521084")
                                .frame(maxWidth: .infinity) //g.size.width * 0.95)
                                .frame(height: g.size.height * 0.1)
                                .padding(.bottom, -g.size.height * 0.01)
                        }
                    }
                    

                }
            }
            .background(Image("Background Image").resizable().scaledToFill().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(views)
    }
    
    func fetchDataAndUpdateViews() {
        Task {
            do {
                let fetchedCatName = try await fetchDailyCat()
                DispatchQueue.main.async {
                    views.dailyCategory = formatCategoryName(fetchedCatName.capitalized)
                }
            } catch {
                // Handle the error
            }
        }
    }
    
    func refresh_daily() {
        }

    func verticalContent(
        geometry g: GeometryProxy
    ) -> some View {
        NavigationStack{
            WithViewStore(store, observe: { $0 }) { viewStore in
                    
            VStack {
                
                Spacer()
                
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                
                Spacer()
                
                HStack{
                    Spacer()
//                                      DEBUG TEXT:
//                                      Text("\(lastPlayedDailyDay):\(lastPlayedDailyMonth):\(lastPlayedDailyYear)")
                    
                    if ( canPlayDailyChallenge() ){
                        //They can play the daily -- store the current date
                        Button(action: {
                            sounds.select.play()
//                            viewStore.send(.stopTimer)
                            
                            if (seenDailyInstrs){
                                views.dailyStacked = true
                                views.isGearPresented = false
                                views.isQuestionPresented = false
                                views.statIconShown = false
                            } else {
                                views.firstDailyInstr = true
                                seenDailyInstrs = true
                                views.isGearPresented = false
                                views.isQuestionPresented = false
                                views.statIconShown = false
                            }
                        }
                                ) {
                            Text("Daily Challenge: \(views.dailyCategory)")
                                .font(.custom("Helvetica Neue", size: 300).weight(.bold))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: 0.85 * g.size.width)
                                .padding(.vertical, 20)
                                .padding(.horizontal, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white, lineWidth: 4.0)
                                )
                                .background(Color("AccentColor").opacity(0.52))
                                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                                .shadow(color: .black, radius: 4, x: 0, y: 4)
                                .lineLimit(2)
                                .minimumScaleFactor(0.01)
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 15.0))
                        .onAppear {
                            let _ = Task {
                                do {
                                    let fetchedCatName = try await fetchDailyCat()
                                    DispatchQueue.main.async {
                                        views.dailyCategory = formatCategoryName(fetchedCatName.capitalized)
                                    }
                                } catch {
                                    // Handle the error
                                }
                            }
                        }
                    } else {
                        HStack {
                            Button (action: {
                                views.prevResults = true
                            }){
                                VStack {
                                    Text("New Daily Challenge: \(String(viewStore.totalTime / 3600)):\(String(format: "%02d", (viewStore.totalTime % 3600) / 60)):\(String(format: "%02d", viewStore.totalTime % 60))")
                                        .onAppear {
                                            viewStore.send(.startTimer)
                                        }
                                        .onDisappear {
                                            viewStore.send(.stopTimer)
                                        }
                                    .lineLimit(1)
                                    
                                    HStack {
                                        Spacer()
                                        Text("See My Score ")
                                            .lineLimit(1)
                                        Image(systemName: "chevron.forward")
                                            .font(.custom("Helvetica Neue", size: 25).weight(.bold))
                                            .frame(maxWidth: 0.1 * g.size.width)
                                            .foregroundStyle(Color(.white))
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                }
                            }
                        }
                            .font(.custom("Helvetica Neue", size: 300).weight(.bold))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: 0.8 * g.size.width)
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
                    }
                    
                    Spacer()
                }
                .navigationDestination(isPresented: $views.dailyStacked) {
                    QuestionsView(
                        store: Store(initialState: QuestionsModel.State(totalTime: 60, daily: true, category: views.dailyCategory)) {
                            QuestionsModel()
                        }
                    )
                }
                .navigationDestination(isPresented: $views.firstDailyInstr) {
                    InstructionView()
                }
                .navigationDestination(isPresented: $views.prevResults) {
                    PrevResultsView()
                }
                
                Spacer()
                
                HStack{
                    Spacer()
                    Button(action: {
                        sounds.select.play()
                        viewStore.send(.stopTimer)
                        views.stacked = true
                        views.isGearPresented = false
                        views.statIconShown = false
                        views.isQuestionPresented = false
                    }) {
                        Text("1 Minute Challenge")
                            .font(.custom("Helvetica Neue", size: 30).weight(.bold))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: 0.8 * g.size.width)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white, lineWidth: 4.0)
                            )
                            //.background(Color("AccentColor").opacity(0.52))
                            .background(Color(.white).opacity(0.20))
                            .clipShape(RoundedRectangle(cornerRadius: 15.0))
                            .shadow(color: .black, radius: 4, x: 0, y: 4)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 15.0))
                    
                    Spacer()
                }
                .navigationDestination(isPresented: $views.stacked) {
                    QuestionsView(
                        store: Store(initialState: QuestionsModel.State(totalTime: 60, daily: false, category: "")) {
                            QuestionsModel()
                        }
                    )
                }
                
                
                
                HStack{
                    Spacer()
                    
                    Button(action: {
                        sounds.select.play()
                        viewStore.send(.stopTimer)
                        views.categoriesStacked = true
                        views.isGearPresented = false
                        views.statIconShown = false
                        views.isQuestionPresented = false
                    }) {
                        Text("Categories")
                            .font(.custom("Helvetica Neue", size: 30).weight(.bold))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: 0.8 * g.size.width)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white, lineWidth: 4.0)
                            )
                            .background(Color(.white).opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 15.0))
                            .shadow(color: .black, radius: 4, x: 0, y: 4)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 15.0))
                    
                    
                    Spacer()
                }
                .navigationDestination(isPresented: $views.categoriesStacked) {
                    CategoriesView()
                }
                
                Spacer()
                Spacer()
            }
            .background(Image("Background Image").resizable().scaledToFill().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all))
                
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    func PopUpView(
        geometry g: GeometryProxy
    ) -> some View {
            return VStack {
                
                ZStack {
                    HStack{
                        Button(action: {
                            views.isSheetPresented = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .padding(.leading, 15)
                        }
                        Spacer()
                        Spacer()
                    }
                    
                    Text("Menu")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: g.size.width * 0.9, height: g.size.height * 0.1)
                        .font(.custom("Helvetica Neue", size: 200).weight(.bold))
                        .minimumScaleFactor(0.01)
                }
                
                Spacer()
                
                Link(destination: URL(string: "https://samreed432.github.io/TimeCrunchTrivia/")!) {
                            Text("Privacy Policy")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: g.size.width * 0.8, height: g.size.height * 0.1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white, lineWidth: 4.0)
                                )
                                .background(Color(.white).opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                                .shadow(color: .black, radius: 4, x: 0, y: 4)
                                .font(.custom("Helvetica Neue", size: 200).weight(.bold))
                                .minimumScaleFactor(0.01)
                        }
                        .padding()
                Link(destination: URL(string: "https://the-trivia-api.com/")!) {
                            Text("Trivia API")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: g.size.width * 0.8, height: g.size.height * 0.1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white, lineWidth: 4.0)
                                )
                                .background(Color(.white).opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                                .shadow(color: .black, radius: 4, x: 0, y: 4)
                                .font(.custom("Helvetica Neue", size: 200).weight(.bold))
                                .minimumScaleFactor(0.01)
                }
                
                Spacer()
                Spacer()
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Image("Background Image").resizable().scaledToFill().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all))
        }
    
    func PopUpInstrs(
        geometry g: GeometryProxy
    ) -> some View {
        return VStack {
            ZStack {
                BackgroundImageView()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    
                    ZStack {
                        HStack{
                            Button(action: {
                                views.instructionsShown = false
                            }) {
                                Image(systemName: "xmark")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding()
                                    .padding(.leading, 0)
                            }
                            Spacer()
                            Spacer()
                        }
                        
                        Text("How To Play")
                            .foregroundColor(.white)
                            .padding(.leading, 40)
                            .frame(width: g.size.width * 0.8, height: g.size.height * 0.12)
                            .font(.custom("Helvetica Neue", size: 150).weight(.bold))
                            .minimumScaleFactor(0.01)
                    }
                    
                    
                    VStack(spacing: 20) {
                        // Daily Challenge
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Daily Challenge:")
                                .font(.custom("Helvetica Neue", size: 300).weight(.bold))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: 0.65 * g.size.width)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                            
                            
                            Text("✅ Everyone receives the same 10 questions based on a new category each day.")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                            
                            Text("✅ You have just 1 minute to answer as many as you can.")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                            
                            Text("✅ Ready to test your knowledge? Share your score to compete with other players!")
                                .font(.system(size:20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                        }
                        .padding(.vertical, 10)
                        
                        // One Minute and Custom Challenges
                        VStack(alignment: .leading, spacing: 10) {
                            Text("One Minute and Custom Challenges:")
                                .font(.custom("Helvetica Neue", size: 25).weight(.bold))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: 0.65 * g.size.width)
                            //                                    .lineLimit(1)
                                .minimumScaleFactor(0.01)
                            
                            Text("⊙ Custom challenges let you tailor the trivia experience.")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                            
                            Text("⊙ Choose your category and set your own time limit.")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                            
                            Text("⊙ Ready to challenge yourself or your friends? Let the trivia fun begin!")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                        }
                        .padding(.vertical, 10)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            
            Spacer()
        }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Image("Background Image").resizable().scaledToFill().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all))
        }
    

    func horizontalContent(
        geometry g: GeometryProxy
    ) -> some View {
        HStack {
        }
    }
}


struct catResponse: Decodable {
    let catName: String
}


func fetchDailyCat() async throws -> String {
    let url = URL(string: "https://tct.reedserver.com/get_daily_cat")!

    let (data, _) = try await URLSession.shared.data(from: url)

    let decoded = try JSONDecoder().decode(catResponse.self, from: data)

    return decoded.catName
}
//
//#Preview {
//    let previewState = QuestionsModel.State(totalTime: 60, daily: false, category: "")
//        return HomeView()
//}


@Reducer
public struct HomeViewModel{
    
    public struct State: Equatable, Codable {
        public var isRunningTimer: Bool
        public var totalTime: Int
        public var dailyCategory = ""
        
        public init() {
            self.isRunningTimer = false
            self.totalTime = 0
        }
    }

    private let midnightEST: TimeInterval = 24 * 60 * 60 // 24 hours
    
    public enum Action {
        case startTimer
        case stopTimer
        case setRemainingTime(_ : Int)
        case cancelTimer
    }

    enum Identifiers: Hashable, CaseIterable {
           case fetchCancellable
           case simulationTimer
           case simulationCancellable
       }

    public static let scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()

    public static func timerPublisher(
        _ totalTime: Int
    ) -> () -> AnyPublisher<HomeViewModel.Action, Never> {
        {
            let calendar = Calendar.current
            let now = Date()
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)
            let midnight = calendar.startOfDay(for: tomorrow!)
            
            let timeIntervalUntilMidnight = midnight.timeIntervalSince(now)
            var remainingTime = Int(timeIntervalUntilMidnight)
            
            return Timer.publish(every: 1, on: RunLoop.main, in: .common)
                .autoconnect()
                .map { _ in
                    remainingTime -= 1
                    if remainingTime >= 0 {
                        return .setRemainingTime(remainingTime)
                    } else {
                        return .stopTimer
                    }
                }
                .eraseToAnyPublisher()
        }
    }

    public init() { }

    public var body: some ReducerOf<Self> {

        Reduce { state, action in
            switch action {
                case .startTimer:
                    state.isRunningTimer = true
                    return Effect
                        .publisher(HomeViewModel.timerPublisher(state.totalTime))
                        .cancellable(id: HomeCancelID.dailyTimer)
                case .stopTimer:
                    state.isRunningTimer = false
                    return Effect.run { send in
                        await send(.cancelTimer)
                    }
                case .cancelTimer:
                    return .cancel(id: HomeCancelID.dailyTimer)
                
                case .setRemainingTime(let time):
                    state.totalTime = time
                    return .none
            }
        }
    }

}

func formatCategoryName(_ categoryName: String) -> String {
    let components = categoryName.components(separatedBy: "_")
    let formattedCategoryName = components.joined(separator: " ")
    return formattedCategoryName
}

func canPlayDailyChallenge() -> Bool {
    let calendar = Calendar.current
    let currentDate = Date()
    
    @AppStorage("lastPlayedDailyDay") var lastPlayedDailyDay: Int = 0
    @AppStorage("lastPlayedDailyMonth") var lastPlayedDailyMonth: Int = 0
    @AppStorage("lastPlayedDailyYear") var lastPlayedDailyYear: Int = 0

    // Create a DateComponents for the last played date
    var lastPlayedDateComponents = DateComponents()
    lastPlayedDateComponents.year = lastPlayedDailyYear
    lastPlayedDateComponents.month = lastPlayedDailyMonth
    lastPlayedDateComponents.day = lastPlayedDailyDay
    
    let dayNumber = calendar.component(.day, from: currentDate)
    let monthNumber = calendar.component(.month, from: currentDate)
    let yearNumber = calendar.component(.year, from: currentDate)

    // Convert components into a Date object
    if let lastPlayedDate = calendar.date(from: lastPlayedDateComponents) {
        return ((dayNumber > lastPlayedDateComponents.day! && monthNumber >= lastPlayedDateComponents.month! && yearNumber >= lastPlayedDateComponents.year!) ||
                (monthNumber > lastPlayedDateComponents.month! && yearNumber >= lastPlayedDateComponents.year!) ||
                (yearNumber > lastPlayedDateComponents.year!)
        )
    }
//    
//    dayNumber > lastPlayedDailyDay && monthNumber >= lastPlayedDailyMonth && yearNumber >= lastPlayedDailyYear) ||
//                            (monthNumber > lastPlayedDailyMonth && yearNumber >= lastPlayedDailyYear) ||
//                            (yearNumber > lastPlayedDailyYear) ||
    
    return true // Default to true if date conversion fails
}


#Preview {
    return HomeView(
        store: Store(initialState: HomeViewModel.State()) {
            HomeViewModel()
        }
    )
}
