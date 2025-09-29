# Your Wallet - 个人财务管理应用

一个现代化的个人财务管理应用，支持记账、投资追踪、资产管理和定投计划。使用 Flutter 前端和 Rust 后端构建，数据存储在 SQLite 数据库中。

## 项目概述

Your Wallet 旨在提供全面的个人财务管理解决方案，主要功能包括：

- **记账管理**: 支持收入、支出、转账记录，多账户管理
- **投资追踪**: 手动录入持仓，实时价格更新，收益分析
- **可视化分析**: 资产分布图表，收支趋势分析，净资产变化
- **定投计划**: 自动定投执行，成本均摊分析
- **双人共享**: 情侣/夫妻共享账户，权限管理
- **再平衡提醒**: 资产配置偏差检测，调整建议
- **数据同步**: 离线支持，多端数据同步

## 技术架构

### 后端 (Rust)
- **Web框架**: Axum
- **数据库**: SQLite + SeaORM
- **认证**: JWT + bcrypt
- **异步运行时**: Tokio

### 前端 (Flutter)
- **状态管理**: Provider
- **网络请求**: Dio
- **图表**: fl_chart
- **路由**: go_router
- **本地存储**: SharedPreferences

### 开发工具
- **容器化**: Docker
- **CI/CD**: GitHub Actions
- **代码质量**: Clippy, dartanalyzer

## 项目结构

```
your-wallet/
├── server/                 # Rust 后端
│   ├── src/
│   │   ├── config/        # 配置管理
│   │   ├── models/        # 数据模型
│   │   ├── routes/        # API 路由
│   │   ├── services/      # 业务逻辑
│   │   ├── lib.rs         # 库入口
│   │   └── main.rs        # 应用入口
│   ├── Cargo.toml         # Rust 依赖
│   └── .env               # 环境配置
├── client/                # Flutter 前端
│   ├── lib/
│   │   ├── models/        # 数据模型
│   │   ├── services/      # API 服务
│   │   ├── providers/     # 状态管理
│   │   ├── screens/       # 页面组件
│   │   └── widgets/       # UI 组件
│   └── pubspec.yaml       # Flutter 依赖
├── TODO.md                # 开发计划
└── README.md              # 项目说明
```

## 数据库设计

### 核心表结构

- **users**: 用户信息 (id, username, email, password_hash)
- **accounts**: 账户信息 (id, user_id, name, account_type, balance)
- **transactions**: 交易记录 (id, account_id, type, amount, description)
- **assets**: 资产持仓 (id, user_id, symbol, quantity, avg_price)
- **asset_prices**: 行情数据 (id, symbol, price, updated_at)

## 开发阶段

项目分为 5 个开发阶段：

### 阶段 0: 准备期 (1周)
搭建基础环境和项目框架

### 阶段 1: 核心功能 MVP (2周)
实现单用户记账和资产管理

### 阶段 2: 可视化与投资计划 (2周)
添加图表展示和定投功能

### 阶段 3: 双人绑定与共享账户 (2周)
实现多用户协作功能

### 阶段 4: 行情数据接入与再平衡提醒 (2周)
接入实时行情，提供投资建议

### 阶段 5: 优化与增强 (2-4周)
性能优化，安全加强，生产级特性

## 快速开始

### 环境要求

- Rust 1.70+
- Flutter 3.0+
- SQLite 3.0+

### 后端启动

```bash
cd server
cargo run
```

服务将在 http://127.0.0.1:9999 启动

### 前端启动

```bash
cd client
flutter run
```

### 环境配置

复制 `server/.env.example` 到 `server/.env` 并配置：

```env
DATABASE_URL=sqlite:./wallet.db
JWT_SECRET=your-secret-key
SERVER_HOST=127.0.0.1
SERVER_PORT=9999
```

## API 文档

### 健康检查
```
GET /health
```

返回服务状态信息

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/新功能`)
3. 提交更改 (`git commit -am '添加新功能'`)
4. 推送到分支 (`git push origin feature/新功能`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 联系方式

如有问题或建议，请通过 GitHub Issues 联系我们。