use axum::{response::Json, http::StatusCode};
use serde_json::{json, Value};

pub async fn health_check() -> Result<Json<Value>, StatusCode> {
    Ok(Json(json!({
        "status": "ok",
        "message": "Wallet API is running",
        "timestamp": chrono::Utc::now().to_rfc3339()
    })))
}