//
//  NodeChoicesView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import SwiftUI
import Combine

struct NodeChoicesView: View {
    
    
    let story: Story
    
    let node: StoryNode
    
    @ObservedObject var adminVM: AdminViewModel
    
    var onUpdate: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    
    @State private var choices: [Choice] = []
    
    @State private var showAddChoice: Bool = false
    
    @State private var newChoiceLabel: String = ""
    @State private var newChoiceTargetId: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text(node.narrative)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .padding(.horizontal)
                .padding(.top, 8)
            
            Text("Cabang Cerita")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 12) {
                    if choices.isEmpty {
                        Text("Belum ada pilihan. Node ini adalah ending.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    } else {
                        ForEach(choices.indices, id: \.self) { index in
                            ChoiceRowView(
                                choice: choices[index],
                                availableNodes: availableTargetNodes(),
                                onDelete: {
                                    choices.remove(at: index)
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    Button(action: {
                        newChoiceLabel = ""
                        newChoiceTargetId = ""
                        showAddChoice = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .font(.title3)
                            Text("Tambah Pilihan")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            
            Button(action: saveChoices) {
                Text("Simpan Pilihan")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary)
                    .foregroundColor(Color(.systemBackground))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Edit Cabang")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            choices = node.choices
        }
        .sheet(isPresented: $showAddChoice) {
            AddChoiceSheetView(
                availableNodes: availableTargetNodes(),
                isPresented: $showAddChoice,
                onSave: { label, targetId in
                    let newChoice = Choice(label: label, targetNodeId: targetId)
                    choices.append(newChoice)
                }
            )
        }
    }
    
    
    private func availableTargetNodes() -> [StoryNode] {
        return story.nodes.filter { $0.nodeId != node.nodeId }
    }
    
    
    private func saveChoices() {
        guard let storyId = story.id else { return }
        adminVM.updateNodeChoices(storyId: storyId, nodeId: node.nodeId, choices: choices)
        onUpdate()
        dismiss()
    }
}

struct ChoiceRowView: View {
    
    let choice: Choice
    let availableNodes: [StoryNode]
    let onDelete: () -> Void
    
    private var targetNodeLabel: String {
        if let target = availableNodes.first(where: { $0.nodeId == choice.targetNodeId }) {
            return String(target.narrative.prefix(30)) + "..."
        }
        return choice.targetNodeId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(choice.label)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("→ \(targetNodeLabel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct AddChoiceSheetView: View {
    
    let availableNodes: [StoryNode]
    @Binding var isPresented: Bool
    var onSave: (String, String) -> Void
    
    @State private var label: String = ""
    @State private var selectedTargetId: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Spacer()
                Button("Simpan") {
                    onSave(label, selectedTargetId)
                    isPresented = false
                }
                .disabled(label.isEmpty || selectedTargetId.isEmpty)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    (label.isEmpty || selectedTargetId.isEmpty)
                    ? Color(.systemGray4)
                    : Color(.systemGray6)
                )
                .cornerRadius(20)
                .fontWeight(.semibold)
            }
            .padding(.top, 16)
            .padding(.trailing, 4)
            
            Text("Pilihan Baru")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Label Pilihan")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                TextField("Contoh: Meditasi Chakra", text: $label)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Tujuan Node")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if availableNodes.isEmpty {
                    Text("Tidak ada node lain. Buat node baru terlebih dahulu.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                } else {
                    VStack(spacing: 0) {
                        ForEach(availableNodes) { targetNode in
                            Button(action: {
                                selectedTargetId = targetNode.nodeId
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(String(targetNode.narrative.prefix(40)))
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        Text(targetNode.nodeId)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if selectedTargetId == targetNode.nodeId {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                            }
                            
                            if targetNode.id != availableNodes.last?.id {
                                Divider().padding(.horizontal)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        NodeChoicesView(
            story: Story(title: "Test", description: "Test", nodes: []),
            node: StoryNode(nodeId: "test", narrative: "Test narrative", isMainEntryPoint: false, choices: []),
            adminVM: AdminViewModel(),
            onUpdate: {}
        )
    }
}
