import SwiftUI

struct ContentView: View {
    @State private var viewModel = GameViewModel()
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
    
    var body: some View {
        NavigationSplitView {
            // 原生 Sidebar — 奖金看板
            AmountBoardSidebar(viewModel: viewModel)
        } detail: {
            // 主游戏区域
            VStack(spacing: 16) {
                // 顶部状态提示
                statusHeaderView
                
                // 箱子矩阵
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(viewModel.briefcases) { briefcase in
                            BriefcaseButton(briefcase: briefcase) {
                                handleCaseTap(briefcase)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 底部控制/互动区
                bottomActionView
            }
            .navigationTitle("一掷千金 (Deal or No Deal)")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("重置", action: viewModel.startNewGame)
                }
            }
        }
    }
    
    private var statusHeaderView: some View {
        VStack(spacing: 4) {
            switch viewModel.currentPhase {
            case .selectInitialCase:
                Text("请选择你的专属箱子")
                    .font(.headline)
            case .openingCases(let remaining):
                Text("第 \(viewModel.currentRound) 轮：还需开启 \(remaining) 个箱子")
                    .font(.headline)
            case .bankerOffer(let offer):
                Text("银行家报价：$\(offer, specifier: "%.2f")")
                    .font(.title2.bold())
                    .foregroundStyle(.green)
            case .finalDecision:
                Text("终局对决：是否交换箱子？")
                    .font(.headline)
                    .foregroundStyle(.orange)
            case .gameOver(let wonAmount, let reason):
                VStack(spacing: 6) {
                    Text(gameOverDescription(for: reason))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("最终带走：$\(wonAmount, specifier: "%.2f")")
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                    
                    if let playerCase = viewModel.playerCase {
                        Text("你的专属箱 (#\(playerCase.id)) 实际金额为：$\(playerCase.amount, specifier: "%.2f")")
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.15))
    }
    
    private var bottomActionView: some View {
        VStack {
            switch viewModel.currentPhase {
            case .bankerOffer(let offer):
                HStack(spacing: 20) {
                    Button("Deal (接受)") {
                        viewModel.acceptOffer(offer)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    
                    Button("No Deal (拒绝)") {
                        viewModel.rejectOffer()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            case .finalDecision:
                HStack(spacing: 20) {
                    Button("坚持原箱") {
                        viewModel.keepOriginalCase()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("交换箱子") {
                        viewModel.swapCase()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            case .gameOver:
                Button("再玩一局", action: viewModel.startNewGame)
                    .buttonStyle(.borderedProminent)
            default:
                EmptyView()
            }
        }
        .padding(.bottom)
    }
    
    private func handleCaseTap(_ briefcase: Briefcase) {
        switch viewModel.currentPhase {
        case .selectInitialCase:
            viewModel.selectPlayerCase(briefcase)
        case .openingCases:
            viewModel.openBriefcase(briefcase)
        default:
            break
        }
    }
    
    private func gameOverDescription(for reason: GameOverReason) -> String {
        switch reason {
        case .acceptedDeal: return "你接受了银行家的报价！"
        case .openedPlayerCase: return "你坚持了自己最初选中的箱子！"
        case .swappedCase: return "你交换了箱子！"
        }
    }
}

// 单个箱子组件
struct BriefcaseButton: View {
    let briefcase: Briefcase
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                if briefcase.isPlayerCase {
                    Text("我的箱 #\(briefcase.id)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                    if briefcase.isOpened {
                        Text("$\(briefcase.amount, specifier: "%.2f")")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(.yellow)
                    }
                } else if briefcase.isOpened {
                    Text("$\(briefcase.amount, specifier: "%.2f")")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.gray)
                } else {
                    Text("#\(briefcase.id)")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(briefcase.isOpened || briefcase.isPlayerCase)
    }
    
    private var backgroundColor: Color {
        if briefcase.isPlayerCase {
            return Color.blue
        }
        if briefcase.isOpened {
            return Color.gray.opacity(0.3)
        }
        return Color.orange
    }
}
