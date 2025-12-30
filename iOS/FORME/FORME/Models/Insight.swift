import Foundation
import CoreData

enum InsightSource: String, CaseIterable {
    case deepSeek = "DeepSeek"
    case localModel = "本地模型"
    case manual = "手动"
    case other = "其他"
}

enum InsightType: String, CaseIterable {
    case summary = "摘要"
    case analysis = "分析"
    case connection = "关联"
    case prediction = "预测"
    case suggestion = "建议"
    case question = "问题"
    case answer = "回答"
    case other = "其他"
}

@objc(Insight)
public class Insight: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var insightType: String
    @NSManaged public var source: String
    @NSManaged public var confidence: Float
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var research: Research?
    @NSManaged public var material: Material?
    @NSManaged public var tags: Set<Tag>?

    var type: InsightType {
        get { InsightType(rawValue: insightType) ?? .other }
        set { insightType = newValue.rawValue }
    }

    var insightSource: InsightSource {
        get { InsightSource(rawValue: source) ?? .other }
        set { source = newValue.rawValue }
    }

    func addTag(_ tag: Tag) {
        if tags == nil {
            tags = Set<Tag>()
        }
        tags?.insert(tag)
        updatedAt = Date()
    }

    func removeTag(_ tag: Tag) {
        tags?.remove(tag)
        updatedAt = Date()
    }

    func updateContent(_ newContent: String) {
        content = newContent
        updatedAt = Date()
    }

    func updateConfidence(_ newConfidence: Float) {
        confidence = newConfidence
        updatedAt = Date()
    }
}

extension Insight {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Insight> {
        return NSFetchRequest<Insight>(entityName: "Insight")
    }

    static func create(
        title: String,
        content: String,
        type: InsightType = .analysis,
        source: InsightSource = .localModel,
        confidence: Float = 0.8,
        research: Research? = nil,
        material: Material? = nil,
        tags: [Tag] = []
    ) -> Insight {
        let insight = Insight(context: CoreDataStack.shared.context)
        insight.id = UUID()
        insight.title = title
        insight.content = content
        insight.type = type
        insight.insightSource = source
        insight.confidence = confidence
        insight.createdAt = Date()
        insight.updatedAt = Date()
        insight.research = research
        insight.material = material

        for tag in tags {
            insight.addTag(tag)
        }

        research?.addInsight(insight)
        material?.addInsight(insight)

        return insight
    }

    static func createFromDeepSeek(
        title: String,
        content: String,
        type: InsightType,
        confidence: Float = 0.9,
        research: Research? = nil,
        material: Material? = nil
    ) -> Insight {
        return create(
            title: title,
            content: content,
            type: type,
            source: .deepSeek,
            confidence: confidence,
            research: research,
            material: material
        )
    }

    static func createFromLocalModel(
        title: String,
        content: String,
        type: InsightType,
        confidence: Float = 0.7,
        research: Research? = nil,
        material: Material? = nil
    ) -> Insight {
        return create(
            title: title,
            content: content,
            type: type,
            source: .localModel,
            confidence: confidence,
            research: research,
            material: material
        )
    }

    static func createManual(
        title: String,
        content: String,
        type: InsightType,
        research: Research? = nil,
        material: Material? = nil
    ) -> Insight {
        return create(
            title: title,
            content: content,
            type: type,
            source: .manual,
            confidence: 1.0,
            research: research,
            material: material
        )
    }

    static func fetchAll() -> [Insight] {
        let request: NSFetchRequest<Insight> = Insight.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch insights: \(error)")
            return []
        }
    }

    static func fetchByType(_ type: InsightType) -> [Insight] {
        let request: NSFetchRequest<Insight> = Insight.fetchRequest()
        request.predicate = NSPredicate(format: "insightType == %@", type.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch insights by type: \(error)")
            return []
        }
    }

    static func fetchBySource(_ source: InsightSource) -> [Insight] {
        let request: NSFetchRequest<Insight> = Insight.fetchRequest()
        request.predicate = NSPredicate(format: "source == %@", source.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch insights by source: \(error)")
            return []
        }
    }

    static func fetchByResearch(_ research: Research) -> [Insight] {
        let request: NSFetchRequest<Insight> = Insight.fetchRequest()
        request.predicate = NSPredicate(format: "research == %@", research)
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch insights by research: \(error)")
            return []
        }
    }

    static func fetchByMaterial(_ material: Material) -> [Insight] {
        let request: NSFetchRequest<Insight> = Insight.fetchRequest()
        request.predicate = NSPredicate(format: "material == %@", material)
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch insights by material: \(error)")
            return []
        }
    }

    static func search(with query: String) -> [Insight] {
        let request: NSFetchRequest<Insight> = Insight.fetchRequest()
        request.predicate = NSPredicate(
            format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@",
            query, query
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to search insights: \(error)")
            return []
        }
    }

    func delete() {
        research?.removeInsight(self)
        material?.removeInsight(self)
        CoreDataStack.shared.context.delete(self)
    }
}