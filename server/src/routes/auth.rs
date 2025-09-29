use axum::{extract::{State, Request}, http::StatusCode, middleware::Next, response::Response, Json};
use serde::{Deserialize, Serialize};
use crate::routes::AppState;
use crate::services::get_user_by_email;
use bcrypt::verify;
use jsonwebtoken::{encode, decode, EncodingKey, DecodingKey, Header, Validation};
use chrono::{Utc, Duration};
use crate::routes::{ErrorResp, json_error, internal_json};

#[derive(Deserialize)]
pub struct LoginReq {
    pub email: String,
    pub password: String,
}

#[derive(Serialize)]
pub struct LoginResp {
    pub token: String,
    pub refresh_token: String,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct Claims {
    sub: String,
    uid: i32,
    iat: i64,
    exp: i64,
}

#[derive(Deserialize)]
pub struct RefreshReq { pub refresh_token: String }

#[derive(Serialize)]
pub struct RefreshResp { pub token: String, pub refresh_token: String }

pub async fn auth_login(
    State(state): State<AppState>,
    Json(body): Json<LoginReq>,
) -> Result<Json<LoginResp>, (StatusCode, Json<ErrorResp>)> {
    // Basic input validation
    if body.email.trim().is_empty() || !is_valid_email(&body.email) {
        return Err(json_error(StatusCode::BAD_REQUEST, "invalid_request", "invalid email"));
    }
    if body.password.len() < 6 {
        return Err(json_error(StatusCode::BAD_REQUEST, "invalid_request", "password too short"));
    }

    // Find user by email
    let Some(user) = get_user_by_email(&state.db, &body.email)
        .await
        .map_err(internal_json)?
    else {
        return Err(json_error(StatusCode::UNAUTHORIZED, "invalid_credentials", "invalid credentials"));
    };

    // Verify password
    let ok = verify(&body.password, &user.password_hash).map_err(internal_json)?;
    if !ok {
        return Err(json_error(StatusCode::UNAUTHORIZED, "invalid_credentials", "invalid credentials"));
    }

    // Prepare tokens
    let token = create_access_token(user.id, &user.email).map_err(internal_json)?;
    let refresh = create_refresh_token(user.id, &user.email).map_err(internal_json)?;

    Ok(Json(LoginResp { token, refresh_token: refresh }))
}

fn is_valid_email(s: &str) -> bool {
    let s = s.trim();
    // minimal check; avoid pulling regex dep
    s.contains('@') && s.contains('.') && !s.ends_with('.')
}

pub fn verify_token(token: &str) -> Result<Claims, jsonwebtoken::errors::Error> {
    let secret = std::env::var("JWT_SECRET").unwrap_or_else(|_| "your-secret-key".to_string());
    let data = decode::<Claims>(token, &DecodingKey::from_secret(secret.as_bytes()), &Validation::default())?;
    Ok(data.claims)
}

pub async fn require_auth(
    State(_state): State<AppState>,
    mut req: Request,
    next: Next,
) -> Result<Response, (StatusCode, Json<ErrorResp>)> {
    // Allow skipping in development unless explicitly enabled
    let require = std::env::var("REQUIRE_AUTH").unwrap_or_else(|_| "false".into());
    let require = require.eq_ignore_ascii_case("true") || require == "1";
    if !require {
        return Ok(next.run(req).await);
    }

    // Allowlist public endpoints
    let path = req.uri().path();
    let method = req.method();
    let is_public = path == "/api/auth/login" || path == "/api/auth/refresh" || (path == "/api/users" && method == axum::http::Method::POST);
    if is_public {
        return Ok(next.run(req).await);
    }

    let Some(header_val) = req.headers().get(axum::http::header::AUTHORIZATION) else {
        return Err(json_error(StatusCode::UNAUTHORIZED, "missing_authorization", "missing Authorization header"));
    };
    let auth = header_val.to_str().unwrap_or_default();
    let prefix = "Bearer ";
    if !auth.starts_with(prefix) {
        return Err(json_error(StatusCode::UNAUTHORIZED, "invalid_authorization", "expected Bearer token"));
    }
    let token = &auth[prefix.len()..];
    let claims = verify_token(token).map_err(|_| json_error(StatusCode::UNAUTHORIZED, "invalid_token", "invalid or expired token"))?;

    // Attach claims for downstream handlers if needed
    req.extensions_mut().insert(claims);
    Ok(next.run(req).await)
}

fn create_access_token(uid: i32, email: &str) -> Result<String, jsonwebtoken::errors::Error> {
    let now = Utc::now();
    // Access token validity (e.g., 1 hour)
    let exp = now + Duration::hours(1);
    let claims = Claims { sub: email.to_string(), uid, iat: now.timestamp(), exp: exp.timestamp() };
    let secret = std::env::var("JWT_SECRET").unwrap_or_else(|_| "your-secret-key".to_string());
    encode(&Header::default(), &claims, &EncodingKey::from_secret(secret.as_bytes()))
}

fn create_refresh_token(uid: i32, email: &str) -> Result<String, jsonwebtoken::errors::Error> {
    let now = Utc::now();
    // Refresh token validity (e.g., 30 days)
    let exp = now + Duration::days(30);
    let claims = Claims { sub: email.to_string(), uid, iat: now.timestamp(), exp: exp.timestamp() };
    let secret = std::env::var("JWT_REFRESH_SECRET").unwrap_or_else(|_| std::env::var("JWT_SECRET").unwrap_or_else(|_| "your-secret-key".to_string()));
    encode(&Header::default(), &claims, &EncodingKey::from_secret(secret.as_bytes()))
}

fn verify_refresh(token: &str) -> Result<Claims, jsonwebtoken::errors::Error> {
    let secret = std::env::var("JWT_REFRESH_SECRET").unwrap_or_else(|_| std::env::var("JWT_SECRET").unwrap_or_else(|_| "your-secret-key".to_string()));
    let data = decode::<Claims>(token, &DecodingKey::from_secret(secret.as_bytes()), &Validation::default())?;
    Ok(data.claims)
}

pub async fn auth_refresh(Json(body): Json<RefreshReq>) -> Result<Json<RefreshResp>, (StatusCode, Json<ErrorResp>)> {
    if body.refresh_token.trim().is_empty() {
        return Err(json_error(StatusCode::BAD_REQUEST, "invalid_request", "missing refresh_token"));
    }
    let claims = verify_refresh(&body.refresh_token)
        .map_err(|_| json_error(StatusCode::UNAUTHORIZED, "invalid_token", "invalid or expired refresh token"))?;

    let token = create_access_token(claims.uid, &claims.sub).map_err(internal_json)?;
    let refresh_token = create_refresh_token(claims.uid, &claims.sub).map_err(internal_json)?;
    Ok(Json(RefreshResp { token, refresh_token }))
}
