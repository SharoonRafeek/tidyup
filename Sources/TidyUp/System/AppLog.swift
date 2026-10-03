import Foundation
import OSLog

enum AppLog {
    private static let logger = Logger(subsystem: "com.sharoonrafeek.tidyup", category: "runtime")

    static func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
        printToConsole(level: "INFO", message: message)
    }

    static func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
        printToConsole(level: "ERROR", message: message)
    }

    private static func printToConsole(level: String, message: String) {
        let timestamp = Date.now.formatted(date: .omitted, time: .standard)
        fputs("\(timestamp) [\(level)] \(message)\n", stderr)
    }
}
