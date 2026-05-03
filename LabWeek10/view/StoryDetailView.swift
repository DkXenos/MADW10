//
//  StoryDetailView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Story Detail View
//  Shows the detail of a selected story with:
//  - Story title as header
//  - "Struktur Cerita" subtitle
//  - List of nodes (with narrative preview, MULAI badge, delete, Edit Cabang)
//  - "Tambah Pilihan" button to add new nodes via a sheet
//  - Tapping a node navigates to NodeChoicesView to edit its choices
//

import SwiftUI
import Combine

/// Detail page for a selected story, showing its node tree structure.
struct StoryDetailView: View {
    
    // MARK: - Properties
    
    /// The story being viewed (refreshed from adminVM)
    @State var story: Story
    
    /// Reference to the shared AdminViewModel
    @ObservedObject var adminVM: AdminViewModel
    
    /// Controls whether the "Node Baru" creation sheet is shown
    @State private var showAddNodeSheet: Bool = false
    
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Story Title
            Text(story.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 8)
            
            // MARK: - "Struktur Cerita" Subtitle
            Text("Struktur Cerita")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // MARK: - Node List or Empty State
            ScrollView {
                VStack(spacing: 12) {
                    
                    if story.nodes.isEmpty {
                        // Empty state message
                        Text("Gunakan tombol + di bawah.")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    } else {
                        // MARK: - Node Cards
                        ForEach(story.nodes) { node in
                            NavigationLink(destination: NodeChoicesView(
                                story: story,
                                node: node,
                                adminVM: adminVM,
                                onUpdate: { refreshStory() }
                            )) {
                                NodeCardView(
                                    node: node,
                                    onDelete: {
                                        deleteNode(nodeId: node.nodeId)
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - "Tambah Pilihan" Button
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
            // MARK: - Custom Back Button
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
        // MARK: - "Node Baru" Creation Sheet
        .sheet(isPresented: $showAddNodeSheet) {
            AddNodeSheetView(
                isPresented: $showAddNodeSheet,
                onSave: { narrative, isEntry in
                    addNode(narrative: narrative, isEntry: isEntry)
                }
            )
        }
    }
    
    // MARK: - Add Node Action
    
    /// Creates a new node with a unique ID and adds it to the story.
    /// - Parameters:
    ///   - narrative: The narrative text for the new node
    ///   - isEntry: Whether this node is the main entry point
    private func addNode(narrative: String, isEntry: Bool) {
        guard let storyId = story.id else { return }
        
        // Generate a unique node ID
        let nodeId = "node_\(UUID().uuidString.prefix(8))"
        
        let newNode = StoryNode(
            nodeId: nodeId,
            narrative: narrative,
            isMainEntryPoint: isEntry,
            choices: []  // Choices are added later via NodeChoicesView
        )
        
        adminVM.addNodeToStory(storyId: storyId, node: newNode)
        
        // Refresh after a brief delay to allow Firestore write
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            refreshStory()
        }
    }
    
    // MARK: - Delete Node Action
    
    /// Deletes a node from the story.
    /// - Parameter nodeId: The nodeId of the node to remove
    private func deleteNode(nodeId: String) {
        guard let storyId = story.id else { return }
        adminVM.deleteNode(storyId: storyId, nodeId: nodeId)
        
        // Refresh after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            refreshStory()
        }
    }
    
    // MARK: - Refresh Story
    
    /// Re-fetches the story from Firestore to update the local state.
    private func refreshStory() {
        guard let storyId = story.id else { return }
        adminVM.refreshStory(storyId: storyId) { refreshed in
            if let refreshed = refreshed {
                story = refreshed
            }
        }
    }
}

// MARK: - Node Card View
/// Displays a single node in the story detail list.
/// Shows narrative preview, MULAI badge (if entry point), delete button,
/// and an "Edit Cabang" link.
struct NodeCardView: View {
    
    let node: StoryNode
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                // Node narrative text (preview, limited to 3 lines)
                Text(node.narrative)
                    .font(.subheadline)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // MULAI badge if this is the entry point
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
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            HStack {
                // "Edit Cabang" link text
                Text("Edit Cabang")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                // Chevron indicating tappable
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Add Node Sheet View
/// Sheet popup for creating a new node.
/// Matches the "Node Baru" design from the reference screenshots.
/// Has a narrative text editor and a "Titik Mulai Cerita" toggle.
struct AddNodeSheetView: View {
    
    @Binding var isPresented: Bool
    
    /// Callback with (narrative, isMainEntryPoint) when saved
    var onSave: (String, Bool) -> Void
    
    // MARK: - Form State
    @State private var narrative: String = ""
    @State private var isMainEntryPoint: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Top Bar with "Simpan"
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
            
            // MARK: - "Node Baru" Title
            Text("Node Baru")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // MARK: - "Teks Narasi" Label
            Text("Teks Narasi")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // MARK: - Narrative Text Editor
            TextEditor(text: $narrative)
                .frame(minHeight: 150)
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            
            // MARK: - "Titik Mulai Cerita" Toggle
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

#Preview {
    NavigationStack {
        StoryDetailView(
            story: Story(title: "Ian dan cerita hidupnya", description: "Test", nodes: []),
            adminVM: AdminViewModel()
        )
    }
}
