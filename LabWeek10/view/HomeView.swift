//
//  HomeView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import SwiftUI
import Combine

struct HomeView: View {
    
    @StateObject private var storyVM = StoryViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Daftar Cerita")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("Pilih jalan yang ingin kau lalui!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    if storyVM.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding()
                    }
                    
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
                    
                    ForEach(storyVM.stories) { story in
                        StoryCardView(story: story) {
                            storyVM.startStory(story)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .fullScreenCover(isPresented: $storyVM.isPlaying) {
                GameplayView()
                    .environmentObject(storyVM)
            }
            .onAppear {
                storyVM.fetchStories()
            }
        }
    }
}

struct StoryCardView: View {
    
    let story: Story
    
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(story.title)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(story.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
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
