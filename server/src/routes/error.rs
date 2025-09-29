use axum::{http::StatusCode, Json};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ErrorResp {
    pub error: String,
    pub code: String,
}

pub fn json_error(status: StatusCode, code: &str, msg: impl Into<String>) -> (StatusCode, Json<ErrorResp>) {
    (status, Json(ErrorResp { error: msg.into(), code: code.to_string() }))
}

pub fn internal_json<E: std::fmt::Display>(e: E) -> (StatusCode, Json<ErrorResp>) {
    json_error(StatusCode::INTERNAL_SERVER_ERROR, "internal", e.to_string())
}

pub fn bad_request_json<E: std::fmt::Display>(e: E) -> (StatusCode, Json<ErrorResp>) {
    json_error(StatusCode::BAD_REQUEST, "bad_request", e.to_string())
}

