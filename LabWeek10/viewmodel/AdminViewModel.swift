//
//  AdminViewModel.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Admin ViewModel
//  Handles admin story management: fetching, creating, and adding nodes.
//

import Foundation
import FirebaseFirestore

/// ViewModel for admin story CRUD operations.
class AdminViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var stories: [Story] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var successMessage: String = ""
    
    // MARK: - Private
    private let db = Firestore.firestore()
    
    // MARK: - Fetch Stories
    /// Fetches all stories from Firestore for the admin list.
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
    
    // MARK: - Create New Story
    /// Creates a new story with one initial node.
    func createStory(title: String, description: String, node: StoryNode) {
        isLoading = true
        errorMessage = ""
        successMessage = ""
        
        let storyData: [String: Any] = [
            "title": title,
            "description": description,
            "nodes": [encodeNode(node)]
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
    /// Appends a new node to an existing story.
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
    
    // MARK: - Encode Node
    /// Converts a StoryNode to a Firestore-compatible dictionary.
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
