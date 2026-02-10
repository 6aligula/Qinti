import Foundation

enum AppConstants {
    static let chatAPIBaseURL = "https://moldline-api-312503514287.europe-southwest1.run.app"
    static let authAPIBaseURL = "https://moldline-auth-gjoom7xsla-no.a.run.app"
    static let wsBaseURL = "wss://moldline-api-312503514287.europe-southwest1.run.app"

    static func wsURL(userId: String) -> URL {
        URL(string: "\(wsBaseURL)/ws?userId=\(userId)")!
    }
}
