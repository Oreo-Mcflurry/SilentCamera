import SwiftUI
import Router
import Coordinator

public struct ContentView: View {
    public init() {}
    
    @StateObject private var router = Router()
    public var body: some View {
        NavigationStack(path: $router.path) {
            Button {
                router.push(to: .cameraView)
            } label: {
                Text("Test")
            }
            .navigationDestination(for: Route.self) {
                return Coordinator.view(for: $0)
            }
        }
    }
}
