import Foundation
import NaturalLanguage

class LocalAnalysisService {
    static let shared = LocalAnalysisService()

    private let tagger = NLTagger(tagSchemes: [.language, .lemma, .nameType])
    private let tokenizer = NLTokenizer(unit: .word)
    private let sentimentAnalyzer = NLTagger(tagSchemes: [.sentimentScore])

    private init() {}

    // MARK: - Text Analysis

    func analyzeText(
        text: String,
        analysisType: AnalysisType
    ) async -> AnalysisResult {
        // 模拟异步处理
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = self.performAnalysis(text: text, analysisType: analysisType)
                continuation.resume(returning: result)
            }
        }
    }

    private func performAnalysis(
        text: String,
        analysisType: AnalysisType
    ) -> AnalysisResult {
        let content: String

        switch analysisType {
        case .deepUnderstanding:
            content = performDeepUnderstanding(text: text)
        case .questionAnswering:
            content = performQuestionAnswering(text: text)
        case .connection:
            content = performConnectionAnalysis(text: text)
        case .insight:
            content = performInsightGeneration(text: text)
        case .summary(let length):
            content = performSummarization(text: text, length: length)
        case .custom(_, let userPrompt, _):
            content = performCustomAnalysis(text: text, prompt: userPrompt(text))
        }

        // 创建模拟的API响应
        let mockResponse = createMockResponse(content: content)

        return AnalysisResult(
            type: analysisType,
            content: content,
            rawResponse: mockResponse
        )
    }

    // MARK: - Analysis Methods

    private func performDeepUnderstanding(text: String) -> String {
        let sentences = extractSentences(from: text)
        let keywords = extractKeywords(from: text, count: 10)
        let entities = extractNamedEntities(from: text)
        let sentiment = analyzeSentiment(text: text)
        let language = detectLanguage(text: text)

        var result = "## 深度理解分析\n\n"

        result += "### 文本概览\n"
        result += "- 语言: \(language)\n"
        result += "- 句子数量: \(sentences.count)\n"
        result += "- 情感倾向: \(sentiment)\n\n"

        result += "### 关键内容\n"
        for (index, sentence) in sentences.prefix(5).enumerated() {
            result += "\(index + 1). \(sentence)\n"
        }
        result += "\n"

        result += "### 关键词\n"
        for (index, keyword) in keywords.enumerated() {
            result += "- \(keyword)\n"
        }
        result += "\n"

        if !entities.isEmpty {
            result += "### 命名实体\n"
            for entity in entities.prefix(5) {
                result += "- \(entity.type): \(entity.text)\n"
            }
            result += "\n"
        }

        result += "### 核心观点\n"
        result += "1. 文本主要讨论了\(keywords.first ?? "相关主题")\n"
        result += "2. 强调了\(sentences.first?.components(separatedBy: " ").prefix(5).joined(separator: " ") ?? "重要内容")\n"
        result += "3. 提供了关于\(keywords.last ?? "相关领域")的见解\n"

        return result
    }

    private func performQuestionAnswering(text: String) -> String {
        let sentences = extractSentences(from: text)
        let keywords = extractKeywords(from: text, count: 5)

        var result = "## 问题回答\n\n"

        if sentences.count >= 3 {
            result += "根据文本内容，可以得出以下回答：\n\n"
            result += "文本主要讨论了\(keywords.first ?? "相关主题")。"
            result += "其中提到\(sentences[1])。"
            result += "此外，还涉及\(sentences.last ?? "其他相关内容")。\n\n"

            result += "### 关键信息\n"
            for (index, keyword) in keywords.enumerated() {
                result += "\(index + 1). \(keyword)\n"
            }
        } else {
            result += "文本内容较短，提供的信息有限。\n"
            result += "主要涉及：\(text.prefix(100))...\n"
        }

        result += "\n注：这是基于本地模型的简单分析，深度问题建议使用DeepSeek API。"

        return result
    }

    private func performConnectionAnalysis(text: String) -> String {
        let paragraphs = text.components(separatedBy: "\n\n")
        let keywords = extractKeywords(from: text, count: 15)
        let entities = extractNamedEntities(from: text)

        var result = "## 关联分析\n\n"

        result += "### 文本结构\n"
        result += "- 段落数量: \(paragraphs.count)\n"
        result += "- 主要话题: \(keywords.prefix(3).joined(separator: ", "))\n\n"

        result += "### 主题关联\n"
        let groupedKeywords = groupKeywords(keywords)
        for (group, words) in groupedKeywords {
            result += "**\(group)**: \(words.joined(separator: ", "))\n"
        }
        result += "\n"

        if !entities.isEmpty {
            result += "### 实体网络\n"
            for entity in entities.prefix(8) {
                result += "- \(entity.type): \(entity.text)\n"
            }
            result += "\n"
        }

        result += "### 关联发现\n"
        result += "1. 文本围绕\(keywords.first ?? "核心主题")展开\n"
        result += "2. 各段落之间通过\(groupedKeywords.keys.first ?? "共同概念")相互联系\n"
        result += "3. 存在从\(paragraphs.first?.components(separatedBy: " ").prefix(3).joined(separator: " ") ?? "起始点")到\(paragraphs.last?.components(separatedBy: " ").prefix(3).joined(separator: " ") ?? "结论")的逻辑演进\n"

        return result
    }

    private func performInsightGeneration(text: String) -> String {
        let sentences = extractSentences(from: text)
        let keywords = extractKeywords(from: text, count: 8)
        let sentiment = analyzeSentiment(text: text)

        var result = "## 洞察生成\n\n"

        result += "### 关键洞察\n"
        result += "1. **主题聚焦**: 文本深度探讨了\(keywords.first ?? "特定领域")，表明对此领域的重视\n"
        result += "2. **观点倾向**: 整体情感为\(sentiment)，反映了作者的立场和态度\n"
        result += "3. **信息密度**: 包含\(sentences.count)个句子，信息较为\(sentences.count > 10 ? "丰富" : "简洁")\n\n"

        result += "### 模式识别\n"
        if keywords.count >= 3 {
            result += "- 高频概念: \(keywords[0]), \(keywords[1]), \(keywords[2])\n"
            result += "- 概念关联: \(keywords[0])与\(keywords[1])经常同时出现\n"
            result += "- 论述结构: 从\(sentences.first?.components(separatedBy: " ").prefix(5).joined(separator: " ") ?? "引言")到\(sentences.last?.components(separatedBy: " ").prefix(5).joined(separator: " ") ?? "结论")的渐进式论述\n\n"
        }

        result += "### 行动建议\n"
        result += "1. 进一步研究\(keywords.first ?? "核心概念")的相关资料\n"
        result += "2. 验证文本中提到的关键数据和事实\n"
        result += "3. 将本文洞察与已有研究进行对比分析\n"

        return result
    }

    private func performSummarization(text: String, length: SummaryLength) -> String {
        let sentences = extractSentences(from: text)
        let keywords = extractKeywords(from: text, count: 5)

        var result = "## 文本摘要\n\n"

        switch length {
        case .short:
            if sentences.count >= 2 {
                result += "\(sentences[0]) \(sentences[1])"
            } else if !sentences.isEmpty {
                result += sentences[0]
            } else {
                result += text.prefix(100) + "..."
            }

        case .medium:
            result += "本文主要讨论了\(keywords.first ?? "相关主题")。\n\n"
            result += "### 主要内容\n"
            for (index, sentence) in sentences.prefix(min(5, sentences.count)).enumerated() {
                result += "\(index + 1). \(sentence)\n"
            }
            if sentences.count > 5 {
                result += "...\n"
            }

        case .long:
            result += "### 详细摘要\n"
            result += "文本围绕\(keywords.first ?? "核心主题")展开，涉及以下方面：\n\n"
            for (index, sentence) in sentences.enumerated() {
                result += "**第\(index + 1)部分**: \(sentence)\n\n"
            }
            result += "### 关键要点\n"
            for (index, keyword) in keywords.enumerated() {
                result += "\(index + 1). \(keyword)\n"
            }
        }

        return result
    }

    private func performCustomAnalysis(text: String, prompt: String) -> String {
        // 简单的自定义分析实现
        let sentences = extractSentences(from: text)
        let keywords = extractKeywords(from: text, count: 6)

        var result = "## 自定义分析\n\n"
        result += "**分析提示**: \(prompt)\n\n"
        result += "**分析结果**:\n\n"

        result += "根据您的分析要求，对文本进行如下分析：\n"
        result += "1. 文本包含\(sentences.count)个句子\n"
        result += "2. 主要关键词: \(keywords.joined(separator: ", "))\n"
        result += "3. 文本长度: \(text.count)字符\n\n"

        result += "**具体分析**:\n"
        if prompt.contains("总结") || prompt.contains("summary") {
            result += performSummarization(text: text, length: .medium)
        } else if prompt.contains("关键词") || prompt.contains("keyword") {
            result += "关键词分析:\n"
            for keyword in keywords {
                result += "- \(keyword)\n"
            }
        } else {
            result += "文本内容概要: \(text.prefix(200))..."
        }

        return result
    }

    // MARK: - NLP Utilities

    private func extractSentences(from text: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.tokenType])
        tagger.string = text

        var sentences: [String] = []
        var currentSentence = ""

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .sentence, scheme: .tokenType) { tag, range in
            let sentence = String(text[range])
            sentences.append(sentence)
            return true
        }

        // 如果NLTokenizer没有找到句子，使用简单分割
        if sentences.isEmpty {
            sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?。！？"))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        return sentences
    }

    private func extractKeywords(from text: String, count: Int) -> [String] {
        var words: [String: Int] = [:]

        tokenizer.string = text
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, attributes in
            let word = String(text[range]).lowercased()

            // 过滤停用词和短词
            if word.count > 2 && !stopWords.contains(word) {
                words[word, default: 0] += 1
            }
            return true
        }

        return Array(words.sorted { $0.value > $1.value }
            .prefix(count)
            .map { $0.key }
            .map { $0.capitalized })
    }

    private func extractNamedEntities(from text: String) -> [(text: String, type: String)] {
        tagger.string = text
        var entities: [(String, String)] = []

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, range in
            if let tag = tag, tag.rawValue != "Other" {
                let entity = String(text[range])
                entities.append((entity, tag.rawValue))
            }
            return true
        }

        return entities
    }

    private func analyzeSentiment(text: String) -> String {
        sentimentAnalyzer.string = text

        var sentimentScore: Double = 0
        sentimentAnalyzer.enumerateTags(in: text.startIndex..<text.endIndex, unit: .paragraph, scheme: .sentimentScore) { tag, _ in
            if let tag = tag, let score = Double(tag.rawValue) {
                sentimentScore = score
            }
            return true
        }

        switch sentimentScore {
        case ..<(-0.5):
            return "非常负面"
        case -0.5..<0:
            return "略微负面"
        case 0..<0.5:
            return "略微正面"
        case 0.5...:
            return "非常正面"
        default:
            return "中性"
        }
    }

    private func detectLanguage(text: String) -> String {
        tagger.string = text
        if let language = tagger.dominantLanguage {
            return language.rawValue
        }
        return "未知"
    }

    private func groupKeywords(_ keywords: [String]) -> [String: [String]] {
        // 简单的关键词分组逻辑
        var groups: [String: [String]] = [:]

        for keyword in keywords {
            let firstChar = String(keyword.prefix(1)).uppercased()
            if groups[firstChar] == nil {
                groups[firstChar] = []
            }
            groups[firstChar]?.append(keyword)
        }

        return groups
    }

    // MARK: - Mock Response

    private func createMockResponse(content: String) -> ChatCompletionResponse {
        return ChatCompletionResponse(
            id: "local-\(UUID().uuidString)",
            object: "chat.completion",
            created: Int(Date().timeIntervalSince1970),
            model: "local-model",
            choices: [
                ChatCompletionResponse.Choice(
                    index: 0,
                    message: ChatCompletionResponse.Choice.Message(
                        role: "assistant",
                        content: content
                    ),
                    finishReason: "stop"
                )
            ],
            usage: ChatCompletionResponse.Usage(
                promptTokens: 0,
                completionTokens: content.count / 4, // 粗略估计
                totalTokens: content.count / 4
            )
        )
    }

    // MARK: - Stop Words

    private let stopWords: Set<String> = [
        "a", "an", "the", "and", "or", "but", "in", "on", "at", "to", "for",
        "of", "with", "by", "from", "up", "about", "into", "over", "after",
        "的", "了", "在", "是", "我", "有", "和", "就", "不", "人", "都",
        "一", "一个", "一些", "这", "那", "你", "他", "她", "它", "我们", "他们"
    ]
}

