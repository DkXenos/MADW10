//
//  AdminView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Admin View (Arsitek)
//  Management interface for story design.
//  Lists all stories and provides a "+" button to create new nodes.
//

import SwiftUI

/// Admin page for managing stories and adding new nodes.
struct AdminView: View {
    
    // MARK: - State
    @StateObject private var adminVM = AdminViewModel()
    @State private var showCreateSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Subtitle
                Text("Rancangan Cerita")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // MARK: - Story List
                if adminVM.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.top, 40)
                } else if adminVM.stories.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Belum ada cerita.")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    List {
                        ForEach(adminVM.stories) { story in
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
                    .listStyle(.plain)
                }
                
                Spacer()
            }
            .navigationTitle("Arsitek")
            .toolbar {
                // MARK: - Add Button (+)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                AdminCreateNodeView(adminVM: adminVM, isPresented: $showCreateSheet)
            }
            .onAppear {
                adminVM.fetchStories()
            }
        }
    }
}

#Preview {
    AdminView()
}
