import SwiftUI
import RevenueCat

struct PaywallView: View {
    var onDismiss: () -> Void
    @State private var purchaseService = PurchaseService.shared
    @State private var selectedPlan = 1
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var showError = false

    let plans = ["Monthly", "Yearly", "Lifetime"]

    var selectedProduct: StoreProduct? {
        switch selectedPlan {
        case 0: return purchaseService.monthlyProduct
        case 1: return purchaseService.yearlyProduct
        case 2: return purchaseService.lifetimeProduct
        default: return nil
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                ScrollView {
                    VStack(spacing: 24) {
                        heroSection
                        featuresSection
                        planSelector
                        purchaseButton
                        footerLinks
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Something went wrong")
        }
        .task { await purchaseService.loadProducts() }
    }

    private var headerView: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundStyle(Color(hex: "888888"))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: "1a1a2e"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Spacer()
            Text("Revvo Premium")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(16)
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "6C5CE7").opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundStyle(Color(hex: "6C5CE7"))
            }

            VStack(spacing: 8) {
                Text("Unlock unlimited learning")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("Scan as many notes as you want\nand never run out of flashcards")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(hex: "888888"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .padding(.top, 8)
    }

    private var featuresSection: some View {
        VStack(spacing: 0) {
            featureRow(icon: "infinity", color: "6C5CE7", title: "Unlimited AI scans", subtitle: "Scan as many pages as you need")
            Divider().background(Color(hex: "2a2a3a"))
            featureRow(icon: "doc.on.doc.fill", color: "1D9E75", title: "Unlimited decks", subtitle: "Organise all your subjects")
            Divider().background(Color(hex: "2a2a3a"))
            featureRow(icon: "checkmark.circle.fill", color: "378ADD", title: "Quiz mode", subtitle: "Test yourself with multiple choice")
            Divider().background(Color(hex: "2a2a3a"))
            featureRow(icon: "function", color: "F59E0B", title: "Maths & science", subtitle: "Full LaTeX equation support")
        }
        .background(Color(hex: "13132a"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
        )
    }

    private func featureRow(icon: String, color: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: color))
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "666666"))
            }
            Spacer()
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: "6C5CE7"))
        }
        .padding(14)
    }

    private var planSelector: some View {
        VStack(spacing: 10) {
            ForEach(0..<3) { index in
                planCard(index: index)
            }
        }
    }

    private func planCard(index: Int) -> some View {
        let isSelected = selectedPlan == index
        let product = index == 0 ? purchaseService.monthlyProduct :
                      index == 1 ? purchaseService.yearlyProduct :
                      purchaseService.lifetimeProduct

        return Button(action: { selectedPlan = index }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(plans[index])
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white)
                        if index == 1 {
                            Text("BEST VALUE")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color(hex: "1D9E75"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "0d2a1a"))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    if product != nil {
                        Text(index == 2 ? "One time payment" : "per \(index == 0 ? "month" : "year")")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: "666666"))
                    } else {
                        Text("Loading...")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: "666666"))
                    }
                }

                Spacer()

                if let product = product {
                    Text(product.localizedPriceString)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(isSelected ? Color(hex: "6C5CE7") : .white)
                }

                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: "6C5CE7") : Color(hex: "2a2a3a"), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "6C5CE7"))
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(16)
            .background(Color(hex: "13132a"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color(hex: "6C5CE7") : Color(hex: "2a2a3a"),
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

   private var purchaseButton: some View {
    VStack(spacing: 12) {
        Button(action: { Task { await purchase() } }) {
            HStack(spacing: 8) {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                }
                Text(isPurchasing ? "Processing..." : "Start Premium")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(hex: "6C5CE7"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isPurchasing || selectedProduct == nil)

        Text(selectedPlan == 2 ? "One-time purchase, no subscription" :
             "Cancel anytime in App Store settings")
            .font(.system(size: 12))
            .foregroundStyle(Color(hex: "555555"))

        // Terms notice
        HStack(spacing: 4) {
            Text("By subscribing you agree to our")
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: "444444"))
            Button("Terms of Use") {
                if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(size: 11))
            .foregroundStyle(Color(hex: "6C5CE7"))
            Text("and")
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: "444444"))
            Button("Privacy Policy") {
                if let url = URL(string: "https://suftnetrepo.github.io/revvo-ios/") {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(size: 11))
            .foregroundStyle(Color(hex: "6C5CE7"))
        }
        .multilineTextAlignment(.center)
    }
}
   private var footerLinks: some View {
    HStack(spacing: 12) {
        Button("Restore purchases") {
            Task { await restore() }
        }
        .font(.system(size: 13))
        .foregroundStyle(Color(hex: "555555"))

    }
}

    private func purchase() async {
        guard let product = selectedProduct else { return }
        isPurchasing = true
        do {
            try await purchaseService.purchase(product)
            onDismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isPurchasing = false
    }

    private func restore() async {
        do {
            try await purchaseService.restorePurchases()
            if purchaseService.isPremium { onDismiss() }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
