//
//  AdminViewModel.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AdminViewModel: ObservableObject {
    
    
    @Published var stories: [Story] = []
    
    @Published var isLoading: Bool = false
    
    @Published var errorMessage: String = ""
    
    @Published var successMessage: String = ""
    
    
    private let db = Firestore.firestore()
    
    
    func fetchStories() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        db.collection("stories").whereField("ownerId", isEqualTo: currentUserId).getDocuments { [weak self] snapshot, error in
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
    
    
    func createStoryDraft(title: String, description: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        errorMessage = ""
        successMessage = ""
        
        let storyData: [String: Any] = [
            "title": title,
            "description": description,
            "nodes": [],  // Empty nodes array — nodes added separately
            "ownerId": currentUserId
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
    
    
    func deleteNode(storyId: String, nodeId: String) {
        guard let storyIndex = stories.firstIndex(where: { $0.id == storyId }) else { return }
        
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
    
    
    func updateNode(storyId: String, node: StoryNode) {
        guard let storyIndex = stories.firstIndex(where: { $0.id == storyId }) else { return }
        
        var updatedNodes = stories[storyIndex].nodes
        if let nodeIndex = updatedNodes.firstIndex(where: { $0.nodeId == node.nodeId }) {
            updatedNodes[nodeIndex] = node
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
                    self?.successMessage = "Node berhasil diupdate!"
                    self?.fetchStories()
                }
            }
        }
    }
    
    
    func updateNodeChoices(storyId: String, nodeId: String, choices: [Choice]) {
        guard let storyIndex = stories.firstIndex(where: { $0.id == storyId }) else { return }
        
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
    
    
    func refreshStory(storyId: String, completion: @escaping (Story?) -> Void) {
        db.collection("stories").document(storyId).getDocument { [weak self] doc, error in
            DispatchQueue.main.async {
                guard let doc = doc, let story = try? doc.data(as: Story.self) else {
                    completion(nil)
                    return
                }
                if let index = self?.stories.firstIndex(where: { $0.id == storyId }) {
                    self?.stories[index] = story
                }
                completion(story)
            }
        }
    }
    
    
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
