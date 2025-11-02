//
//  DexApp.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 26.11.2024.
//

import SwiftUI

@main
struct DexApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
