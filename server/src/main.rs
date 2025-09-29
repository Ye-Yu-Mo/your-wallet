use axum::{routing::{get, post, patch, delete}, Router};
use dotenv::dotenv;
use std::net::SocketAddr;
use server::{config::Config, routes::{health_check, AppState, post_user, get_user, patch_user, delete_user_route, post_account, get_account, list_accounts, patch_account, delete_account_route, post_transaction, get_transaction, list_transactions, patch_transaction, delete_transaction_route, post_asset, get_asset, list_assets, patch_asset, delete_asset_route}, services::establish_connection};
use migration::{Migrator, MigratorTrait};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    dotenv().ok();

    let config = Config::from_env()?;

    let db = establish_connection(&config.database_url).await?;

    // Run database migrations on startup
    Migrator::up(&db, None).await?;

    let state = AppState { db: db.clone() };

    let app = server::build_router(state.clone());

    let host: std::net::IpAddr = config
        .server_host
        .parse()
        .unwrap_or_else(|_| "127.0.0.1".parse().expect("valid ip"));
    let addr = SocketAddr::from((host, config.server_port));
    println!("Server running on http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}
