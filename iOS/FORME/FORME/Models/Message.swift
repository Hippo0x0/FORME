import Foundation

class Message {
    let id: String
    var content: String
    let isUser: Bool
    let timestamp: Date

    init(id: String, content: String, isUser: Bool, timestamp: Date) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }

    convenience init(content: String, isUser: Bool) {
        self.init(
            id: UUID().uuidString,
            content: content,
            isUser: isUser,
            timestamp: Date()
        )
    }
}
