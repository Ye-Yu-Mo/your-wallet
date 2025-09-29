use axum::{extract::{Path, State, Query}, http::StatusCode, Json};
use serde::Deserialize;
use crate::routes::AppState;
use sea_orm::prelude::Decimal;
use crate::services::{create_account, get_account_by_id, find_accounts_by_user, update_account, delete_account};
use std::str::FromStr;

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

pub async fn post_account(State(state): State<AppState>, Json(body): Json<CreateAccountReq>) -> Result<(StatusCode, Json<crate::models::account::Model>), (StatusCode, String)> {
    let bal = Decimal::from_str(&body.balance).map_err(bad_request)?;
    let model = create_account(&state.db, body.user_id, body.name, body.account_type, bal, body.currency).await.map_err(internal)?;
    Ok((StatusCode::CREATED, Json(model)))
}

pub async fn get_account(State(state): State<AppState>, Path(id): Path<i32>) -> Result<Json<crate::models::account::Model>, (StatusCode, String)> {
    match get_account_by_id(&state.db, id).await.map_err(internal)? {
        Some(m) => Ok(Json(m)),
        None => Err((StatusCode::NOT_FOUND, "account not found".into())),
    }
}

pub async fn list_accounts(State(state): State<AppState>, Query(q): Query<AccountsQuery>) -> Result<Json<Vec<crate::models::account::Model>>, (StatusCode, String)> {
    let list = find_accounts_by_user(&state.db, q.user_id).await.map_err(internal)?;
    Ok(Json(list))
}

pub async fn patch_account(State(state): State<AppState>, Path(id): Path<i32>, Json(body): Json<UpdateAccountReq>) -> Result<Json<crate::models::account::Model>, (StatusCode, String)> {
    let balance = match body.balance {
        Some(s) => Some(Decimal::from_str(&s).map_err(bad_request)?),
        None => None,
    };
    match update_account(&state.db, id, body.name, body.account_type, balance, body.currency).await.map_err(internal)? {
        Some(m) => Ok(Json(m)),
        None => Err((StatusCode::NOT_FOUND, "account not found".into())),
    }
}

pub async fn delete_account_route(State(state): State<AppState>, Path(id): Path<i32>) -> Result<StatusCode, (StatusCode, String)> {
    let affected = delete_account(&state.db, id).await.map_err(internal)?;
    if affected == 0 { return Err((StatusCode::NOT_FOUND, "account not found".into())); }
    Ok(StatusCode::NO_CONTENT)
}

fn internal<E: std::fmt::Display>(e: E) -> (StatusCode, String) {
    (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
}
fn bad_request<E: std::fmt::Display>(e: E) -> (StatusCode, String) {
    (StatusCode::BAD_REQUEST, e.to_string())
}
