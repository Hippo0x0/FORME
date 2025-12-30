import Foundation
import CoreData

enum MaterialType: String, CaseIterable {
    case web = "网页"
    case pdf = "PDF"
    case image = "图片"
    case note = "笔记"
    case video = "视频"
    case audio = "音频"
    case other = "其他"
}

enum MaterialStatus: String, CaseIterable {
    case parsing = "解析中"
    case saved = "已保存"
    case analyzing = "分析中"
    case analyzed = "已分析"
    case linked = "已关联"
}

@objc(Material)
public class Material: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var content: String?
    @NSManaged public var url: String?
    @NSManaged public var filePath: String?
    @NSManaged public var materialType: String
    @NSManaged public var status: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var tags: Set<Tag>?
    @NSManaged public var annotations: Set<Annotation>?
    @NSManaged public var researches: Set<Research>?
    @NSManaged public var insights: Set<Insight>?

    var type: MaterialType {
        get { MaterialType(rawValue: materialType) ?? .other }
        set { materialType = newValue.rawValue }
    }

    var materialStatus: MaterialStatus {
        get { MaterialStatus(rawValue: status) ?? .saved }
        set { status = newValue.rawValue }
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

    func addAnnotation(_ annotation: Annotation) {
        if annotations == nil {
            annotations = Set<Annotation>()
        }
        annotations?.insert(annotation)
        updatedAt = Date()
    }

    func removeAnnotation(_ annotation: Annotation) {
        annotations?.remove(annotation)
        updatedAt = Date()
    }

    func addResearch(_ research: Research) {
        if researches == nil {
            researches = Set<Research>()
        }
        researches?.insert(research)
        updatedAt = Date()
    }

    func removeResearch(_ research: Research) {
        researches?.remove(research)
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

    func updateContent(_ newContent: String) {
        content = newContent
        updatedAt = Date()
    }

    func updateStatus(_ newStatus: MaterialStatus) {
        materialStatus = newStatus
        updatedAt = Date()
    }
}

extension Material {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Material> {
        return NSFetchRequest<Material>(entityName: "Material")
    }

    static func create(
        title: String,
        content: String? = nil,
        url: String? = nil,
        filePath: String? = nil,
        type: MaterialType = .other,
        status: MaterialStatus = .saved,
        tags: [Tag] = []
    ) -> Material {
        let material = Material(context: CoreDataStack.shared.context)
        material.id = UUID()
        material.title = title
        material.content = content
        material.url = url
        material.filePath = filePath
        material.type = type
        material.materialStatus = status
        material.createdAt = Date()
        material.updatedAt = Date()

        for tag in tags {
            material.addTag(tag)
        }

        return material
    }

    static func createFromWeb(
        url: String,
        title: String,
        content: String
    ) -> Material {
        return create(
            title: title,
            content: content,
            url: url,
            type: .web,
            status: .parsing
        )
    }

    static func createFromFile(
        filePath: String,
        title: String,
        content: String? = nil,
        type: MaterialType
    ) -> Material {
        return create(
            title: title,
            content: content,
            filePath: filePath,
            type: type,
            status: .saved
        )
    }

    static func createNote(
        title: String,
        content: String
    ) -> Material {
        return create(
            title: title,
            content: content,
            type: .note,
            status: .saved
        )
    }

    static func fetchAll() -> [Material] {
        let request: NSFetchRequest<Material> = Material.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch materials: \(error)")
            return []
        }
    }

    static func fetchByType(_ type: MaterialType) -> [Material] {
        let request: NSFetchRequest<Material> = Material.fetchRequest()
        request.predicate = NSPredicate(format: "materialType == %@", type.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch materials by type: \(error)")
            return []
        }
    }

    static func fetchByStatus(_ status: MaterialStatus) -> [Material] {
        let request: NSFetchRequest<Material> = Material.fetchRequest()
        request.predicate = NSPredicate(format: "status == %@", status.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch materials by status: \(error)")
            return []
        }
    }

    static func search(with query: String) -> [Material] {
        let request: NSFetchRequest<Material> = Material.fetchRequest()
        request.predicate = NSPredicate(
            format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@",
            query, query
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to search materials: \(error)")
            return []
        }
    }

    static func fetchByTag(_ tag: Tag) -> [Material] {
        let request: NSFetchRequest<Material> = Material.fetchRequest()
        request.predicate = NSPredicate(format: "ANY tags == %@", tag)
        request.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch materials by tag: \(error)")
            return []
        }
    }

    static func fetchByResearch(_ research: Research) -> [Material] {
        let request: NSFetchRequest<Material> = Material.fetchRequest()
        request.predicate = NSPredicate(format: "ANY researches == %@", research)
        request.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch materials by research: \(error)")
            return []
        }
    }

    func delete() {
        CoreDataStack.shared.context.delete(self)
    }
}

@objc(Annotation)
public class Annotation: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var content: String
    @NSManaged public var position: String? // 用于标记在原文中的位置
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var material: Material?
}

extension Annotation {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Annotation> {
        return NSFetchRequest<Annotation>(entityName: "Annotation")
    }

    static func create(
        content: String,
        position: String? = nil,
        material: Material
    ) -> Annotation {
        let annotation = Annotation(context: CoreDataStack.shared.context)
        annotation.id = UUID()
        annotation.content = content
        annotation.position = position
        annotation.createdAt = Date()
        annotation.updatedAt = Date()
        annotation.material = material

        material.addAnnotation(annotation)

        return annotation
    }

    func updateContent(_ newContent: String) {
        content = newContent
        updatedAt = Date()
    }

    func delete() {
        material?.removeAnnotation(self)
        CoreDataStack.shared.context.delete(self)
    }
}