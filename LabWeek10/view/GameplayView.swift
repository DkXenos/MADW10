//
//  GameplayView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import SwiftUI
import Combine

struct GameplayView: View {
    
    @EnvironmentObject var storyVM: StoryViewModel
    
    @State private var storyFinished: Bool = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
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
                
                if let node = storyVM.currentNode {
                    if node.choices.isEmpty {
                        VStack(spacing: 12) {
                            Text("— Tamat —")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                            
                            Button(action: {
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
