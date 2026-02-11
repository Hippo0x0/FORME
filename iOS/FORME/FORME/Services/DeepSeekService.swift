import Foundation
import Alamofire
import AnyLanguageModel

class DeepSeekService {
    static let shared = DeepSeekService()

    private let baseURL = "https://api.deepseek.com"
    private var apiKey: String?
    private var model: String = "deepseek-chat"

    private init() {
        loadConfiguration()
    }

    private func loadConfiguration() {
        let settings = UserSettings.current
        apiKey = settings.deepSeekAPIKey
        model = settings.deepSeekModelName
    }

    func updateConfiguration() {
        loadConfiguration()
    }

    var isConfigured: Bool {
        return apiKey?.isEmpty == false
    }

    // MARK: - Chat Completion

    func chatCompletion(
        messages: [ChatMessage],
        maxTokens: Int32? = nil,
        temperature: Double = 0.7,
        stream: Bool = true
    ) async throws -> ChatCompletionResponse {
        guard let apiKey = apiKey else {
            throw DeepSeekError.apiKeyNotConfigured
        }

        let url = "\(baseURL)/chat/completions"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]

        let request = ChatCompletionRequest(
            model: model,
            messages: messages,
            maxTokens: maxTokens ?? UserSettings.current.singleRequestLimit,
            temperature: temperature,
            stream: stream
        )

        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
                .validate()
                .responseDecodable(of: ChatCompletionResponse.self) { response in
                    switch response.result {
                    case .success(let completionResponse):
                        // 记录token使用量
//                        if let usage = completionResponse.usage {
//                            DataStoreService.shared.recordDeepSeekTokenUsage(tokens: usage.totalTokens)
//                        }
                        continuation.resume(returning: completionResponse)
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error))
                    }
                }
        }
    }

    // MARK: - Analysis Functions

    func analyzeText(
        text: String,
        analysisType: AnalysisType,
        maxTokens: Int32? = nil
    ) async throws -> AnalysisResult {
        let systemPrompt = analysisType.systemPrompt
        let userPrompt = analysisType.userPrompt(for: text)

        let messages: [ChatMessage] = [
            ChatMessage(role: .system, content: systemPrompt),
            ChatMessage(role: .user, content: userPrompt)
        ]

        let response = try await chatCompletion(
            messages: messages,
            maxTokens: maxTokens,
            temperature: analysisType.temperature
        )

        guard let content = response.choices.first?.message.content else {
            throw DeepSeekError.emptyResponse
        }

        return AnalysisResult(
            type: analysisType,
            content: content,
            rawResponse: response
        )
    }

    func analyzeMaterial(
        material: Material,
        analysisType: AnalysisType,
        maxTokens: Int32? = nil
    ) async throws -> AnalysisResult {
        guard let content = material.content else {
            throw DeepSeekError.invalidInput
        }

        return try await analyzeText(
            text: content,
            analysisType: analysisType,
            maxTokens: maxTokens
        )
    }

    func analyzeMultipleMaterials(
        materials: [Material],
        analysisType: AnalysisType,
        maxTokens: Int32? = nil
    ) async throws -> AnalysisResult {
        let combinedText = materials.compactMap { $0.content }.joined(separator: "\n\n---\n\n")
        return try await analyzeText(
            text: combinedText,
            analysisType: analysisType,
            maxTokens: maxTokens
        )
    }

    func answerQuestion(
        question: String,
        context: String? = nil,
        maxTokens: Int32? = nil
    ) async throws -> String {
        var messages: [ChatMessage] = []

        if let context = context {
            messages.append(ChatMessage(role: .system, content: "基于以下上下文回答问题：\n\(context)"))
        }

        messages.append(ChatMessage(role: .user, content: question))

        let response = try await chatCompletion(
            messages: messages,
            maxTokens: maxTokens,
            temperature: 0.3 // 较低的温度以获得更确定的答案
        )

        guard let content = response.choices.first?.message.content else {
            throw DeepSeekError.emptyResponse
        }

        return content
    }

    func generateSummary(
        text: String,
        length: SummaryLength = .medium,
        maxTokens: Int32? = nil
    ) async throws -> String {
        let analysisType = AnalysisType.summary(length: length)
        let result = try await analyzeText(
            text: text,
            analysisType: analysisType,
            maxTokens: maxTokens
        )
        return result.content
    }

    func findConnections(
        materials: [Material],
        maxTokens: Int32? = nil
    ) async throws -> String {
        let analysisType = AnalysisType.connection
        let result = try await analyzeMultipleMaterials(
            materials: materials,
            analysisType: analysisType,
            maxTokens: maxTokens
        )
        return result.content
    }

    func generateInsights(
        material: Material,
        maxTokens: Int32? = nil
    ) async throws -> [String] {
        let analysisType = AnalysisType.insight
        let result = try await analyzeMaterial(
            material: material,
            analysisType: analysisType,
            maxTokens: maxTokens
        )

        // 解析洞察点，假设每个洞察点以 "- " 或数字开头
        let lines = result.content.components(separatedBy: .newlines)
        let insights = lines.filter { line in
            line.hasPrefix("- ") || line.hasPrefix("• ") || line.rangeOfCharacter(from: .decimalDigits) != nil
        }.map { line in
            line.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return insights.isEmpty ? [result.content] : insights
    }

    // MARK: - Test Connection

    func testConnection() async throws -> Bool {
        guard let apiKey = apiKey else {
            throw DeepSeekError.apiKeyNotConfigured
        }

        let url = "\(baseURL)/models"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)"
        ]

        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .get, headers: headers)
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success:
                        continuation.resume(returning: true)
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error))
                    }
                }
        }
    }

    // MARK: - Error Handling

    private func handleError(_ error: AFError) -> Error {
        if let underlyingError = error.underlyingError {
            return underlyingError
        }

        if let responseCode = error.responseCode {
            switch responseCode {
            case 401:
                return DeepSeekError.invalidAPIKey
            case 429:
                return DeepSeekError.rateLimitExceeded
            case 500...599:
                return DeepSeekError.serverError
            default:
                return DeepSeekError.networkError(error.localizedDescription)
            }
        }

        return DeepSeekError.unknownError(error.localizedDescription)
    }
}

