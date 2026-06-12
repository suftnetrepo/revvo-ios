import Foundation
import RevenueCat

@Observable
class PurchaseService {
    static let shared = PurchaseService()

    var isPremium = false
    var monthlyProduct: StoreProduct?
    var yearlyProduct: StoreProduct?
    var lifetimeProduct: StoreProduct?
    var isLoading = false
    var scansThisMonth: Int = 0

    private var scansKey: String {
        let month = Calendar.current.component(.month, from: Date())
        let year = Calendar.current.component(.year, from: Date())
        return "scans_\(year)_\(month)"
    }

    var canScan: Bool { isPremium || scansThisMonth < 10 }
    var scansRemaining: Int { isPremium ? 999 : max(0, 1 - scansThisMonth) }

    init() {
        scansThisMonth = UserDefaults.standard.integer(forKey: scansKey)
    }

    func configure() {
        let apiKey = Bundle.main.infoDictionary?["REVENUECAT_API_KEY"] as? String ?? ""
        Purchases.configure(withAPIKey: apiKey)
        Purchases.logLevel = .error
        Task { await refreshStatus() }
        Task { await loadProducts() }
    }

    func refreshStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isPremium = customerInfo.entitlements["premium"]?.isActive == true
        } catch {
            print("❌ RevenueCat refresh error: \(error)")
        }
    }

    func loadProducts() async {
        isLoading = true
        do {
            let offerings = try await Purchases.shared.offerings()
            if let current = offerings.current {
                for package in current.availablePackages {
                    switch package.packageType {
                    case .monthly:
                        monthlyProduct = package.storeProduct
                    case .annual:
                        yearlyProduct = package.storeProduct
                    case .lifetime:
                        lifetimeProduct = package.storeProduct
                    default:
                        break
                    }
                }
            }
        } catch {
            print("❌ Failed to load products: \(error)")
        }
        isLoading = false
    }

    func purchase(_ product: StoreProduct) async throws {
        let result = try await Purchases.shared.purchase(product: product)
        isPremium = result.customerInfo.entitlements["premium"]?.isActive == true
    }

    func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        isPremium = customerInfo.entitlements["premium"]?.isActive == true
    }

    func recordScan() {
        scansThisMonth += 1
        UserDefaults.standard.set(scansThisMonth, forKey: scansKey)
     
    }

    func resetScans() {
        scansThisMonth = 0
        UserDefaults.standard.set(0, forKey: scansKey)
       
    }
    var studyStreak: Int {
        get { UserDefaults.standard.integer(forKey: "studyStreak") }
    }

    var lastStudyDate: Date? {
        get { UserDefaults.standard.object(forKey: "lastStudyDate") as? Date }
    }

    func recordStudySession() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let last = lastStudyDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let daysDiff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDiff == 0 {
                // Already studied today — no change
                return
            } else if daysDiff == 1 {
                // Studied yesterday — increment streak
                UserDefaults.standard.set(studyStreak + 1, forKey: "studyStreak")
            } else {
                // Missed a day — reset streak to 1
                UserDefaults.standard.set(1, forKey: "studyStreak")
            }
        } else {
            // First time studying
            UserDefaults.standard.set(1, forKey: "studyStreak")
        }
        
        UserDefaults.standard.set(Date(), forKey: "lastStudyDate")
     
    }
}
