import SwiftUI
import RealityKit
import Combine

class ContentsModel {
    private let queue = DispatchQueue(label: "com.content.myqueue")
    private var content: RealityViewContent? = nil
    private var characters: [String: Character] = [:]
    private let planeWidth100:Int = 180
    private let planeHeight100:Int = 100
    private let initialRangeX: Float = 0.9
    private let initialRangeZ: Float = 0
    private let initialMinZ: Float = -1.0
    private var minZ: Float = -1.0 // check physics model and canputobj if change this
    private var rangeX: Float = 0.9
    private var rangeZ: Float = 0
    private var yTransform: Float = 0.0
    private var isClosing: Bool = false
    private let walkMovement: Float = 0.28289
    private let trotMovement: Float = 0.47015
    private let runMovement: Float = 0.72235
    private var subscriptions: [EventSubscription] = []
    private var audioList: [String: AudioFileResource] = [:]
    private var travelingCharacter: String = ""
    private var characterTravelInQueue: String = ""
    private var isHandlingCollision: Bool = false
    private var collisionHandlingCharacter = ""
    private let maxCatCount = 3
    private var transforms: [(SIMD3<Float>, String)] = []
    private let catSize:Float = 0.48
    private var planeMatrix: [[Bool]] = []
    
    // Helper functions
    func createRandomOrientation() -> simd_quatf {
        let randomRotation = Float.random(in: 0...(.pi * 2))
        return simd_quatf(angle: randomRotation, axis: SIMD3<Float>(0, 1, 0))
    }
    
