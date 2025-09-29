# Wallet API 文档

- 基础地址: `http://127.0.0.1:9999`
- 前缀: `/api`
- 认证: 无（开发期），请勿对公网暴露
- 请求类型: `application/json`
- 时间格式: RFC3339（例: `2025-09-28T10:50:00Z`）
- Decimal 字段: 建议以字符串传递（如 `"12.34"`），以避免浮点精度问题；响应中十进制可能序列化为字符串

## 健康检查
GET `/health`
- 200 OK
- 响应示例:
```json
{"status":"ok","message":"Wallet API is running","timestamp":"2025-09-28T10:50:00Z"}
```

## 用户 Users
响应模型 UserOut
- `id` i32
- `username` string
- `email` string
- `created_at` string(RFC3339)
- `updated_at` string(RFC3339)

POST `/api/users`
- 请求体: `{ "username":"alice", "email":"a@example.com", "password":"secret" }`
- 201 Created → UserOut
- 409 Conflict → 文本 `username already exists`

GET `/api/users/{id}`
- 200 OK → UserOut
- 404 Not Found

PATCH `/api/users/{id}`
- 请求体(任意子集): `{ "username":"...", "email":"...", "password":"..." }`
- 200 OK → UserOut（若携带 password，将进行加密保存）
- 404 Not Found

DELETE `/api/users/{id}`
- 204 No Content
- 404 Not Found

示例（cURL）
```bash
curl -X POST http://127.0.0.1:9999/api/users \
  -H 'content-type: application/json' \
  -d '{"username":"alice","email":"a@example.com","password":"secret"}'

curl http://127.0.0.1:9999/api/users/1
```

## 账户 Accounts
响应模型 Account
- `id` i32
- `user_id` i32
- `name` string
- `account_type` string
- `balance` decimal-string
- `currency` string
- `created_at` string(RFC3339)

POST `/api/accounts`
- 请求体: `{ "user_id":1, "name":"Cash", "account_type":"cash", "balance":"0", "currency":"CNY" }`
- 201 Created → Account
- 外键无效可能 500（文本错误）

GET `/api/accounts/{id}`
- 200 OK → Account
- 404 Not Found

GET `/api/accounts?user_id={user_id}`
- 200 OK → Account[]

PATCH `/api/accounts/{id}`
- 请求体(任意子集): `{ "name":"...", "account_type":"...", "balance":"123.45", "currency":"..." }`
- 200 OK → Account
- 404 Not Found

DELETE `/api/accounts/{id}`
- 204 No Content
- 404 Not Found

示例（cURL）
```bash
curl -X POST http://127.0.0.1:9999/api/accounts \
  -H 'content-type: application/json' \
  -d '{"user_id":1,"name":"Cash","account_type":"cash","balance":"0","currency":"CNY"}'

curl 'http://127.0.0.1:9999/api/accounts?user_id=1'
```

## 流水 Transactions
响应模型 Transaction
- `id` i32
- `account_id` i32
- `transaction_type` string（`income` | `expense` | `transfer`）
- `amount` decimal-string
- `description` string
- `category` string|null
- `created_at` string(RFC3339)

POST `/api/transactions`
- 请求体: `{ "account_id":1, "transaction_type":"expense", "amount":"12.34", "description":"lunch", "category":"food" }`
- 201 Created → Transaction

GET `/api/transactions/{id}`
- 200 OK → Transaction
- 404 Not Found

GET `/api/transactions?account_id={account_id}`
- 200 OK → Transaction[]

PATCH `/api/transactions/{id}`
- 请求体(任意子集): `{ "transaction_type":"income", "amount":"5.55", "description":"...", "category":"..." }`
- 200 OK → Transaction
- 404 Not Found

DELETE `/api/transactions/{id}`
- 204 No Content
- 404 Not Found

示例（cURL）
```bash
curl -X POST http://127.0.0.1:9999/api/transactions \
  -H 'content-type: application/json' \
  -d '{"account_id":1,"transaction_type":"expense","amount":"12.34","description":"coffee","category":"food"}'
```

## 资产 Assets
响应模型 Asset
- `id` i32
- `user_id` i32
- `symbol` string
- `name` string
- `quantity` decimal-string
- `avg_price` decimal-string
- `asset_type` string
- `created_at` string(RFC3339)
- `updated_at` string(RFC3339)
- 唯一约束: (`user_id`, `symbol`)

POST `/api/assets`
- 请求体: `{ "user_id":1, "symbol":"AAPL", "name":"Apple", "quantity":"10", "avg_price":"180", "asset_type":"stock" }`
- 201 Created → Asset
- 可能 409（唯一约束冲突，错误文本）

GET `/api/assets/{id}`
- 200 OK → Asset
- 404 Not Found

GET `/api/assets?user_id={user_id}`
- 200 OK → Asset[]

PATCH `/api/assets/{id}`
- 请求体(任意子集): `{ "name":"...", "quantity":"12", "avg_price":"181.50", "asset_type":"stock" }`
- 200 OK → Asset
- 404 Not Found

DELETE `/api/assets/{id}`
- 204 No Content
- 404 Not Found

示例（cURL）
```bash
curl -X POST http://127.0.0.1:9999/api/assets \
  -H 'content-type: application/json' \
  -d '{"user_id":1,"symbol":"AAPL","name":"Apple","quantity":"10","avg_price":"180","asset_type":"stock"}'
```

## 错误处理
- 错误响应目前为纯文本（非 JSON）。
- 常见状态码
  - 400 Bad Request: 十进制解析失败（如金额格式非法）
  - 404 Not Found: 资源不存在
  - 409 Conflict: 业务唯一性冲突（例如用户名已存在）
  - 500 Internal Server Error: 数据库/服务器错误

## 快速开始
1) 启动服务（自动迁移）
```bash
cd server
cargo run
```
2) 健康检查
```bash
curl http://127.0.0.1:9999/health
```
3) 典型流程
```bash
# 创建用户
curl -X POST http://127.0.0.1:9999/api/users \
  -H 'content-type: application/json' \
  -d '{"username":"alice","email":"a@example.com","password":"secret"}'
# 创建账户
curl -X POST http://127.0.0.1:9999/api/accounts \
  -H 'content-type: application/json' \
  -d '{"user_id":1,"name":"Cash","account_type":"cash","balance":"0","currency":"CNY"}'
# 记一笔支出
curl -X POST http://127.0.0.1:9999/api/transactions \
  -H 'content-type: application/json' \
  -d '{"account_id":1,"transaction_type":"expense","amount":"12.34","description":"lunch","category":"food"}'
# 添加一条资产
curl -X POST http://127.0.0.1:9999/api/assets \
  -H 'content-type: application/json' \
  -d '{"user_id":1,"symbol":"AAPL","name":"Apple","quantity":"10","avg_price":"180","asset_type":"stock"}'
```

> 注意：当前无鉴权，仅用于开发联调。若用于生产，请加入 JWT 鉴权、CORS、日志与更严格的错误格式（JSON）。

