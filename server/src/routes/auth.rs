use axum::{http::StatusCode, extract::State, Json};
use serde::{Deserialize, Serialize};
use crate::routes::AppState;
use crate::services::get_user_by_email;
use bcrypt::verify;
use jsonwebtoken::{encode, EncodingKey, Header};
use chrono::{Utc, Duration};

#[derive(Deserialize)]
pub struct LoginReq {
    pub email: String,
    pub password: String,
}

#[derive(Serialize)]
pub struct LoginResp {
    pub token: String,
}

#[derive(Serialize, Deserialize)]
struct Claims {
    sub: String,
    uid: i32,
    iat: i64,
    exp: i64,
}

pub async fn auth_login(
    State(state): State<AppState>,
    Json(body): Json<LoginReq>,
) -> Result<Json<LoginResp>, (StatusCode, String)> {
    // Find user by email
    let Some(user) = get_user_by_email(&state.db, &body.email)
        .await
        .map_err(internal)?
    else {
        return Err((StatusCode::UNAUTHORIZED, "invalid credentials".into()));
    };

    // Verify password
    let ok = verify(&body.password, &user.password_hash).map_err(internal)?;
    if !ok {
        return Err((StatusCode::UNAUTHORIZED, "invalid credentials".into()));
    }

    // Prepare JWT
    let now = Utc::now();
    let exp = now + Duration::days(7);
    let claims = Claims {
        sub: user.email.clone(),
        uid: user.id,
        iat: now.timestamp(),
        exp: exp.timestamp(),
    };

    let secret = std::env::var("JWT_SECRET").unwrap_or_else(|_| "your-secret-key".to_string());
    let token = encode(&Header::default(), &claims, &EncodingKey::from_secret(secret.as_bytes()))
        .map_err(internal)?;

    Ok(Json(LoginResp { token }))
}

fn internal<E: std::fmt::Display>(e: E) -> (StatusCode, String) {
    (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
}

