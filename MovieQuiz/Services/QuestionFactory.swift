import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    private var usedQuestionIndices = Set<Int>()

    private func loadImageData(url: URL, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            completion(data)
        }
        task.resume()
    }

    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            guard !self.movies.isEmpty else {
                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: nil)
                }
                return
            }
            
            let availableIndices = Set(0..<self.movies.count).subtracting(self.usedQuestionIndices)
            guard let randomIndex = availableIndices.randomElement() else {
    
                DispatchQueue.main.async {
                    self.delegate?.didEndQuestions()
                }
                return
            }
            
            self.usedQuestionIndices.insert(randomIndex)
            let movie = self.movies[randomIndex]
            
            self.loadImageData(url: movie.resizedImageURL) { [weak self] imageData in
                guard let self = self else { return }
                
                let rating = Float(movie.rating) ?? 0
                let text = "Рейтинг этого фильма больше чем 7?"
                let correctAnswer = rating > 7
                
                let question = QuizQuestion(
                    image: imageData ?? Data(),
                    text: text,
                    correctAnswer: correctAnswer
                )
                
                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            }
        }
    }
    
    func resetGame() {
        usedQuestionIndices.removeAll()
    }
    
}
