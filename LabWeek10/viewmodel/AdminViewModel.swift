//
//  AdminViewModel.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Admin ViewModel
//  Handles all admin story management operations:
//  - Fetch stories from Firestore
//  - Create new story drafts (title + description only, no nodes yet)
//  - Add nodes to an existing story
//  - Delete nodes from a story
//  - Update a node's choices (linking nodes together)
//  - Refresh a single story after modifications
//

import Foundation
import Combine
import FirebaseFirestore

/// ViewModel for admin story CRUD operations.
/// Supports the multi-step flow: Create Story → Add Nodes → Edit Choices.
class AdminViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// All stories fetched from Firestore
    @Published var stories: [Story] = []
    
    /// Loading indicator for async operations
    @Published var isLoading: Bool = false
    
    /// Error message to display to the user
    @Published var errorMessage: String = ""
    
    /// Success message after a successful operation
    @Published var successMessage: String = ""
    
    // MARK: - Private Properties
    
    /// Firestore database reference
    private let db = Firestore.firestore()
    
    // MARK: - Fetch All Stories
    
    /// Fetches all story documents from the "stories" Firestore collection.
    func fetchStories() {
        isLoading = true
        db.collection("stories").getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.stories = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Story.self)
                } ?? []
            }
        }
    }
    
    // MARK: - Create Story Draft
    
    /// Creates a new story with only title and description (no nodes yet).
    /// Nodes are added separately via addNodeToStory().
    /// - Parameters:
    ///   - title: The story title
    ///   - description: A brief summary/ringkasan of the story
    func createStoryDraft(title: String, description: String) {
        isLoading = true
        errorMessage = ""
        successMessage = ""
        
        let storyData: [String: Any] = [
            "title": title,
            "description": description,
            "nodes": []  // Empty nodes array — nodes added separately
        ]
        
        db.collection("stories").addDocument(data: storyData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.successMessage = "Cerita berhasil dibuat!"
                    self?.fetchStories()
                }
            }
        }
    }
    
    // MARK: - Add Node to Story
    
    /// Appends a new node to an existing story's nodes array.
    /// - Parameters:
    ///   - storyId: The Firestore document ID of the story
    ///   - node: The new StoryNode to add (starts with empty choices)
    func addNodeToStory(storyId: String, node: StoryNode) {
        isLoading = true
        errorMessage = ""
        successMessage = ""
        
        db.collection("stories").document(storyId).updateData([
            "nodes": FieldValue.arrayUnion([encodeNode(node)])
        ]) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.successMessage = "Node berhasil ditambahkan!"
                    self?.fetchStories()
                }
            }
        }
    }
    
    // MARK: - Delete Node from Story
    
    /// Removes a node from a story's nodes array.
    /// Rewrites the entire nodes array without the deleted node.
    /// - Parameters:
    ///   - storyId: The Firestore document ID of the story
    ///   - nodeId: The nodeId of the node to remove
    func deleteNode(storyId: String, nodeId: String) {
        guard let storyIndex = stories.firstIndex(where: { $0.id == storyId }) else { return }
        
        // Filter out the node to delete
        let updatedNodes = stories[storyIndex].nodes.filter { $0.nodeId != nodeId }
        let nodesData = updatedNodes.map { encodeNode($0) }
        
        isLoading = true
        db.collection("stories").document(storyId).updateData([
            "nodes": nodesData
        ]) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.fetchStories()
                }
            }
        }
    }
    
    // MARK: - Update Node Choices
    
    /// Updates the choices array of a specific node within a story.
    /// Rewrites the entire nodes array with the updated node.
    /// - Parameters:
    ///   - storyId: The Firestore document ID of the story
    ///   - nodeId: The nodeId of the node to update
    ///   - choices: The new array of Choice objects for this node
    func updateNodeChoices(storyId: String, nodeId: String, choices: [Choice]) {
        guard let storyIndex = stories.firstIndex(where: { $0.id == storyId }) else { return }
        
        // Create updated nodes array with the modified choices
        var updatedNodes = stories[storyIndex].nodes
        if let nodeIndex = updatedNodes.firstIndex(where: { $0.nodeId == nodeId }) {
            updatedNodes[nodeIndex].choices = choices
        }
        
        let nodesData = updatedNodes.map { encodeNode($0) }
        
        isLoading = true
        db.collection("stories").document(storyId).updateData([
            "nodes": nodesData
        ]) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.successMessage = "Pilihan berhasil disimpan!"
                    self?.fetchStories()
                }
            }
        }
    }
    
    // MARK: - Refresh Single Story
    
    /// Fetches a single story by ID and updates it in the local array.
    /// Used after modifying nodes/choices to refresh the detail view.
    /// - Parameter storyId: The Firestore document ID to refresh
    /// - Returns: The refreshed Story object (via completion)
    func refreshStory(storyId: String, completion: @escaping (Story?) -> Void) {
        db.collection("stories").document(storyId).getDocument { [weak self] doc, error in
            DispatchQueue.main.async {
                guard let doc = doc, let story = try? doc.data(as: Story.self) else {
                    completion(nil)
                    return
                }
                // Update the story in the local array
                if let index = self?.stories.firstIndex(where: { $0.id == storyId }) {
                    self?.stories[index] = story
                }
                completion(story)
            }
        }
    }
    
    // MARK: - Encode Node Helper
    
    /// Converts a StoryNode struct into a Firestore-compatible dictionary.
    /// - Parameter node: The StoryNode to encode
    /// - Returns: A dictionary representation for Firestore
    private func encodeNode(_ node: StoryNode) -> [String: Any] {
        let choicesData: [[String: Any]] = node.choices.map { choice in
            ["label": choice.label, "targetNodeId": choice.targetNodeId]
        }
        return [
            "nodeId": node.nodeId,
            "narrative": node.narrative,
            "isMainEntryPoint": node.isMainEntryPoint,
            "choices": choicesData
        ]
    }
}
