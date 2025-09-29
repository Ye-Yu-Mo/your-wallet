use axum::{extract::{Path, State, Query}, http::StatusCode, Json};
use serde::Deserialize;
use crate::routes::AppState;
use sea_orm::prelude::Decimal;
use crate::services::{create_transaction, get_transaction_by_id, find_transactions_by_account, update_transaction, delete_transaction};
use std::str::FromStr;
use crate::routes::{ErrorResp, json_error, internal_json, bad_request_json};

#[derive(Deserialize)]
pub struct CreateTransactionReq {
    pub account_id: i32,
    pub transaction_type: String,
    pub amount: String,
    pub description: String,
    pub category: Option<String>,
}

#[derive(Deserialize)]
pub struct UpdateTransactionReq {
    pub transaction_type: Option<String>,
    pub amount: Option<String>,
    pub description: Option<String>,
    pub category: Option<String>,
}

#[derive(Deserialize)]
pub struct TransactionsQuery { pub account_id: i32 }

pub async fn post_transaction(State(state): State<AppState>, Json(body): Json<CreateTransactionReq>) -> Result<(StatusCode, Json<crate::models::transaction::Model>), (StatusCode, Json<ErrorResp>)> {
    let amount = Decimal::from_str(&body.amount).map_err(bad_request_json)?;
    let model = create_transaction(&state.db, body.account_id, body.transaction_type, amount, body.description, body.category).await.map_err(internal_json)?;
    Ok((StatusCode::CREATED, Json(model)))
}

pub async fn get_transaction(State(state): State<AppState>, Path(id): Path<i32>) -> Result<Json<crate::models::transaction::Model>, (StatusCode, Json<ErrorResp>)> {
    match get_transaction_by_id(&state.db, id).await.map_err(internal_json)? {
        Some(m) => Ok(Json(m)),
        None => Err(json_error(StatusCode::NOT_FOUND, "not_found", "transaction not found")),
    }
}

pub async fn list_transactions(State(state): State<AppState>, Query(q): Query<TransactionsQuery>) -> Result<Json<Vec<crate::models::transaction::Model>>, (StatusCode, Json<ErrorResp>)> {
    let list = find_transactions_by_account(&state.db, q.account_id).await.map_err(internal_json)?;
    Ok(Json(list))
}

pub async fn patch_transaction(State(state): State<AppState>, Path(id): Path<i32>, Json(body): Json<UpdateTransactionReq>) -> Result<Json<crate::models::transaction::Model>, (StatusCode, Json<ErrorResp>)> {
    let amount = match body.amount {
        Some(s) => Some(Decimal::from_str(&s).map_err(bad_request_json)?),
        None => None,
    };
    match update_transaction(&state.db, id, body.transaction_type, amount, body.description, body.category).await.map_err(internal_json)? {
        Some(m) => Ok(Json(m)),
        None => Err(json_error(StatusCode::NOT_FOUND, "not_found", "transaction not found")),
    }
}

pub async fn delete_transaction_route(State(state): State<AppState>, Path(id): Path<i32>) -> Result<StatusCode, (StatusCode, Json<ErrorResp>)> {
    let affected = delete_transaction(&state.db, id).await.map_err(internal_json)?;
    if affected == 0 { return Err(json_error(StatusCode::NOT_FOUND, "not_found", "transaction not found")); }
    Ok(StatusCode::NO_CONTENT)
}
