//
//  ProfileViewModel.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Profile ViewModel
//  Handles user profile data, achievements, and seed data operations.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

/// ViewModel for profile page: achievements and seed data.
class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var userEmail: String = ""
    @Published var achievements: [String] = []
    @Published var isLoading: Bool = false
    @Published var seedMessage: String = ""
    
    // MARK: - Private
    private let db = Firestore.firestore()
    
    // MARK: - Fetch User Profile
    /// Loads the current user's email and achievements from Firestore.
    func fetchProfile() {
        guard let user = Auth.auth().currentUser else { return }
        userEmail = user.email ?? "No Email"
        
        isLoading = true
        db.collection("users").document(user.uid).getDocument { [weak self] doc, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let data = doc?.data() {
                    self?.achievements = data["achievements"] as? [String] ?? []
                }
            }
        }
    }
    
    // MARK: - Seed Data: Bajak Laut
    /// Writes a complete pirate story tree into Firestore.
    func seedBajakLaut() {
        let nodes: [StoryNode] = [
            StoryNode(nodeId: "bl_1", narrative: "Kapten Arjuna berdiri di dek kapal. Badai mendekat dari barat, tapi harta karun ada di timur. Kru menunggu perintah.", isMainEntryPoint: true, choices: [
                Choice(label: "Menerjang Badai", targetNodeId: "bl_2"),
                Choice(label: "Berlayar ke Timur", targetNodeId: "bl_3")
            ]),
            StoryNode(nodeId: "bl_2", narrative: "Kapal oleng dihantam ombak raksasa! Tiang layar retak. Kru panik.", isMainEntryPoint: false, choices: [
                Choice(label: "Perbaiki Tiang", targetNodeId: "bl_4"),
                Choice(label: "Tinggalkan Kapal", targetNodeId: "bl_5")
            ]),
            StoryNode(nodeId: "bl_3", narrative: "Kalian berlayar tenang ke timur. Sebuah pulau kecil terlihat di cakrawala. Ada asap dari pulau itu.", isMainEntryPoint: false, choices: [
                Choice(label: "Mendarat di Pulau", targetNodeId: "bl_6"),
                Choice(label: "Lewati Pulau", targetNodeId: "bl_7")
            ]),
            StoryNode(nodeId: "bl_4", narrative: "Dengan kerja keras, tiang berhasil diperbaiki. Badai mereda dan kalian menemukan gua harta karun! Kapten Arjuna menjadi legenda.", isMainEntryPoint: false, choices: []),
            StoryNode(nodeId: "bl_5", narrative: "Kru melompat ke sekoci. Kapal tenggelam, tapi semua selamat. Kalian terdampar di pulau tak dikenal.", isMainEntryPoint: false, choices: []),
            StoryNode(nodeId: "bl_6", narrative: "Di pulau itu kalian menemukan suku asli yang ramah. Mereka menunjukkan lokasi harta karun kuno! Misi berhasil.", isMainEntryPoint: false, choices: []),
            StoryNode(nodeId: "bl_7", narrative: "Kalian melewati pulau dan berlayar lebih jauh. Sayangnya, persediaan habis. Kapal kembali ke pelabuhan dengan tangan kosong.", isMainEntryPoint: false, choices: [])
        ]
        writeSeedStory(title: "Tekad Sang Kapten", description: "Petualangan bajak laut mencari harta karun di lautan berbahaya.", nodes: nodes)
    }
    
    // MARK: - Seed Data: Ninja
    /// Writes a complete ninja story tree into Firestore.
    func seedNinja() {
        let nodes: [StoryNode] = [
            StoryNode(nodeId: "nj_1", narrative: "Ian berlatih di hutan. Ujian ninja tinggal besok pagi. Ian merasa kurang menguasai chakra-nya.", isMainEntryPoint: true, choices: [
                Choice(label: "Meditasi Chakra", targetNodeId: "nj_2"),
                Choice(label: "Latihan Fisik Keras", targetNodeId: "nj_3")
            ]),
            StoryNode(nodeId: "nj_2", narrative: "Ian duduk tenang di bawah air terjun. Chakra mengalir sempurna. Sebuah visi muncul — guru besar memanggilnya.", isMainEntryPoint: false, choices: [
                Choice(label: "Ikuti Visi", targetNodeId: "nj_4"),
                Choice(label: "Abaikan Visi", targetNodeId: "nj_5")
            ]),
            StoryNode(nodeId: "nj_3", narrative: "Ian berlari menembus hutan, menghancurkan target latihan. Tubuhnya kuat, tapi chakra tidak stabil.", isMainEntryPoint: false, choices: [
                Choice(label: "Istirahat Sebentar", targetNodeId: "nj_6"),
                Choice(label: "Terus Berlatih", targetNodeId: "nj_7")
            ]),
            StoryNode(nodeId: "nj_4", narrative: "Guru besar mengajarkan jutsu rahasia. Ian lulus ujian dengan nilai sempurna dan menjadi ninja legendaris!", isMainEntryPoint: false, choices: []),
            StoryNode(nodeId: "nj_5", narrative: "Ian mengabaikan visi dan melanjutkan meditasi sendiri. Ia lulus ujian, cukup baik tapi biasa saja.", isMainEntryPoint: false, choices: []),
            StoryNode(nodeId: "nj_6", narrative: "Setelah istirahat, Ian menemukan keseimbangan. Ia lulus ujian dengan kemampuan fisik dan chakra yang seimbang.", isMainEntryPoint: false, choices: []),
            StoryNode(nodeId: "nj_7", narrative: "Ian kelelahan saat ujian. Tubuhnya tidak kuat. Ia gagal dan harus mengulang tahun depan.", isMainEntryPoint: false, choices: [])
        ]
        writeSeedStory(title: "Jalan Ninja", description: "Ian harus memilih jalannya sendiri sebagai ninja desa kebanggaannya.", nodes: nodes)
    }
    
    // MARK: - Seed Data: Romance
    /// Writes a complete romance story tree into Firestore.
    func seedRomance() {
        let nodes: [StoryNode] = [
            StoryNode(nodeId: "rm_1", narrative: "Sakura bertemu Daichi di musim semi setelah menangis di taman. Daichi memberikan saputangan biru.", isMainEntryPoint: true, choices: [
                Choice(label: "Terima Saputangan", targetNodeId: "rm_2"),
                Choice(label: "Tolak dengan Sopan", targetNodeId: "rm_3")
            ]),
            StoryNode(nodeId: "rm_2", narrative: "Sakura menerima saputangan itu. Mereka mulai bertemu setiap sore di taman yang sama.", isMainEntryPoint: false, choices: [
                Choice(label: "Nyatakan Perasaan", targetNodeId: "rm_4"),
                Choice(label: "Tetap Berteman", targetNodeId: "rm_5")
            ]),
            StoryNode(nodeId: "rm_3", narrative: "Sakura menolak dengan sopan. Tapi ia menyesal. Seminggu kemudian ia mencari Daichi ke taman.", isMainEntryPoint: false, choices: [
                Choice(label: "Minta Maaf", targetNodeId: "rm_6"),
                Choice(label: "Pura-pura Kebetulan", targetNodeId: "rm_7")
            ]),
            StoryNode(nodeId: "rm_4", narrative: "Daichi tersenyum. 'Aku juga merasakan hal yang sama.' Mereka resmi bersama di bawah pohon sakura.", isMainEntryPoint: false, choices: []),
            StoryNode(nodeId: "rm_5", narrative: "Mereka tetap berteman baik selama bertahun-tahun. Kadang Sakura bertanya-tanya, bagaimana jika ia lebih berani?", isMainEntryPoint: false, choices: []),
            StoryNode(nodeId: "rm_6", narrative: "Daichi memaafkan Sakura. Mereka memulai pertemanan baru yang perlahan tumbuh menjadi cinta.", isMainEntryPoint: false, choices: []),
            StoryNode(nodeId: "rm_7", narrative: "Sakura berpura-pura kebetulan lewat. Daichi tahu, tapi hanya tersenyum. Hubungan mereka canggung selamanya.", isMainEntryPoint: false, choices: [])
        ]
        writeSeedStory(title: "Sakura Terakhir", description: "Kisah cinta Daichi di musim semi setelah menangis di taman.", nodes: nodes)
    }
    
    // MARK: - Write Seed Story to Firestore
    /// Helper that encodes nodes and writes a full story to Firestore.
    private func writeSeedStory(title: String, description: String, nodes: [StoryNode]) {
        isLoading = true
        seedMessage = ""
        
        let nodesData: [[String: Any]] = nodes.map { node in
            let choicesData: [[String: Any]] = node.choices.map { c in
                ["label": c.label, "targetNodeId": c.targetNodeId]
            }
            return [
                "nodeId": node.nodeId,
                "narrative": node.narrative,
                "isMainEntryPoint": node.isMainEntryPoint,
                "choices": choicesData
            ]
        }
        
        let storyData: [String: Any] = [
            "title": title,
            "description": description,
            "nodes": nodesData
        ]
        
        db.collection("stories").addDocument(data: storyData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.seedMessage = "Error: \(error.localizedDescription)"
                } else {
                    self?.seedMessage = "\(title) berhasil ditambahkan!"
                }
            }
        }
    }
}
