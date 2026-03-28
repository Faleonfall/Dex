import SwiftData

enum SharedModelContainer {
    static let appGroupID = "group.com.kvolodymyr.DexGroup"
    static let schema = Schema([
        Pokemon.self,
    ])

    static func make(inMemoryOnly: Bool = false) throws -> ModelContainer {
        let configuration: ModelConfiguration

        if inMemoryOnly {
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
        } else {
            // App and widget must point at the same app-group-backed store.
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                groupContainer: .identifier(appGroupID)
            )
        }

        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
