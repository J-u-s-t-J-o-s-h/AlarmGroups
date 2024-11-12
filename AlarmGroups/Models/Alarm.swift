import Foundation

struct Alarm: Identifiable, Codable {
    let id: UUID
    var time: Date
    var isEnabled: Bool
    var label: String
    
    init(id: UUID = UUID(), time: Date, isEnabled: Bool = true, label: String = "") {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
        self.label = label
    }
    
    mutating func toggle() {
        isEnabled.toggle()
    }
    
    mutating func updateTime(_ newTime: Date) {
        time = newTime
    }
    
    mutating func updateLabel(_ newLabel: String) {
        label = newLabel
    }
} 