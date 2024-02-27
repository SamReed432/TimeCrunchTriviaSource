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

class Views: ObservableObject {
    @Published var stacked = false
    @Published var dailyStacked = false
    @Published var categoriesStacked = false
    @Published var customStacked = false
    @Published var dailyCategory = ""
    @Published var resultsViewShown = false
    
}

public struct HomeView: View {
    
    @ObservedObject var views = Views()
    
    let store: StoreOf<HomeViewModel>
    
    @AppStorage("lastPlayedDailyDay") var lastPlayedDailyDay: Int = 0
    @AppStorage("lastPlayedDailyMonth") var lastPlayedDailyMonth: Int = 0
    @AppStorage("lastPlayedDailyYear") var lastPlayedDailyYear: Int = 0
    
    
    public init(store: StoreOf<HomeViewModel>) {
        self.store = store
        Task { [self] in
            do {
                let fetchedCatName = try await fetchDailyCat()
                print("\(fetchedCatName)")
                DispatchQueue.main.async {
                    views.dailyCategory = fetchedCatName.capitalized
                }
            } catch {
                // Handle the error
            }
        }
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
            }
            .background(Image("Background Image").resizable().scaledToFill().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(views)
        
        .onAppear {
        }
    }

    func verticalContent(
        geometry g: GeometryProxy
    ) -> some View {
        return NavigationStack{
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
                        Button(action: {
                            viewStore.send(.stopTimer)
                            views.stacked = true
                        }) {
                            Text("Play 1 Minute Challenge")
                                .font(.custom("Helvetica Neue", size: 23).weight(.bold))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: 0.9 * g.size.width)
                                .padding(.vertical, 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white, lineWidth: 4.0)
                                )
                                .background(Color("accent").opacity(0.52))
                                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                                .shadow(color: .black, radius: 4, x: 0, y: 4)
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
                        
                        
                        let calendar = Calendar.current
                        let currentDate = Date()
                        
                        let dayNumber = calendar.component(.day, from: currentDate)
                        let monthNumber = calendar.component(.month, from: currentDate)
                        let yearNumber = calendar.component(.year, from: currentDate)
                        
                        //                  DEBUG TEXT:
                        //                  Text("\(lastPlayedDailyDay):\(lastPlayedDailyMonth):\(lastPlayedDailyYear)")
                        
                        if (
                            (dayNumber > lastPlayedDailyDay && monthNumber >= lastPlayedDailyMonth && yearNumber >= lastPlayedDailyYear) ||
                            (monthNumber > lastPlayedDailyMonth && yearNumber >= lastPlayedDailyYear) ||
                            (yearNumber > lastPlayedDailyYear)
                        ){
                            //They can play the daily -- store the current date
                            Button(action: {
                                viewStore.send(.stopTimer)
                                views.dailyStacked = true
                            }) {
                                Text("Play The Daily Challenge : \(views.dailyCategory)")
                                    .font(.custom("Helvetica Neue", size: 20).weight(.bold))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 0.9 * g.size.width)
                                    .padding(.vertical, 20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.white, lineWidth: 4.0)
                                    )
                                    .background(Color("accent").opacity(0.52))
                                    .clipShape(RoundedRectangle(cornerRadius: 15.0))
                                    .shadow(color: .black, radius: 4, x: 0, y: 4)
                            }
                            .contentShape(RoundedRectangle(cornerRadius: 15.0))
                        } else {
                            HStack {
                                Text("New Daily Challenge: \(String(viewStore.totalTime / 3600)):\(String(format: "%02d", (viewStore.totalTime % 3600) / 60)):\(String(format: "%02d", viewStore.totalTime % 60))")
                                    .frame(width: 350)
                                    .onAppear {
                                        viewStore.send(.startTimer)
                                    }
//                                    .onDisappear{
//                                        viewStore.send(.stopTimer)
//                                    }
                            }
                                .font(.custom("Helvetica Neue", size: 20).weight(.bold))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: 0.9 * g.size.width)
                                .padding(.vertical, 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white, lineWidth: 4.0)
                                )
                                .background(Color.gray.opacity(0.52))
                                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                                //.shadow(color: .black, radius: 4, x: 0, y: 4)
                            
                            
                        }
                        
                        Spacer()
                    }
                    .navigationDestination(isPresented: $views.dailyStacked) {
                        QuestionsView(
                            store: Store(initialState: QuestionsModel.State(totalTime: 60, daily: true, category: "")) {
                                QuestionsModel()
                            }
                        )
                    }
                    
                    Spacer()
                    
                    HStack{
                        Spacer()
                        
                        Button(action: {
                            viewStore.send(.stopTimer)
                            views.categoriesStacked = true
                        }) {
                            Text("Categories")
                                .font(.custom("Helvetica Neue", size: 25).weight(.bold))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: 0.9 * g.size.width)
                                .padding(.vertical, 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white, lineWidth: 4.0)
                                )
                                .background(Color(.white).opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                                .shadow(color: .black, radius: 4, x: 0, y: 4)
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 15.0))
                        
                        
                        Spacer()
                    }
                    .navigationDestination(isPresented: $views.categoriesStacked) {
                        CategoriesView()
                    }
                    
                    Spacer()
                }
                .background(Image("Background Image").resizable().scaledToFill().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all))
            }
            .scrollContentBackground(.hidden)
            
            
        }
    }

    func horizontalContent(
        geometry g: GeometryProxy
    ) -> some View {
        HStack {
        }
    }
    
//    private func calculateTimeRemaining() {
//        let currentDate = Date()
//        let calendar = Calendar.current
//        let midnightESTDate = calendar.startOfDay(for: currentDate).addingTimeInterval(midnightEST)
//
//        if midnightESTDate > currentDate {
//            timeRemaining = midnightESTDate.timeIntervalSince(currentDate)
//        } else {
//            // Daily challenge already reset for today
//            timeRemaining = 0
//        }
//    }
//
//    private func formattedTime(_ time: TimeInterval) -> String {
//        let hours = Int(time) / 3600
//        let minutes = Int(time) / 60 % 60
//        let seconds = Int(time) % 60
//        return String(format: "%2d:%02d:%02d", hours, minutes, seconds)
//    }
//    
//    private func startTimer() {
//            timer = Timer.publish(every: 1.0, on: .main, in: .common)
//                .autoconnect()
//                .sink { _ in
//                    if timeRemaining > 0 {
//                        timeRemaining -= 1
//                    } else {
//                        calculateTimeRemaining()
//                    }
//                }
//        }
//
//    private func stopTimer() {
//        timer?.cancel()
//    }
}


struct catResponse: Decodable {
    let catName: String
}


func fetchDailyCat() async throws -> String {
    let url = URL(string: "https://trivia-time-api-c4d7013f9357.herokuapp.com/dailyCat")!

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
public struct HomeViewModel {
    public struct State: Equatable, Codable {
        public var isRunningTimer: Bool
        public var totalTime: Int
        
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
                        .cancellable(id: QuestionsModel.Identifiers.simulationCancellable)
                case .stopTimer:
                    state.isRunningTimer = false
                    return Effect.run { send in
                        await send(.cancelTimer)
                    }
                case .cancelTimer:
                    return .cancel(id: QuestionsModel.Identifiers.simulationCancellable)
                
                case .setRemainingTime(let time):
                    state.totalTime = time
                    return .none
            }
        }
    }
}


#Preview {
    return HomeView(
        store: Store(initialState: HomeViewModel.State()) {
            HomeViewModel()
        }
    )
}
