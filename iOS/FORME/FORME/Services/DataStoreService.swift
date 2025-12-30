import Foundation
import CoreData
import UIKit

class DataStoreService {
    static let shared = DataStoreService()

    private init() {}

    // MARK: - Research Operations

    func createResearch(
        title: String,
        description: String? = nil,
        status: ResearchStatus = .new,
        tags: [Tag] = []
    ) -> Research {
        let research = Research.create(
            title: title,
            description: description,
            status: status,
            tags: tags
        )
        CoreDataStack.shared.saveContext()
        UsageStatistics.today.incrementResearchCount()
        return research
    }

    func updateResearch(
        _ research: Research,
        title: String? = nil,
        description: String? = nil,
        status: ResearchStatus? = nil
    ) {
        if let title = title {
            research.title = title
        }
        if let description = description {
            research.researchDescription = description
        }
        if let status = status {
            research.researchStatus = status
        }
        research.updatedAt = Date()
        CoreDataStack.shared.saveContext()
    }

    func deleteResearch(_ research: Research) {
        research.delete()
        CoreDataStack.shared.saveContext()
    }

    func getAllResearches() -> [Research] {
        return Research.fetchAll()
    }

    func getResearchesByStatus(_ status: ResearchStatus) -> [Research] {
        return Research.fetchByStatus(status)
    }

    func searchResearches(query: String) -> [Research] {
        return Research.search(with: query)
    }

    // MARK: - Material Operations

    func createMaterial(
        title: String,
        content: String? = nil,
        url: String? = nil,
        filePath: String? = nil,
        type: MaterialType = .other,
        status: MaterialStatus = .saved,
        tags: [Tag] = []
    ) -> Material {
        let material = Material.create(
            title: title,
            content: content,
            url: url,
            filePath: filePath,
            type: type,
            status: status,
            tags: tags
        )
        CoreDataStack.shared.saveContext()
        UsageStatistics.today.incrementMaterialCount()
        return material
    }

    func createWebMaterial(
        url: String,
        title: String,
        content: String
    ) -> Material {
        let material = Material.createFromWeb(
            url: url,
            title: title,
            content: content
        )
        CoreDataStack.shared.saveContext()
        UsageStatistics.today.incrementMaterialCount()
        return material
    }

    func createNoteMaterial(
        title: String,
        content: String
    ) -> Material {
        let material = Material.createNote(
            title: title,
            content: content
        )
        CoreDataStack.shared.saveContext()
        UsageStatistics.today.incrementMaterialCount()
        return material
    }

    func updateMaterial(
        _ material: Material,
        title: String? = nil,
        content: String? = nil,
        status: MaterialStatus? = nil
    ) {
        if let title = title {
            material.title = title
        }
        if let content = content {
            material.content = content
        }
        if let status = status {
            material.materialStatus = status
        }
        material.updatedAt = Date()
        CoreDataStack.shared.saveContext()
    }

    func deleteMaterial(_ material: Material) {
        material.delete()
        CoreDataStack.shared.saveContext()
    }

    func getAllMaterials() -> [Material] {
        return Material.fetchAll()
    }

    func getMaterialsByType(_ type: MaterialType) -> [Material] {
        return Material.fetchByType(type)
    }

    func getMaterialsByStatus(_ status: MaterialStatus) -> [Material] {
        return Material.fetchByStatus(status)
    }

    func searchMaterials(query: String) -> [Material] {
        return Material.search(with: query)
    }

    func getMaterialsByResearch(_ research: Research) -> [Material] {
        return Material.fetchByResearch(research)
    }

    // MARK: - Insight Operations

    func createInsight(
        title: String,
        content: String,
        type: InsightType = .analysis,
        source: InsightSource = .localModel,
        confidence: Float = 0.8,
        research: Research? = nil,
        material: Material? = nil,
        tags: [Tag] = []
    ) -> Insight {
        let insight = Insight.create(
            title: title,
            content: content,
            type: type,
            source: source,
            confidence: confidence,
            research: research,
            material: material,
            tags: tags
        )
        CoreDataStack.shared.saveContext()
        UsageStatistics.today.incrementAnalysisCount()
        return insight
    }

