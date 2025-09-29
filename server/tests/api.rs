use axum::{http::{Request, StatusCode}, body::Body};
use migration::MigratorTrait;
use tower::ServiceExt; // for `oneshot`

#[tokio::test]
async fn health_works() {
    let db = sea_orm::Database::connect("sqlite::memory:").await.unwrap();
    migration::Migrator::up(&db, None).await.unwrap();
    let state = server::routes::AppState { db };
    let app = server::build_router(state);

    let res = app
        .clone()
        .oneshot(Request::builder().uri("/health").body(Body::empty()).unwrap())
        .await
        .unwrap();

    assert_eq!(res.status(), StatusCode::OK);
}

#[tokio::test]
async fn users_crud() {
    use http_body_util::BodyExt; // for collect
    use serde_json::{json, Value};

    let db = sea_orm::Database::connect("sqlite::memory:").await.unwrap();
    migration::Migrator::up(&db, None).await.unwrap();
    let state = server::routes::AppState { db };
    let app = server::build_router(state);

    // create
    let body = json!({
        "username": "tester",
        "email": "t@example.com",
        "password": "secret"
    })
    .to_string();
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/users")
                .header("content-type", "application/json")
                .body(Body::from(body))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::CREATED);
    let bytes = res.into_body().collect().await.unwrap().to_bytes();
    let created: Value = serde_json::from_slice(&bytes).unwrap();
    let id = created["id"].as_i64().unwrap() as i32;

    // get
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .uri(format!("/api/users/{}", id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // patch
    let body = json!({ "email": "new@example.com" }).to_string();
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .method("PATCH")
                .uri(format!("/api/users/{}", id))
                .header("content-type", "application/json")
                .body(Body::from(body))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // delete
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .method("DELETE")
                .uri(format!("/api/users/{}", id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::NO_CONTENT);

    // get 404
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .uri(format!("/api/users/{}", id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::NOT_FOUND);
}

#[tokio::test]
async fn accounts_crud() {
    use http_body_util::BodyExt; // for collect
    use serde_json::{json, Value};

    let db = sea_orm::Database::connect("sqlite::memory:").await.unwrap();
    migration::Migrator::up(&db, None).await.unwrap();
    let state = server::routes::AppState { db };
    let app = server::build_router(state);

    // create user for FK
    let body = json!({"username":"u1","email":"u1@example.com","password":"p"}).to_string();
    let res = app.clone().oneshot(
        Request::builder().method("POST").uri("/api/users")
            .header("content-type","application/json")
            .body(Body::from(body)).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::CREATED);
    let bytes = res.into_body().collect().await.unwrap().to_bytes();
    let created_user: Value = serde_json::from_slice(&bytes).unwrap();
    let user_id = created_user["id"].as_i64().unwrap() as i32;

    // create account
    let body = json!({
        "user_id": user_id,
        "name": "Cash",
        "account_type": "cash",
        "balance": "0",
        "currency": "CNY"
    }).to_string();
    let res = app.clone().oneshot(
        Request::builder().method("POST").uri("/api/accounts")
            .header("content-type","application/json")
            .body(Body::from(body)).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::CREATED);
    let bytes = res.into_body().collect().await.unwrap().to_bytes();
    let created_acc: Value = serde_json::from_slice(&bytes).unwrap();
    let acc_id = created_acc["id"].as_i64().unwrap() as i32;

    // get
    let res = app.clone().oneshot(
        Request::builder().uri(format!("/api/accounts/{}", acc_id))
            .body(Body::empty()).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // list
    let res = app.clone().oneshot(
        Request::builder().uri(format!("/api/accounts?user_id={}", user_id))
            .body(Body::empty()).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // patch
    let body = json!({"balance": "100.50"}).to_string();
    let res = app.clone().oneshot(
        Request::builder().method("PATCH").uri(format!("/api/accounts/{}", acc_id))
            .header("content-type","application/json")
            .body(Body::from(body)).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // delete
    let res = app.clone().oneshot(
        Request::builder().method("DELETE").uri(format!("/api/accounts/{}", acc_id))
            .body(Body::empty()).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::NO_CONTENT);
}

#[tokio::test]
async fn transactions_crud() {
    use http_body_util::BodyExt; // for collect
    use serde_json::{json, Value};

    let db = sea_orm::Database::connect("sqlite::memory:").await.unwrap();
    migration::Migrator::up(&db, None).await.unwrap();
    let state = server::routes::AppState { db };
    let app = server::build_router(state);

    // user + account
    let body = json!({"username":"u2","email":"u2@example.com","password":"p"}).to_string();
    let res = app.clone().oneshot(
        Request::builder().method("POST").uri("/api/users")
            .header("content-type","application/json")
            .body(Body::from(body)).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::CREATED);
    let bytes = res.into_body().collect().await.unwrap().to_bytes();
    let user_id = serde_json::from_slice::<Value>(&bytes).unwrap()["id"].as_i64().unwrap() as i32;
    let body = json!({
        "user_id": user_id,
        "name": "Wallet",
        "account_type": "cash",
        "balance": "0",
        "currency": "USD"
    }).to_string();
    let res = app.clone().oneshot(
        Request::builder().method("POST").uri("/api/accounts")
            .header("content-type","application/json")
            .body(Body::from(body)).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::CREATED);
    let bytes = res.into_body().collect().await.unwrap().to_bytes();
    let acc_id = serde_json::from_slice::<Value>(&bytes).unwrap()["id"].as_i64().unwrap() as i32;

    // create transaction
    let body = json!({
        "account_id": acc_id,
        "transaction_type": "expense",
        "amount": "12.34",
        "description": "coffee",
        "category": "food"
    }).to_string();
    let res = app.clone().oneshot(
        Request::builder().method("POST").uri("/api/transactions")
            .header("content-type","application/json")
            .body(Body::from(body)).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::CREATED);
    let bytes = res.into_body().collect().await.unwrap().to_bytes();
    let tx_id = serde_json::from_slice::<Value>(&bytes).unwrap()["id"].as_i64().unwrap() as i32;

    // get
    let res = app.clone().oneshot(
        Request::builder().uri(format!("/api/transactions/{}", tx_id))
            .body(Body::empty()).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // list
    let res = app.clone().oneshot(
        Request::builder().uri(format!("/api/transactions?account_id={}", acc_id))
            .body(Body::empty()).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // patch
    let body = json!({"amount": "5.55"}).to_string();
    let res = app.clone().oneshot(
        Request::builder().method("PATCH").uri(format!("/api/transactions/{}", tx_id))
            .header("content-type","application/json")
            .body(Body::from(body)).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // delete
    let res = app.clone().oneshot(
        Request::builder().method("DELETE").uri(format!("/api/transactions/{}", tx_id))
            .body(Body::empty()).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::NO_CONTENT);
}

#[tokio::test]
async fn assets_crud() {
    use http_body_util::BodyExt; // for collect
    use serde_json::{json, Value};

    let db = sea_orm::Database::connect("sqlite::memory:").await.unwrap();
    migration::Migrator::up(&db, None).await.unwrap();
    let state = server::routes::AppState { db };
    let app = server::build_router(state);

    // user
    let body = json!({"username":"u3","email":"u3@example.com","password":"p"}).to_string();
    let res = app.clone().oneshot(
        Request::builder().method("POST").uri("/api/users")
            .header("content-type","application/json")
            .body(Body::from(body)).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::CREATED);
    let bytes = res.into_body().collect().await.unwrap().to_bytes();
    let user_id = serde_json::from_slice::<Value>(&bytes).unwrap()["id"].as_i64().unwrap() as i32;

    // create asset
    let body = json!({
        "user_id": user_id,
        "symbol": "AAPL",
        "name": "Apple",
        "quantity": "10",
        "avg_price": "180",
        "asset_type": "stock"
    }).to_string();
    let res = app.clone().oneshot(
        Request::builder().method("POST").uri("/api/assets")
            .header("content-type","application/json")
            .body(Body::from(body)).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::CREATED);
    let bytes = res.into_body().collect().await.unwrap().to_bytes();
    let asset_id = serde_json::from_slice::<Value>(&bytes).unwrap()["id"].as_i64().unwrap() as i32;

    // get
    let res = app.clone().oneshot(
        Request::builder().uri(format!("/api/assets/{}", asset_id))
            .body(Body::empty()).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // list by user
    let res = app.clone().oneshot(
        Request::builder().uri(format!("/api/assets?user_id={}", user_id))
            .body(Body::empty()).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // patch
    let body = json!({"quantity": "12"}).to_string();
    let res = app.clone().oneshot(
        Request::builder().method("PATCH").uri(format!("/api/assets/{}", asset_id))
            .header("content-type","application/json")
            .body(Body::from(body)).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // delete
    let res = app.clone().oneshot(
        Request::builder().method("DELETE").uri(format!("/api/assets/{}", asset_id))
            .body(Body::empty()).unwrap()
    ).await.unwrap();
    assert_eq!(res.status(), StatusCode::NO_CONTENT);
}
