import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {

    // MARK: - Mocks

    final class MockView: MovieQuizViewProtocol {
        var quizStepShown: QuizStepViewModel?
        var quizResultShown: QuizResultsViewModel?
        var loadingShown = false
        var loadingHidden = false
        var networkError: String?
        var imageBorderWasHighlighted: Bool?

        func show(quiz step: QuizStepViewModel) {
            quizStepShown = step
        }

        func show(quiz result: QuizResultsViewModel) {
            quizResultShown = result
        }

        func showLoadingIndicator() {
            loadingShown = true
        }

        func hideLoadingIndicator() {
            loadingHidden = true
        }

        func highlightImageBorder(isCorrectAnswer: Bool) {
            imageBorderWasHighlighted = isCorrectAnswer
        }

        func showNetworkError(message: String) {
            networkError = message
        }
    }

    final class StubQuestionFactory: QuestionFactoryProtocol {
        var delegate: QuestionFactoryDelegate?
        var stubQuestion: QuizQuestion?
        var loadDataCalled = false
        var requestNextQuestionCalled = false
        var resetGameCalled = false

        func loadData() {
            loadDataCalled = true
            delegate?.didLoadDataFromServer()
        }

        func requestNextQuestion() {
            requestNextQuestionCalled = true
            delegate?.didReceiveNextQuestion(question: stubQuestion)
        }

        func resetGame() {
            resetGameCalled = true
        }
    }

    final class DummyStatisticService: StatisticServiceProtocol {
        var gamesCount: Int = 5
        var bestGame: GameResult = GameResult(correct: 9, total: 10, date: Date())
        var totalAccuracy: Double = 87.0
        var storeCalled = false

        func store(correct count: Int, total amount: Int) {
            storeCalled = true
        }
    }

    // MARK: - Tests

    func testPresenterHandlesCorrectAnswer() {
        let view = MockView()
        let question = QuizQuestion(image: Data(), text: "Test?", correctAnswer: true)
        let factory = StubQuestionFactory()
        factory.stubQuestion = question
        
        let presenter = MovieQuizPresenter(view: view)
        presenter.questionFactory = factory
        factory.delegate = presenter
        presenter.didReceiveNextQuestion(question: question)

        presenter.yesButtonClicked()

        XCTAssertEqual(view.imageBorderWasHighlighted, true)
    }

    func testPresenterHandlesWrongAnswer() {
        let view = MockView()
        let question = QuizQuestion(image: Data(), text: "Test?", correctAnswer: false)
        let factory = StubQuestionFactory()
        factory.stubQuestion = question

        let presenter = MovieQuizPresenter(view: view)
        presenter.questionFactory = factory
        factory.delegate = presenter
        presenter.didReceiveNextQuestion(question: question)

        presenter.yesButtonClicked()

        XCTAssertEqual(view.imageBorderWasHighlighted, false)
    }

    func testPresenterCallsShowQuizStep() {
        let view = MockView()
        let question = QuizQuestion(image: Data(), text: "Some text?", correctAnswer: true)
        let factory = StubQuestionFactory()
        factory.stubQuestion = question

        let presenter = MovieQuizPresenter(view: view)
        presenter.questionFactory = factory
        factory.delegate = presenter
        presenter.didReceiveNextQuestion(question: question)

        XCTAssertNotNil(view.quizStepShown)
        XCTAssertEqual(view.quizStepShown?.question, "Some text?")
    }

    func testPresenterCallsShowQuizResultAfterLastQuestion() {
        let view = MockView()
        let factory = StubQuestionFactory()
        let statService = DummyStatisticService()
        let presenter = MovieQuizPresenter(view: view)
        presenter.questionFactory = factory
        factory.delegate = presenter

        presenter.correctAnswers = 9
        presenter.currentQuestionIndex = 9
        presenter.proceedToNextQuestionOrResults()

        XCTAssertNotNil(view.quizResultShown)
        XCTAssertTrue(view.quizResultShown!.text.contains("Ваш результат"))
    }

    func testPresenterRestartsGame() {
        let view = MockView()
        let factory = StubQuestionFactory()
        let presenter = MovieQuizPresenter(view: view)
        presenter.questionFactory = factory
        factory.delegate = presenter

        presenter.restartGame()

        XCTAssertEqual(presenter.correctAnswers, 0)
        XCTAssertEqual(presenter.currentQuestionIndex, 0)
        XCTAssertTrue(factory.resetGameCalled)
        XCTAssertTrue(factory.requestNextQuestionCalled)
    }
}
