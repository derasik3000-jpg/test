import SwiftUI
import SceneKit

struct GamingIconsSceneView: UIViewRepresentable {
    var iconCount: Int
    var iconColor: Color
    var iconViewType: String
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = createScene()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = true
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = createScene()
    }
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        scene.rootNode.addChildNode(cameraNode)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.lightGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let gridSize = Int(ceil(sqrt(Double(iconCount))))
        let spacing: Float = 1.5
        let startOffset = Float(gridSize - 1) * spacing / 2.0
        
        for i in 0..<min(iconCount, 50) {
            let x = Float(i % gridSize) * spacing - startOffset
            let z = Float(i / gridSize) * spacing - startOffset
            
            let iconNode = createIconNode(type: iconViewType, color: iconColor)
            iconNode.position = SCNVector3(x: x, y: 0, z: z)
            
            let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 8.0)
            let repeatAction = SCNAction.repeatForever(rotateAction)
            iconNode.runAction(repeatAction)
            
            let floatAction = SCNAction.sequence([
                SCNAction.moveBy(x: 0, y: 0.3, z: 0, duration: 2.0),
                SCNAction.moveBy(x: 0, y: -0.3, z: 0, duration: 2.0)
            ])
            let floatRepeat = SCNAction.repeatForever(floatAction)
            iconNode.runAction(floatRepeat)
            
            scene.rootNode.addChildNode(iconNode)
        }
        
        return scene
    }
    
    private func createIconNode(type: String, color: Color) -> SCNNode {
        let node = SCNNode()
        let uiColor = UIColor(color)
        
        switch type {
        case "joystick":
            let geometry = SCNBox(width: 0.6, height: 0.3, length: 0.6, chamferRadius: 0.1)
            geometry.firstMaterial?.diffuse.contents = uiColor
            node.geometry = geometry
            
        case "controller":
            let geometry = SCNBox(width: 0.8, height: 0.2, length: 0.4, chamferRadius: 0.05)
            geometry.firstMaterial?.diffuse.contents = uiColor
            node.geometry = geometry
            
        case "pixel":
            let geometry = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
            geometry.firstMaterial?.diffuse.contents = uiColor
            node.geometry = geometry
            
        default:
            let geometry = SCNSphere(radius: 0.4)
            geometry.firstMaterial?.diffuse.contents = uiColor
            node.geometry = geometry
        }
        
        return node
    }
}

struct GamingIconsSceneContainer: View {
    var iconCount: Int
    var iconColor: Color
    var iconViewType: String
    
    var body: some View {
        GamingIconsSceneView(iconCount: iconCount, iconColor: iconColor, iconViewType: iconViewType)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