// MARK: - Analysis Service Protocol

protocol AnalysisService {
    func analyzeText(text: String, analysisType: AnalysisType) async -> AnalysisResult
    func analyzeMaterial(material: Material, analysisType: AnalysisType) async -> AnalysisResult
}

extension LocalAnalysisService: AnalysisService {
    func analyzeMaterial(material: Material, analysisType: AnalysisType) async -> AnalysisResult {
        guard let content = material.content else {
            return AnalysisResult(
                type: analysisType,
                content: "错误: 资料内容为空",
                rawResponse: createMockResponse(content: "错误: 资料内容为空")
            )
        }

        return await analyzeText(text: content, analysisType: analysisType)
    }
}

// MARK: - Analysis Manager

class AnalysisManager {
    static let shared = AnalysisManager()

    private let deepSeekService = DeepSeekService.shared
    private let localService = LocalAnalysisService.shared

    func analyze(
        text: String,
        analysisType: AnalysisType,
        preferDeepSeek: Bool = true
    ) async -> AnalysisResult {
        let settings = UserSettings.current

        switch settings.userAPIMode {
        case .localOnly:
            return await localService.analyzeText(text: text, analysisType: analysisType)

        case .apiOnly:
            if deepSeekService.isConfigured {
                do {
                    return try await deepSeekService.analyzeText(
                        text: text,
                        analysisType: analysisType
                    )
                } catch {
                    if settings.enableAutoFallback {
                        print("DeepSeek API失败，回退到本地分析: \(error)")
                        return await localService.analyzeText(text: text, analysisType: analysisType)
                    } else {
                        // 创建错误结果
                        return AnalysisResult(
                            type: analysisType,
                            content: "分析失败: \(error.localizedDescription)",
                            rawResponse: ChatCompletionResponse(
                                id: "error-\(UUID().uuidString)",
                                object: "chat.completion",
                                created: Int(Date().timeIntervalSince1970),
                                model: "error",
                                choices: [],
                                usage: nil
                            )
                        )
                    }
                }
            } else {
                return await localService.analyzeText(text: text, analysisType: analysisType)
            }

        case .auto:
            if preferDeepSeek && deepSeekService.isConfigured {
                if deepSeekService.hasSufficientTokens(for: 1000) {
                    do {
                        return try await deepSeekService.analyzeText(
                            text: text,
                            analysisType: analysisType
                        )
                    } catch where settings.enableAutoFallback {
                        print("DeepSeek API失败，回退到本地分析: \(error)")
                        return await localService.analyzeText(text: text, analysisType: analysisType)
                    } catch {
                        return await localService.analyzeText(text: text, analysisType: analysisType)
                    }
                } else {
                    return await localService.analyzeText(text: text, analysisType: analysisType)
                }
            } else {
                return await localService.analyzeText(text: text, analysisType: analysisType)
            }
        }
    }

    func analyzeMaterial(
        material: Material,
        analysisType: AnalysisType,
        preferDeepSeek: Bool = true
    ) async -> AnalysisResult {
        guard let content = material.content else {
            return AnalysisResult(
                type: analysisType,
                content: "错误: 资料内容为空",
                rawResponse: ChatCompletionResponse(
                    id: "error-\(UUID().uuidString)",
                    object: "chat.completion",
                    created: Int(Date().timeIntervalSince1970),
                    model: "error",
                    choices: [],
                    usage: nil
                )
            )
        }

        return await analyze(text: content, analysisType: analysisType, preferDeepSeek: preferDeepSeek)
    }
}