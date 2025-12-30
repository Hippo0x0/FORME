import Foundation
import CoreData
import UIKit

enum TagCategory: String, CaseIterable {
    case topic = "课题"
    case skill = "技能"
    case technology = "技术"
    case industry = "行业"
    case location = "地点"
    case person = "人物"
    case organization = "组织"
    case event = "事件"
    case other = "其他"
}

@objc(Tag)
public class Tag: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var category: String?
    @NSManaged public var color: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var researches: Set<Research>?
    @NSManaged public var materials: Set<Material>?
    @NSManaged public var insights: Set<Insight>?

    var tagCategory: TagCategory? {
        get {
            guard let categoryString = category else { return nil }
            return TagCategory(rawValue: categoryString)
        }
        set { category = newValue?.rawValue }
    }

    var tagColor: UIColor? {
        get {
            guard let colorString = color else { return nil }
            return UIColor(hex: colorString)
        }
        set { color = newValue?.toHex() }
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

    func updateName(_ newName: String) {
        name = newName
        updatedAt = Date()
    }

    func updateCategory(_ newCategory: TagCategory?) {
        tagCategory = newCategory
        updatedAt = Date()
    }

    func updateColor(_ newColor: UIColor?) {
        tagColor = newColor
        updatedAt = Date()
    }
}

extension Tag {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    static func create(
        name: String,
        category: TagCategory? = nil,
        color: UIColor? = nil
    ) -> Tag {
        let tag = Tag(context: CoreDataStack.shared.context)
        tag.id = UUID()
        tag.name = name
        tag.tagCategory = category
        tag.tagColor = color
        tag.createdAt = Date()
        tag.updatedAt = Date()

        return tag
    }

    static func createTopicTag(name: String) -> Tag {
        return create(name: name, category: .topic)
    }

    static func createSkillTag(name: String) -> Tag {
        return create(name: name, category: .skill)
    }

    static func createTechnologyTag(name: String) -> Tag {
        return create(name: name, category: .technology)
    }

    static func fetchAll() -> [Tag] {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch tags: \(error)")
            return []
        }
    }

    static func fetchByCategory(_ category: TagCategory) -> [Tag] {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to fetch tags by category: \(error)")
            return []
        }
    }

    static func search(with query: String) -> [Tag] {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        do {
            return try CoreDataStack.shared.context.fetch(request)
        } catch {
            print("Failed to search tags: \(error)")
            return []
        }
    }

    static func findOrCreate(name: String) -> Tag {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1

        do {
            if let existingTag = try CoreDataStack.shared.context.fetch(request).first {
                return existingTag
            }
        } catch {
            print("Failed to find tag: \(error)")
        }

        return create(name: name)
    }

    func usageCount() -> Int {
        let researchCount = researches?.count ?? 0
        let materialCount = materials?.count ?? 0
        let insightCount = insights?.count ?? 0
        return researchCount + materialCount + insightCount
    }

    func delete() {
        // 从所有关联对象中移除
        researches?.forEach { $0.removeTag(self) }
        materials?.forEach { $0.removeTag(self) }
        insights?.forEach { $0.removeTag(self) }

        CoreDataStack.shared.context.delete(self)
    }
}

// MARK: - UIColor Extension for Hex Conversion

extension UIColor {
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }

        guard hexString.count == 6 || hexString.count == 8 else {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        if hexString.count == 6 {
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else {
            self.init(
                red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
            )
        }
    }

    func toHex(includeAlpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if includeAlpha {
            return String(format: "#%02lX%02lX%02lX%02lX",
                          lroundf(r * 255),
                          lroundf(g * 255),
                          lroundf(b * 255),
                          lroundf(a * 255))
        } else {
            return String(format: "#%02lX%02lX%02lX",
                          lroundf(r * 255),
                          lroundf(g * 255),
                          lroundf(b * 255))
        }
    }
}
