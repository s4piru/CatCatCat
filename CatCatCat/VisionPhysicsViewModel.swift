import SwiftUI
import RealityKit
import Foundation
import ARKit

@MainActor class VisionPhysicsViewModel: ObservableObject {
    private let session = ARKitSession()
    private let sceneReconstruction = SceneReconstructionProvider()
    private let planeWidth:Float = 2.4
    private let planeHeight:Float = 1.0
    private let planeWidth100:Int = 240
    private let planeHeight100:Int = 100
    private var contentEntity = Entity()
    private var meshEntities = [UUID: ModelEntity]()
    private var planeMatrix: [[Bool]] = []
    private var isSupported: Bool = false
    private let initialMinZ: Float = -1.0
    private let initialRangeX: Float = 1.2
    private let catSize:Float = 0.48
    private let minObjHeight: Float = 0.2

    func setUpMatrix() {
        for _ in 0...planeWidth100 {
            var lineX: [Bool] = []
            for _ in 0...planeWidth100 {
                lineX.append(true)
            }
            planeMatrix.append(lineX)
        }
    }

    func setupContentEntity() -> Entity {
        return contentEntity
    }
    
    func getPlaneMatrix() -> [[Bool]] {
        print("===============getPlaneMatrix=================")
        for indZ in 0...planeHeight100 {
            print(planeMatrix[indZ])
        }
        print("===============getPlaneMatrix=================")
        return planeMatrix
    }

    func runSession() async {
        let authorizationResult = await session.requestAuthorization(for: [.worldSensing])
        for (authorizationType, authorizationStatus) in authorizationResult {
            print("Authorization status for \(authorizationType): \(authorizationStatus)")
            
            // Do something for a real app
            switch authorizationStatus {
            case .allowed:
                isSupported = true
                continue
            case .denied:
                return
            case .notDetermined:
                return
            @unknown default:
                return
            }
        }
        
        do {
            try await session.run([sceneReconstruction])
        } catch {
            print ("Failed to start session: \(error)")
        }
    }
        
    func processReconstructionUpdates() async {
        if isSupported == false {
            return
        }
        
        for await update in sceneReconstruction.anchorUpdates {
            let meshAnchor = update.anchor
            guard let shape = try? await ShapeResource.generateStaticMesh(from: meshAnchor) else { continue }
            
            switch update.event {
            case .added:
                let entity = ModelEntity()
                entity.name = "Plane \(meshAnchor.id)"
                
                // Generate a mesh resource for occlusion
                var meshResource: MeshResource? = nil
                do {
                    let contents = MeshResource.Contents(meshGeometry: meshAnchor.geometry)
                    meshResource = try MeshResource.generate(from: contents)
                } catch {
                    print("Failed to create a mesh resource for a plane anchor: \(error).")
                    return
                }
                
                if let meshResource {
                    // Make this mesh occlude virtual objects behind it.
                    entity.components.set(ModelComponent(mesh: meshResource, materials: [OcclusionMaterial()]))
                    if /*meshResource.bounds.max.y > 0.05*/ shape.bounds.max.y > minObjHeight  {
                        var minX:Int = Int((meshAnchor.originFromAnchorTransform.translation.x + shape.bounds.min.x + initialRangeX) * 100)
                        var maxX:Int = Int((meshAnchor.originFromAnchorTransform.translation.x + shape.bounds.max.x + initialRangeX) * 100)
                        var minZ:Int = Int((meshAnchor.originFromAnchorTransform.translation.z + shape.bounds.min.z + -initialMinZ) * 100)
                        var maxZ:Int = Int((meshAnchor.originFromAnchorTransform.translation.z + shape.bounds.max.z + -initialMinZ) * 100)
                        if minX > planeWidth100 || maxX < 0 || minZ > planeHeight100 || maxZ < 0 {
                            print("Outside mesh")
                        } else {
                            minX = max(minX, 0)
                            maxX = min(maxX, planeWidth100)
                            minZ = max(minZ, 0)
                            maxZ = min(maxZ, planeHeight100)
                            for indZ in minZ...maxZ {
                                for indX in minX...maxX {
                                    planeMatrix[indZ][indX] = false
                                }
                            }
                        }
                    }
                }
                
                entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
                entity.collision = CollisionComponent(shapes: [shape], isStatic: true)
                entity.physicsBody = PhysicsBodyComponent()
                meshEntities[meshAnchor.id] = entity
                contentEntity.addChild(entity)
            // ignore for now
            case .updated:
                guard let entity = meshEntities[meshAnchor.id] else { fatalError("...") }
                entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
                entity.collision?.shapes = [shape]
            case .removed:
                meshEntities[meshAnchor.id]?.removeFromParent()
                meshEntities.removeValue(forKey: meshAnchor.id)
            }
        }
    }
}
