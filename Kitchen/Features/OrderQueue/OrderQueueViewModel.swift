import Foundation
import Combine

class OrderQueueViewModel: ObservableObject {
    // Hapus properti orderService di sini. OrderService akan diakses melalui init atau parameter method.
    // Jika ViewModel perlu akses langsung ke service, Anda bisa pass itu di init atau melalui closures.

    @Published var orders: [Order] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private var orderService: OrderService // Simpan referensi ke service jika di-inject

    // REVISI DI SINI: Inisialisasi dengan OrderService
    init(orderService: OrderService) { // OrderService harus di-inject
        self.orderService = orderService
        subscribeToOrderService()
        orderService.listenForKitchenOrders()
    }

    private func subscribeToOrderService() {
        orderService.$kitchenOrders
            .receive(on: DispatchQueue.main)
            .assign(to: \.orders, on: self)
            .store(in: &cancellables)

        orderService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)

        orderService.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
    }

    // Fungsi lainnya tetap sama, karena orderService sudah ada di properti
    func updateOrderStatus(order: Order, newStatus: String) {
        guard let orderID = order.id else {
            self.errorMessage = "Order ID tidak valid."
            return
        }
        Task {
            do {
                try await orderService.updateOrderStatus(orderID: orderID, newStatus: newStatus)
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Gagal update status pesanan: \(error.localizedDescription)"
                }
            }
        }
    }

    func updateOrderItemStatus(order: Order, item: OrderItem, newStatus: String) {
        guard let orderID = order.id else {
            self.errorMessage = "Order ID tidak valid."
            return
        }
        Task {
            do {
                try await orderService.updateOrderItemStatus(orderID: orderID, itemToUpdate: item, newStatus: newStatus, currentOrder: order)
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Gagal update status item: \(error.localizedDescription)"
                }
            }
        }
    }

    func refreshOrders() {
        orderService.listenForKitchenOrders()
    }

    deinit {
        orderService.stopListeningForOrders()
        print("OrderQueueViewModel deinitialized and listener stopped.")
    }
}
