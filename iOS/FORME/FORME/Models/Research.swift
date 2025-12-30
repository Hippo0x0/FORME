import Foundation
import CoreData

enum ResearchStatus: String, CaseIterable {
    case new = "新建"
    case inProgress = "进行中"
    case paused = "暂停"
    case completed = "完成"
    case archived = "归档"
}

enum ResearchStep: String, CaseIterable {
    case boost = "Boost"
    case pickTarget = "Pick Target"
    case schedule = "Schedule"
    case workFeedbackLoop = "Work-Feedback-Loop"
    case outputFeedbackLoop = "Output-Feedback-Loop"
}

@objc(Research)
public class Research: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var researchDescription: String?
    @NSManaged public var status: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var progress: Float
    @NSManaged public var tags: Set<Tag>?
    @NSManaged public var materials: Set<Material>?
    @NSManaged public var insights: Set<Insight>?
    @NSManaged public var steps: Set<ResearchStepEntity>?

    var researchStatus: ResearchStatus {
        get { ResearchStatus(rawValue: status) ?? .new }
        set { status = newValue.rawValue }
    }

    var stepStatuses: [ResearchStep: Bool] {
        var result: [ResearchStep: Bool] = [:]
        guard let steps = steps else { return result }

        for step in steps {
            if let stepType = ResearchStep(rawValue: step.stepType ?? ""),
               let isCompleted = step.isCompleted {
                result[stepType] = isCompleted.boolValue
            }
        }

        // 确保所有步骤都有值
        for step in ResearchStep.allCases {
            if result[step] == nil {
                result[step] = false
            }
        }

        return result
    }

    func updateProgress() {
        let completedSteps = stepStatuses.values.filter { $0 }.count
        let totalSteps = ResearchStep.allCases.count
        progress = totalSteps > 0 ? Float(completedSteps) / Float(totalSteps) : 0
        updatedAt = Date()
    }

    func markStepCompleted(_ step: ResearchStep, isCompleted: Bool = true) {
        let stepEntity: ResearchStepEntity
        if let existingStep = steps?.first(where: { $0.stepType == step.rawValue }) {
            stepEntity = existingStep
        } else {
            stepEntity = ResearchStepEntity(context: CoreDataStack.shared.context)
            stepEntity.id = UUID()
            stepEntity.stepType = step.rawValue
            stepEntity.research = self
        }
        stepEntity.isCompleted = isCompleted as NSNumber
        stepEntity.updatedAt = Date()
        updateProgress()
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

    func addMaterial(_ material: Material) {
        if materials == nil {
            materials = Set<Material>()
        }
        materials?.insert(material)
        updatedAt = Date()
    }

    func removeMaterial(_ material: Material) {
        materials?.remove(material)
        updatedAt = Date()
    }

    func addInsight(_ insight: Insight) {
        if insights == nil {
            insights = Set<Insight>()
        }
        insights?.insert(insight)
        updatedAt = Date()
    }

    func removeInsight(_ insight: Insight) {
        insights?.remove(insight)
        updatedAt = Date()
    }
}

extension Research {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Research> {
        return NSFetchRequest<Research>(entityName: "Research")
    }

    static func create(
        title: String,
        description: String? = nil,
        status: ResearchStatus = .new,
        tags: [Tag] = []
    ) -> Research {
        let research = Research(context: CoreDataStack.shared.context)
        research.id = UUID()
        research.title = title
        research.researchDescription = description
        research.researchStatus = status
        research.createdAt = Date()
        research.updatedAt = Date()
        research.progress = 0

        for tag in tags {
            research.addTag(tag)
        }

        // 初始化所有步骤为未完成
        for step in ResearchStep.allCases {
            research.markStepCompleted(step, isCompleted: false)
        }

        return research
    }

    static func fetchAll() -> [Research] {
        let request: NSFetchRequest<Research> = Research.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch researches: \(error)")
            return []
        }
    }

    static func fetchByStatus(_ status: ResearchStatus) -> [Research] {
        let request: NSFetchRequest<Research> = Research.fetchRequest()
        request.predicate = NSPredicate(format: "status == %@", status.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch researches by status: \(error)")
            return []
        }
    }

    static func search(with query: String) -> [Research] {
        let request: NSFetchRequest<Research> = Research.fetchRequest()
        request.predicate = NSPredicate(
            format: "title CONTAINS[cd] %@ OR researchDescription CONTAINS[cd] %@",
            query, query
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to search researches: \(error)")
            return []
        }
    }

    func delete() {
        CoreDataStack.shared.context.delete(self)
    }
}

@objc(ResearchStepEntity)
public class ResearchStepEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var stepType: String?
    @NSManaged public var isCompleted: NSNumber?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var research: Research?
}

extension ResearchStepEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ResearchStepEntity> {
        return NSFetchRequest<ResearchStepEntity>(entityName: "ResearchStepEntity")
    }
}