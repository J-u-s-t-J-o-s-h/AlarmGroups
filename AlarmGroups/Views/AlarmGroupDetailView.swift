import SwiftUI

struct AlarmGroupDetailView: View {
    @ObservedObject var viewModel: AlarmGroupViewModel
    let group: AlarmGroup
    @State private var editingAlarmId: UUID?
    @State private var tempTime: Date = Date()
    @State private var tempLabel: String = ""
    @State private var groupName: String
    @State private var isEditingGroupName = false
    
    init(viewModel: AlarmGroupViewModel, group: AlarmGroup) {
        self.viewModel = viewModel
        self.group = group
        self._groupName = State(initialValue: group.name)
    }
    
    var body: some View {
        ZStack {
            // Background with particles
            BackgroundView()
            FloatingParticles()
                .allowsHitTesting(false)
                .opacity(0.3)
            
            // Content
            List {
                Section {
                    if isEditingGroupName {
                        HStack {
                            TextField("Group Name", text: $groupName)
                                .textFieldStyle(.roundedBorder)
                            
                            Button("Save") {
                                viewModel.updateGroupName(group, newName: groupName)
                                isEditingGroupName = false
                            }
                            .foregroundColor(.blue)
                        }
                    } else {
                        HStack {
                            Text(group.name)
                            Spacer()
                            Button(action: { isEditingGroupName = true }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Group Status")
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { group.isEnabled },
                            set: { _ in viewModel.toggleAlarmGroup(group) }
                        ))
                    }
                    
                    HStack {
                        Text("Interval")
                        Spacer()
                        Text("\(Int(group.interval)) minutes")
                            .foregroundColor(.gray)
                    }
                }
                
                Section("Alarms") {
                    ForEach(group.alarms.indices, id: \.self) { index in
                        AlarmRow(
                            alarm: group.alarms[index],
                            isEditing: Binding(
                                get: { editingAlarmId == group.alarms[index].id },
                                set: { isEditing in
                                    if isEditing {
                                        editingAlarmId = group.alarms[index].id
                                        tempTime = group.alarms[index].time
                                        tempLabel = group.alarms[index].label
                                    } else {
                                        editingAlarmId = nil
                                    }
                                }
                            ),
                            tempTime: $tempTime,
                            tempLabel: $tempLabel,
                            onToggle: {
                                viewModel.toggleIndividualAlarm(in: group, at: index)
                            },
                            onSave: {
                                viewModel.updateAlarm(in: group, at: index, time: tempTime, label: tempLabel)
                                editingAlarmId = nil
                            }
                        )
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(group.name)
    }
}

struct AlarmRow: View {
    let alarm: Alarm
    @Binding var isEditing: Bool
    @Binding var tempTime: Date
    @Binding var tempLabel: String
    let onToggle: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        if isEditing {
            VStack(alignment: .leading, spacing: 12) {
                DatePicker("Time", selection: $tempTime, displayedComponents: .hourAndMinute)
                
                TextField("Alarm Label", text: $tempLabel)
                    .textFieldStyle(.roundedBorder)
                    .padding(.vertical, 4)
                
                HStack {
                    Spacer()
                    Button("Cancel") {
                        isEditing = false
                    }
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    
                    Button("Save") {
                        onSave()
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.vertical, 4)
        } else {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatTime(alarm.time))
                        .font(.system(.title3, design: .monospaced))
                    
                    if !alarm.label.isEmpty {
                        Text(alarm.label)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text("Add label")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .opacity(0.5)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { alarm.isEnabled },
                    set: { _ in onToggle() }
                ))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isEditing = true
            }
            .swipeActions(edge: .leading) {
                Button {
                    isEditing = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.orange)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 