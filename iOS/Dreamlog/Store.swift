import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [DreamEntry] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var isPro: Bool = false

    /// Free tier allows up to this many entries. Deliberately set well above
    /// the seed data count so a fresh install never trips the paywall.
    static let freeLimit = 14

    private let entriesFileName = "entries.json"
    private let settingsFileName = "settings.json"

    init() {
        load()
        if entries.isEmpty {
            seed()
            save()
        }
    }

    private var supportDirectory: URL {
        let fm = FileManager.default
        let dir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Dreamlog", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private func seed() {
        entries = [
            DreamEntry(name: "Flying Over Water", tags: "flying, ocean", mood: "Peaceful", notes: "Was flying over calm water"),
            DreamEntry(name: "The Exam", tags: "falling, exam", mood: "Anxious", notes: "Missed an exam, kept falling")
        ]
    }

    func load() {
        let entriesURL = supportDirectory.appendingPathComponent(entriesFileName)
        if let data = try? Data(contentsOf: entriesURL),
           let decoded = try? JSONDecoder().decode([DreamEntry].self, from: data) {
            entries = decoded
        }
        let settingsURL = supportDirectory.appendingPathComponent(settingsFileName)
        if let data = try? Data(contentsOf: settingsURL),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }

    func save() {
        let entriesURL = supportDirectory.appendingPathComponent(entriesFileName)
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: entriesURL)
        }
        let settingsURL = supportDirectory.appendingPathComponent(settingsFileName)
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: settingsURL)
        }
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    @discardableResult
    func add(name: String, f1: String, f2: String, f3: String) -> Bool {
        guard canAddMore else { return false }
        let entry = DreamEntry(name: name, tags: f1, mood: f2, notes: f3)
        entries.insert(entry, at: 0)
        save()
        return true
    }

    func update(_ entry: DreamEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: DreamEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }
}