    func createDeepSeekInsight(
        title: String,
        content: String,
        type: InsightType,
        confidence: Float = 0.9,
        research: Research? = nil,
        material: Material? = nil
    ) -> Insight {
        let insight = Insight.createFromDeepSeek(
            title: title,
            content: content,
            type: type,
            confidence: confidence,
            research: research,
            material: material
        )
        CoreDataStack.shared.saveContext()
        UsageStatistics.today.incrementAnalysisCount()
        return insight
    }

    func updateInsight(
        _ insight: Insight,
        title: String? = nil,
        content: String? = nil,
        confidence: Float? = nil
    ) {
        if let title = title {
            insight.title = title
        }
        if let content = content {
            insight.content = content
        }
        if let confidence = confidence {
            insight.confidence = confidence
        }
        insight.updatedAt = Date()
        CoreDataStack.shared.saveContext()
    }

    func deleteInsight(_ insight: Insight) {
        insight.delete()
        CoreDataStack.shared.saveContext()
    }

    func getAllInsights() -> [Insight] {
        return Insight.fetchAll()
    }

    func getInsightsByType(_ type: InsightType) -> [Insight] {
        return Insight.fetchByType(type)
    }

    func getInsightsBySource(_ source: InsightSource) -> [Insight] {
        return Insight.fetchBySource(source)
    }

    func getInsightsByResearch(_ research: Research) -> [Insight] {
        return Insight.fetchByResearch(research)
    }

    func getInsightsByMaterial(_ material: Material) -> [Insight] {
        return Insight.fetchByMaterial(material)
    }

    func searchInsights(query: String) -> [Insight] {
        return Insight.search(with: query)
    }

    // MARK: - Tag Operations

    func createTag(
        name: String,
        category: TagCategory? = nil,
        color: UIColor? = nil
    ) -> Tag {
        let tag = Tag.create(name: name, category: category, color: color)
        CoreDataStack.shared.saveContext()
        return tag
    }

    func findOrCreateTag(name: String) -> Tag {
        let tag = Tag.findOrCreate(name: name)
        CoreDataStack.shared.saveContext()
        return tag
    }

    func updateTag(
        _ tag: Tag,
        name: String? = nil,
        category: TagCategory? = nil,
        color: UIColor? = nil
    ) {
        if let name = name {
            tag.name = name
        }
        if let category = category {
            tag.tagCategory = category
        }
        if let color = color {
            tag.tagColor = color
        }
        tag.updatedAt = Date()
        CoreDataStack.shared.saveContext()
    }

    func deleteTag(_ tag: Tag) {
        tag.delete()
        CoreDataStack.shared.saveContext()
    }

    func getAllTags() -> [Tag] {
        return Tag.fetchAll()
    }

    func getTagsByCategory(_ category: TagCategory) -> [Tag] {
        return Tag.fetchByCategory(category)
    }

    func searchTags(query: String) -> [Tag] {
        return Tag.search(with: query)
    }

    // MARK: - Annotation Operations

    func createAnnotation(
        content: String,
        position: String? = nil,
        material: Material
    ) -> Annotation {
        let annotation = Annotation.create(
            content: content,
            position: position,
            material: material
        )
        CoreDataStack.shared.saveContext()
        return annotation
    }

    func updateAnnotation(
        _ annotation: Annotation,
        content: String? = nil,
        position: String? = nil
    ) {
        if let content = content {
            annotation.content = content
        }
        if let position = position {
            annotation.position = position
        }
        annotation.updatedAt = Date()
        CoreDataStack.shared.saveContext()
    }

    func deleteAnnotation(_ annotation: Annotation) {
        annotation.delete()
        CoreDataStack.shared.saveContext()
    }

    // MARK: - Statistics

    func recordDeepSeekTokenUsage(tokens: Int) {
        let stats = UsageStatistics.today
        stats.incrementDeepSeekTokens(by: Int32(tokens))
        CoreDataStack.shared.saveContext()

        // 检查是否超过阈值
        checkUsageAlert()
    }

    func recordUsageTime(minutes: Int) {
        let stats = UsageStatistics.today
        stats.addUsageTime(minutes: Int32(minutes))
        CoreDataStack.shared.saveContext()
    }

