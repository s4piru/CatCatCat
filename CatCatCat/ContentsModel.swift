import SwiftUI
import RealityKit
import Combine

class ContentsModel {
    private let queue = DispatchQueue(label: "com.content.myqueue")
    private var content: RealityViewContent? = nil
    private var characters: [String: Character] = [:]
    private let initialRangeX: Float = 1.25
    private let initialRangeZ: Float = 1.25
    private var rangeX: Float = 1.25
    private var rangeZ: Float = 1.25
    private var yPosition: Float = 0.0
    private var floorPlaneAnchor: AnchorEntity = AnchorEntity()
    private var isClosing: Bool = false
    private let walkMovement: Float = 0.28289
    private let trotMovement: Float = 0.47015
    private let runMovement: Float = 0.72235
    private var subscriptions: [EventSubscription] = []
    private var audioList: [String: AudioFileResource] = [:]
    private var travelingCharacter: String = ""
    private var characterTravelInQueue: String = ""
    private var isHandlingCollision: Bool = false
    
    // Helper functions
    func createRandomOrientation() -> simd_quatf {
        let randomRotation = Float.random(in: 0...(.pi * 2))
        return simd_quatf(angle: randomRotation, axis: SIMD3<Float>(0, 1, 0))
    }
    
    // TODO: Need to be updated.
    func createRandomPositions(count:Int) -> [SIMD3<Float>] {
        var result: [SIMD3<Float>] = []
        var isSmallZ = true
        let perRange = (rangeX * 2) / Float(count)
        var minX: Float = rangeX * -1
        for _ in 1...count {
            let minZ:Float = isSmallZ ? -rangeZ : 0.25
            let maxZ:Float = isSmallZ ? -0.25 : rangeZ
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
    
    func getCharacterFromName(characterName: String) -> Character? {
        guard let character = self.characters[characterName] else {
            print("ContentsModel::getCharacterFromName() characterA Failed to get")
            return nil
        }
        return character
    }
    
    func getModelEntityFromEntity(entity: Entity) -> ModelEntity? {
        guard let modelEntity = entity as? ModelEntity else {
            print("ContentsModel::getModelEntityFromEntity() Failed to convert to ModelEnity ")
            return nil
        }
        return modelEntity
    }
    
    func getFirstEntityFromQueue(character: Character) -> (String, ForceActivityType, ModelEntity) {
        guard var (firstEntityName, forceActivity): (String, ForceActivityType) = character.entityNameQueue.first else {
            print("ContentsModel::getFirstEntityFromQueue(): entityNameQueue is empty for: ", character.characterName)
            return ("", ForceActivityType.none, ModelEntity())
        }
        
        print("ContentsModel::getFirstEntityFromQueue(): firstEntityName: ", firstEntityName)
        
        guard let firstEntity = character.entities[firstEntityName] else {
            print("ContentsModel::getFirstEntityFromQueue(): No entity found for: ", character.characterName, ", entityName: ", firstEntityName)
            return ("", ForceActivityType.none, ModelEntity())
        }
        return (firstEntityName, forceActivity, firstEntity)
    }
    
    func getNextEntityType(currentType: EntityType, isNoTurn: Bool, isNoTravel: Bool = false) -> EntityType {
        guard let possibleEntities = nextEntityList[currentType] else {
            print("ContentsModel::getNextEntityType() There is no currentType: ", currentType)
            return EntityType.unknown
        }
        
        let randomValue = Int.random(in: 0..<100)
        var cumulativeProbability: Int = 0
        
        for (entityType, probability) in possibleEntities {
            cumulativeProbability += probability
            if randomValue <= cumulativeProbability {
                if isNoTurn && (entityType == EntityType.turn90 || entityType == EntityType.turn180) {
                    return EntityType.idle
                } else if isNoTravel && travelEntityTypeList.contains(entityType) { //TODO: onlywalk_start
                    return EntityType.idle
                } else {
                    return entityType
                }
            }
        }
        
        
        print("ContentsModel::getNextEntityType(): Failed to get random entityType")
        return EntityType.unknown
    }
    
    func getRandomEntityName(entityTypes: [EntityType], isNoTurn: Bool, isNoTravel: Bool = false) -> String {
        var usdzList: [String] = []
        for entityType in entityTypes {
            guard let usdzs = entityTypeUsdzList[entityType] else {
                print("ContentsModel::getRandomEntityName(): Failed to get usdzList for: ", entityType)
                return ""
            }
            if isNoTurn && (entityType == EntityType.turn90 || entityType == EntityType.turn180) {
                print("ContentsModel::getRandomEntityName(): Skip Turn")
            } else if isNoTravel && travelEntityTypeList.contains(entityType) {
                print("ContentsModel::getRandomEntityName(): Skip Travel")
            } else {
                usdzList.append(contentsOf: usdzs)
            }
        }
        
        guard let randomEntityName = usdzList.randomElement() else {
            print("ContentsModel::getRandomEntityName(): Failed to get randomEntityName ")
            return ""
        }
        
        return randomEntityName
    }
    
    func isOtherCatTraveling(characterName: String, shouldInculdeQueue: Bool) -> Bool {
        if travelingCharacter != "" && characterName != travelingCharacter {
            return true
        }
        
        if shouldInculdeQueue && characterTravelInQueue != "" && characterName != characterTravelInQueue {
            return true
        }
        return false
    }
    
    func getNewEntityName(hasModelLoadCompleted: Bool, lastEntityType: EntityType, isNoturn: Bool, isNoTravel: Bool = false) -> String {
        if hasModelLoadCompleted {
            let newLastEntityType = getNextEntityType(currentType: lastEntityType, isNoTurn: isNoturn, isNoTravel: isNoTravel)
            return getRandomEntityName(entityTypes: [newLastEntityType], isNoTurn: isNoturn, isNoTravel: isNoTravel)
        } else {
            return firstUsdzEntityTypeList.randomElement()!.key
        }
    }
    
    func appendRandomActionToLastEntity(character: Character, newLastForceActivity: ForceActivityType, isNoTurn: Bool, isNoTravel: Bool = false) {
        guard let (lastEntityName, lastForceActivity): (String, ForceActivityType) = character.entityNameQueue.last else {
            print("ContentsModel::appendRandomActionToLastEntity(): No lastEntityName found for: ", character.characterName)
            return
        }
        
        print("ContentsModel::appendRandomActionToLastEntity(): lastEntityName: ", lastEntityName)
        
        guard let lastEntityType = usdzEntityTypeList[lastEntityName] else {
            print("ContentsModel::appendRandomActionToLastEntity(): No lastEntityType found for: ", character.characterName)
            return
        }
        
        print("ContentsModel::appendRandomActionToLastEntity(): hasModelLoadCompleted: ", character.hasModelLoadCompleted)
        
        var newLastEntityName: String
        
        if isOtherCatTraveling(characterName: character.characterName, shouldInculdeQueue: true) {
            newLastEntityName = getNewEntityName(hasModelLoadCompleted: character.hasModelLoadCompleted, lastEntityType: lastEntityType, isNoturn: isNoTurn, isNoTravel: true)
        } else {
            newLastEntityName = getNewEntityName(hasModelLoadCompleted: character.hasModelLoadCompleted, lastEntityType: lastEntityType, isNoturn: isNoTurn, isNoTravel: isNoTravel)
        }
        
        print("ContentsModel::appendRandomActionToLastEntity(): newLastEntityName: ", newLastEntityName)
        
        character.entityNameQueue.append((newLastEntityName, newLastForceActivity))
        
        if travelEntityNameList.contains(newLastEntityName) {
            characterTravelInQueue = character.characterName
        }
        
        if character.entityNameQueue.count > 1 {
            character.entityNameQueue.remove(at: 0)
        } else {
            print("ContentsModel::appendRandomActionToLastEntity(): No available queue element found for: ", character.characterName)
        }
    }
    
    func canTurn(currentType: EntityType) -> Bool {
        return canTurnList.contains(currentType)
    }
    
    func getTurnEntityNameFromCount(count: Int) -> String {
        if count == 1 {
            return getRandomEntityName(entityTypes: [EntityType.turn180], isNoTurn: false, isNoTravel: true)
        } else {
            return count % 2 == 0 ? "Kitten_Turn_90_L" : "Kitten_Turn_90_R"
        }
    }
    
    func clearTravelFromQueue(characterName: String) {
        guard let character = characters[characterName] else {
            print("ContentsModel::clearTravelFromQueue() Failed to get character catName: ", characterName)
            return
        }
        
        var (firstEntityName, _) = character.entityNameQueue.first!
        character.entityNameQueue.removeAll()
        if travelEntityNameList.contains(firstEntityName) {
            if usdzEntityTypeList[firstEntityName]! == EntityType.walk_start {
                firstEntityName = getRandomEntityName(entityTypes: [EntityType.independent, EntityType.idle], isNoTurn: true, isNoTravel: true)
            } else {
                firstEntityName = "Kitten_Walk_end"
            }
        }
        
        character.entityNameQueue.append((firstEntityName, ForceActivityType.none))
        let nextName = getNewEntityName(hasModelLoadCompleted: character.hasModelLoadCompleted, lastEntityType: usdzEntityTypeList[firstEntityName]!, isNoturn: false, isNoTravel: true)
        character.entityNameQueue.append((nextName, ForceActivityType.none))
        appendRandomActionToLastEntity(character: character, newLastForceActivity: ForceActivityType.none, isNoTurn: false, isNoTravel: true)
        appendRandomActionToLastEntity(character: character, newLastForceActivity: ForceActivityType.none, isNoTurn: false, isNoTravel: true)
        
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
    
    // This is run only when ContentsModel is created.
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
            
            for _ in 1...3 {
                character.entityNameQueue.append((firstUsdzEntityTypeList.randomElement()!.key, ForceActivityType.none))
            }
            
            self.characters[catNameTexture.key] = character
        }
        
        for audioSource in audioSourceList {
            let audio = try! AudioFileResource.load(named: audioSource, configuration: .init(shouldLoop: false))
            audioList[audioSource] = audio
        }
    }
    
    // This is called when user update the character status
    func updateCharacterEnable(catName: String, isEnabled: Bool) {
        let character = getCharacterFromName(characterName: catName)!
        if isEnabled {
            if character.entities.keys.count >= firstUsdzEntityTypeList.keys.count {
                let firstEntityName = firstUsdzEntityTypeList.randomElement()!.key
                guard let firstEntity = character.entities[firstEntityName] else {
                    print("ContentsModel::updateCharacterEnable() There is no Kitten_Walk_start for catName: ", catName)
                    return
                }
                firstEntity.isEnabled = true
                startAnimation(animateEntity: firstEntity, characterName: character.characterName, entiityName: firstEntityName)
                startAudio(character: character, entity: firstEntity, entiityName: firstEntityName)
            } else {
                print("ContentsModel::updateCharacterEnable(), wait for entity load")
            }
            character.isEnabled = true
        } else {
            character.isEnabled = false
        }
    }
    
    // This is called everytime immersiveView is closed
    func closeImmersiveView() {
        cancelAllSubscriptions()
        removeAllChildren()
    }
    
    // This is called everytime immersiveView is opend
    func registerContent(content: RealityViewContent) {
        self.isClosing = false
        self.travelingCharacter = ""
        self.characterTravelInQueue = ""
        self.rangeX = self.initialRangeX
        self.rangeZ = self.initialRangeZ
        self.floorPlaneAnchor = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: SIMD2<Float>(0.01, 0.01)))
        self.floorPlaneAnchor.generateCollisionShapes(recursive: false)
        self.floorPlaneAnchor.position.x = 0.0
        self.floorPlaneAnchor.position.z = 0.0
        self.isHandlingCollision = false
        content.add(floorPlaneAnchor)
        self.content = content
    }
    
    func handleCollision(entityA: Entity, entityB: Entity, isCollide: Bool) {
        let modelEntityA = getModelEntityFromEntity(entity: entityA)!
        let modelEntityB = getModelEntityFromEntity(entity: entityB)!
        let characterA = getCharacterFromName(characterName: modelEntityA.name)!
        let characterB = getCharacterFromName(characterName: modelEntityB.name)!
        
        let (_, countA) = characterA.shouldResolveCollisionCount
        let (_, countB) = characterB.shouldResolveCollisionCount
        if isCollide {
            self.isHandlingCollision = true
            if modelEntityA.name == travelingCharacter {
                characterA.shouldResolveCollisionCount = (true, countA+1)
            } else if modelEntityB.name == travelingCharacter {
                characterB.shouldResolveCollisionCount = (true, countB+1)
            } else {
                characterB.shouldResolveCollisionCount = (true, 1)
            }
        }
    }
    
    func registerEntity(entity: ModelEntity, characterName: String, entityType: EntityType, entityName: String) {
        if content != nil {
            subscriptions.append(content!.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: entity) { e in
                self.processAfterAnimation(characterName: characterName, entityType: entityType, entityName: entityName)
                print("ContentsModel::registerEntity() processAfterAnimation called: ", characterName, ", usdzName: ", entityName)
            })
            subscriptions.append(content!.subscribe(to: CollisionEvents.Began.self) { e in
                if !self.isHandlingCollision && e.entityA.isEnabled && e.entityB.isEnabled {
                    print("====================Collision between \(e.entityA.name) and \(e.entityB.name) is occured====================")
                    self.handleCollision(entityA: e.entityA, entityB: e.entityB, isCollide: true)
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
            startAnimation(animateEntity: firstEntity, characterName: character.characterName, entiityName: firstEntityName)
            startAudio(character: character, entity: firstEntity, entiityName: firstEntityName)
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
        let collisionShape = ShapeResource.generateBox(size: SIMD3<Float>(entity.scale.x/1.95, entity.scale.y/1.95, entity.scale.z*1.3))
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
    
    func startAudio(character: Character, entity: ModelEntity, entiityName: String) {
        if audioAvailableUsdzSoucesList.keys.contains(entiityName) {
            let shouldPlay: Bool = Int.random(in: 0...10000) % 8 == 0
            if shouldPlay {
                let sourceName: String = audioAvailableUsdzSoucesList[entiityName]!.randomElement()!
                guard let audio = audioList[sourceName] else {
                    print("ContentsModel::startAudio() Failed to get audio: ", sourceName)
                    return
                }
                character.audioSource.removeFromParent()
                entity.addChild(character.audioSource)
                character.audioSource.playAudio(audio)
            }
        }
    }
    
    func startAnimation(animateEntity: ModelEntity, characterName: String, entiityName: String) {
        if animateEntity.availableAnimations.count > 0 {
            animateEntity.playAnimation(animateEntity.availableAnimations[0])
            if travelEntityNameList.contains(entiityName) {
                self.travelingCharacter = characterName
            } else {
                if self.travelingCharacter == characterName {
                    self.travelingCharacter = ""
                }
            }
        } else {
            print("ContentsModel::startAnimation() No available animation: ", animateEntity.name)
            return
        }
    }
    
    func processRandomEntityFromType(character: Character, position: SIMD3<Float>, orientation: simd_quatf, currentEntity: ModelEntity, isTapped: Bool = false, isForceTurn: Bool = false, isCurrentTravel: Bool = false) {
        var nextEntity: ModelEntity = ModelEntity()
        var nextEntityName: String = ""
        let (shouldResolve, count) = character.shouldResolveCollisionCount
        if isTapped {
            character.entityNameQueue.removeAll()
            character.entityNameQueue.append(("Kitten_Walk_end", ForceActivityType.none))
            let independentEntityName = getRandomEntityName(entityTypes: [EntityType.independent, EntityType.idle], isNoTurn: true, isNoTravel: true)
            if character.entities.keys.contains(independentEntityName) {
                character.entityNameQueue.append((independentEntityName, ForceActivityType.none))
            } else {
                character.entityNameQueue.append((firstUsdzEntityTypeList.randomElement()!.key, ForceActivityType.none))
            }
            return
        } else if !character.hasModelLoadCompleted {
            (nextEntityName, _, nextEntity) = getFirstEntityFromQueue(character: character)
            appendRandomActionToLastEntity(character: character, newLastForceActivity: ForceActivityType.none, isNoTurn: true)
        } else if isHandlingCollision {
            if shouldResolve {
                if character.entities["Kitten_Walk_F_RM"]! == currentEntity {
                    // if walk, end walk and return
                    nextEntityName = "Kitten_Walk_end"
                    nextEntity = character.entities["Kitten_Walk_end"]!
                    let turnEntityName = getTurnEntityNameFromCount(count: count)
                    character.entityNameQueue.removeAll()
                    character.entityNameQueue.append((turnEntityName, ForceActivityType.collision))
                    character.entityNameQueue.append(("Kitten_Walk_start", ForceActivityType.collision))
                    character.entityNameQueue.append(("Kitten_Walk_F_RM", ForceActivityType.collision))
                    character.entityNameQueue.append(("Kitten_Walk_end", ForceActivityType.collision))
                    character.shouldResolveCollisionCount = (false, count)
                    if self.characterTravelInQueue != "" && self.characterTravelInQueue != character.characterName {
                        clearTravelFromQueue(characterName: self.characterTravelInQueue)
                    }
                    self.characterTravelInQueue = character.characterName
                } else if isCurrentTravel {
                    // if not walk, walk first.
                    nextEntityName = "Kitten_Walk_F_RM"
                    nextEntity = character.entities["Kitten_Walk_F_RM"]!
                } else if character.entityNameQueue.count > 0 && !canTurn(currentType: usdzEntityTypeList[character.entityNameQueue.first!.0]!) {
                    // not travel, cannot turn
                    (nextEntityName, _, nextEntity) = getFirstEntityFromQueue(character: character)
                    appendRandomActionToLastEntity(character: character, newLastForceActivity: ForceActivityType.collision, isNoTurn: true, isNoTravel: true)
                } else {
                    // not travel, can turn
                    let turnEntityName = getTurnEntityNameFromCount(count: count)
                    nextEntityName = turnEntityName
                    nextEntity = character.entities[nextEntityName]!
                    character.entityNameQueue.removeAll()
                    character.entityNameQueue.append(("Kitten_Walk_start", ForceActivityType.collision))
                    character.entityNameQueue.append(("Kitten_Walk_F_RM", ForceActivityType.collision))
                    character.entityNameQueue.append(("Kitten_Walk_end", ForceActivityType.collision))
                    character.shouldResolveCollisionCount = (false, count)
                    if self.characterTravelInQueue != "" && self.characterTravelInQueue != character.characterName {
                        clearTravelFromQueue(characterName: self.characterTravelInQueue)
                    }
                    self.characterTravelInQueue = character.characterName
                }
            } else{
                var nextForceActivity: ForceActivityType
                (nextEntityName, nextForceActivity, nextEntity) = getFirstEntityFromQueue(character: character)
                appendRandomActionToLastEntity(character: character, newLastForceActivity: ForceActivityType.none, isNoTurn: true, isNoTravel: true)
                if nextForceActivity == ForceActivityType.none {
                    self.isHandlingCollision = false
                }
            }
        } else if isForceTurn {
            if character.entities["Kitten_Walk_F_RM"]! == currentEntity {
                nextEntityName = "Kitten_Walk_end"
                nextEntity = character.entities["Kitten_Walk_end"]!
                character.entityNameQueue.removeAll()
                character.entityNameQueue.append(("Kitten_Turn_180_R", ForceActivityType.turn))
            } else {
                nextEntityName = "Kitten_Walk_F_RM"
                nextEntity = character.entities["Kitten_Walk_F_RM"]!
            }
        } else {
            (nextEntityName, _, nextEntity) = getFirstEntityFromQueue(character: character)
            appendRandomActionToLastEntity(character: character, newLastForceActivity: ForceActivityType.none, isNoTurn: false)
        }
        
        nextEntity.position.x = position.x
        nextEntity.position.z = position.z
        nextEntity.orientation = orientation
        currentEntity.isEnabled = false
        nextEntity.isEnabled = true
        startAnimation(animateEntity: nextEntity, characterName: character.characterName, entiityName: nextEntityName)
        startAudio(character: character, entity: nextEntity, entiityName: nextEntityName)
        
        if self.characterTravelInQueue == character.characterName {
            var hasTravelItem: Bool = false
            for (name, type) in character.entityNameQueue {
                if travelEntityNameList.contains(name) {
                    hasTravelItem = true
                }
            }
            if !hasTravelItem {
                self.characterTravelInQueue = ""
            }
        }
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
        case EntityType.turn90, EntityType.turn180:
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
        return position.x >= (rangeX * -1.0) && position.x <= rangeX && position.z >= (rangeZ * -1.0) && position.z <= rangeZ
    }
    
    func updateRange(position: SIMD3<Float>) {
        if position.x < -rangeX {
            self.rangeX = position.x * -1.0
        }
        
        if position.x > rangeX {
            self.rangeX = position.x
        }
        
        if position.z < -rangeZ {
            self.rangeZ = position.z * -1.0
        }
        
        if position.z > rangeZ {
            self.rangeZ = position.z
        }
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
            processRandomEntityFromType(character: character, position: finalPosition, orientation: entity.orientation, currentEntity: entity, isCurrentTravel: true)
        } else {
            processRandomEntityFromType(character: character, position: finalPosition, orientation: entity.orientation, currentEntity: entity, isForceTurn: true, isCurrentTravel: true)
            updateRange(position: finalPosition)
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
