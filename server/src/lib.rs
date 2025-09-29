pub mod config;
pub mod models;
pub mod routes;
pub mod services;

pub use config::*;
pub use models::*;
pub use routes::*;
pub use services::*;

use axum::{routing::{get, post, patch, delete}, Router};

// Build the application router so tests can instantiate it.
pub fn build_router(state: routes::AppState) -> Router {
    let api = Router::new()
        // users
        .route("/users", post(routes::post_user))
        .route("/users/{id}", get(routes::get_user).patch(routes::patch_user).delete(routes::delete_user_route))
        // auth
        .route("/auth/login", post(routes::auth_login))
        // accounts
        .route("/accounts", post(routes::post_account).get(routes::list_accounts))
        .route("/accounts/{id}", get(routes::get_account).patch(routes::patch_account).delete(routes::delete_account_route))
        // transactions
        .route("/transactions", post(routes::post_transaction).get(routes::list_transactions))
        .route("/transactions/{id}", get(routes::get_transaction).patch(routes::patch_transaction).delete(routes::delete_transaction_route))
        // assets
        .route("/assets", post(routes::post_asset).get(routes::list_assets))
        .route("/assets/{id}", get(routes::get_asset).patch(routes::patch_asset).delete(routes::delete_asset_route))
        .with_state(state.clone());

    Router::new()
        .route("/health", get(routes::health_check))
        .nest("/api", api)
        .with_state(state)
}
