//
//  User.swift
//  Kitchen
//
//  Created by iCodeWave Community on 02/06/25.
//
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String? // userID dari Firestore auth (UID Firebase)
    let email: String
    var displayName: String? // Tambahkan jika Anda ingin nama tampilan
//    let role: String
    // Tambahkan field lain jika perlu, misal: createdAt: Timestamp?
}
