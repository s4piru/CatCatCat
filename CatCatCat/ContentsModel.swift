import SwiftUI
import RealityKit
import Combine

class ContentsModel {
    // TODO: Add Audio
    // TODO: Adjust angle
    // TODO: Adjust possibilities
    private let queue = DispatchQueue(label: "com.content.myqueue")
    private var content: RealityViewContent? = nil
    private var characters: [String: Character] = [:]
    private let rangeX: Float = 2.0
    private let rangeZ: Float = 2.0
    private var yPosition: Float = 0.0
    private var floorPlaneAnchor: AnchorEntity = AnchorEntity()
    private var isClosing: Bool = false
    private let walkMovement: Float = 0.28289
    private let trotMovement: Float = 0.47015
    private let runMovement: Float = 0.72235
    private var subscriptions: [EventSubscription] = []
    
    init() {
        var randomPositions = createRandomPositions(count: catNameTextureList.keys.count)
        for catNameTexture in catNameTextureList {
            guard let textureName: String = catNameTextureList[catNameTexture.key] else {
                print("ContentsModel::init() There is no catName: ", catNameTexture.key)
                return
            }
            
            var material = SimpleMaterial()
            let texture = try! TextureResource.load(named: textureName)
            material.color.texture = .init(texture)
            
            guard let randomPosition:SIMD3<Float> = randomPositions.first else {
                print("ContentsModel::init() Failed to get randomPosition: ", catNameTexture.key)
                return
            }
            randomPositions.remove(at: 0)
            
            
            let character = Character(characterName: catNameTexture.key, entities: [:], material: material, firstPosition: randomPosition)
            for catName in catNameTextureList.keys {
                character.characterNameIsCollide[catName] = false
            }
            
            for _ in 1...3 {
                character.entityNameQueue.append(firstUsdzEntityTypeList.randomElement()!.key)
            }
            
            self.characters[catNameTexture.key] = character
        }
    }
    
    func updateCharacterEnable(catName: String, isEnabled: Bool) {
        guard let character = self.characters[catName] else {
            print("ContentsModel::updateCharacterEnable() Failed to get character catName: ", catName)
            return
        }
        
        if isEnabled {
            if character.entities.keys.count >= firstUsdzEntityTypeList.keys.count {
                let firstEntityName = firstUsdzEntityTypeList.randomElement()!.key
                guard let firstEntity = character.entities[firstEntityName] else {
                    print("ContentsModel::updateCharacterEnable() There is no Kitten_Walk_start for catName: ", catName)
                    return
                }
                firstEntity.isEnabled = true
                startAnimation(animateEntity: firstEntity)
            } else {
                print("ContentsModel::updateCharacterEnable(), wait for entity load")
            }
            character.isEnabled = true
        } else {
            character.isEnabled = false
        }
    }
    
    func closeImmersiveView() {
        cancelAllSubscriptions()
        removeAllChildren()
    }
    
    func removeAllChildren() {
        isClosing = true
        for catNameTexture in catNameTextureList {
            guard let character = characters[catNameTexture.key] else {
                print("ContentsModel::removeAllChildren() Failed to get character catName: ", catNameTexture.key)
                return
            }
            
            for entity in character.entities {
                entity.value.stopAllAnimations()
                entity.value.isEnabled = false
                floorPlaneAnchor.removeChild(entity.value)
            }
        }
        content?.remove(floorPlaneAnchor)
    }
    
    func cancelAllSubscriptions() {
        for event in subscriptions {
            event.cancel()
        }
    }
    
    func getSubscriptions() -> [EventSubscription] {
        return subscriptions
    }
    
