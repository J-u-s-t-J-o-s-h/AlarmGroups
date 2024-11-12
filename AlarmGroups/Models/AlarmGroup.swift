import Foundation

struct AlarmGroup: Identifiable, Codable {
    let id: UUID
    var name: String
    var startTime: Date
    var endTime: Date
    var interval: TimeInterval
    var isEnabled: Bool
    var alarms: [Alarm]
    
    private enum CodingKeys: String, CodingKey {
        case id, name, startTime, endTime, interval, isEnabled, alarms
    }
    
    init(id: UUID = UUID(), name: String = "New Alarm Group", startTime: Date, endTime: Date, interval: TimeInterval, isEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.interval = interval
        self.isEnabled = isEnabled
        self.alarms = AlarmGroup.generateAlarms(start: startTime, end: endTime, interval: interval)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        interval = try container.decode(TimeInterval.self, forKey: .interval)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        alarms = try container.decode([Alarm].self, forKey: .alarms)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(interval, forKey: .interval)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(alarms, forKey: .alarms)
    }
    
    static func generateAlarms(start: Date, end: Date, interval: TimeInterval) -> [Alarm] {
        var alarms: [Alarm] = []
        var currentTime = start
        
        while currentTime <= end {
            alarms.append(Alarm(time: currentTime))
            currentTime = currentTime.addingTimeInterval(interval * 60) // Convert minutes to seconds
        }
        
        return alarms
    }
    
    mutating func toggle() {
        isEnabled.toggle()
    }
} 