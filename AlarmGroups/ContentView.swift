//
//  ContentView.swift
//  AlarmGroups
//
//  Created by Josh Boynton on 11/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AlarmGroupViewModel()
    @State private var showingNewAlarmSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background layer
                BackgroundView()
                    .ignoresSafeArea()
                
                // Particles layer
                FloatingParticles()
                    .allowsHitTesting(false)
                    .opacity(0.3)
                    .ignoresSafeArea()
                
                // Content layer
                List {
                    ForEach(viewModel.alarmGroups) { group in
                        NavigationLink(destination: AlarmGroupDetailView(viewModel: viewModel, group: group)) {
                            AlarmGroupRow(group: group, onToggle: {
                                viewModel.toggleAlarmGroup(group)
                            })
                        }
                    }
                    .onDelete(perform: deleteAlarmGroups)
                }
                .navigationTitle("Alarm Groups")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingNewAlarmSheet = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .sheet(isPresented: $showingNewAlarmSheet) {
            NewAlarmGroupView(viewModel: viewModel)
        }
        .preferredColorScheme(.dark)
    }
    
    private func deleteAlarmGroups(at offsets: IndexSet) {
        viewModel.deleteAlarmGroup(at: offsets)
    }
}

struct AlarmGroupRow: View {
    let group: AlarmGroup
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(group.name)
                .font(.headline)
            
            HStack {
                Text(timeRangeText)
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { group.isEnabled },
                    set: { _ in onToggle() }
                ))
            }
            
            Text("\(group.alarms.count) alarms • \(Int(group.interval))min intervals")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    private var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: group.startTime)) - \(formatter.string(from: group.endTime))"
    }
}

#Preview {
    ContentView()
}
