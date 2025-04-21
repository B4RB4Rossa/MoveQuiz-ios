import UIKit

protocol MovieQuizViewProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showNetworkError(message: String)
}
