import Foundation

public extension DataStore {
    /// Return local notes for a single calendar occurrence.
    func preparationNotes(for eventKey: String) throws -> String {
        try preparationNotesByEvent()[eventKey] ?? ""
    }

    /// Atomically save preparation notes without changing the calendar event.
    func setPreparationNotes(_ text: String, for eventKey: String) throws {
        var notes = try preparationNotesByEvent()
        notes[eventKey] = text.isEmpty ? nil : text
        if let preparationNotesURL {
            try JSONEncoder().encode(notes).write(to: preparationNotesURL, options: .atomic)
        } else {
            inMemoryPreparationNotes = notes
        }
    }

    private func preparationNotesByEvent() throws -> [String: String] {
        guard let preparationNotesURL else { return inMemoryPreparationNotes }
        do {
            let data = try Data(contentsOf: preparationNotesURL)
            return try JSONDecoder().decode([String: String].self, from: data)
        } catch CocoaError.fileReadNoSuchFile {
            return [:]
        }
    }
}
