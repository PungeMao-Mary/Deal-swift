import Foundation

struct Briefcase: Identifiable {
    let id: Int             // 箱子编号 1-26
    let amount: Double      // 隐藏的金额
    var isOpened: Bool = false
    var isPlayerCase: Bool = false
}

enum GamePhase: Equatable {
    case selectInitialCase              // 选择自己的箱子
    case openingCases(remainingInRound: Int) // 逐个开箱阶段
    case bankerOffer(offer: Double)     // 银行家报价阶段
    case finalDecision                  // 最终二选一（换箱还是坚持原箱）
    case gameOver(wonAmount: Double, reason: GameOverReason)
}

enum GameOverReason {
    case acceptedDeal
    case openedPlayerCase
    case swappedCase
}

enum GameConfig {
    // 经典的 26 个美版奖金池（单位：美元）
    static let classicAmounts: [Double] = [
        0.01, 1, 5, 10, 25, 50, 75, 100,
        200, 300, 400, 500, 750, 1000,
        5000, 10000, 25000, 50000, 75000, 100000,
        200000, 300000, 400000, 500000, 750000, 1000000
    ]
    
    // 每一轮需要开启的箱子数量：第1轮开6个，第2轮开5个...
    static let roundCasesToOpen = [6, 5, 4, 3, 2, 1, 1, 1, 1]
}
