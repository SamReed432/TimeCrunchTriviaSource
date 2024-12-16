import Foundation
import SwiftUI
import ComposableArchitecture

struct StatsView: View {
    @AppStorage("game_results") private var gameResultsData: Data = Data()
    
    @EnvironmentObject var views: Views

    private var gameResults: [GameResult] {
        decodeGameResults()
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    BackgroundImageView()
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        headerView
                        
                        statsSummaryView(geometry: geometry)
                        
                        bestCategoryView(geometry: geometry)
                        
                        Text("Game Log")
                            .underline()
                            .font(.title)
                            .foregroundStyle(Color.white)
                            .padding()
                        
                        // ScrollView takes up the remaining space
                        gameResultsScrollView(geometry: geometry)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 4)
                            )
                        
                        Spacer() // Pushes the content upwards and ensures layout remains correct
                    }
                }
            }
        }
        .background(
            Image("Background Image")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        )
    }
}

// MARK: - Helper Functions and Computations
extension StatsView {
    private func decodeGameResults() -> [GameResult] {
        guard let decoded = try? JSONDecoder().decode([GameResult].self, from: gameResultsData) else {
            return []
        }
        return decoded
    }
    
    private func calculateDailyAverage() -> Double {
        let dailyResults = gameResults.filter { $0.isDaily }
        guard !dailyResults.isEmpty else { return 0 }
        let totalScore = dailyResults.reduce(0) { $0 + $1.correctAnswers }
        return Double(totalScore) / Double(dailyResults.count) * 100
    }
    
    private func calculateOverallAccuracy() -> Double {
        let totalCorrect = gameResults.reduce(0) { $0 + $1.correctAnswers }
        let totalQuestions = gameResults.reduce(0) { $0 + $1.totalQuestions }
        return totalQuestions > 0 ? Double(totalCorrect) / Double(totalQuestions) * 100 : 0
    }
    
    private func calculateBestCategory() -> String? {
        guard !gameResults.isEmpty else { return nil }
        let validResults = gameResults.filter { !$0.category.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !validResults.isEmpty else { return nil }

        let categoryScores = Dictionary(grouping: validResults, by: { $0.category })
            .mapValues { results in
                let totalScore = results.reduce(0) { $0 + $1.correctAnswers }
                let totalQuestions = results.reduce(0) { $0 + $1.totalQuestions }
                return totalQuestions > 0 ? Double(totalScore) / Double(totalQuestions) : 0
            }
        
        return categoryScores.max(by: { $0.value < $1.value })?.key
    }
    
    private func calculateRank(accuracy: Double, gamesPlayed: Int) -> String {
        // Normalize accuracy to be between 0 and 100 if needed
        let normalizedAccuracy = min(max(accuracy, 0), 100)
        
        // Define weightings for accuracy and games played (e.g., 70% accuracy, 30% games played)
        let accuracyWeight = 0.7
        let gamesWeight = 0.3
        
        // Scale games played to a comparable range, for example, between 0 and 100
        let maxGames = 100  // This can be adjusted based on your dataset
        let normalizedGames = min(Double(gamesPlayed), Double(maxGames))
        
        // Calculate the weighted score
        let weightedScore = (accuracyWeight * normalizedAccuracy) + (gamesWeight * normalizedGames)
        
        // Determine the rank based on the score
        switch weightedScore {
        case 90...100:
            return "A+"
        case 80..<90:
            return "A"
        case 70..<80:
            return "B"
        case 60..<70:
            return "C"
        case 50..<60:
            return "D"
        default:
            return "F"
        }
    }

}

// MARK: - Subviews
extension StatsView {
    private var headerView: some View {
        ZStack {
            HStack {
                Button(action: {
                    views.statsShown = false
                }) {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                }
                Spacer()
            }
            
            Text("Stats")
                .font(.largeTitle)
                .foregroundStyle(Color.white)
                .padding()
        }
    }
    
    private func statsSummaryView(geometry: GeometryProxy) -> some View {
        VStack {
            HStack {
                summaryColumn(title: "Daily Average:", value: String(format: "%.1f%%", calculateDailyAverage()))
                summaryColumn(title: "Dailies Played:", value: "\(gameResults.filter(\.isDaily).count)")
            }
                .padding(.vertical)
                .frame(width: geometry.size.width * 0.95)
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 4)
                )
            HStack {
                summaryColumn(title: "Overall Accuracy:", value: String(format: "%.1f%%", calculateOverallAccuracy()))
                summaryColumn(title: "Games Played:", value: "\(gameResults.count)")
            }
                .padding(.vertical)
                .frame(width: geometry.size.width * 0.95)
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 4)
                )
        }
    }
    
    private func summaryColumn(title: String, value: String) -> some View {
        VStack {
            Text(title)
                .font(.title2)
                .foregroundStyle(Color.white)
            Text(value)
                .font(.title2)
                .foregroundStyle(Color.white)
        }
    }
    
    private func bestCategoryView(geometry: GeometryProxy) -> some View {
        HStack {
            VStack {
                Text("Best Category: \(calculateBestCategory() ?? "?")")
//                Text("\(calculateBestCategory() ?? "?")")
            }
                .frame(width: geometry.size.width * 0.72)
                .padding(.vertical)
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 4)
                )
                .foregroundStyle(Color.white)
                .font(.title2)
            
            Text("\(calculateRank(accuracy: calculateOverallAccuracy(), gamesPlayed: gameResults.count))")
                .frame(width: geometry.size.width * 0.20)
                .padding(.vertical, 13)
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 4)
                )
                .foregroundStyle(Color.white)
                .font(.title)
                .fontWeight(.bold)
            
        }
        .frame(width: geometry.size.width * 0.95)
    }
    
    private func gameResultsScrollView(geometry: GeometryProxy) -> some View {
        ScrollView {
            ForEach(gameResults) { result in
                HStack {
                    Image(systemName: "circle.fill")
                    VStack(alignment: .leading) {
                        Text("Date: \(result.date.formatted())")
                        Text("Score: \(result.correctAnswers)/\(result.totalQuestions)")
                        if result.isDaily {
                            Text("Daily Challenge")
                                .font(.footnote)
                                .foregroundColor(Color.white)
                        }
                    }
                    Spacer()
                }
                .padding()
                .frame(width: geometry.size.width * 0.82)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.white, lineWidth: 2)
                )
                .padding(.top, 10)
                .foregroundStyle(Color.white)
                
            }
        }
        .frame(maxHeight: geometry.size.height * 0.45)
        .frame(width: geometry.size.width * 0.9)
        .scrollIndicators(.hidden)
    }
}

#Preview {
    StatsView()
}