    func registerContent(content: RealityViewContent) {
        isClosing = false
        floorPlaneAnchor = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: SIMD2<Float>(0.01, 0.01)))
        floorPlaneAnchor.generateCollisionShapes(recursive: false)
        content.add(floorPlaneAnchor)
        self.content = content
    }
    
    func createRandomPositions(count:Int) -> [SIMD3<Float>] {
        var result: [SIMD3<Float>] = []
        var isSmallZ = true
        var perRange = (rangeX * 2) / Float(count)
        var minX: Float = -rangeX
        for num in 1...count {
            let minZ:Float = isSmallZ ? -rangeZ : 0.1
            let maxZ:Float = isSmallZ ? -0.1 : rangeZ
            result.append(SIMD3<Float>(
                x: Float.random(in: minX...minX+perRange),
                y: yPosition,
                z: Float.random(in: minZ...maxZ)
            ))
            minX += perRange
            isSmallZ = !isSmallZ
        }
        result.shuffle()
        return result
    }
    
    /*func createRandomPosition() -> SIMD3<Float> {
        return SIMD3<Float>(
            x: Float.random(in: -rangeX...rangeX),
            y: yPosition,
            z: Float.random(in: -rangeZ...rangeZ)
        )
    }*/
    
    func createRandomOrientation() -> simd_quatf {
        let randomRotation = Float.random(in: 0...(.pi * 2))
        return simd_quatf(angle: randomRotation, axis: SIMD3<Float>(0, 1, 0))
    }
    
    func handleCollision(entityA: Entity, entityB: Entity, isCollide: Bool) {
        guard let modelEntityA = entityA as? ModelEntity else {
            print("ContentsModel::handleTouchedAnimation() Failed to convert to ModelEnity ")
            return
        }
        guard let modelEntityB = entityB as? ModelEntity else {
            print("ContentsModel::handleTouchedAnimation() Failed to convert to ModelEnity ")
            return
        }
        
        guard let characterA = characters[modelEntityA.name] else {
            print("ContentsModel::handleCollisionEnd() characterA Failed to get")
            return
        }
        
        guard let characterB = characters[modelEntityB.name] else {
            print("ContentsModel::handleCollisionEnd() characterA Failed to get")
            return
        }
        
        characterA.characterNameIsCollide[modelEntityB.name]! = isCollide
        characterB.characterNameIsCollide[modelEntityA.name]! = isCollide
    }
    
    func registerEntity(entity: ModelEntity, characterName: String, entityType: EntityType, entityName: String) {
        if content != nil {
            subscriptions.append(content!.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: entity) { e in
                self.processAfterAnimation(characterName: characterName, entityType: entityType, entityName: entityName)
                print("ContentsModel::registerEntity() processAfterAnimation called: ", characterName, ", usdzName: ", entityName)
            })
            subscriptions.append(content!.subscribe(to: CollisionEvents.Began.self) { e in
                if e.entityA.isEnabled && e.entityB.isEnabled {
                    print("====================Collision between \(e.entityA.name) and \(e.entityB.name) is occured====================")
                    self.handleCollision(entityA: e.entityA, entityB: e.entityB, isCollide: true)
                }
            })
            subscriptions.append(content!.subscribe(to: CollisionEvents.Ended.self) { e in
                if e.entityA.isEnabled && e.entityB.isEnabled {
                    print("====================Collision between \(e.entityA.name) and \(e.entityB.name) is ended====================")
                    self.handleCollision(entityA: e.entityA, entityB: e.entityB, isCollide: false)
                }
            })
        } else {
            print("ContentsModel::registerEntity() NO content!!!")
        }
    }
    
    @MainActor
    func showCat(catName: String) async {
        guard let character = characters[catName] else {
            print("ContentsModel::createCharacter() Failed to get character catName: ", catName)
            return
        }
        
        let firstPosition = character.firstPosition
        let orientation = createRandomOrientation()
        
        for usdzEntityType in firstUsdzEntityTypeList {
            if !character.entities.keys.contains(usdzEntityType.key) {
                let entity = await loadEntity(characterName: catName, entityType:usdzEntityType.value, usdzName: usdzEntityType.key, material: character.material, position: firstPosition, orientation: orientation)
                    character.entities[usdzEntityType.key] = entity
            }
        }
        
        for regiterEntity in character.entities {
            DispatchQueue.main.async {
                self.floorPlaneAnchor.addChild(regiterEntity.value)
                self.registerEntity(entity: regiterEntity.value, characterName: catName, entityType: usdzEntityTypeList[regiterEntity.key]!, entityName: regiterEntity.key)
            }
        }
        
        let firstEntityName = firstUsdzEntityTypeList.randomElement()!.key
        guard let firstEntity = character.entities[firstEntityName] else {
            print("ContentsModel::createCharacter() There is no Kitten_Walk_start for catName: ", catName)
            return
        }

        if character.isEnabled {
            firstEntity.position.x = firstPosition.x
            firstEntity.position.z = firstPosition.z
            firstEntity.orientation = orientation
            firstEntity.isEnabled = true
            startAnimation(animateEntity: firstEntity)
        }
        
        Task {
            await addRemainigEntities(character: character, material: character.material, position: firstPosition, orientation: orientation)
            character.hasModelLoadCompleted = true
        }
        
        return
    }
    
    func addRemainigEntities(character: Character, material:  SimpleMaterial, position: SIMD3<Float>, orientation: simd_quatf) async {
        for usdzEntityType in usdzEntityTypeList {
            if !character.entities.keys.contains(usdzEntityType.key) && !firstUsdzEntityTypeList.keys.contains(usdzEntityType.key) {
                let entity = await self.loadEntity(characterName: character.characterName, entityType:usdzEntityType.value, usdzName: usdzEntityType.key, material: material, position: position, orientation: orientation)
                DispatchQueue.main.async {
                    self.floorPlaneAnchor.addChild(entity)
                    self.registerEntity(entity: entity, characterName: character.characterName, entityType: usdzEntityType.value, entityName: usdzEntityType.key)
                    character.entities[usdzEntityType.key] = entity
                }
            } else if !firstUsdzEntityTypeList.keys.contains(usdzEntityType.key) {
                DispatchQueue.main.async {
                    let entity = character.entities[usdzEntityType.key]!
                    self.floorPlaneAnchor.addChild(entity)
                }
            }
        }
    }
    
    func setCollisionComponent(entity: ModelEntity) {
        entity.generateCollisionShapes(recursive: true)
        let collisionShape = ShapeResource.generateBox(size: SIMD3<Float>(entity.scale.x/2, entity.scale.y/2, entity.scale.z*1.2))
        entity.components.set(CollisionComponent(shapes: [collisionShape]))
    }
    
    @MainActor
    func loadEntity(characterName: String, entityType: EntityType, usdzName: String, material: SimpleMaterial, position: SIMD3<Float>, orientation: simd_quatf) async -> ModelEntity {
        do {
            let loadedEntity = try await ModelEntity(named: usdzName)
            loadedEntity.model?.materials = [material]
            loadedEntity.name = characterName
            loadedEntity.position.x = position.x
            loadedEntity.position.z = position.z
            loadedEntity.transform.translation.y = 0.0
            loadedEntity.orientation = orientation
            loadedEntity.components.set(InputTargetComponent(allowedInputTypes: .all))
            loadedEntity.isEnabled = false
            self.setCollisionComponent(entity: loadedEntity)
            
            print("ContentsModel::loadEntity() Succeeded to load entity for characterName: ", characterName, ", usdzName: ", usdzName)
            return loadedEntity
        } catch {
            print("ContentsModel::loadEntity() Failed to load entity usdzName: ", usdzName)
            return ModelEntity()
        }
    }
    
    func startAnimation(animateEntity: ModelEntity) {
        if animateEntity.availableAnimations.count > 0{
            animateEntity.playAnimation(animateEntity.availableAnimations[0])
        } else {
            print("ContentsModel::startAnimation() No available animation: ", animateEntity.name)
            return
        }
    }
    
    func getNextEntityType(currentType: EntityType) -> EntityType {
        guard let possibleEntities = nextEntityList[currentType] else {
            print("ContentsModel::getNextEntityType() There is no currentType: ", currentType)
            return EntityType.unknown
        }
        
        // TODO: Comment out after validating
        let sum = possibleEntities.values.reduce(0, +)
        guard sum == 100 else {
            print("ContentsModel::getNextEntityType(): Probabilities must sum up to 100")
            return EntityType.unknown
        }
        
        let randomValue = Int.random(in: 0..<100)
        var cumulativeProbability: Int = 0
        
        for (entityType, probability) in possibleEntities {
            cumulativeProbability += probability
            if randomValue <= cumulativeProbability {
                return entityType
            }
        }
        
        print("ContentsModel::getNextEntityType(): Failed to get random entityType")
        return EntityType.unknown
    }
    
    func getRandomEntityName(entityTypes: [EntityType]) -> String {
        var usdzList: [String] = []
        for entityType in entityTypes {
            guard let usdzs = entityTypeUsdzList[entityType] else {
                print("ContentsModel::getRandomEntityName(): Failed to get usdzList for: ", entityType)
                return ""
            }
            usdzList.append(contentsOf: usdzs)
        }
        
        guard let randomEntityName = usdzList.randomElement() else {
            print("ContentsModel::getRandomEntityName(): Failed to get randomEntityName ")
            return ""
        }
        
        return randomEntityName
    }
    
    func getFirstEntityFromQueue(character: Character) -> ModelEntity {
        guard let firstEntityName: String = character.entityNameQueue.first else {
            print("ContentsModel::processRandomEntityFromType(): entityNameQueue is empty for: ", character.characterName)
            return ModelEntity()
        }
        
        print("ContentsModel::processRandomEntityFromType(): firstEntityName: ", firstEntityName)
        
        guard let firstEntity = character.entities[firstEntityName] else {
            print("ContentsModel::processRandomEntityFromType(): No entity found for: ", character.characterName, ", entityName: ", firstEntityName)
            return ModelEntity()
        }
        return firstEntity
    }
    
    func getNewEntityName(hasModelLoadCompleted: Bool, lastEntityType: EntityType) -> String {
        if hasModelLoadCompleted {
            let newLastEntityType = getNextEntityType(currentType: lastEntityType)
            return getRandomEntityName(entityTypes: [newLastEntityType])
        } else {
            return firstUsdzEntityTypeList.randomElement()!.key
        }
    }
    
    func appendRandomActionToLastEntity(character: Character) {
        guard let lastEntityName: String = character.entityNameQueue.last else {
            print("ContentsModel::appendRandomActionToLastEntity(): No lastEntityName found for: ", character.characterName)
            return
        }
        
        print("ContentsModel::appendRandomActionToLastEntity(): lastEntityName: ", lastEntityName)
        
        guard let lastEntityType = usdzEntityTypeList[lastEntityName] else {
            print("ContentsModel::appendRandomActionToLastEntity(): No lastEntityType found for: ", character.characterName)
            return
        }
        
        print("ContentsModel::appendRandomActionToLastEntity(): hasModelLoadCompleted: ", character.hasModelLoadCompleted)
        
        let newLastEntityName: String = getNewEntityName(hasModelLoadCompleted: character.hasModelLoadCompleted, lastEntityType: lastEntityType)
        
        print("ContentsModel::appendRandomActionToLastEntity(): newLastEntityName: ", newLastEntityName)
        
        character.entityNameQueue.append(newLastEntityName)
        
        if character.entityNameQueue.count > 1 {
            character.entityNameQueue.remove(at: 0)
        } else {
            print("ContentsModel::appendRandomActionToLastEntity(): No available queue element found for: ", character.characterName)
        }
    }
    
    func canTurn(currentType: EntityType) -> Bool {
        return canTurnList.contains(currentType)
    }
    
    func processRandomEntityFromType(character: Character, position: SIMD3<Float>, orientation: simd_quatf, currentEntity: ModelEntity, isTapped: Bool = false, isForceTurn: Bool = false, isCurrentTravel: Bool = false) {
        var nextEntity: ModelEntity = ModelEntity()
        if isTapped {
            character.entityNameQueue.removeAll()
            character.entityNameQueue.append("Kitten_Walk_end")
            let independentEntityName = getRandomEntityName(entityTypes: [EntityType.independent, EntityType.idle])
            if character.entities.keys.contains(independentEntityName) {
                character.entityNameQueue.append(independentEntityName)
            } else {
                character.entityNameQueue.append(firstUsdzEntityTypeList.randomElement()!.key)
            }
            return
        } else if !character.hasModelLoadCompleted {
            nextEntity = getFirstEntityFromQueue(character: character)
            appendRandomActionToLastEntity(character: character)
        } else if isInCollision(characterNameIsCollide: character.characterNameIsCollide) {
            if character.isHandlingColision {
                nextEntity = getFirstEntityFromQueue(character: character)
                character.entityNameQueue.append("Kitten_Walk_F_RM")
                if character.entityNameQueue.count > 1 {
                    character.entityNameQueue.remove(at: 0)
                } else {
                    print("ContentsModel::processRandomEntityFromType(): No available queue element found in isHandlingColision  for: ", character.characterName)
                }
            } else if isCurrentTravel {
                if character.entities["Kitten_Walk_F_RM"]! == currentEntity {
                    nextEntity = character.entities["Kitten_Walk_end"]!
                    character.entityNameQueue.removeAll()
                    let newLastEntityName: String = getNewEntityName(hasModelLoadCompleted: character.hasModelLoadCompleted, lastEntityType: EntityType.walk_end)
                    character.entityNameQueue.append(newLastEntityName)
                } else {
                    nextEntity = character.entities["Kitten_Walk_F_RM"]!
                }
            } else {
                nextEntity = getFirstEntityFromQueue(character: character)
                if character.entityNameQueue.count > 0 && !canTurn(currentType: usdzEntityTypeList[character.entityNameQueue.first!]!) {
                    appendRandomActionToLastEntity(character: character)
                } else {
                    character.entityNameQueue.removeAll()
                    let shouldTurn: Bool = Int.random(in: 0...500) % 10 == 0
                    if shouldTurn {
                        character.entityNameQueue.append("Kitten_Turn_180_L")
                        character.entityNameQueue.append("Kitten_Walk_start")
                        character.isHandlingColision = true
                    } else {
                        let newLastEntityName: String = getNewEntityName(hasModelLoadCompleted: character.hasModelLoadCompleted, lastEntityType: EntityType.walk_end)
                        character.entityNameQueue.append(newLastEntityName)
                    }
                }
            }
        } else {
            character.isHandlingColision = false
            if isForceTurn {
                if character.isInForceTurn {
                    nextEntity = getFirstEntityFromQueue(character: character)
                    character.entityNameQueue.append("Kitten_Walk_F_RM")
                    if character.entityNameQueue.count > 1 {
                        character.entityNameQueue.remove(at: 0)
                    } else {
                        print("ContentsModel::processRandomEntityFromType(): No available queue element found in isForceTurn  for: ", character.characterName)
                    }
                } else {
                    if character.entities["Kitten_Walk_F_RM"]! == currentEntity {
                        nextEntity = character.entities["Kitten_Walk_end"]!
                        character.entityNameQueue.removeAll()
                        character.entityNameQueue.append("Kitten_Turn_180_R")
                        character.isInForceTurn = true
                    } else {
                        nextEntity = character.entities["Kitten_Walk_F_RM"]!
                    }
                }
            } else {
                nextEntity = getFirstEntityFromQueue(character: character)
                appendRandomActionToLastEntity(character: character)
            }
        }
        
        nextEntity.position.x = position.x
        nextEntity.position.z = position.z
        nextEntity.orientation = orientation
        currentEntity.isEnabled = false
        nextEntity.isEnabled = true
        startAnimation(animateEntity: nextEntity)
    }

    func isInCollision(characterNameIsCollide: [String:Bool]) -> Bool {
        for isCollide in characterNameIsCollide.values {
            if isCollide {
                return true
            }
        }
        return false
    }
    
    func processAfterAnimation(characterName: String, entityType: EntityType, entityName: String) {
        if isClosing {
            print("=========ContentsModel::processAfterAnimation(): Now on Closing!", characterName)
            return
        }
        
        guard let character = characters[characterName] else {
            print("ContentsModel::processAfterAnimation(): There is no character: ", characterName)
            return
        }
        
        guard let entity = character.entities[entityName] else {
            print("ContentsModel::processAfterAnimation(): There is no entity: ", entityName)
            return
        }
        
        if !character.isEnabled {
            entity.isEnabled = false
            print("!-------ContentsModel::processAfterAnimation(): Disable character: ", character.characterName)
            return
        }
        
        switch entityType {
        case EntityType.walk, EntityType.walk_start, EntityType.run, EntityType.trot:
            processAfterTravel(character: character, entity: entity, entityType: entityType)
            break;
        case EntityType.turn:
            processAfterTurn(character: character, turnEntity: entity)
            break;
        case EntityType.unknown:
            print("ContentsModel::processAfterAnimation(): Do Nothing for EntityType: ", entityType)
            break;
        default:
            print("ContentsModel::processAfterAnimation(): Process random next animation for: ", entityType)
            processRandomEntityFromType(character: character, position: entity.position, orientation: entity.orientation, currentEntity: entity)
        }
    }
    
    func isInsizeRange(position: SIMD3<Float>) -> Bool {
        return position.x >= -rangeX && position.x <= rangeX && position.z >= -rangeZ && position.z <= rangeZ
    }
    
    func processAfterTravel(character: Character, entity: ModelEntity, entityType: EntityType) {
        let forwardDirection = entity.orientation.act(SIMD3<Float>(0, 0, 1))
        var meshMovement: Float = 0.0
        switch entityType {
        case EntityType.walk, EntityType.walk_start:
            meshMovement = walkMovement
            break;
        case EntityType.trot:
            meshMovement = trotMovement
            break;
        case EntityType.run:
            meshMovement = runMovement
            break;
        default:
            print("ContentsModel::processAfterTravel() Invalid Entity", meshMovement)
        }
        
        let finalPosition = entity.position + forwardDirection * meshMovement
        if isInsizeRange(position: finalPosition) {
            character.isInForceTurn = false
            processRandomEntityFromType(character: character, position: finalPosition, orientation: entity.orientation, currentEntity: entity, isCurrentTravel: true)
        } else {
            processRandomEntityFromType(character: character, position: finalPosition, orientation: entity.orientation, currentEntity: entity, isForceTurn: true, isCurrentTravel: true)
        }
    }
    
    func processAfterTurn(character: Character, turnEntity: ModelEntity) {
        let rotationAngle: Float
        switch turnEntity {
        case character.entities["Kitten_Turn_90_L"]:
            rotationAngle = .pi / 2 // 90 degrees to the left
            break;
        case character.entities["Kitten_Turn_90_R"]:
            rotationAngle = -.pi / 2 // 90 degrees to the right
            break;
        case character.entities["Kitten_Turn_180_L"] , character.entities["Kitten_Turn_180_R"]:
            rotationAngle = .pi
            break;
        default:
            print("ContentsModel::processAfterTurn(): No turnEntity found.")
            return
        }
        let newOrientation = turnEntity.orientation * simd_quatf(angle: rotationAngle, axis: SIMD3<Float>(0, 1, 0)) // Orientation?
        processRandomEntityFromType(character: character, position: turnEntity.position, orientation: newOrientation, currentEntity: turnEntity)
    }
    
    func handleTouchedAnimation(entity: Entity) {
        if !entity.isEnabled {
            print("ContentsModel::handleTouchedAnimation() This is NOT enabled : ", entity.name)
            return
        }
        print("ContentsModel::handleTouchedAnimation() entity.name : ", entity.name)
        guard let _entity = entity as? ModelEntity else {
            print("ContentsModel::handleTouchedAnimation() Failed to convert to ModelEnity ")
            return
        }
        guard let character = characters[entity.name] else {
            print("ContentsModel::handleTouchedAnimation(): No character found for : ", entity.name)
            return
        }
        
        if character.entities["Kitten_Walk_F_RM"] == entity {
            processRandomEntityFromType(character: character, position: entity.position, orientation: entity.orientation, currentEntity: _entity, isTapped: true)
        }
    }
    
    func degreesToRadians(_ degrees: Float) -> Float {
        return degrees * .pi / 180
    }
}
