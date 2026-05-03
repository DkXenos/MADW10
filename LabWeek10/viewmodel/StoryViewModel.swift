//
//  StoryViewModel.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Story ViewModel
//  Handles fetching stories from Firestore and managing gameplay state.
//  Responsibilities:
//  - Fetch all stories from the "stories" collection
//  - Track the current story and active node during gameplay
//  - Navigate between nodes based on player choices
//  - Record achievements when a story ending is reached
//  - Provide typewriter animation state for the gameplay view
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// ViewModel responsible for story listing, gameplay logic, and achievements.
class StoryViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// All stories fetched from Firestore, displayed on the Home page
    @Published var stories: [Story] = []
    
    /// The story currently being played
    @Published var currentStory: Story?
    
    /// The active node in the current story (the node being displayed)
    @Published var currentNode: StoryNode?
    
    /// Controls whether the gameplay view is presented
    @Published var isPlaying: Bool = false
    
    /// Text currently visible in the typewriter animation
    @Published var displayedText: String = ""
    
    /// Whether the typewriter animation has finished revealing all text
    @Published var isTypewriterComplete: Bool = false
    
    /// Loading state for Firestore operations
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    /// Firestore database reference
    private let db = Firestore.firestore()
    
    /// Timer used for the typewriter text animation
    private var typewriterTimer: Timer?
    
    /// Index tracking how many characters have been revealed
    private var charIndex: Int = 0
    
    // MARK: - Fetch Stories
    
    /// Fetches all story documents from the "stories" Firestore collection.
    /// Called when HomeView appears. Updates the `stories` published property.
    func fetchStories() {
        isLoading = true
        
        db.collection("stories").getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("Error fetching stories: \(error.localizedDescription)")
                    return
                }
                
                // Decode each document into a Story object
                self?.stories = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Story.self)
                } ?? []
            }
        }
    }
    
    // MARK: - Gameplay: Start Story
    
    /// Starts playing a story by finding its main entry point node.
    /// - Parameter story: The story to begin playing
    func startStory(_ story: Story) {
        currentStory = story
        
        // Find the node marked as the main entry point
        if let entryNode = story.nodes.first(where: { $0.isMainEntryPoint }) {
            currentNode = entryNode
            isPlaying = true
            // Begin the typewriter animation for the entry node's text
            startTypewriterAnimation(for: entryNode.narrative)
        }
    }
    
    // MARK: - Gameplay: Navigate to Next Node
    
    /// Navigates to the target node when the player makes a choice.
    /// - Parameter choice: The choice selected by the player
    func selectChoice(_ choice: Choice) {
        guard let story = currentStory else { return }
        
        // Find the target node in the current story's nodes array
        if let targetNode = story.nodes.first(where: { $0.nodeId == choice.targetNodeId }) {
            currentNode = targetNode
            // Restart the typewriter animation for the new node's text
            startTypewriterAnimation(for: targetNode.narrative)
        }
    }
    
    // MARK: - Gameplay: Stop / Close Story
    
    /// Stops the current gameplay session and resets all gameplay state.
    /// Called when the user taps the close ("X") button.
    func stopStory() {
        isPlaying = false
        currentStory = nil
        currentNode = nil
        displayedText = ""
        isTypewriterComplete = false
        stopTypewriterTimer()
    }
    
    // MARK: - Typewriter Animation
    
    /// Starts the typewriter animation that reveals text character by character.
    /// This is the CRITICAL +5 points requirement from the assignment.
    /// - Parameter text: The full narrative text to animate
    func startTypewriterAnimation(for text: String) {
        // Reset animation state
        displayedText = ""
        charIndex = 0
        isTypewriterComplete = false
        stopTypewriterTimer()
        
        let characters = Array(text)
        
        // Schedule a timer that fires every 0.03 seconds to reveal one character
        typewriterTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.charIndex < characters.count {
                // Append the next character to the displayed text
                DispatchQueue.main.async {
                    self.displayedText += String(characters[self.charIndex])
                    self.charIndex += 1
                }
            } else {
                // All characters revealed — animation complete
                DispatchQueue.main.async {
                    self.isTypewriterComplete = true
                }
                timer.invalidate()
            }
        }
    }
    
    /// Stops and invalidates the typewriter timer
    private func stopTypewriterTimer() {
        typewriterTimer?.invalidate()
        typewriterTimer = nil
    }
    
    // MARK: - Achievements
    
    /// Records a completed story as an achievement in the user's Firestore document.
    /// Called when the player reaches an ending node (a node with no choices).
    /// - Parameter storyTitle: The title of the completed story
    func recordAchievement(storyTitle: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Use arrayUnion to add the story title without duplicates
        db.collection("users").document(uid).updateData([
            "achievements": FieldValue.arrayUnion([storyTitle])
        ]) { error in
            if let error = error {
                print("Error recording achievement: \(error.localizedDescription)")
            }
        }
    }
}
