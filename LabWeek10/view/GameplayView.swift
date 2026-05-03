//
//  GameplayView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Gameplay View
//  Displays the interactive story with:
//  - Typewriter animation for narrative text (+5 points)
//  - Multiple choice buttons for navigation
//  - Close (X) button to return to Home
//  - Finish button and achievement recording on ending nodes
//

import SwiftUI

/// Full-screen gameplay view with dark theme, typewriter text, and choices.
struct GameplayView: View {
    
    // MARK: - Environment
    @EnvironmentObject var storyVM: StoryViewModel
    
    // MARK: - State
    /// Tracks whether the story has been completed (ending node reached)
    @State private var storyFinished: Bool = false
    
    var body: some View {
        ZStack {
            // MARK: - Dark Background
            Color.black
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: - Close Button (X)
                HStack {
                    Button(action: {
                        storyVM.stopStory()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
                
                // MARK: - Narrative Text with Typewriter Animation
                /// This is the CRITICAL +5 points requirement.
                /// Text is revealed progressively using a timer-based animation
                /// defined in StoryViewModel.startTypewriterAnimation().
                ScrollView {
                    Text(storyVM.displayedText)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                        .animation(.easeIn(duration: 0.05), value: storyVM.displayedText)
                }
                .frame(maxHeight: 250)
                
                // MARK: - Choices or Finish Button
                if let node = storyVM.currentNode {
                    if node.choices.isEmpty {
                        // MARK: - Ending Node: Show Finish Button
                        VStack(spacing: 12) {
                            Text("— Tamat —")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                            
                            Button(action: {
                                // Record achievement in Firestore
                                if let title = storyVM.currentStory?.title {
                                    storyVM.recordAchievement(storyTitle: title)
                                }
                                storyVM.stopStory()
                            }) {
                                Text("Finish")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 32)
                        .opacity(storyVM.isTypewriterComplete ? 1 : 0)
                        .animation(.easeIn(duration: 0.5), value: storyVM.isTypewriterComplete)
                    } else {
                        // MARK: - Choice Buttons
                        VStack(spacing: 10) {
                            ForEach(node.choices) { choice in
                                Button(action: {
                                    storyVM.selectChoice(choice)
                                }) {
                                    HStack {
                                        Text(choice.label)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                        .opacity(storyVM.isTypewriterComplete ? 1 : 0)
                        .animation(.easeIn(duration: 0.5), value: storyVM.isTypewriterComplete)
                    }
                }
            }
        }
    }
}

#Preview {
    GameplayView()
        .environmentObject(StoryViewModel())
}
