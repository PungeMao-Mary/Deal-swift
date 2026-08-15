import Foundation
import Observation

@Observable
final class GameViewModel {
    var briefcases: [Briefcase] = []
    var playerCase: Briefcase? = nil
    var currentPhase: GamePhase = .selectInitialCase
    var currentRound: Int = 0
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        let shuffledAmounts = GameConfig.classicAmounts.shuffled()
        briefcases = (1...26).map { index in
            Briefcase(id: index, amount: shuffledAmounts[index - 1])
        }
        playerCase = nil
        currentRound = 0
        currentPhase = .selectInitialCase
    }
    
    // 选取专属箱
    func selectPlayerCase(_ briefcase: Briefcase) {
        guard playerCase == nil else { return }
        if let index = briefcases.firstIndex(where: { $0.id == briefcase.id }) {
            briefcases[index].isPlayerCase = true
            playerCase = briefcases[index]
            currentRound = 1
            currentPhase = .openingCases(remainingInRound: GameConfig.roundCasesToOpen[0])
        }
    }
    
    // 打开剩余的箱子
    func openBriefcase(_ briefcase: Briefcase) {
        guard case .openingCases(let remaining) = currentPhase else { return }
        guard !briefcase.isOpened && !briefcase.isPlayerCase else { return }
        
        if let index = briefcases.firstIndex(where: { $0.id == briefcase.id }) {
            briefcases[index].isOpened = true
            let newRemaining = remaining - 1
            
            if newRemaining > 0 {
                currentPhase = .openingCases(remainingInRound: newRemaining)
            } else {
                // 检查是否仅剩下 1 个未开的箱子和玩家的箱子（进入终局）
                let unOpenedNonPlayerCases = briefcases.filter { !$0.isOpened && !$0.isPlayerCase }
                if unOpenedNonPlayerCases.count == 1 {
                    currentPhase = .finalDecision
                } else {
                    let offer = calculateBankerOffer()
                    currentPhase = .bankerOffer(offer: offer)
                }
            }
        }
    }
    
    // 接受报价 (Deal)
    func acceptOffer(_ offer: Double) {
        revealAllCases()
        currentPhase = .gameOver(wonAmount: offer, reason: .acceptedDeal)
    }
    
    // 拒绝报价 (No Deal)
    func rejectOffer() {
        currentRound += 1
        let casesToOpen = (currentRound - 1 < GameConfig.roundCasesToOpen.count)
            ? GameConfig.roundCasesToOpen[currentRound - 1]
            : 1
        currentPhase = .openingCases(remainingInRound: casesToOpen)
    }
    
    // 最终抉择：坚持原箱
    func keepOriginalCase() {
        guard let playerCase = playerCase else { return }
        revealAllCases()
        currentPhase = .gameOver(wonAmount: playerCase.amount, reason: .openedPlayerCase)
    }
    
    // 最终抉择：交换箱子
    func swapCase() {
        guard let lastCase = briefcases.first(where: { !$0.isOpened && !$0.isPlayerCase }) else { return }
        let won = lastCase.amount
        revealAllCases()
        currentPhase = .gameOver(wonAmount: won, reason: .swappedCase)
    }
    
    // 检查某个具体金额是否仍在游戏中（未开出）
    func isAmountActive(_ amount: Double) -> Bool {
        briefcases.contains(where: { $0.amount == amount && !$0.isOpened })
    }
    
    // 终局揭晓全部箱子
    private func revealAllCases() {
        for index in briefcases.indices {
            briefcases[index].isOpened = true
        }
    }
    
    // 银行家出价算法：基于场上未开箱金额的期望值与风险折价率
    private func calculateBankerOffer() -> Double {
        let activeCases = briefcases.filter { !$0.isOpened }
        let total = activeCases.reduce(0.0) { $0 + $1.amount }
        let expectedValue = total / Double(activeCases.count)
        
        // 折价因子：随着轮次增加，银行家的报价越接近期望值（模拟真实博弈）
        let roundFactor = min(0.95, 0.15 + (Double(currentRound) * 0.09))
        return (expectedValue * roundFactor).rounded()
    }
}
