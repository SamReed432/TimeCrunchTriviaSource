//
//  QuestionsView.swift
//  Trivia App
//
//  Created by Sam Reed on 12/25/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Combine
import AVFoundation

private var configURL = URL(string: "https://the-trivia-api.com/v2/questions")!

public struct TriviaQuestion: Codable, Equatable {
    let category: String
    let id: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let question: Question
    let tags: [String]
    let type: String
    let difficulty: String
    let regions: [String]
    let isNiche: Bool

    struct Question: Codable, Equatable {
        let text: String
    }
}

let defaultTrivia = TriviaQuestion(category: "Hello", id: "Hello", correctAnswer: "Hello", incorrectAnswers: ["Hello","Hell2","Hello3"], question: TriviaQuestion.Question(text: ""), tags: ["Hello"], type: "Hello", difficulty: "Hello", regions: ["Hello1"], isNiche: false)


enum APIError: Error {
    case urlError(URL, URLError)
    case badResponse(URL, URLResponse)
    case badResponseStatus(URL, HTTPURLResponse)
    case jsonDecodingError(URL, Error, String)
}

class DefaultHandlingSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        completionHandler(.performDefaultHandling, .none)
    }
}

class GameSounds: ObservableObject {
    @Published var audioPlayer = AVAudioPlayer()
    
    let url = URL(fileURLWithPath: Bundle.main.path(forResource: "select", ofType: ".mp3")!)
    
    public init () {
        do {
            audioPlayer = AVAudioPlayer()
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            print("inited")
        } catch {
            print(error)
        }
    }
}


@Reducer
public struct QuestionsModel {
    
    @ObservedObject var sounds = SoundManager.shared
    
    public struct State: Equatable, Codable {
        public var qNum: Int
        public var cNum: Int
        public var question: String
        public var a1: String
        public var a2: String
        public var a3: String
        public var a4: String
        public var currentQuestion: TriviaQuestion
        public var savedQuestions: [TriviaQuestion]
        public var isFetching: Bool
        public var correctAnswerIndex: Int
        public var fractionComplete: Double
        public var isCorrect: String
        public var isRunningTimer: Bool
        public var totalTime: Int
        public var remainingTime: Int
        public var countDownTime: Int
        public var showResults: Bool
        public var daily: Bool
        public var category: String
        public var emojiString = ""
        public var isAnimationInProgress = false
        public var shareString = ""
        public var maxQs = -1
        
        public var gameRunning: Bool = false
        
        public init(totalTime: Int, daily: Bool, category: String) {
            self.qNum = 0
            self.cNum = 0
            self.question = ""
            self.a1 = ""
            self.a2 = ""
            self.a3 = ""
            self.a4 = ""
            self.currentQuestion = defaultTrivia
            self.savedQuestions = []
            self.isFetching = false
            self.correctAnswerIndex = 0
            self.fractionComplete = 0.0
            self.isCorrect = ""
            self.isRunningTimer = false
            self.totalTime = totalTime
            self.remainingTime = totalTime
            self.countDownTime = 3
            self.showResults = false
            self.daily = daily
            self.category = category
            
            if (daily) {
                self.maxQs = 10
            }
        }
    }
    
