//
//  AdminCreateNodeView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Admin Create Node View
//  Form for creating a new story or adding a node to an existing story.
//  Includes: story title/description, narrative text, isMainEntryPoint toggle,
//  and a dynamic "Add Choice" list with label and targetNodeId fields.
//

import SwiftUI
import Combine

/// Form view for creating new stories/nodes in admin mode.
struct AdminCreateNodeView: View {
    
    // MARK: - Properties
    @ObservedObject var adminVM: AdminViewModel
    @Binding var isPresented: Bool
    
    // MARK: - Form State
    /// Whether to create a brand new story or add to existing
    @State private var isNewStory: Bool = true
    
    /// New story fields
    @State private var storyTitle: String = ""
    @State private var storyDescription: String = ""
    
    /// Selected existing story ID (when adding to existing)
    @State private var selectedStoryId: String = ""
    
    /// Node fields
    @State private var nodeId: String = ""
    @State private var narrative: String = ""
    @State private var isMainEntryPoint: Bool = false
    
    /// Dynamic choices list
    @State private var choices: [(label: String, targetNodeId: String)] = []
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Story Type Selection
                Section(header: Text("Tipe")) {
                    Picker("", selection: $isNewStory) {
                        Text("Cerita Baru").tag(true)
                        Text("Tambah Node").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                // MARK: - New Story Fields
                if isNewStory {
                    Section(header: Text("Detail Cerita")) {
                        TextField("Judul Cerita", text: $storyTitle)
                        TextField("Deskripsi", text: $storyDescription)
                    }
                } else {
                    // MARK: - Select Existing Story
                    Section(header: Text("Pilih Cerita")) {
                        Picker("Cerita", selection: $selectedStoryId) {
                            Text("Pilih...").tag("")
                            ForEach(adminVM.stories) { story in
                                Text(story.title).tag(story.id ?? "")
                            }
                        }
                    }
                }
                
                // MARK: - Node Details
                Section(header: Text("Detail Node")) {
                    TextField("Node ID (unik)", text: $nodeId)
                    
                    // Narrative text input
                    VStack(alignment: .leading) {
                        Text("Narasi")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $narrative)
                            .frame(minHeight: 80)
                    }
                    
                    // Main entry point toggle
                    Toggle("Main Entry Point", isOn: $isMainEntryPoint)
                }
                
                // MARK: - Choices Section
                Section(header: HStack {
                    Text("Pilihan (Choices)")
                    Spacer()
                    // Add Choice button
                    Button(action: {
                        choices.append((label: "", targetNodeId: ""))
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }) {
                    if choices.isEmpty {
                        Text("Tidak ada pilihan (ending node)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ForEach(choices.indices, id: \.self) { index in
                        VStack(spacing: 8) {
                            TextField("Label pilihan", text: Binding(
                                get: { choices[index].label },
                                set: { choices[index].label = $0 }
                            ))
                            TextField("Target Node ID", text: Binding(
                                get: { choices[index].targetNodeId },
                                set: { choices[index].targetNodeId = $0 }
                            ))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indices in
                        choices.remove(atOffsets: indices)
                    }
                }
                
                // MARK: - Messages
                if !adminVM.errorMessage.isEmpty {
                    Section {
                        Text(adminVM.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                if !adminVM.successMessage.isEmpty {
                    Section {
                        Text(adminVM.successMessage)
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                // MARK: - Save Button
                Section {
                    Button(action: saveNode) {
                        HStack {
                            Spacer()
                            if adminVM.isLoading {
                                ProgressView()
                            }
                            Text("Simpan")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(adminVM.isLoading || nodeId.isEmpty || narrative.isEmpty)
                }
            }
            .navigationTitle("Buat Node")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    // MARK: - Save Action
    /// Validates and saves the node (either as new story or appended to existing).
    private func saveNode() {
        // Build the Choice array from the form state
        let nodeChoices = choices.compactMap { item -> Choice? in
            guard !item.label.isEmpty, !item.targetNodeId.isEmpty else { return nil }
            return Choice(label: item.label, targetNodeId: item.targetNodeId)
        }
        
        // Create the StoryNode
        let node = StoryNode(
            nodeId: nodeId,
            narrative: narrative,
            isMainEntryPoint: isMainEntryPoint,
            choices: nodeChoices
        )
        
        if isNewStory {
            // Create a brand new story with this node
            guard !storyTitle.isEmpty, !storyDescription.isEmpty else {
                adminVM.errorMessage = "Judul dan deskripsi tidak boleh kosong."
                return
            }
            adminVM.createStory(title: storyTitle, description: storyDescription, node: node)
        } else {
            // Add node to an existing story
            guard !selectedStoryId.isEmpty else {
                adminVM.errorMessage = "Pilih cerita terlebih dahulu."
                return
            }
            adminVM.addNodeToStory(storyId: selectedStoryId, node: node)
        }
    }
}

#Preview {
    AdminCreateNodeView(adminVM: AdminViewModel(), isPresented: .constant(true))
}