    private func checkUsageAlert() {
        let settings = UserSettings.current
        guard settings.enableUsageAlert else { return }

        let monthlyTokens = UsageStatistics.getTotalMonthlyTokens()
        let limit = settings.monthlyTokenLimit
        let threshold = settings.usageAlertThreshold

        let usagePercentage = Float(monthlyTokens) / Float(limit) * 100
        if usagePercentage >= Float(threshold) {
            // TODO: 发送用量提醒通知
            print("用量提醒: 本月已使用 \(monthlyTokens)/\(limit) tokens (\(Int(usagePercentage))%)")
        }
    }

    func getMonthlyStatistics() -> MonthlyStatistics {
        let monthlyTokens = UsageStatistics.getTotalMonthlyTokens()
        let monthlyResearch = UsageStatistics.getTotalMonthlyResearchCount()
        let monthlyMaterials = UsageStatistics.getTotalMonthlyMaterialCount()
        let monthlyAnalysis = UsageStatistics.getTotalMonthlyAnalysisCount()
        let monthlyUsageTime = UsageStatistics.getTotalMonthlyUsageTime()

        return MonthlyStatistics(
            tokensUsed: Int(monthlyTokens),
            researchCount: Int(monthlyResearch),
            materialCount: Int(monthlyMaterials),
            analysisCount: Int(monthlyAnalysis),
            usageTimeMinutes: Int(monthlyUsageTime)
        )
    }

    func getTodayStatistics() -> DailyStatistics {
        let stats = UsageStatistics.today
        return DailyStatistics(
            tokensUsed: Int(stats.deepSeekTokensUsed),
            researchCount: Int(stats.researchCount),
            materialCount: Int(stats.materialCount),
            analysisCount: Int(stats.analysisCount),
            usageTimeMinutes: Int(stats.totalUsageTime)
        )
    }

    // MARK: - Export/Import

    func exportResearch(_ research: Research) -> ResearchExport? {
        guard let researchId = research.id.uuidString.data(using: .utf8) else {
            return nil
        }

        let materials = getMaterialsByResearch(research)
        let insights = getInsightsByResearch(research)
        let tags = Array(research.tags ?? [])

        return ResearchExport(
            research: research,
            materials: materials,
            insights: insights,
            tags: tags
        )
    }

    func exportAllData() -> DataExport? {
        let researches = getAllResearches()
        let materials = getAllMaterials()
        let insights = getAllInsights()
        let tags = getAllTags()

        return DataExport(
            researches: researches,
            materials: materials,
            insights: insights,
            tags: tags,
            userSettings: UserSettings.current,
            usageStatistics: UsageStatistics.today
        )
    }

    func importResearch(_ researchExport: ResearchExport) -> Research? {
        // TODO: 实现研究导入逻辑
        return nil
    }

    func importAllData(_ dataExport: DataExport) -> Bool {
        // TODO: 实现数据导入逻辑
        return false
    }

    // MARK: - Backup/Restore

    func createBackup() -> URL? {
        // TODO: 实现备份逻辑
        return nil
    }

    func restoreFromBackup(_ backupURL: URL) -> Bool {
        // TODO: 实现恢复逻辑
        return false
    }
}

// MARK: - Data Structures

struct MonthlyStatistics {
    let tokensUsed: Int
    let researchCount: Int
    let materialCount: Int
    let analysisCount: Int
    let usageTimeMinutes: Int

    var usageTimeHours: Double {
        return Double(usageTimeMinutes) / 60.0
    }
}

struct DailyStatistics {
    let tokensUsed: Int
    let researchCount: Int
    let materialCount: Int
    let analysisCount: Int
    let usageTimeMinutes: Int

    var usageTimeHours: Double {
        return Double(usageTimeMinutes) / 60.0
    }
}

struct ResearchExport {
    let research: Research
    let materials: [Material]
    let insights: [Insight]
    let tags: [Tag]
}

struct DataExport {
    let researches: [Research]
    let materials: [Material]
    let insights: [Insight]
    let tags: [Tag]
    let userSettings: UserSettings
    let usageStatistics: UsageStatistics
}
