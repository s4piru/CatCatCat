import RealityKit
import Foundation
import ARKit

@MainActor class VisionPhysicsViewModel: ObservableObject {
    private let session = ARKitSession()
    private let sceneReconstruction = SceneReconstructionProvider()

    private var contentEntity = Entity()

    private var meshEntities = [UUID: ModelEntity]()

    func setupContentEntity() -> Entity {
        return contentEntity
    }

    func runSession() async {
        
        let authorizationResult = await session.requestAuthorization(for: [.worldSensing/*, .handTracking*/])

       for (authorizationType, authorizationStatus) in authorizationResult {
           print("Authorization status for \(authorizationType): \(authorizationStatus)")

           // Do something for a real app
           switch authorizationStatus {
           case .allowed:
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
            try await session.run([sceneReconstruction/*, handTracking*/])
        } catch {
            print ("Failed to start session: \(error)")
        }
    }
        
    func processReconstructionUpdates() async {
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
                }
                
                entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
                entity.collision = CollisionComponent(shapes: [shape], isStatic: true)
                entity.physicsBody = PhysicsBodyComponent()
                entity.components.set(InputTargetComponent())
                
                meshEntities[meshAnchor.id] = entity
                contentEntity.addChild(entity)
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
