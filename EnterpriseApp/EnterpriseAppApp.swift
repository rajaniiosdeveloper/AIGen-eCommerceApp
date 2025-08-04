//
//  EnterpriseAppApp.swift
//  EnterpriseApp
//
//  Created by Chandan Singh on 04/08/25.
//

import SwiftUI

@main
struct EnterpriseAppApp: App {
    let persistenceController = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
