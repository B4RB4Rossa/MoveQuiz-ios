import UIKit


final class StatisticServiceImplementation: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correct, total, gamesCount
        case bestGameCorrect, bestGameTotal, bestGameDate
    }
    
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let total = storage.integer(forKey: Keys.total.rawValue)
        let correct = storage.integer(forKey: Keys.correct.rawValue)
        guard total > 0 else { return 0 }
        return (Double(correct) / Double(total)) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        let newCorrect = storage.integer(forKey: Keys.correct.rawValue) + count
        let newTotal = storage.integer(forKey: Keys.total.rawValue) + amount
        storage.set(newCorrect, forKey: Keys.correct.rawValue)
        storage.set(newTotal, forKey: Keys.total.rawValue)
        
        gamesCount += 1
        
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}