// MARK: - Data Models

enum DeepSeekError: Error, LocalizedError {
    case apiKeyNotConfigured
    case invalidAPIKey
    case rateLimitExceeded
    case serverError
    case networkError(String)
    case unknownError(String)
    case emptyResponse
    case invalidInput

    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured:
            return "API Key未配置"
        case .invalidAPIKey:
            return "API Key无效"
        case .rateLimitExceeded:
            return "请求频率超限"
        case .serverError:
            return "服务器错误"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .unknownError(let message):
            return "未知错误: \(message)"
        case .emptyResponse:
            return "响应为空"
        case .invalidInput:
            return "输入无效"
        }
    }
}

struct ChatMessage: Codable {
    enum Role: String, Codable {
        case system
        case user
        case assistant
    }

    let role: Role
    let content: String
}

struct ChatCompletionRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
    let maxTokens: Int32?
    let temperature: Double
    let stream: Bool

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxTokens = "max_tokens"
        case temperature
        case stream
    }
}

struct ChatCompletionResponse: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage?

    struct Choice: Decodable {
        let index: Int
        let message: Message
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }

        struct Message: Decodable {
            let role: String
            let content: String
        }
    }

    struct Usage: Decodable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int

        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

enum AnalysisType {
    case deepUnderstanding
    case questionAnswering
    case connection
    case insight
    case summary(length: SummaryLength)
    case custom(systemPrompt: String, userPrompt: (String) -> String, temperature: Double)

