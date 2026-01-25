//
//  DataManager.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import Foundation

@MainActor
class DataManager: ObservableObject {

    @Published var user: User
    @Published var seances: [Seance] = []

    private static let userKey = "performed_user"
    private static let seancesKey = "performed_seances"

    init() {
        self.user = DataManager.loadUser() ?? User(id: UUID() ,name: "User")
        self.seances = DataManager.loadSeances()
    }

    func saveUser() {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: Self.userKey)
        }
    }

    static func loadUser() -> User? {
        if let data = UserDefaults.standard.data(forKey: Self.userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            return user
        }
        return nil
    }

    func saveSeances() {
        if let encoded = try? JSONEncoder().encode(seances) {
            UserDefaults.standard.set(encoded, forKey: Self.seancesKey)
        }
    }

    static func loadSeances() -> [Seance] {
        if let data = UserDefaults.standard.data(forKey: Self.seancesKey),
           let seances = try? JSONDecoder().decode([Seance].self, from: data) {
            return seances.sorted { $0.date > $1.date }
        }
        return []
    }

    func addSeance(_ seance: Seance) {
        seances.insert(seance, at: 0)
        saveSeances()
    }

    func updateSeance(_ seance: Seance) {
        if let index = seances.firstIndex(where: { $0.id == seance.id }) {
            seances[index] = seance
            saveSeances()
        }
    }

    func deleteSeance(_ seance: Seance) {
        seances.removeAll { $0.id == seance.id }
        saveSeances()
    }
}
