import RealityKit

class Character {
    var characterName: String
    var entities: [String: ModelEntity]
    var hasModelLoadCompleted: Bool = false
    var entityNameQueue: [(String, ForceActivityType)] = []
    var material: SimpleMaterial = SimpleMaterial()
    var isEnabled = false
    var shouldResolveCollisionCount: (Bool, Int) = (false, 0)
    var firstPosition: SIMD3<Float>
    var audioSource: Entity = Entity()

    init(characterName: String, entities: [String: ModelEntity], material: SimpleMaterial, firstPosition: SIMD3<Float>) {
        self.characterName = characterName
        self.entities = entities
        self.material = material
        self.firstPosition = firstPosition
        self.audioSource.spatialAudio = SpatialAudioComponent(directivity: .beam(focus: 0.75))
        self.audioSource.orientation = .init(angle: .pi, axis: [0, 1, 0])
    }
    
    func addEntity(entityName: String, entity: ModelEntity) {
        self.entities[entityName] = entity
    }
}