    var systemPrompt: String {
        switch self {
        case .deepUnderstanding:
            return "你是一个专业的研究助手。请对提供的文本进行深度理解分析，提取核心观点、关键论据、重要数据和潜在意义。"
        case .questionAnswering:
            return "你是一个知识渊博的助手。请基于提供的上下文准确回答问题。如果无法确定答案，请诚实地说明。"
        case .connection:
            return "你是一个关联分析专家。请分析多个文本之间的关联性，发现隐藏的联系、共同主题和差异点。"
        case .insight:
            return "你是一个洞察生成专家。请从文本中提取有价值的洞察点，包括趋势、模式、启示和建议。"
        case .summary(let length):
            switch length {
            case .short:
                return "请生成一个简洁的摘要，突出文本的核心内容。"
            case .medium:
                return "请生成一个中等长度的摘要，包含主要观点和关键细节。"
            case .long:
                return "请生成一个详细的摘要，涵盖文本的所有重要方面。"
            }
        case .custom(let systemPrompt, _, _):
            return systemPrompt
        }
    }

    func userPrompt(for text: String) -> String {
        switch self {
        case .deepUnderstanding:
            return "请对以下文本进行深度理解分析：\n\n\(text)"
        case .questionAnswering:
            return "请基于以下文本回答问题：\n\n\(text)"
        case .connection:
            return "请分析以下文本之间的关联性：\n\n\(text)"
        case .insight:
            return "请从以下文本中提取洞察点：\n\n\(text)"
        case .summary:
            return "请为以下文本生成摘要：\n\n\(text)"
        case .custom(_, let userPrompt, _):
            return userPrompt(text)
        }
    }

    var temperature: Double {
        switch self {
        case .deepUnderstanding, .connection, .insight:
            return 0.7
        case .questionAnswering:
            return 0.3
        case .summary:
            return 0.5
        case .custom(_, _, let temperature):
            return temperature
        }
    }
}

enum SummaryLength {
    case short
    case medium
    case long
}

struct AnalysisResult {
    let type: AnalysisType
    let content: String
    let rawResponse: ChatCompletionResponse
    let timestamp: Date

    init(type: AnalysisType, content: String, rawResponse: ChatCompletionResponse) {
        self.type = type
        self.content = content
        self.rawResponse = rawResponse
        self.timestamp = Date()
    }
}

// MARK: - Streaming Models

struct ChatCompletionStreamResponse: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [StreamChoice]

    struct StreamChoice: Decodable {
        let index: Int
        let delta: Delta
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case index
            case delta
            case finishReason = "finish_reason"
        }

        struct Delta: Decodable {
            let role: String?
            let content: String?
        }
    }
}

// MARK: - Streaming Support

extension DeepSeekService {
    /// 流式聊天完成请求
    /// - Parameters:
    ///   - messages: 消息数组
    ///   - maxTokens: 最大token数
    ///   - temperature: 温度参数
    ///   - onChunk: 每收到一个数据块时的回调，返回累积的完整响应内容
    ///   - onCompletion: 流式请求完成时的回调
    func chatCompletionStream(
        messages: [ChatMessage],
        maxTokens: Int32? = nil,
        temperature: Double = 0.7,
        onChunk: @escaping (String) -> Void,
        onCompletion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let apiKey = apiKey else {
            onCompletion(.failure(DeepSeekError.apiKeyNotConfigured))
            return
        }

        let url = "\(baseURL)/chat/completions"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json",
            "Accept": "text/event-stream"
        ]

        let request = ChatCompletionRequest(
            model: model,
            messages: messages,
            maxTokens: maxTokens ?? UserSettings.current.singleRequestLimit,
            temperature: temperature,
            stream: true
        )

        var accumulatedContent = ""

        AF.streamRequest(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseStream { [weak self] stream in
                guard let self = self else { return }

                switch stream.event {
                case .stream(let result):
                    switch result {
                    case .success(let data):
                        if let chunkString = String(data: data, encoding: .utf8) {
                            self.processStreamChunk(chunkString, accumulatedContent: &accumulatedContent, onChunk: onChunk)
                        }
                    case .failure(let error):
                        // todo@zpj
                        break
//                        onCompletion(.failure(self.handleError(error)))
                    }

                case .complete(let completion):
                    if let error = completion.error {
                        onCompletion(.failure(self.handleError(error)))
                    } else {
                        onCompletion(.success(accumulatedContent))
                    }
                }
            }
    }

