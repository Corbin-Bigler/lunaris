import SwiftUI
import MetalKit

public struct LunarisView: UIViewRepresentable {
    
    let lunaris: Lunaris
    let clearColor: Color
    public init(lunaris: Lunaris, clearColor: Color) {
        self.lunaris = lunaris
        self.clearColor = clearColor
    }
    
    public func makeCoordinator() -> Lunaris { return lunaris }
    
    public func makeUIView(context: UIViewRepresentableContext<LunarisView>) -> MTKView {
        let metalView = MTKView()
        metalView.device = Lunaris.device
        metalView.delegate = context.coordinator
        metalView.clearColor = clearColor.mtlClearColor
        metalView.depthStencilPixelFormat = .depth32Float
        return metalView
    }
    
    public func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<LunarisView>) {}

}
