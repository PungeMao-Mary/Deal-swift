import SwiftUI

struct AmountBoardSidebar: View {
    let viewModel: GameViewModel
    
    // 拆分为低奖金区（左栏）和高奖金区（右栏）
    private var lowAmounts: [Double] {
        Array(GameConfig.classicAmounts.prefix(13))
    }
    
    private var highAmounts: [Double] {
        Array(GameConfig.classicAmounts.suffix(13))
    }
    
    var body: some View {
        List {
            Section("低奖金池") {
                ForEach(lowAmounts, id: \.self) { amount in
                    AmountRow(amount: amount, isActive: viewModel.isAmountActive(amount), tintColor: .blue)
                }
            }
            
            Section("高奖金池") {
                ForEach(highAmounts, id: \.self) { amount in
                    AmountRow(amount: amount, isActive: viewModel.isAmountActive(amount), tintColor: .orange)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("奖金看板")
    }
}

private struct AmountRow: View {
    let amount: Double
    let isActive: Bool
    let tintColor: Color
    
    var body: some View {
        HStack {
            Text("$\(formattedAmount(amount))")
                .fontWeight(isActive ? .bold : .regular)
                .strikethrough(!isActive, color: .secondary)
                .foregroundStyle(isActive ? tintColor : .secondary.opacity(0.6))
            
            Spacer()
            
            if !isActive {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary.opacity(0.4))
            }
        }
        .padding(.vertical, 2)
    }
    
    private func formattedAmount(_ value: Double) -> String {
        if value < 1 {
            return String(format: "%.2f", value)
        } else if value >= 1_000 {
            return NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
        } else {
            return String(format: "%.0f", value)
        }
    }
}
