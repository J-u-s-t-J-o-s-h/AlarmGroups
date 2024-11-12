import SwiftUI

struct NewAlarmGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AlarmGroupViewModel
    
    @State private var groupName = ""
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var selectedInterval: TimeInterval = 5
    
    private let intervals: [TimeInterval] = [5, 10, 15]
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                FloatingParticles()
                    .allowsHitTesting(false)
                    .opacity(0.3)
                
                Form {
                    Section("Group Name") {
                        TextField("Enter group name", text: $groupName)
                    }
                    
                    Section("Time Range") {
                        DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Section("Interval") {
                        Picker("Minutes between alarms", selection: $selectedInterval) {
                            ForEach(intervals, id: \.self) { interval in
                                Text("\(Int(interval)) minutes")
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("New Alarm Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        viewModel.createAlarmGroup(
                            name: groupName.isEmpty ? "New Alarm Group" : groupName,
                            startTime: startTime,
                            endTime: endTime,
                            interval: selectedInterval
                        )
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
} 