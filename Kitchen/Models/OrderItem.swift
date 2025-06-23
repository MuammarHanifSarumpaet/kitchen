//import FirebaseFirestoreSwift

struct OrderItem: Identifiable, Codable, Hashable {
    // Jika ingin ID unik untuk OrderItem (misalnya, jika item bisa dihapus/diedit satu per satu
    // dengan cara yang lebih kompleks), tambahkan @DocumentID atau var id: String = UUID().uuidString.
    // Namun, untuk kasus umum di daftar, menuItemID bisa cukup sebagai pembeda dalam konteks satu order.
    // Menggunakan menuItemID sebagai ID untuk Identifiable dalam konteks daftar item per order.
    var id: String { menuItemID + (notes ?? "") } // Kombinasi untuk keunikan jika menuItemID sama bisa ada dgn notes berbeda
    
    let menuItemID: String         // Referensi ke ID dokumen di `menu_makanan`
    let nama_makanan: String       // Duplikasi nama untuk kemudahan display
    var quantity: Int
    var notes: String?             // Catatan khusus dari pelanggan
    var itemStatus: String         // "pending", "preparing", "ready"

    func hash(into hasher: inout Hasher) {
        hasher.combine(menuItemID)
        hasher.combine(notes) // Tambahkan notes agar lebih unik jika diperlukan
    }

    static func == (lhs: OrderItem, rhs: OrderItem) -> Bool {
        lhs.menuItemID == rhs.menuItemID && lhs.notes == rhs.notes
    }
}
