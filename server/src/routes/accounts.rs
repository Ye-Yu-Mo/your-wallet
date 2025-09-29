use axum::{extract::{Path, State, Query}, http::StatusCode, Json};
use serde::Deserialize;
use crate::routes::AppState;
use sea_orm::prelude::Decimal;
use crate::services::{create_account, get_account_by_id, find_accounts_by_user, update_account, delete_account};
use std::str::FromStr;
use crate::routes::{ErrorResp, json_error, internal_json, bad_request_json};

#[derive(Deserialize)]
pub struct CreateAccountReq {
    pub user_id: i32,
    pub name: String,
    pub account_type: String,
    pub balance: String,
    pub currency: String,
}

#[derive(Deserialize)]
pub struct UpdateAccountReq {
    pub name: Option<String>,
    pub account_type: Option<String>,
    pub balance: Option<String>,
    pub currency: Option<String>,
}

#[derive(Deserialize)]
pub struct AccountsQuery { pub user_id: i32 }

pub async fn post_account(State(state): State<AppState>, Json(body): Json<CreateAccountReq>) -> Result<(StatusCode, Json<crate::models::account::Model>), (StatusCode, Json<ErrorResp>)> {
    let bal = Decimal::from_str(&body.balance).map_err(bad_request_json)?;
    let model = create_account(&state.db, body.user_id, body.name, body.account_type, bal, body.currency).await.map_err(internal_json)?;
    Ok((StatusCode::CREATED, Json(model)))
}

pub async fn get_account(State(state): State<AppState>, Path(id): Path<i32>) -> Result<Json<crate::models::account::Model>, (StatusCode, Json<ErrorResp>)> {
    match get_account_by_id(&state.db, id).await.map_err(internal_json)? {
        Some(m) => Ok(Json(m)),
        None => Err(json_error(StatusCode::NOT_FOUND, "not_found", "account not found")),
    }
}

pub async fn list_accounts(State(state): State<AppState>, Query(q): Query<AccountsQuery>) -> Result<Json<Vec<crate::models::account::Model>>, (StatusCode, Json<ErrorResp>)> {
    let list = find_accounts_by_user(&state.db, q.user_id).await.map_err(internal_json)?;
    Ok(Json(list))
}

pub async fn patch_account(State(state): State<AppState>, Path(id): Path<i32>, Json(body): Json<UpdateAccountReq>) -> Result<Json<crate::models::account::Model>, (StatusCode, Json<ErrorResp>)> {
    let balance = match body.balance {
        Some(s) => Some(Decimal::from_str(&s).map_err(bad_request_json)?),
        None => None,
    };
    match update_account(&state.db, id, body.name, body.account_type, balance, body.currency).await.map_err(internal_json)? {
        Some(m) => Ok(Json(m)),
        None => Err(json_error(StatusCode::NOT_FOUND, "not_found", "account not found")),
    }
}

pub async fn delete_account_route(State(state): State<AppState>, Path(id): Path<i32>) -> Result<StatusCode, (StatusCode, Json<ErrorResp>)> {
    let affected = delete_account(&state.db, id).await.map_err(internal_json)?;
    if affected == 0 { return Err(json_error(StatusCode::NOT_FOUND, "not_found", "account not found")); }
    Ok(StatusCode::NO_CONTENT)
}
