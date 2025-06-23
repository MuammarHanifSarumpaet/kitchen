//
//  MenuItem.swift
//  Kitchen
//
//  Created by iCodeWave Community on 02/06/25.
//

import FirebaseFirestoreSwift

struct MenuItem: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let nama_makanan: String
    let description: String
    let harga: Double
    let image_url: String?
    var stock: Int
    var status_makanan: String // "tersedia", "habis"

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        lhs.id == rhs.id
    }
}