    func canPutObj(x: Float, z: Float) -> Bool {
        var addZ:Float = 0.0
        if minZ < 0 {
            addZ = -minZ
        }
        var minX: Int = Int((x - catSize/2 + rangeX) * 100)
        var maxX: Int = Int((x + catSize/2 + rangeX) * 100)
        var minZ: Int = Int((z - catSize/2 + addZ) * 100)
        var maxZ: Int = Int((z + catSize/2 + addZ) * 100)
        if minX > planeWidth100 || maxX < 0 || minZ > planeHeight100 || maxZ < 0 {
            print("Outside plane")
            return false
        } else {
            minX = max(minX, 0)
            maxX = min(maxX, planeWidth100)
            minZ = max(minZ, 0)
            maxZ = min(maxZ, planeHeight100)
            for indZ in minZ...maxZ {
                for indX in minX...maxX {
                    if planeMatrix[indZ][indX] == false {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    // TODO: Need to be updated.
    func createRandomTransforms() -> Int {
        var isSmallZ = true
        let perRange: Float = (rangeX * 2) / Float(maxCatCount)
        var curX: Float = (rangeX * -1) + (perRange/2)
        var availableNum: Int = 0
        for _ in 1...maxCatCount {
            /*let minZ:Float = isSmallZ ? minZ : (rangeZ - minZ)/2 + 0.2 + minZ
            let maxZ:Float = isSmallZ ? (rangeZ - minZ)/2 - 0.2 + minZ : rangeZ
            let acMinX: Float = ind != 1 ? minX + 0.2 : minX
            let acMaxX: Float = ind != maxCatCount ? minX+perRange - 0.2 : minX+perRange*/
            var canPut: Bool = false
            var curZ: Float = isSmallZ ? minZ + catSize/2 : rangeZ - catSize/2
            if isSmallZ {
                while curZ <= (rangeZ - catSize) {
                    if canPutObj(x: curX, z: curZ) {
                        canPut = true
                        break;
                    }
                    curZ += 0.1
                }
            } else {
                while curZ >= (minZ + catSize) {
                    if canPutObj(x: curX, z: curZ) {
                        canPut = true
                        break;
                    }
                    curZ -= 0.1
                }
            }
           
            if canPut {
                transforms.append((SIMD3<Float>(
                    x: curX,
                    y: yTransform,
                    z: curZ
                ), ""))
                availableNum += 1
            }
            curX += perRange
            isSmallZ = isSmallZ ? false : true
        }
        print("createRandomTransforms:: availableNum: ", availableNum)
        return availableNum
    }
    
    func updateTransformFromName(characterName: String, transform: SIMD3<Float>) {
        for (ind, ele) in transforms.enumerated() {
            if ele.1 == characterName {
                self.transforms[ind].0 = transform
            }
        }
    }
    
    func removeCharacterFromTransForm(characterName: String) {
        for (ind, ele) in transforms.enumerated() {
            if ele.1 == characterName {
                self.transforms[ind].1 = ""
            }
        }
    }
    
    func getUnusedTransform(characterName: String) -> SIMD3<Float> {
        for (ind, ele) in transforms.enumerated() {
            if ele.1 == "" {
                self.transforms[ind].1 = characterName
                return ele.0
            }
        }
        print("ContentsModel::getUnusedTransform() failed to get Unused")
        return SIMD3<Float>()
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
        guard let (firstEntityName, forceActivity): (String, ForceActivityType) = character.entityNameQueue.first else {
            print("ContentsModel::getFirstEntityFromQueue(): entityNameQueue is empty for: ", character.characterName)
            return ("", ForceActivityType.none, ModelEntity())
        }
        
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
                } else if isNoTravel && travelEntityTypeList.contains(entityType) { //TODO: only walk_start
                    return EntityType.idle
                } else {
                    return entityType
                }
            }
        }
        
        print("ContentsModel::getNextEntityType(): Failed to get random entityType")
        return EntityType.unknown
    }
    
    func getRandomEntityNameFromTypes(entityTypes: [EntityType], isNoTurn: Bool, isNoTravel: Bool = false) -> String {
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
    
    func getNewEntityNameFromlastEntityType(hasModelLoadCompleted: Bool, lastEntityType: EntityType, isNoturn: Bool, isNoTravel: Bool = false) -> String {
        if hasModelLoadCompleted {
            let newLastEntityType = getNextEntityType(currentType: lastEntityType, isNoTurn: isNoturn, isNoTravel: isNoTravel)
            return getRandomEntityNameFromTypes(entityTypes: [newLastEntityType], isNoTurn: isNoturn, isNoTravel: isNoTravel)
        } else {
            return firstUsdzEntityTypeList.randomElement()!.key
        }
    }
    
    func appendRandomActionToQueue(character: Character, newLastForceActivity: ForceActivityType, isNoTurn: Bool, isNoTravel: Bool = false) {
        guard let (lastEntityName, _): (String, ForceActivityType) = character.entityNameQueue.last else {
            print("ContentsModel::appendRandomActionToLastEntity(): No lastEntityName found for: ", character.characterName)
            return
        }
        
        guard let lastEntityType = usdzEntityTypeList[lastEntityName] else {
            print("ContentsModel::appendRandomActionToLastEntity(): No lastEntityType found for: ", character.characterName)
            return
        }
        
        var newLastEntityName: String
        
        if isOtherCatTraveling(characterName: character.characterName, shouldInculdeQueue: true) {
            newLastEntityName = getNewEntityNameFromlastEntityType(hasModelLoadCompleted: character.hasModelLoadCompleted, lastEntityType: lastEntityType, isNoturn: isNoTurn, isNoTravel: true)
        } else {
            newLastEntityName = getNewEntityNameFromlastEntityType(hasModelLoadCompleted: character.hasModelLoadCompleted, lastEntityType: lastEntityType, isNoturn: isNoTurn, isNoTravel: isNoTravel)
        }
        
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
            return getRandomEntityNameFromTypes(entityTypes: [EntityType.turn180], isNoTurn: false, isNoTravel: true)
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
                firstEntityName = getRandomEntityNameFromTypes(entityTypes: [EntityType.independent, EntityType.idle], isNoTurn: true, isNoTravel: true)
            } else {
                firstEntityName = "Kitten_Walk_end"
            }
        }
        
        character.entityNameQueue.append((firstEntityName, ForceActivityType.none))
        let nextName = getNewEntityNameFromlastEntityType(hasModelLoadCompleted: character.hasModelLoadCompleted, lastEntityType: usdzEntityTypeList[firstEntityName]!, isNoturn: false, isNoTravel: true)
        character.entityNameQueue.append((nextName, ForceActivityType.none))
        appendRandomActionToQueue(character: character, newLastForceActivity: ForceActivityType.none, isNoTurn: false, isNoTravel: true)
        appendRandomActionToQueue(character: character, newLastForceActivity: ForceActivityType.none, isNoTurn: false, isNoTravel: true)
    }
    
    func degreesToRadians(_ degrees: Float) -> Float {
        return degrees * .pi / 180
    }
    
    func isInsizeRange(transform: SIMD3<Float>) -> Bool {
        return transform.x >= (rangeX * -1.0) && transform.x <= rangeX && transform.z >= minZ && transform.z <= rangeZ
    }
    
    func updateRange(transform: SIMD3<Float>) {
        if transform.x < -rangeX {
            self.rangeX = transform.x * -1.0
        }
        
        if transform.x > rangeX {
            self.rangeX = transform.x
        }
        
        if transform.z < minZ {
            self.minZ = transform.z
        }
        
        if transform.z > rangeZ {
            self.rangeZ = transform.z
        }
    }
    
    func removeAllChildren() {
        isClosing = true
        for catNameTexture in catNameTextureList {
            let character = getCharacterFromName(characterName: catNameTexture.key)!
            for entity in character.entities {
                entity.value.stopAllAnimations()
                entity.value.isEnabled = false
                content!.remove(entity.value)
            }
        }
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
        for catNameTexture in catNameTextureList {
            guard let textureName: String = catNameTextureList[catNameTexture.key] else {
                print("ContentsModel::init() There is no catName: ", catNameTexture.key)
                return
            }
            
            var material = SimpleMaterial()
            let texture = try! TextureResource.load(named: textureName)
            material.color.texture = .init(texture)
            
            let character = Character(characterName: catNameTexture.key, entities: [:], material: material)
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
                    print("ContentsModel::updateCharacterEnable() There is no : ", firstEntityName, catName)
                    return
                }
                character.entityNameQueue.removeAll()
                for _ in 1...3 {
                    character.entityNameQueue.append((firstUsdzEntityTypeList.randomElement()!.key, ForceActivityType.none))
                }
                let firstTransform = getUnusedTransform(characterName: catName)
                firstEntity.transform.translation.x = firstTransform.x
                firstEntity.transform.translation.z = firstTransform.z
                firstEntity.orientation = createRandomOrientation()
                firstEntity.isEnabled = true
                startAnimation(animateEntity: firstEntity, characterName: character.characterName, entiityName: firstEntityName)
                startAudio(character: character, entity: firstEntity, entiityName: firstEntityName)
            } else {
                print("ContentsModel::updateCharacterEnable(), wait for entity load")
            }
            character.isEnabled = true
        } else {
            character.isEnabled = false
            removeCharacterFromTransForm(characterName: catName)
            if travelingCharacter == catName {
                travelingCharacter = ""
            }
            if characterTravelInQueue == catName {
                characterTravelInQueue = ""
            }
            let currentName = character.currentEnabledEntityName
            if character.entities.keys.contains(currentName) {
                let currentEntity = character.entities[character.currentEnabledEntityName]!
                currentEntity.isEnabled = false
                currentEntity.stopAllAnimations()
            }
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
        self.minZ = self.initialMinZ
        self.rangeX = self.initialRangeX
        self.rangeZ = self.initialRangeZ
        self.isHandlingCollision = false
        self.collisionHandlingCharacter = ""
        self.content = content
    }
    
