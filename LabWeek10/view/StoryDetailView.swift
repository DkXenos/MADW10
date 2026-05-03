//
//  StoryDetailView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import SwiftUI
import Combine

struct StoryDetailView: View {
    
    
    @State var story: Story
    
    @ObservedObject var adminVM: AdminViewModel
    
    @State private var showAddNodeSheet: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text(story.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 8)
            
            Text("Struktur Cerita")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 12) {
                    
                    if story.nodes.isEmpty {
                        Text("Gunakan tombol + di bawah.")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    } else {
                        ForEach(story.nodes) { node in
                            NodeCardView(
                                story: story,
                                node: node,
                                adminVM: adminVM,
                                onEditNode: {
                                    nodeToEdit = node
                                },
                                onDelete: {
                                    deleteNode(nodeId: node.nodeId)
                                },
                                onUpdate: { refreshStory() }
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    Button(action: {
                        showAddNodeSheet = true
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
            
            Spacer()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                }
            }
        }
        .sheet(isPresented: $showAddNodeSheet) {
            AddNodeSheetView(
                isPresented: $showAddNodeSheet,
                onSave: { narrative, isEntry in
                    addNode(narrative: narrative, isEntry: isEntry)
                }
            )
        }
        .sheet(item: $nodeToEdit) { node in
            EditNodeSheetView(
                node: node,
                onSave: { updatedNarrative, updatedIsEntry in
                    updateNode(node: node, newNarrative: updatedNarrative, newIsEntry: updatedIsEntry)
                    nodeToEdit = nil
                },
                onCancel: {
                    nodeToEdit = nil
                }
            )
        }
    }
    
    @State private var nodeToEdit: StoryNode?
    
    
    private func addNode(narrative: String, isEntry: Bool) {
        guard let storyId = story.id else { return }
        
        let nodeId = "node_\(UUID().uuidString.prefix(8))"
        
        let newNode = StoryNode(
            nodeId: nodeId,
            narrative: narrative,
            isMainEntryPoint: isEntry,
            choices: []  // Choices are added later via NodeChoicesView
        )
        
        adminVM.addNodeToStory(storyId: storyId, node: newNode)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            refreshStory()
        }
    }
    
    
    private func deleteNode(nodeId: String) {
        guard let storyId = story.id else { return }
        adminVM.deleteNode(storyId: storyId, nodeId: nodeId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            refreshStory()
        }
    }
    
    
    private func updateNode(node: StoryNode, newNarrative: String, newIsEntry: Bool) {
        guard let storyId = story.id else { return }
        
        var updatedNode = node
        updatedNode.narrative = newNarrative
        updatedNode.isMainEntryPoint = newIsEntry
        
        adminVM.updateNode(storyId: storyId, node: updatedNode)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            refreshStory()
        }
    }
    
    
    private func refreshStory() {
        guard let storyId = story.id else { return }
        adminVM.refreshStory(storyId: storyId) { refreshed in
            if let refreshed = refreshed {
                story = refreshed
            }
        }
    }
}

struct NodeCardView: View {
    
    let story: Story
    let node: StoryNode
    @ObservedObject var adminVM: AdminViewModel
    let onEditNode: () -> Void
    let onDelete: () -> Void
    let onUpdate: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onEditNode) {
                HStack(alignment: .top) {
                    Text(node.narrative)
                        .font(.subheadline)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if node.isMainEntryPoint {
                        Text("MULAI")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primary)
                            .foregroundColor(Color(.systemBackground))
                            .cornerRadius(4)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .buttonStyle(.plain)
            
            NavigationLink(destination: NodeChoicesView(
                story: story,
                node: node,
                adminVM: adminVM,
                onUpdate: onUpdate
            )) {
                HStack {
                    Text("Edit Cabang")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct AddNodeSheetView: View {
    
    @Binding var isPresented: Bool
    
    var onSave: (String, Bool) -> Void
    
    @State private var narrative: String = ""
    @State private var isMainEntryPoint: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Spacer()
                Button("Simpan") {
                    onSave(narrative, isMainEntryPoint)
                    isPresented = false
                }
                .disabled(narrative.isEmpty)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(narrative.isEmpty ? Color(.systemGray4) : Color(.systemGray6))
                .cornerRadius(20)
                .fontWeight(.semibold)
            }
            .padding(.top, 16)
            .padding(.trailing, 4)
            
            Text("Node Baru")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Text("Teks Narasi")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            TextEditor(text: $narrative)
                .frame(minHeight: 150)
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            
            HStack {
                Text("Titik Mulai Cerita")
                    .fontWeight(.medium)
                Spacer()
                Toggle("", isOn: $isMainEntryPoint)
                    .labelsHidden()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

struct EditNodeSheetView: View {
    
    let node: StoryNode
    
    var onSave: (String, Bool) -> Void
    var onCancel: () -> Void
    
    @State private var narrative: String = ""
    @State private var isMainEntryPoint: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Button("Batal") {
                    onCancel()
                }
                .foregroundColor(.blue)
                .padding(.leading, 16)
                
                Spacer()
                
                Button("Simpan") {
                    onSave(narrative, isMainEntryPoint)
                }
                .disabled(narrative.isEmpty)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(narrative.isEmpty ? Color(.systemGray4) : Color(.systemGray6))
                .cornerRadius(20)
                .fontWeight(.semibold)
            }
            .padding(.top, 16)
            .padding(.trailing, 4)
            
            Text("Edit Node")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Text("Teks Narasi")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            TextEditor(text: $narrative)
                .frame(minHeight: 150)
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            
            HStack {
                Text("Titik Mulai Cerita")
                    .fontWeight(.medium)
                Spacer()
                Toggle("", isOn: $isMainEntryPoint)
                    .labelsHidden()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .onAppear {
            narrative = node.narrative
            isMainEntryPoint = node.isMainEntryPoint
        }
    }
}

#Preview {
    NavigationStack {
        StoryDetailView(
            story: Story(title: "Ian dan cerita hidupnya", description: "Test", nodes: []),
            adminVM: AdminViewModel()
        )
    }
}
