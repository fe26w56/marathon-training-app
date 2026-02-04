import SwiftUI
import SwiftData

@main
struct MarathonTrainingApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            // Models will be added here
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
