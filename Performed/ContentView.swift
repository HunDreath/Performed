//
//  ContentView.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    
    var body: some View {
        VStack {
            TabView {
                
                HomeView()
                    .tabItem() {
                        Label("Dashbooard" , systemImage: "house.fill")
                    }
                
                SeancesListView()
                    .tabItem {
                        Label("Séances", systemImage: "dumbbell.fill")
                    }

                StatistiquesView()
                    .tabItem {
                        Label("Statistiques", systemImage: "chart.bar.fill")
                    }

                ProfilView()
                    .tabItem {
                        Label("Profil", systemImage: "person.fill")
                    }
            }
        }
        .environmentObject(dataManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataManager())
    }
}