    /// 处理流式数据块
    private func processStreamChunk(_ chunkString: String, accumulatedContent: inout String, onChunk: @escaping (String) -> Void) {
        // 按行分割，处理SSE格式
        let lines = chunkString.components(separatedBy: .newlines)

        for line in lines {
            guard line.hasPrefix("data: ") else { continue }

            let jsonString = String(line.dropFirst(6)) // 移除"data: "前缀

            // 如果是"[DONE]"消息，跳过
            if jsonString.trimmingCharacters(in: .whitespacesAndNewlines) == "[DONE]" {
                continue
            }

            guard let data = jsonString.data(using: .utf8) else { continue }

            do {
                let response = try JSONDecoder().decode(ChatCompletionStreamResponse.self, from: data)

                // 提取内容增量
                for choice in response.choices {
                    if let content = choice.delta.content {
                        accumulatedContent += content
                        onChunk(accumulatedContent)
                    }
                }
            } catch {
                print("Failed to decode streaming chunk: \(error)")
            }
        }
    }
}

// MARK: - Usage Tracking

extension DeepSeekService {
    func getMonthlyUsage() -> Int {
        return Int(UsageStatistics.getTotalMonthlyTokens())
    }

    func getMonthlyLimit() -> Int {
        return Int(UserSettings.current.monthlyTokenLimit)
    }

    func getUsagePercentage() -> Double {
        let usage = getMonthlyUsage()
        let limit = getMonthlyLimit()
        guard limit > 0 else { return 0 }
        return Double(usage) / Double(limit) * 100
    }

    func isNearLimit(threshold: Int = 80) -> Bool {
        return getUsagePercentage() >= Double(threshold)
    }

    func hasSufficientTokens(for estimatedTokens: Int32) -> Bool {
        let remaining = getMonthlyLimit() - getMonthlyUsage()
        return remaining >= estimatedTokens
    }
}

// MARK: - Fallback Mechanism

extension DeepSeekService {
    func analyzeWithFallback(
        text: String,
        analysisType: AnalysisType,
        maxTokens: Int32? = nil
    ) async -> AnalysisResult {
        let settings = UserSettings.current

        // 检查API模式
        switch settings.userAPIMode {
        case .localOnly:
            return await LocalAnalysisService.shared.analyzeText(
                text: text,
                analysisType: analysisType
            )
        case .apiOnly:
            do {
                return try await analyzeText(
                    text: text,
                    analysisType: analysisType,
                    maxTokens: maxTokens
                )
            } catch {
                if settings.enableAutoFallback {
                    print("DeepSeek API失败，回退到本地分析: \(error)")
                    return await LocalAnalysisService.shared.analyzeText(
                        text: text,
                        analysisType: analysisType
                    )
                } else {
                    // 重新抛出错误
                    fatalError("DeepSeek API失败且未启用自动回退: \(error)")
                }
            }
        case .auto:
            if isConfigured && hasSufficientTokens(for: maxTokens ?? 1000) {
                do {
                    return try await analyzeText(
                        text: text,
                        analysisType: analysisType,
                        maxTokens: maxTokens
                    )
                } catch where settings.enableAutoFallback {
                    print("DeepSeek API失败，回退到本地分析: \(error)")
                    return await LocalAnalysisService.shared.analyzeText(
                        text: text,
                        analysisType: analysisType
                    )
                } catch {
                    print("DeepSeek API失败，回退到本地分析: \(error)")
                  // todo@zpj
                  return AnalysisResult(type: .questionAnswering, content: "ERROR", rawResponse: ChatCompletionResponse(id: "-1", object: "", created: 0, model: "", choices: [], usage: nil))
//                    throw error
                }
            } else {
                return await LocalAnalysisService.shared.analyzeText(
                    text: text,
                    analysisType: analysisType
                )
            }
        }
    }
}
