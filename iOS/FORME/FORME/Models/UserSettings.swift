import Foundation
import CoreData

enum Theme: String, CaseIterable {
    case system = "系统"
    case light = "浅色"
    case dark = "深色"
}

enum APIMode: String, CaseIterable {
    case auto = "自动"
    case localOnly = "仅本地"
    case apiOnly = "仅API"
}

@objc(UserSettings)
public class UserSettings: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var theme: String
    @NSManaged public var apiMode: String
    @NSManaged public var enableNotifications: Bool
    @NSManaged public var enableAutoSave: Bool
    @NSManaged public var enableCloudSync: Bool
    @NSManaged public var deepSeekAPIKey: String?
    @NSManaged public var deepSeekBaseURL: String?
    @NSManaged public var deepSeekModel: String?
    @NSManaged public var monthlyTokenLimit: Int32
    @NSManaged public var singleRequestLimit: Int32
    @NSManaged public var enableUsageAlert: Bool
    @NSManaged public var usageAlertThreshold: Int32
    @NSManaged public var enableAutoFallback: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    var userTheme: Theme {
        get { Theme(rawValue: theme) ?? .system }
        set { theme = newValue.rawValue }
    }

    var userAPIMode: APIMode {
        get { APIMode(rawValue: apiMode) ?? .auto }
        set { apiMode = newValue.rawValue }
    }

    var deepSeekModelName: String {
        get { deepSeekModel ?? "deepseek-chat" }
        set { deepSeekModel = newValue }
    }

    var deepSeekBaseURLString: String {
        get { deepSeekBaseURL ?? "https://api.deepseek.com" }
        set { deepSeekBaseURL = newValue }
    }

    func updateTheme(_ newTheme: Theme) {
        userTheme = newTheme
        updatedAt = Date()
    }

    func updateAPIMode(_ newMode: APIMode) {
        userAPIMode = newMode
        updatedAt = Date()
    }

    func updateDeepSeekAPIKey(_ newKey: String?) {
        deepSeekAPIKey = newKey
        updatedAt = Date()
    }

    func updateDeepSeekBaseURL(_ newURL: String?) {
        deepSeekBaseURL = newURL
        updatedAt = Date()
    }

    func updateDeepSeekModel(_ newModel: String?) {
        deepSeekModel = newModel
        updatedAt = Date()
    }

    func updateMonthlyTokenLimit(_ newLimit: Int32) {
        monthlyTokenLimit = newLimit
        updatedAt = Date()
    }

    func updateSingleRequestLimit(_ newLimit: Int32) {
        singleRequestLimit = newLimit
        updatedAt = Date()
    }

    func updateUsageAlert(_ enabled: Bool, threshold: Int32? = nil) {
        enableUsageAlert = enabled
        if let threshold = threshold {
            usageAlertThreshold = threshold
        }
        updatedAt = Date()
    }

    func updateAutoFallback(_ enabled: Bool) {
        enableAutoFallback = enabled
        updatedAt = Date()
    }

    func updateNotifications(_ enabled: Bool) {
        enableNotifications = enabled
        updatedAt = Date()
    }

    func updateAutoSave(_ enabled: Bool) {
        enableAutoSave = enabled
        updatedAt = Date()
    }

    func updateCloudSync(_ enabled: Bool) {
        enableCloudSync = enabled
        updatedAt = Date()
    }
}

extension UserSettings {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserSettings> {
        return NSFetchRequest<UserSettings>(entityName: "UserSettings")
    }

    static var current: UserSettings {
        let request: NSFetchRequest<UserSettings> = UserSettings.fetchRequest()
        request.fetchLimit = 1

        do {
            if let settings = try CoreDataStack.shared.context.fetch(request).first {
                return settings
            }
        } catch {
            print("Failed to fetch user settings: \(error)")
        }

        // 创建默认设置
        return createDefaultSettings()
    }

    private static func createDefaultSettings() -> UserSettings {
        let settings = UserSettings(context: CoreDataStack.shared.context)
        settings.id = UUID()
        settings.userTheme = .system
        settings.userAPIMode = .auto
        settings.enableNotifications = true
        settings.enableAutoSave = true
        settings.enableCloudSync = false
        settings.deepSeekAPIKey = nil
        settings.deepSeekBaseURL = "https://api.deepseek.com"
        settings.deepSeekModel = "deepseek-chat"
        settings.monthlyTokenLimit = 10000
        settings.singleRequestLimit = 2000
        settings.enableUsageAlert = true
        settings.usageAlertThreshold = 80
        settings.enableAutoFallback = true
        settings.createdAt = Date()
        settings.updatedAt = Date()

        CoreDataStack.shared.saveContext()

        return settings
    }

