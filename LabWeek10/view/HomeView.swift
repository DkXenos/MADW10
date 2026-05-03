//
//  HomeView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Home View (Daftar Cerita)
//  Displays a scrollable list of story cards fetched from Firestore.
//  Each card shows title, description, and a "Mulai cerita" button.
//

import SwiftUI
import Combine

/// Home page displaying the list of interactive stories.
struct HomeView: View {
    
    // MARK: - State
    @StateObject private var storyVM = StoryViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // MARK: - Header
                    Text("Daftar Cerita")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("Pilih jalan yang ingin kau lalui!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    // MARK: - Loading Indicator
                    if storyVM.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding()
                    }
                    
                    // MARK: - Empty State
                    if !storyVM.isLoading && storyVM.stories.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("Belum ada cerita.")
                                .foregroundColor(.secondary)
                            Text("Tambahkan seed data di Profile!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    }
                    
                    // MARK: - Story Cards List
                    ForEach(storyVM.stories) { story in
                        StoryCardView(story: story) {
                            storyVM.startStory(story)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            // MARK: - Gameplay Fullscreen Cover
            .fullScreenCover(isPresented: $storyVM.isPlaying) {
                GameplayView()
                    .environmentObject(storyVM)
            }
            // Fetch stories when the view appears
            .onAppear {
                storyVM.fetchStories()
            }
        }
    }
}

// MARK: - Story Card Component
/// A card view displaying a single story's title, description, and play button.
struct StoryCardView: View {
    
    /// The story data to display
    let story: Story
    
    /// Action to perform when "Mulai cerita" is tapped
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Story title
            Text(story.title)
                .font(.headline)
                .fontWeight(.bold)
            
            // Story description
            Text(story.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // "Mulai cerita" button
            Button(action: onStart) {
                HStack {
                    Text("Mulai cerita")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray5))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    HomeView()
}
