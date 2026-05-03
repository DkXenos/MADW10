//
//  StoryViewModel.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class StoryViewModel: ObservableObject {
    
    
    @Published var stories: [Story] = []
    
    @Published var currentStory: Story?
    
    @Published var currentNode: StoryNode?
    
    @Published var isPlaying: Bool = false
    
    @Published var displayedText: String = ""
    
    @Published var isTypewriterComplete: Bool = false
    
    @Published var isLoading: Bool = false
    
    
    private let db = Firestore.firestore()
    
    private var typewriterTimer: Timer?
    
    private var charIndex: Int = 0
    
    
    func fetchStories() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        db.collection("stories").whereField("ownerId", isEqualTo: currentUserId).getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("Error fetching stories: \(error.localizedDescription)")
                    return
                }
                
                self?.stories = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Story.self)
                } ?? []
            }
        }
    }
    
    
    func startStory(_ story: Story) {
        currentStory = story
        
        if let entryNode = story.nodes.first(where: { $0.isMainEntryPoint }) {
            currentNode = entryNode
            isPlaying = true
            startTypewriterAnimation(for: entryNode.narrative)
        }
    }
    
    
    func selectChoice(_ choice: Choice) {
        guard let story = currentStory else { return }
        
        if let targetNode = story.nodes.first(where: { $0.nodeId == choice.targetNodeId }) {
            currentNode = targetNode
            startTypewriterAnimation(for: targetNode.narrative)
        }
    }
    
    
    func stopStory() {
        isPlaying = false
        currentStory = nil
        currentNode = nil
        displayedText = ""
        isTypewriterComplete = false
        stopTypewriterTimer()
    }
    
    
    func startTypewriterAnimation(for text: String) {
        displayedText = ""
        charIndex = 0
        isTypewriterComplete = false
        stopTypewriterTimer()
        
        let characters = Array(text)
        
        typewriterTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.charIndex < characters.count {
                DispatchQueue.main.async {
                    self.displayedText += String(characters[self.charIndex])
                    self.charIndex += 1
                }
            } else {
                DispatchQueue.main.async {
                    self.isTypewriterComplete = true
                }
                timer.invalidate()
            }
        }
    }
    
    private func stopTypewriterTimer() {
        typewriterTimer?.invalidate()
        typewriterTimer = nil
    }
    
    
    func recordAchievement(storyTitle: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).updateData([
            "achievements": FieldValue.arrayUnion([storyTitle])
        ]) { error in
            if let error = error {
                print("Error recording achievement: \(error.localizedDescription)")
            }
        }
    }
}