    static func resetToDefaults() {
        let request: NSFetchRequest<UserSettings> = UserSettings.fetchRequest()

        do {
            let allSettings = try CoreDataStack.shared.context.fetch(request)
            for settings in allSettings {
                CoreDataStack.shared.context.delete(settings)
            }

            // 创建新的默认设置
            _ = createDefaultSettings()
        } catch {
            print("Failed to reset user settings: \(error)")
        }
    }

    func isDeepSeekConfigured() -> Bool {
        return deepSeekAPIKey?.isEmpty == false
    }

    func getDeepSeekConfiguration() -> DeepSeekConfiguration? {
        guard let apiKey = deepSeekAPIKey, !apiKey.isEmpty else {
            return nil
        }

        return DeepSeekConfiguration(
            apiKey: apiKey,
            baseURL: deepSeekBaseURLString,
            model: deepSeekModelName,
            monthlyLimit: Int(monthlyTokenLimit),
            singleLimit: Int(singleRequestLimit)
        )
    }
}

struct DeepSeekConfiguration {
    let apiKey: String
    let baseURL: String
    let model: String
    let monthlyLimit: Int
    let singleLimit: Int
}

// MARK: - Usage Statistics

@objc(UsageStatistics)
public class UsageStatistics: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var deepSeekTokensUsed: Int32
    @NSManaged public var researchCount: Int32
    @NSManaged public var materialCount: Int32
    @NSManaged public var analysisCount: Int32
    @NSManaged public var totalUsageTime: Int32 // 分钟
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    func incrementDeepSeekTokens(by amount: Int32) {
        deepSeekTokensUsed += amount
        updatedAt = Date()
    }

    func incrementResearchCount() {
        researchCount += 1
        updatedAt = Date()
    }

    func incrementMaterialCount() {
        materialCount += 1
        updatedAt = Date()
    }

    func incrementAnalysisCount() {
        analysisCount += 1
        updatedAt = Date()
    }

    func addUsageTime(minutes: Int32) {
        totalUsageTime += minutes
        updatedAt = Date()
    }
}

extension UsageStatistics {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UsageStatistics> {
        return NSFetchRequest<UsageStatistics>(entityName: "UsageStatistics")
    }

    static var today: UsageStatistics {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let request: NSFetchRequest<UsageStatistics> = UsageStatistics.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@", today as NSDate)
        request.fetchLimit = 1

        do {
            if let stats = try CoreDataStack.shared.context.fetch(request).first {
                return stats
            }
        } catch {
            print("Failed to fetch today's usage statistics: \(error)")
        }

        // 创建新的统计记录
        return createForDate(today)
    }

    static func createForDate(_ date: Date) -> UsageStatistics {
        let stats = UsageStatistics(context: CoreDataStack.shared.context)
        stats.id = UUID()
        stats.date = date
        stats.deepSeekTokensUsed = 0
        stats.researchCount = 0
        stats.materialCount = 0
        stats.analysisCount = 0
        stats.totalUsageTime = 0
        stats.createdAt = Date()
        stats.updatedAt = Date()

        CoreDataStack.shared.saveContext()

        return stats
    }

    static func getMonthlyStats(month: Date = Date()) -> [UsageStatistics] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!

        let request: NSFetchRequest<UsageStatistics> = UsageStatistics.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfMonth as NSDate,
            startOfNextMonth as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch monthly statistics: \(error)")
            return []
        }
    }

    static func getTotalMonthlyTokens(month: Date = Date()) -> Int32 {
        let monthlyStats = getMonthlyStats(month: month)
        return monthlyStats.reduce(0) { $0 + $1.deepSeekTokensUsed }
    }

    static func getTotalMonthlyResearchCount(month: Date = Date()) -> Int32 {
        let monthlyStats = getMonthlyStats(month: month)
        return monthlyStats.reduce(0) { $0 + $1.researchCount }
    }

    static func getTotalMonthlyMaterialCount(month: Date = Date()) -> Int32 {
        let monthlyStats = getMonthlyStats(month: month)
        return monthlyStats.reduce(0) { $0 + $1.materialCount }
    }

    static func getTotalMonthlyAnalysisCount(month: Date = Date()) -> Int32 {
        let monthlyStats = getMonthlyStats(month: month)
        return monthlyStats.reduce(0) { $0 + $1.analysisCount }
    }

    static func getTotalMonthlyUsageTime(month: Date = Date()) -> Int32 {
        let monthlyStats = getMonthlyStats(month: month)
        return monthlyStats.reduce(0) { $0 + $1.totalUsageTime }
    }
}