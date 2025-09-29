use axum::{extract::{Path, State}, http::StatusCode, Json};
use serde::{Deserialize, Serialize};
use crate::routes::AppState;
use crate::services::{create_user, get_user_by_id, get_user_by_username, get_user_by_email, update_user, update_user_password, delete_user};
use bcrypt::{hash, DEFAULT_COST};

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

pub async fn post_user(State(state): State<AppState>, Json(body): Json<CreateUserReq>) -> Result<(StatusCode, Json<UserOut>), (StatusCode, String)> {
    // basic uniqueness check for user-friendly message
    if let Ok(Some(_)) = get_user_by_username(&state.db, &body.username).await {
        return Err((StatusCode::CONFLICT, "username already exists".into()));
    }
    if let Ok(Some(_)) = get_user_by_email(&state.db, &body.email).await {
        return Err((StatusCode::CONFLICT, "email already exists".into()));
    }
    let password_hash = hash(&body.password, DEFAULT_COST).map_err(internal)?;
    let model = create_user(&state.db, body.username, body.email, password_hash).await.map_err(internal)?;
    Ok((StatusCode::CREATED, Json(model.into())))
}

pub async fn get_user(State(state): State<AppState>, Path(id): Path<i32>) -> Result<Json<UserOut>, (StatusCode, String)> {
    match get_user_by_id(&state.db, id).await.map_err(internal)? {
        Some(m) => Ok(Json(m.into())),
        None => Err((StatusCode::NOT_FOUND, "user not found".into())),
    }
}

pub async fn patch_user(State(state): State<AppState>, Path(id): Path<i32>, Json(body): Json<UpdateUserReq>) -> Result<Json<UserOut>, (StatusCode, String)> {
    if let Some(pw) = body.password.clone() {
        let hashed = hash(&pw, DEFAULT_COST).map_err(internal)?;
        let _ = update_user_password(&state.db, id, hashed).await.map_err(internal)?;
    }
    match update_user(&state.db, id, body.username, body.email).await.map_err(internal)? {
        Some(m) => Ok(Json(m.into())),
        None => Err((StatusCode::NOT_FOUND, "user not found".into())),
    }
}

pub async fn delete_user_route(State(state): State<AppState>, Path(id): Path<i32>) -> Result<StatusCode, (StatusCode, String)> {
    let affected = delete_user(&state.db, id).await.map_err(internal)?;
    if affected == 0 { return Err((StatusCode::NOT_FOUND, "user not found".into())); }
    Ok(StatusCode::NO_CONTENT)
}

fn internal<E: std::fmt::Display>(e: E) -> (StatusCode, String) {
    (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
}
