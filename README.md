# 一掷千金 (Deal or No Deal)

SwiftUI 实现的《一掷千金》经典博彩游戏，支持 **macOS** 与 **iPadOS**。

[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20iPadOS-lightblue)]()
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)]()
[![Xcode](https://img.shields.io/badge/Xcode-15%2B-purple)]()

## 功能特性

- **26 个经典箱子**：涵盖 $0.01 ~ $1,000,000 的经典美版奖金池
- **多轮博弈**：7 轮逐步开箱（6→5→4→3→2→1→1），每轮后银行家报价
- **侧边栏奖金看板**：使用 `NavigationSplitView` 实现 macOS/iPadOS 原生侧边栏，实时标记哪些金额已被消除（蓝色低奖金池 / 橙色高奖金池）
- **结算揭晓**：接受报价、坚持原箱或交换箱子时，自动揭晓所有箱子的真实金额
- **跨平台兼容**：导航栏、背景色等 iOS 专属 API 通过 `#if os(iOS)` 条件编译，可在 macOS 上正常编译运行

## 技术栈

- SwiftUI（NavigationSplitView、LazyVGrid、List）
- Swift Concurrency（`@Observable` 宏）
- 纯 Swift UI，无 UIKit 依赖

## 项目结构

```
Deal/
├── DealApp.swift              # 应用入口
├── GameModel.swift            # 数据模型（Briefcase、GamePhase、GameConfig）
├── GameViewModel.swift        # 游戏逻辑（开箱、报价、结算）
├── ContentView.swift          # 主游戏界面
├── AmountBoardSidebar.swift   # 侧边栏奖金看板
└── README.md
```

## 构建与运行

### 前置要求

- Xcode 15+
- macOS 14+ (Sonoma) 或 iPadOS 17+

### 构建步骤

```bash
cd Deal
xcodebuild -project Deal.xcodeproj -scheme Deal -configuration Release build
```

或在 Xcode 中直接选择目标平台并运行。

## 下载

最新 macOS DMG 安装包：[Deal-v1.0.1.dmg](https://github.com/PungeMao-Mary/Deal-swift/releases/download/v1.0.1/Deal-v1.0.1.dmg)

## 游戏规则

1. 从 26 个箱子中选择一个作为你的专属箱
2. 按轮次逐步打开非专属箱，每轮后银行家给出报价
3. 可以选择接受报价（Deal）或继续游戏（No Deal）
4. 最后剩下两个箱子时，可选择坚持原箱或交换箱子

## 未实现功能

- 历史报价折线/走势记录
- 复盘盈亏对比提示（如"痛失 $900,000"）

## 许可证

MIT
