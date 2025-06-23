//import FirebaseFirestoreSwift
import FirebaseFirestore // Untuk Timestamp

struct Order: Identifiable, Codable, Hashable {
    @DocumentID var id: String? // Firestore document ID
    var orderNumber: String?     // Nomor pesanan yang mudah dibaca, jika ada
    var customerName: String?    // Opsional
    var tableNumber: String?     // Opsional
    var items: [OrderItem]
    var totalPrice: Double?      // Bisa jadi tidak relevan untuk Kitchen view
    var orderStatus: String      // "pending_confirmation", "confirmed_by_kitchen", "preparing", "ready_for_pickup", "completed", "cancelled"
    var createdAt: Timestamp?    // Kapan pesanan dibuat
    var updatedAt: Timestamp?    // Kapan status terakhir diubah

    // Untuk Hashable (diperlukan jika digunakan di ForEach dengan selection atau diffing)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Order, rhs: Order) -> Bool {
        lhs.id == rhs.id
    }

    // Helper untuk mendapatkan tanggal yang diformat
    var formattedCreatedAt: String {
        createdAt?.dateValue().formatted(date: .numeric, time: .shortened) ?? "N/A"
    }
}
