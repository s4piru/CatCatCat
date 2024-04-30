import RealityKit

class Character {
    var characterName: String
    var entities: [String: ModelEntity]
    var hasModelLoadCompleted: Bool = false
    var entityNameQueue: [String] = []
    var material: SimpleMaterial = SimpleMaterial()
    var isEnabled = false
    var characterNameIsCollide: [String: Bool] = [:]
    var firstPosition: SIMD3<Float>

    init(characterName: String, entities: [String: ModelEntity], material: SimpleMaterial, firstPosition: SIMD3<Float>) {
        self.characterName = characterName
        self.entities = entities
        self.material = material
        self.firstPosition = firstPosition
    }
    
    func addEntity(entityName: String, entity: ModelEntity) {
        self.entities[entityName] = entity
    }
}
