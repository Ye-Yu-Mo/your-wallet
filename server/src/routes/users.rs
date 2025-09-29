use axum::{extract::{Path, State}, http::StatusCode, Json};
use serde::{Deserialize, Serialize};
use crate::routes::AppState;
use crate::services::{create_user, get_user_by_id, get_user_by_username, get_user_by_email, update_user, update_user_password, delete_user};
use bcrypt::{hash, DEFAULT_COST};
use crate::routes::{ErrorResp, json_error, internal_json};

#[derive(Deserialize)]
pub struct CreateUserReq {
    pub username: String,
    pub email: String,
    pub password: String,
}

#[derive(Deserialize)]
pub struct UpdateUserReq {
    pub username: Option<String>,
    pub email: Option<String>,
    pub password: Option<String>,
}

#[derive(Serialize)]
pub struct UserOut {
    pub id: i32,
    pub username: String,
    pub email: String,
    pub created_at: String,
    pub updated_at: String,
}

impl From<crate::models::user::Model> for UserOut {
    fn from(m: crate::models::user::Model) -> Self {
        UserOut {
            id: m.id,
            username: m.username,
            email: m.email,
            created_at: m.created_at.to_rfc3339(),
            updated_at: m.updated_at.to_rfc3339(),
        }
    }
}

pub async fn post_user(State(state): State<AppState>, Json(body): Json<CreateUserReq>) -> Result<(StatusCode, Json<UserOut>), (StatusCode, Json<ErrorResp>)> {
    // basic uniqueness check for user-friendly message
    if let Ok(Some(_)) = get_user_by_username(&state.db, &body.username).await {
        return Err(json_error(StatusCode::CONFLICT, "conflict", "username already exists"));
    }
    if let Ok(Some(_)) = get_user_by_email(&state.db, &body.email).await {
        return Err(json_error(StatusCode::CONFLICT, "conflict", "email already exists"));
    }
    let password_hash = hash(&body.password, DEFAULT_COST).map_err(internal_json)?;
    let model = create_user(&state.db, body.username, body.email, password_hash).await.map_err(internal_json)?;
    Ok((StatusCode::CREATED, Json(model.into())))
}

pub async fn get_user(State(state): State<AppState>, Path(id): Path<i32>) -> Result<Json<UserOut>, (StatusCode, Json<ErrorResp>)> {
    match get_user_by_id(&state.db, id).await.map_err(internal_json)? {
        Some(m) => Ok(Json(m.into())),
        None => Err(json_error(StatusCode::NOT_FOUND, "not_found", "user not found")),
    }
}

pub async fn patch_user(State(state): State<AppState>, Path(id): Path<i32>, Json(body): Json<UpdateUserReq>) -> Result<Json<UserOut>, (StatusCode, Json<ErrorResp>)> {
    if let Some(ref email) = body.email {
        if let Ok(Some(existing)) = get_user_by_email(&state.db, email).await {
            if existing.id != id {
                return Err(json_error(StatusCode::CONFLICT, "conflict", "email already exists"));
            }
        }
    }
    if let Some(pw) = body.password.clone() {
        let hashed = hash(&pw, DEFAULT_COST).map_err(internal_json)?;
        let _ = update_user_password(&state.db, id, hashed).await.map_err(internal_json)?;
    }
    match update_user(&state.db, id, body.username, body.email).await.map_err(internal_json)? {
        Some(m) => Ok(Json(m.into())),
        None => Err(json_error(StatusCode::NOT_FOUND, "not_found", "user not found")),
    }
}

pub async fn delete_user_route(State(state): State<AppState>, Path(id): Path<i32>) -> Result<StatusCode, (StatusCode, Json<ErrorResp>)> {
    let affected = delete_user(&state.db, id).await.map_err(internal_json)?;
    if affected == 0 { return Err(json_error(StatusCode::NOT_FOUND, "not_found", "user not found")); }
    Ok(StatusCode::NO_CONTENT)
}
