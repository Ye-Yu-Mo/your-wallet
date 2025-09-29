use axum::{extract::{Path, State, Query}, http::StatusCode, Json};
use serde::Deserialize;
use crate::routes::AppState;
use sea_orm::prelude::Decimal;
use crate::services::{create_asset, get_asset_by_id, find_assets_by_user, update_asset, delete_asset};
use std::str::FromStr;

#[derive(Deserialize)]
pub struct CreateAssetReq {
    pub user_id: i32,
    pub symbol: String,
    pub name: String,
    pub quantity: String,
    pub avg_price: String,
    pub asset_type: String,
}

#[derive(Deserialize)]
pub struct UpdateAssetReq {
    pub name: Option<String>,
    pub quantity: Option<String>,
    pub avg_price: Option<String>,
    pub asset_type: Option<String>,
}

#[derive(Deserialize)]
pub struct AssetsQuery { pub user_id: i32 }

pub async fn post_asset(State(state): State<AppState>, Json(body): Json<CreateAssetReq>) -> Result<(StatusCode, Json<crate::models::asset::Model>), (StatusCode, String)> {
    let qty = Decimal::from_str(&body.quantity).map_err(bad_request)?;
    let avg = Decimal::from_str(&body.avg_price).map_err(bad_request)?;
    let model = create_asset(&state.db, body.user_id, body.symbol, body.name, qty, avg, body.asset_type).await.map_err(internal)?;
    Ok((StatusCode::CREATED, Json(model)))
}

pub async fn get_asset(State(state): State<AppState>, Path(id): Path<i32>) -> Result<Json<crate::models::asset::Model>, (StatusCode, String)> {
    match get_asset_by_id(&state.db, id).await.map_err(internal)? {
        Some(m) => Ok(Json(m)),
        None => Err((StatusCode::NOT_FOUND, "asset not found".into())),
    }
}

pub async fn list_assets(State(state): State<AppState>, Query(q): Query<AssetsQuery>) -> Result<Json<Vec<crate::models::asset::Model>>, (StatusCode, String)> {
    let list = find_assets_by_user(&state.db, q.user_id).await.map_err(internal)?;
    Ok(Json(list))
}

pub async fn patch_asset(State(state): State<AppState>, Path(id): Path<i32>, Json(body): Json<UpdateAssetReq>) -> Result<Json<crate::models::asset::Model>, (StatusCode, String)> {
    let quantity = match body.quantity { Some(s) => Some(Decimal::from_str(&s).map_err(bad_request)?), None => None };
    let avg_price = match body.avg_price { Some(s) => Some(Decimal::from_str(&s).map_err(bad_request)?), None => None };
    match update_asset(&state.db, id, body.name, quantity, avg_price, body.asset_type).await.map_err(internal)? {
        Some(m) => Ok(Json(m)),
        None => Err((StatusCode::NOT_FOUND, "asset not found".into())),
    }
}

pub async fn delete_asset_route(State(state): State<AppState>, Path(id): Path<i32>) -> Result<StatusCode, (StatusCode, String)> {
    let affected = delete_asset(&state.db, id).await.map_err(internal)?;
    if affected == 0 { return Err((StatusCode::NOT_FOUND, "asset not found".into())); }
    Ok(StatusCode::NO_CONTENT)
}

fn internal<E: std::fmt::Display>(e: E) -> (StatusCode, String) {
    (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
}
fn bad_request<E: std::fmt::Display>(e: E) -> (StatusCode, String) {
    (StatusCode::BAD_REQUEST, e.to_string())
}
