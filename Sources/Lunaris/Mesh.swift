import MetalKit

public struct Mesh {
    var vertexBuffers: [MTLBuffer]
    var submeshes: [Submesh]
    
    init(vertexBuffers: [MTLBuffer], submeshes: [Submesh]) {
        self.vertexBuffers = vertexBuffers
        self.submeshes = submeshes
    }
    
    init(name: String, mdlMesh: MDLMesh, mtkMesh: MTKMesh) {
        self.vertexBuffers = mtkMesh.vertexBuffers.map { $0.buffer }
        submeshes = zip(mdlMesh.submeshes!, mtkMesh.submeshes).map { mesh in
          Submesh(mdlSubmesh: mesh.0 as! MDLSubmesh, mtkSubmesh: mesh.1)
        }
    }
}
