import RealityKit

class Character {
    var characterName: String
    var entities: [String: ModelEntity]
    var isInForceTurn: Bool = false
    var hasModelLoadCompleted: Bool = false
    var entityNameQueue: [String] = [
        "Kitten_Walk_F_RM",
        "Kitten_Walk_F_RM",
        "Kitten_Walk_F_RM",
        "Kitten_Walk_F_RM",
        "Kitten_Walk_F_RM",
    ]
    var material: SimpleMaterial = SimpleMaterial()
    var isEnabled = false
    var characterNameIsCollide: [String: Bool] = [:]
    var isHandlingColision: Bool = false

    init(characterName: String, entities: [String: ModelEntity], material: SimpleMaterial) {
        self.characterName = characterName
        self.entities = entities
        self.material = material
    }
    
    func addEntity(entityName: String, entity: ModelEntity) {
        self.entities[entityName] = entity
    }
}
