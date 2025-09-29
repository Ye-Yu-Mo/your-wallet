pub mod health;
pub mod users;
pub mod accounts;
pub mod transactions;
pub mod assets;
pub mod auth;
pub mod error;

use sea_orm::DatabaseConnection;

#[derive(Clone)]
pub struct AppState {
    pub db: DatabaseConnection,
}

pub use health::*;
pub use users::*;
pub use accounts::*;
pub use transactions::*;
pub use assets::*;
pub use auth::*;
pub use error::*;
