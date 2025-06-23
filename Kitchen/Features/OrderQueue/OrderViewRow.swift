//
//  OrderViewRow.swift
//  Kitchen
//
//  Created by iCodeWave Community on 10/06/25.
//
import SwiftUI
import FirebaseCore

struct OrderRowView: View {
    let order: Order
    var onUpdateOrderStatus: ((String) -> Void)?
    var onUpdateItemStatus: ((OrderItem, String) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header Pesanan
            HStack {
                VStack(alignment: .leading) {
                    Text("Pesanan: #\(order.orderNumber ?? order.id ?? "N/A")")
                        .font(.headline)
                    if let table = order.tableNumber, !table.isEmpty {
                        Text("Meja: \(table)")
                            .font(.subheadline)
                    }
                    if let customer = order.customerName, !customer.isEmpty {
                        Text("Pelanggan: \(customer)")
                            .font(.subheadline)
                    }
                }
                Spacer()
                Text(order.createdAt?.dateValue().formatted(date: .omitted, time: .shortened) ?? "Baru")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Status Pesanan Keseluruhan
            Text("Status Pesanan: \(order.orderStatus.capitalized.replacingOccurrences(of: "_", with: " "))")
                .font(.subheadline.weight(.medium))
                .foregroundColor(statusColor(for: order.orderStatus))
                .padding(.vertical, 2)

            Divider()

            // Daftar Item
            Text("Detail Item:")
                .font(.caption.weight(.semibold))
            ForEach(order.items) { item in
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("\(item.quantity)x \(item.nama_makanan)")
                            .font(.callout)
                        if let notes = item.notes, !notes.isEmpty {
                            Text("Catatan: \(notes)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .padding(.leading, 5)
                        }
                    }
                    Spacer()
                    // Aksi untuk status item
                    Menu {
                        Button("Belum Diproses") { onUpdateItemStatus?(item, "pending") }
                        Button("Sedang Disiapkan") { onUpdateItemStatus?(item, "preparing") }
                        Button("Selesai Disiapkan") { onUpdateItemStatus?(item, "ready") }
                    } label: {
                        HStack {
                            Text(item.itemStatus.capitalized)
                                .font(.caption)
                                .foregroundColor(statusColor(for: item.itemStatus))
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.caption)
                                .foregroundColor(statusColor(for: item.itemStatus))
                        }
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .background(statusColor(for: item.itemStatus).opacity(0.1))
                        .cornerRadius(8)
                    }
                    .disabled(order.orderStatus == "ready_for_pickup" || order.orderStatus == "completed" || order.orderStatus == "cancelled") // Disable jika order sudah final
                }
                .padding(.vertical, 2)
            }
            
            // Aksi untuk Status Pesanan Keseluruhan
            if order.orderStatus != "ready_for_pickup" && order.orderStatus != "completed" && order.orderStatus != "cancelled" {
                Divider().padding(.top, 5)
                HStack {
                    Spacer()
                    if order.orderStatus == "pending_confirmation" {
                        actionButton(title: "Konfirmasi Pesanan", newStatus: "confirmed_by_kitchen", color: .green)
                    } else if order.orderStatus == "confirmed_by_kitchen" {
                        actionButton(title: "Mulai Siapkan", newStatus: "preparing", color: .orange)
                    } else if order.orderStatus == "preparing" {
                        // Cek apakah semua item sudah 'ready' sebelum mengaktifkan tombol ini
                        let allItemsReady = order.items.allSatisfy { $0.itemStatus == "ready" }
                        actionButton(title: "Selesai & Siap Diambil", newStatus: "ready_for_pickup", color: .blue, disabled: !allItemsReady)
                    }
                    Spacer()
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground)) // Lebih adaptif ke light/dark mode
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // Helper view untuk tombol aksi
    @ViewBuilder
    private func actionButton(title: String, newStatus: String, color: Color, disabled: Bool = false) -> some View {
        Button(action: {
            onUpdateOrderStatus?(newStatus)
        }) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundColor(.white)
                .background(disabled ? Color.gray : color)
                .cornerRadius(8)
                .shadow(color: disabled ? .clear : color.opacity(0.3), radius: 3, x: 0, y: 2)
        }
        .disabled(disabled)
    }

    // Helper untuk warna status
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pending", "pending_confirmation":
            return .orange
        case "preparing", "confirmed_by_kitchen":
            return .blue
        case "ready", "ready_for_pickup":
            return .green
        case "completed":
            return .gray
        case "cancelled":
            return .red
        default:
            return .primary // Warna default
        }
    }
}

// Untuk Preview
struct OrderRowView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleItem1 = OrderItem(menuItemID: "mn001", nama_makanan: "Nasi Goreng Ayam", quantity: 1, notes: "Pedas", itemStatus: "pending")
        let sampleItem2 = OrderItem(menuItemID: "mn002", nama_makanan: "Es Teh", quantity: 2, itemStatus: "preparing")
        let sampleOrder = Order(
            id: "ord123",
            orderNumber: "K001",
            tableNumber: "3A",
            items: [sampleItem1, sampleItem2],
            orderStatus: "confirmed_by_kitchen",
            createdAt: Timestamp(date: Date(timeIntervalSinceNow: -3600)) // 1 jam lalu
        )
        
        ScrollView { // Tambahkan ScrollView agar bisa melihat row jika konten panjang
            OrderRowView(order: sampleOrder, onUpdateOrderStatus: { newStatus in
                print("Preview: Order status changed to: \(newStatus)")
            }, onUpdateItemStatus: { item, newStatus in
                print("Preview: Item \(item.nama_makanan) status changed to: \(newStatus)")
            })
            .padding()
            
             let sampleOrder2 = Order(
                id: "ord124",
                orderNumber: "K002",
                items: [sampleItem1],
                orderStatus: "preparing",
                createdAt: Timestamp(date: Date(timeIntervalSinceNow: -7200))
            )
            OrderRowView(order: sampleOrder2)
            .padding()
        }
        .background(Color(UIColor.secondarySystemBackground))
    }
}