    static var session: URLSession {
        URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: DefaultHandlingSessionDelegate(),
            delegateQueue: .none
        )
    }
    
    static func validateHttpResponse(data: Data, response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.badResponse(configURL, response)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.badResponseStatus(configURL, httpResponse)
        }
        return data
    }
    
    public enum Action {
        case appear
        case answer(Answer: Int)
        case skip
        case getQuestion
        case setNextQuestion
        case fetch
        case appendSavedQuestions([TriviaQuestion])
        case none
        case startTimer
        case startCountDown
        case stopTimer
        case setRemainingTime(_ : Int)
        case setCountDownTime(_ : Int)
        case startGame
        case stopCountDown
        case showResults
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
    ) -> () -> AnyPublisher<QuestionsModel.Action, Never> {
        {
            var remainingTime = totalTime
            return Timer.publish(every: 1, on: RunLoop.main, in: .common)
                .autoconnect()
                .map { _ in
                    remainingTime -= 1
                    return remainingTime > 0 ? .setRemainingTime(remainingTime) : .stopTimer
                }
                .eraseToAnyPublisher()
        }
    }
    
    public static func countDownPublisher() -> () -> AnyPublisher<QuestionsModel.Action, Never> {
        {
            var remainingTime = 3
            return Timer.publish(every: 1, on: RunLoop.main, in: .common)
                .autoconnect()
                .map { _ in
                    remainingTime -= 1
                    return remainingTime > 0 ? .setCountDownTime(remainingTime) : .startGame
                }
                .eraseToAnyPublisher()
        }
    }

    public var body: some ReducerOf<Self> {

        Reduce { state, action in
            switch action {
                // Your Problem 6B code modifies the two cases below
                case .appear:
                    return Effect.run { send in
                        await send(.startCountDown)
                        await send(.getQuestion, animation: .easeInOut(duration: 0.5))
                    }
                case .answer(let answer):
                    state.fractionComplete = 1.0
                    state.qNum += 1
                    state.isAnimationInProgress = true
                    if (answer == state.correctAnswerIndex) {
                        sounds.correct.play()
                        state.cNum += 1
                        state.emojiString += "✅"
                    } else {
                        sounds.wrong.play()
                        state.emojiString += "🟥"
                    }
                    return Effect.run { send in
                        try? await Task.sleep(for: .seconds(0.7))
                        await send(.getQuestion, animation: .easeInOut(duration: 0.5))
                    }
                case .skip:
                    return .none
                case .getQuestion:
                    state.fractionComplete = 0.0
                    if (state.savedQuestions.count <= 2){
                        return Effect.run { send in
                            await send(.fetch)
                        }
                    }
                    return Effect.run { send in
                        try? await Task.sleep(for: .seconds(0.5))
                        await send(.setNextQuestion)
                    }
                case .fetch:
                    state.isFetching = true
                    var apiUrlString = ""
                    if (state.daily) {
                        apiUrlString = "https://us-east-1.aws.data.mongodb-api.com/app/data-viaqs/endpoint/get_daily"
                    } else {
                        apiUrlString = "https://the-trivia-api.com/v2/questions"
                    }
                    let category = state.category

                    if (category != ""){
                        apiUrlString += "?categories=\(category)"
                    }
                
                    guard let apiUrl = URL(
                        string: apiUrlString.replacingOccurrences(of: " ", with: "").lowercased()
                    ) else {
                        // Handle invalid URL
                        return .none
                    }

                    return Effect
                        .publisher {
                            URLSession
                                .DataTaskPublisher(request: URLRequest(url: apiUrl), session: Self.session)
                                .mapError { APIError.urlError(apiUrl, $0) }
                                .tryMap (Self.validateHttpResponse)
                                .mapError { $0 as! APIError }
                                .decode(type: [TriviaQuestion].self, decoder: JSONDecoder())
                                .replaceError(with: [defaultTrivia])
                                .map { questions in
                                    withAnimation(.easeInOut(duration: 1)) {
                                        return .appendSavedQuestions(questions)
                                    }
                                }
                                .receive(on: DispatchQueue.main)
                        }
                        .cancellable(id: Identifiers.fetchCancellable)
                    
                case .setNextQuestion:
                    //Case where daily cat and reached 10 qs
                    if (state.maxQs != -1 && state.qNum >= state.maxQs) {
                        return Effect.run { send in
                            await send(.stopTimer)
                        }
                    }
                
                    let question = state.savedQuestions.first
                    if (state.savedQuestions.count > 0){
                        state.savedQuestions.removeFirst()
                        state.currentQuestion = question!
                    } else {
                        return Effect.run { send in
                            await send(.fetch)
                        }
                    }
                    // Shuffle the incorrect answers
                    var shuffledChoices = question!.incorrectAnswers.shuffled()
                    
                    // Insert the correct answer at a random position
                    let correctAnswerIndex = Int.random(in: 0...shuffledChoices.count)
                    shuffledChoices.insert(question!.correctAnswer, at: correctAnswerIndex)
                
                    state.a1 = shuffledChoices[0]
                    state.a2 = shuffledChoices[1]
                    state.a3 = shuffledChoices[2]
                    state.a4 = shuffledChoices[3]
                
                    state.correctAnswerIndex = shuffledChoices.firstIndex(of: question!.correctAnswer) ?? 0
                
                    state.isAnimationInProgress = false
                
                    return .none
                case .appendSavedQuestions(let questions):
                    state.savedQuestions.append(contentsOf: questions)
                    return Effect.run { send in
                        await send(.getQuestion)
                    }
                case .none:
                    return .none
                
                case .startTimer:
                    state.isRunningTimer = true
                    return Effect
                        .publisher(QuestionsModel.timerPublisher(state.totalTime))
                        .cancellable(id: QuestionsModel.Identifiers.simulationCancellable)
                
                case .startCountDown:
                    state.isRunningTimer = true
                    return Effect
                        .publisher(QuestionsModel.countDownPublisher())
                        .cancellable(id: QuestionsModel.Identifiers.simulationCancellable)

                case .stopTimer:
                sounds.game_over.play()
                    state.isRunningTimer = false
                return Effect.run { send in
                    await send(.cancelTimer)
                    await send(.showResults)
                }
                
                case .cancelTimer:
                    return .cancel(id: QuestionsModel.Identifiers.simulationCancellable)
                
                case .stopCountDown:
                    return .cancel(id: QuestionsModel.Identifiers.simulationCancellable)
                
                case .setRemainingTime(let time):
                    state.remainingTime = time
                    return .none
                case .setCountDownTime(let time):
                    state.countDownTime = time
                    return .none
                
                case .startGame:
                    state.gameRunning = true
                    return Effect.run { send in
                        await send(.stopCountDown)
                        await send(.startTimer, animation: .easeInOut(duration: 0.5))
                    }
                case .showResults:
                if (state.daily) {
                    state.shareString = "\(state.emojiString) \n I got \(state.cNum) questions correct in today's Time Crunch Trivia Daily Challenge: \(state.category)! Can you beat it?"
                } else {
                    state.shareString = "\(state.emojiString) \n I got \(state.cNum) questions correct in a \(state.totalTime) second Time Crunch Trivia \(state.category + " ")Challenge! Can you beat it?"
                }
                    state.showResults = true
                    return .none
            }
        }
    }
}