    func getNumCat(planeMatrix: [[Bool]]) -> Int {
        self.planeMatrix = planeMatrix
        return createRandomTransforms()
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
                collisionHandlingCharacter = characterA.characterName
            } else if modelEntityB.name == travelingCharacter {
                characterB.shouldResolveCollisionCount = (true, countB+1)
                collisionHandlingCharacter = characterB.characterName
            } else if self.isHandlingCollision == false {
                characterB.shouldResolveCollisionCount = (true, 1)
                collisionHandlingCharacter = characterB.characterName
            }
        }
    }
    
    func isCharacter(name: String) -> Bool {
        return catNameTextureList.keys.contains(name)
    }
    
    func registerEntity(entity: ModelEntity, characterName: String, entityType: EntityType, entityName: String) {
        if content != nil {
            content!.add(entity)
            subscriptions.append(content!.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: entity) { e in
                self.processAfterAnimation(characterName: characterName, entityType: entityType, entityName: entityName)
                print("ContentsModel::registerEntity() processAfterAnimation called: ", characterName, ", usdzName: ", entityName)
            })
            subscriptions.append(content!.subscribe(to: CollisionEvents.Began.self) { e in
                if self.isCharacter(name: e.entityA.name) && self.isCharacter(name: e.entityB.name) && !self.isHandlingCollision && e.entityA.isEnabled && e.entityB.isEnabled {
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
        let character = getCharacterFromName(characterName: catName)!
        
        for usdzEntityType in firstUsdzEntityTypeList {
            if !character.entities.keys.contains(usdzEntityType.key) {
                let entity = await loadEntity(characterName: catName, entityType:usdzEntityType.value, usdzName: usdzEntityType.key, material: character.material)
                    character.entities[usdzEntityType.key] = entity
            }
        }
        
        for regiterEntity in character.entities {
            DispatchQueue.main.async {
                self.registerEntity(entity: regiterEntity.value, characterName: catName, entityType: usdzEntityTypeList[regiterEntity.key]!, entityName: regiterEntity.key)
            }
        }
        
        let firstEntityName = firstUsdzEntityTypeList.randomElement()!.key
        guard let firstEntity = character.entities[firstEntityName] else {
            print("ContentsModel::createCharacter() There is no Kitten_Walk_start for catName: ", catName)
            return
        }

        if character.isEnabled {
            let firstTransform = getUnusedTransform(characterName: catName)
            firstEntity.transform.translation.x = firstTransform.x
            firstEntity.transform.translation.z = firstTransform.z
            let firstOrientation = createRandomOrientation()
            firstEntity.orientation = firstOrientation
            firstEntity.isEnabled = true
            startAnimation(animateEntity: firstEntity, characterName: character.characterName, entiityName: firstEntityName)
            startAudio(character: character, entity: firstEntity, entiityName: firstEntityName)
        }
        
        Task {
            await addRemainigEntities(character: character)
            character.hasModelLoadCompleted = true
        }
        
        return
    }
    
    func addRemainigEntities(character: Character) async {
        for usdzEntityType in usdzEntityTypeList {
            if !character.entities.keys.contains(usdzEntityType.key) && !firstUsdzEntityTypeList.keys.contains(usdzEntityType.key) {
                let entity = await self.loadEntity(characterName: character.characterName, entityType:usdzEntityType.value, usdzName: usdzEntityType.key, material: character.material)
                DispatchQueue.main.async {
                    self.registerEntity(entity: entity, characterName: character.characterName, entityType: usdzEntityType.value, entityName: usdzEntityType.key)
                    character.entities[usdzEntityType.key] = entity
                }
            }
        }
    }
    
    func setCollisionComponent(entity: ModelEntity) {
        entity.generateCollisionShapes(recursive: true)
        let collisionShape = ShapeResource.generateBox(size: SIMD3<Float>(entity.scale.x*1.3, entity.scale.y*1.3, entity.scale.z*1.3))
        entity.components.set(CollisionComponent(shapes: [collisionShape]))
    }
    
    @MainActor
    func loadEntity(characterName: String, entityType: EntityType, usdzName: String, material: SimpleMaterial) async -> ModelEntity {
        do {
            let loadedEntity = try await ModelEntity(named: usdzName)
            loadedEntity.model?.materials = [material]
            loadedEntity.name = characterName
            loadedEntity.transform.translation.y = 0.0
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
            let shouldPlay: Bool = Int.random(in: 0...10000) % 9 == 0
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
            let character = getCharacterFromName(characterName: characterName)!
            character.currentEnabledEntityName = entiityName
            updateTransformFromName(characterName: characterName, transform: animateEntity.transform.translation)
        } else {
            print("ContentsModel::startAnimation() No available animation: ", animateEntity.name)
            return
        }
    }
    
    func processRandomEntityFromType(character: Character, transform: SIMD3<Float>, orientation: simd_quatf, currentEntity: ModelEntity, isTapped: Bool = false, isForceTurn: Bool = false, isCurrentTravel: Bool = false) {
        var nextEntity: ModelEntity = ModelEntity()
        var nextEntityName: String = ""
        let (shouldResolve, count) = character.shouldResolveCollisionCount
        if isTapped {
            character.entityNameQueue.removeAll()
            character.entityNameQueue.append(("Kitten_Walk_end", ForceActivityType.none))
            let independentEntityName = getRandomEntityNameFromTypes(entityTypes: [EntityType.independent, EntityType.idle], isNoTurn: true, isNoTravel: true)
            if character.entities.keys.contains(independentEntityName) {
                character.entityNameQueue.append((independentEntityName, ForceActivityType.none))
            } else {
                character.entityNameQueue.append((firstUsdzEntityTypeList.randomElement()!.key, ForceActivityType.none))
            }
            return
        } else if !character.hasModelLoadCompleted {
            (nextEntityName, _, nextEntity) = getFirstEntityFromQueue(character: character)
            appendRandomActionToQueue(character: character, newLastForceActivity: ForceActivityType.none, isNoTurn: true, isNoTravel: true)
        } else if isHandlingCollision {
            if shouldResolve {
                if isCurrentTravel {
                    // if walk, end walk and return
                    nextEntityName = "Kitten_Walk_end"
                    nextEntity = character.entities[nextEntityName]!
                    let turnEntityName = getTurnEntityNameFromCount(count: count)
                    character.entityNameQueue.removeAll()
                    character.entityNameQueue.append((turnEntityName, ForceActivityType.collision))
                    character.entityNameQueue.append(("Kitten_Walk_start", ForceActivityType.collision))
                    character.entityNameQueue.append(("Kitten_Walk_F_RM", ForceActivityType.collision))
                    character.entityNameQueue.append(("Kitten_Walk_F_RM", ForceActivityType.collision))
                    character.entityNameQueue.append(("Kitten_Walk_end", ForceActivityType.collision))
                    character.shouldResolveCollisionCount = (false, count)
                    if self.characterTravelInQueue != "" && self.characterTravelInQueue != character.characterName {
                        clearTravelFromQueue(characterName: self.characterTravelInQueue)
                    }
                    self.characterTravelInQueue = character.characterName
                } else if character.entityNameQueue.count > 0 && !canTurn(currentType: usdzEntityTypeList[character.entityNameQueue.first!.0]!) {
                    // not travel, cannot turn
                    (nextEntityName, _, nextEntity) = getFirstEntityFromQueue(character: character)
                    appendRandomActionToQueue(character: character, newLastForceActivity: ForceActivityType.collision, isNoTurn: true, isNoTravel: true)
                } else {
                    // not travel, can turn
                    let turnEntityName = getTurnEntityNameFromCount(count: count)
                    nextEntityName = turnEntityName
                    nextEntity = character.entities[nextEntityName]!
                    character.entityNameQueue.removeAll()
                    character.entityNameQueue.append(("Kitten_Walk_start", ForceActivityType.collision))
                    character.entityNameQueue.append(("Kitten_Walk_F_RM", ForceActivityType.collision))
                    character.entityNameQueue.append(("Kitten_Walk_F_RM", ForceActivityType.collision))
                    character.entityNameQueue.append(("Kitten_Walk_end", ForceActivityType.collision))
                    character.shouldResolveCollisionCount = (false, count)
                    if self.characterTravelInQueue != "" && self.characterTravelInQueue != character.characterName {
                        clearTravelFromQueue(characterName: self.characterTravelInQueue)
                    }
                    self.characterTravelInQueue = character.characterName
                }
            } else {
                var nextForceActivity: ForceActivityType
                (nextEntityName, nextForceActivity, nextEntity) = getFirstEntityFromQueue(character: character)
                appendRandomActionToQueue(character: character, newLastForceActivity: ForceActivityType.none, isNoTurn: true, isNoTravel: true)
                if collisionHandlingCharacter == character.characterName && nextForceActivity == ForceActivityType.none {
                    self.isHandlingCollision = false
                    self.collisionHandlingCharacter = ""
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
            appendRandomActionToQueue(character: character, newLastForceActivity: ForceActivityType.none, isNoTurn: false)
        }
        
        nextEntity.transform.translation.x = transform.x
        nextEntity.transform.translation.z = transform.z
        nextEntity.orientation = orientation
        currentEntity.isEnabled = false
        nextEntity.isEnabled = true
        startAnimation(animateEntity: nextEntity, characterName: character.characterName, entiityName: nextEntityName)
        startAudio(character: character, entity: nextEntity, entiityName: nextEntityName)
        
        if self.characterTravelInQueue == character.characterName {
            var hasTravelItem: Bool = false
            for (name, _) in character.entityNameQueue {
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
            if entity.isEnabled {
                entity.isEnabled = false
            }
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
            processRandomEntityFromType(character: character, transform: entity.transform.translation, orientation: entity.orientation, currentEntity: entity)
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
        
        let finalTransform = entity.transform.translation + forwardDirection * meshMovement
        if isInsizeRange(transform: finalTransform) {
            processRandomEntityFromType(character: character, transform: finalTransform, orientation: entity.orientation, currentEntity: entity, isCurrentTravel: true)
        } else {
            processRandomEntityFromType(character: character, transform: finalTransform, orientation: entity.orientation, currentEntity: entity, isForceTurn: true, isCurrentTravel: true)
            updateRange(transform: finalTransform)
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
        processRandomEntityFromType(character: character, transform: turnEntity.transform.translation, orientation: newOrientation, currentEntity: turnEntity)
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
            processRandomEntityFromType(character: character, transform: entity.transform.translation, orientation: entity.orientation, currentEntity: _entity, isTapped: true)
        }
    }
}
