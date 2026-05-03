//
//  AdminView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import SwiftUI
import Combine

struct AdminView: View {
    
    @StateObject private var adminVM = AdminViewModel()
    
    @State private var showCreateStorySheet: Bool = false
    
    @State private var newStoryTitle: String = ""
    @State private var newStoryDescription: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Rancangan Cerita")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                if adminVM.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.top, 40)
                }
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
                else {
                    List {
                        ForEach(adminVM.stories) { story in
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        newStoryTitle = ""
                        newStoryDescription = ""
                        showCreateStorySheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
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

struct CreateStorySheetView: View {
    
    @Binding var title: String
    @Binding var description: String
    @Binding var isPresented: Bool
    
    var onSave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
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
            
            Text("Draft Cerita")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Text("Detail")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                TextField("Judul cerita", text: $title)
                    .padding()
                
                Divider()
                    .padding(.horizontal)
                
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
