//
//  AdminView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Admin View (Arsitek)
//  Main admin page listing all story drafts.
//  - "+" button opens a sheet to create a new story (title + ringkasan)
//  - Tapping a story navigates to StoryDetailView to manage its nodes
//

import SwiftUI
import Combine

/// Admin page listing all stories with a "+" button to create new drafts.
struct AdminView: View {
    
    // MARK: - State
    @StateObject private var adminVM = AdminViewModel()
    
    /// Controls whether the "Draft Cerita" creation sheet is shown
    @State private var showCreateStorySheet: Bool = false
    
    /// Form fields for the "Draft Cerita" sheet
    @State private var newStoryTitle: String = ""
    @State private var newStoryDescription: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: - Subtitle
                Text("Rancangan Cerita")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // MARK: - Loading State
                if adminVM.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.top, 40)
                }
                // MARK: - Empty State
                else if adminVM.stories.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Belum ada cerita.")
                            .foregroundColor(.secondary)
                        Text("Tekan + untuk membuat cerita baru.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                }
                // MARK: - Story List
                else {
                    List {
                        ForEach(adminVM.stories) { story in
                            // Each story is clickable → navigates to StoryDetailView
                            NavigationLink(destination: StoryDetailView(
                                story: story,
                                adminVM: adminVM
                            )) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(story.title)
                                        .font(.headline)
                                    Text(story.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
                Spacer()
            }
            .navigationTitle("Arsitek")
            .toolbar {
                // MARK: - "+" Button to Create Story
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Reset form fields before showing
                        newStoryTitle = ""
                        newStoryDescription = ""
                        showCreateStorySheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // MARK: - "Draft Cerita" Creation Sheet
            .sheet(isPresented: $showCreateStorySheet) {
                CreateStorySheetView(
                    title: $newStoryTitle,
                    description: $newStoryDescription,
                    isPresented: $showCreateStorySheet,
                    onSave: {
                        adminVM.createStoryDraft(
                            title: newStoryTitle,
                            description: newStoryDescription
                        )
                    }
                )
            }
            .onAppear {
                adminVM.fetchStories()
            }
        }
    }
}

// MARK: - Create Story Sheet View
/// Sheet popup for creating a new story draft.
/// Matches the "Draft Cerita" design from the reference screenshots.
/// Has a title field and a "Ringkasan" (summary) field + "Simpan" button.
struct CreateStorySheetView: View {
    
    @Binding var title: String
    @Binding var description: String
    @Binding var isPresented: Bool
    
    /// Callback when the user taps "Simpan"
    var onSave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Top Bar with "Simpan" button
            HStack {
                Spacer()
                Button("Simpan") {
                    onSave()
                    isPresented = false
                }
                .disabled(title.isEmpty)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(title.isEmpty ? Color(.systemGray4) : Color(.systemGray6))
                .cornerRadius(20)
                .fontWeight(.semibold)
            }
            .padding(.top, 16)
            .padding(.trailing, 4)
            
            // MARK: - "Draft Cerita" Title
            Text("Draft Cerita")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // MARK: - "Detail" Section Label
            Text("Detail")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // MARK: - Input Fields Card
            VStack(spacing: 0) {
                // Title field
                TextField("Judul cerita", text: $title)
                    .padding()
                
                Divider()
                    .padding(.horizontal)
                
                // Summary/Ringkasan field
                TextField("Ringkasan", text: $description)
                    .padding()
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

#Preview {
    AdminView()
}