public struct QuestionsView: View {
    
    let store: StoreOf<QuestionsModel>
    
    @State private var offsetY: CGFloat = 0
    @State private var offsetY2: CGFloat = 0
    @State private var offsetY3: CGFloat = 0
    
    public init(store: StoreOf<QuestionsModel>) {
        self.store = store
    }

    public var body: some View {
        
        @AppStorage("lastPlayedDailyDay") var lastPlayedDailyDay: Int = 0
        @AppStorage("lastPlayedDailyMonth") var lastPlayedDailyMonth: Int = 0
        @AppStorage("lastPlayedDailyYear") var lastPlayedDailyYear: Int = 0
        
        VStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack {
                    if (viewStore.state.gameRunning){
                        GeometryReader { g in
                            if g.size.width < g.size.height {
                                self.verticalContent(for: viewStore, geometry: g)
                            } else {
                                self.horizontalContent(for: viewStore, geometry: g)
                            }
                        }.background(Color.clear)
                         .navigationDestination(isPresented: viewStore.binding(get: \.showResults, send: { _ in .none })) {
                             ResultsView(
                                 store: self.store,
                                 shareString: viewStore.shareString
                             )
                            }
                    } else {
                        GeometryReader { g in
                            self.countDownView(for: viewStore, geometry: g)
                        }
                    }
                }
                .onAppear{
                    viewStore.send(.appear)
                    
                    let calendar = Calendar.current
                    let currentDate = Date()
                    
                    let dayNumber = calendar.component(.day, from: currentDate)
                    let monthNumber = calendar.component(.month, from: currentDate)
                    let yearNumber = calendar.component(.year, from: currentDate)
                    
                    lastPlayedDailyDay = dayNumber
                    lastPlayedDailyMonth = monthNumber
                    lastPlayedDailyYear = yearNumber
                }
                .onDisappear{
                    viewStore.send(.stopTimer)
                    viewStore.send(.showResults)
                }
                    .background(Color.clear)
                    .navigationBarBackButtonHidden(true)
            }
            
        }
        .background(Image("Background Image").resizable().scaledToFill().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all))
    }

    func verticalContent(
        for viewStore: ViewStoreOf<QuestionsModel>,
        geometry g: GeometryProxy
    ) -> some View {
        VStack {
//            Spacer()
            HStack {
                Spacer()
                Text("TriviaTime")
                    .frame(width: 120)
                    .font(.custom("Arial Rounded MT Bold", size: 20))
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                Spacer()
                
                Image("clock")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .frame(width: 65)
                
                Spacer()
                if (viewStore.state.remainingTime > 60){
                    Text("\(formattedMinutes(from: viewStore.state.remainingTime)):\(formattedSeconds(from: viewStore.state.remainingTime))")
                        .frame(width: 120)
                        .font(.custom("Arial Rounded MT Bold", size: 20))
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                } else {
                    Text("\(viewStore.state.remainingTime)")
                        .frame(width: 120)
                        .font(.custom("Arial Rounded MT Bold", size: 20))
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                }
                Spacer()
            }
            .foregroundColor(.white)
            .font(.title)
            Spacer()

            Text("\(viewStore.state.currentQuestion.question.text)")
                .frame(width: g.size.width - 50, height: 100)
                .lineLimit(4) // Set the maximum number of lines
                .minimumScaleFactor(0.5) // Adjust this value to control the minimum font size
                .padding(.horizontal, 10)
                .padding(.vertical, 20)
                .foregroundColor(.white)
                .font(.custom("Helvetica Neue", size: 20, relativeTo: .title).weight(.bold))
                .overlay(
                    RoundedRectangle(cornerRadius: 12.0)
                        .stroke(Color.white, lineWidth: 2)
                )
                .multilineTextAlignment(.center)
                .background(Color.purple.opacity(0.2))
            
            Spacer()
            Button(action: {viewStore.send(
                .answer(Answer: 0),
                animation: .easeOut(duration: 0.3)
            )}) {
                Text(viewStore.state.a1)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 0.9 * g.size.width)
                    .padding(.vertical, 0.03 * g.size.height)
            }
                .overlay(RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white, lineWidth: 4.0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 2.0)
                .background(
                    viewStore.state.correctAnswerIndex == 0 ? Color.green.opacity(viewStore.state.fractionComplete * 0.5) : Color.red.opacity(viewStore.state.fractionComplete * 0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .disabled(viewStore.state.isAnimationInProgress)
            
            Button(action: {viewStore.send(
                .answer(Answer: 1),
                animation: .easeOut(duration: 0.3)
            )}) {
                Text(viewStore.state.a2)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 0.9 * g.size.width)
                    .padding(.vertical, 0.03 * g.size.height)
            }
                .overlay(RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white, lineWidth: 4.0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 2.0)
                .background(
                    viewStore.state.correctAnswerIndex == 1 ? Color.green.opacity(viewStore.state.fractionComplete * 0.5) : Color.red.opacity(viewStore.state.fractionComplete * 0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .disabled(viewStore.state.isAnimationInProgress)
            
            Button(action: {viewStore.send(
                .answer(Answer: 2),
                animation: .easeOut(duration: 0.3)
            )}) {
                Text(viewStore.state.a3)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 0.9 * g.size.width)
                    .padding(.vertical, 0.03 * g.size.height)
            }
                .overlay(RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white, lineWidth: 4.0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 2.0)
                .background(
                    viewStore.state.correctAnswerIndex == 2 ? Color.green.opacity(viewStore.state.fractionComplete * 0.5) : Color.red.opacity(viewStore.state.fractionComplete * 0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .disabled(viewStore.state.isAnimationInProgress)
            
            Button(action: {viewStore.send(
                .answer(Answer: 3),
                animation: .easeOut(duration: 0.3)
            )}) {
                Text(viewStore.state.a4)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 0.9 * g.size.width)
                    .padding(.vertical, 0.03 * g.size.height)
            }
                .overlay(RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white, lineWidth: 4.0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 2.0)
                .background(
                    viewStore.state.correctAnswerIndex == 3 ? Color.green.opacity(viewStore.state.fractionComplete * 0.5) : Color.red.opacity(viewStore.state.fractionComplete * 0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .disabled(viewStore.state.isAnimationInProgress)
            Spacer()
            Button(action: {
                viewStore.send(.getQuestion)
            }, label: {
                Text("Skip")
                    .font(.custom("Arial Rounded MT Bold", size: 20))
                    .foregroundStyle(Color(.white))
            })
            Spacer()
            
//            Text(viewStore.isCorrect)
//                .opacity(viewStore.state.fractionComplete)
//                .font(.title)
        }
        .background(Color.black.opacity(0.15))
    }

    func horizontalContent(
        for viewStore: ViewStoreOf<QuestionsModel>,
        geometry g: GeometryProxy
    ) -> some View {
        HStack {
        }
    }
    
    func startDropAnimation() {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.6, blendDuration: 1.8)) {
            offsetY = UIScreen.main.bounds.height / 3
        }
    }
    
    func startDropAnimation2() {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.6, blendDuration: 1.8)) {
            offsetY2 = UIScreen.main.bounds.height / 3
        }
    }
    
    func startDropAnimation3() {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.6, blendDuration: 1.8)) {
            offsetY3 = UIScreen.main.bounds.height / 3
        }
    }
    
    func startDisapearAnimation() {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.6, blendDuration: 1.8)) {
            offsetY = UIScreen.main.bounds.height + 100
        }
    }
    
    func startDisapearAnimation2() {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.6, blendDuration: 1.8)) {
            offsetY2 = UIScreen.main.bounds.height + 150
        }
    }
    
    func startDisapearAnimation3() {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.6, blendDuration: 1.8)) {
            offsetY3 = UIScreen.main.bounds.height + 150
        }
    }
    
    func countDownView(
        for viewStore: ViewStoreOf<QuestionsModel>,
        geometry g: GeometryProxy
    ) -> some View {
        
        return HStack {
            Spacer()
            
            ZStack(alignment: .center) {
                Spacer()
                
                
                if (viewStore.state.countDownTime == 1 || viewStore.state.countDownTime == 2 || viewStore.state.countDownTime == 3){
                    Text("3")
                        .font(.custom("Arial Rounded MT Bold", size: 350))
                        .foregroundStyle(Color(.white))
                        .frame(width: 350, height: 350)
                        .minimumScaleFactor(0.1)
                        .offset(y: -100)
                        .offset(y: offsetY)
                        .onAppear {
                            startDropAnimation()
                        }
                }
                if (viewStore.state.countDownTime == 1 || viewStore.state.countDownTime == 2){
                    Text("2")
                        .font(.custom("Arial Rounded MT Bold", size: 230))
                        .frame(width: 230, height: 230)
                        .minimumScaleFactor(0.1)
                        .foregroundStyle(Color(.white))
                        .offset(y: -100)
                        .offset(y: offsetY2)
                    //                        .animation(.spring(response: 1.0, dampingFraction: 1.0, blendDuration: 1.0), value: viewStore.state.countDownTime * 100)
                        .onAppear {
                            startDropAnimation2()
                            startDisapearAnimation()
                        }
                }
                if (viewStore.state.countDownTime == 1){
                    Text("1")
                        .font(.custom("Arial Rounded MT Bold", size: 100))
                        .frame(width: 150, height: 150)
                        .minimumScaleFactor(0.1)
                        .foregroundStyle(Color(.white))
                        .offset(y: -100)
                        .offset(y: offsetY3)
                    //                        .animation(.spring(response: 1.0, dampingFraction: 1.0, blendDuration: 1.0), value: viewStore.state.countDownTime * 100)
                        .onAppear {
                            startDropAnimation3()
                            startDisapearAnimation2()
                        }
                }
            }
            Spacer()
        }
    }
    
}

#Preview {
    let previewState = QuestionsModel.State(totalTime: 60, daily: false, category: "")
    return QuestionsView(
        store: Store(
            initialState: previewState,
            reducer: QuestionsModel.init
        )
    )
}
