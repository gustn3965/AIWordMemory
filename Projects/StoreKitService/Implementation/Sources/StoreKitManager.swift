import Foundation
import StoreKit


//@MainActor
public class StoreKitManager: ObservableObject, @unchecked Sendable {
    
    
    public var availableProducts: [Product] = []
    
    // 내 앱에서 사용하려는 구독상품 ID 목록
    private let purchaseIDs = [
        "com.hyunsu.aiwordmemory.ai099",
    ]
    
    // Main App에서 로직 처리
    @Published public var purchasedProducts: [Product] = []
    
    var transacitonListener: Task<Void, Error>?
    
    public let purchaseChatGPTChances: Int
    public let purchaseTTSChances: Int
    
    public init(purcahaseChatGPTChances: Int, purchaseTTSChances: Int) {
        self.purchaseChatGPTChances = purcahaseChatGPTChances
        self.purchaseTTSChances = purchaseTTSChances
        
    }
    
    public func setup() async {
        
        await fetchProducts()
        await updateCurrentEntitlements()
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 앱시작시 pending된거 가져올때 얼럿띄우기위해 
            startListen()
        }
    }
    
    private func startListen() {
        Task {
            for await transaction in listenForTransactions() {
                guard let product = self.availableProducts.first(where: { $0.id == transaction.productID }) else { continue }
                await transaction.finish()
                await appendPurchaseProduct(product)
                
            }
        }
    }
    
    @MainActor private func appendPurchaseProduct(_ product: Product) async {
        purchasedProducts.append(product)
    }
    
    private func fetchProducts() async {
        do {
            let products = try await Product.products(for: purchaseIDs)
            self.availableProducts = products
            print("# \(#file) \(#function)")
            let count = products.count
            
            if count > 0 {
                print("!!!!!!!!!!!!")
            }
            print(count)
            print()
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    public func purchaseFirst() async throws {
        guard let product = availableProducts.first else {
            throw StoreError.unknown
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                // 구매 성공
                await transaction.finish()
                await appendPurchaseProduct(product)
            case .unverified:
                // 구매 검증 실패
                throw StoreError.failedVerification
            }
        case .userCancelled:
            // 사용자가 구매를 취소함
            throw StoreError.userCancelled
        case .pending:
            // 구매 대기 중 (예: 승인 필요)
            throw StoreError.pending
        @unknown default:
            throw StoreError.unknown
        }
    }
    
    
    private func listenForTransactions() -> AsyncStream<Transaction> {
        return AsyncStream { continuation in
            Task {
                for await result in Transaction.updates {
                    switch result {
                    case let .verified(transaction):
                        continuation.yield(transaction)
                    default:
                        continue
                    }
                }
            }
        }
    }
    
    private func updateCurrentEntitlements() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case let.verified(transaction):
                guard let product = availableProducts.first(where: { $0.id == transaction.productID } ) else { return }
                await transaction.finish()
                await appendPurchaseProduct(product)
                
            default:
                return
            }
        }
    }
    
    
}

public enum StoreError: Error, LocalizedError {
    case failedVerification
    case userCancelled
    case pending
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .failedVerification:
            "구매 검증에 실패했습니다"
        case .userCancelled:
            "취소했습니다"
        case .pending:
            "구매 대기중입니다"
        case .unknown:
            "알 수 없는 이유로 구매하지 못했습니다."
        }
    }
}

