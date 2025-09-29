use migration::{Migrator, MigratorTrait};
use sea_orm_migration::prelude::*;
use std::env;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Prefer env var; fallback to sqlite in parent directory
    let database_url = env::var("DATABASE_URL").unwrap_or_else(|_| "sqlite:../wallet.db".to_string());
    println!("Running migrations on {}", database_url);

    let db = Database::connect(&database_url).await?;
    Migrator::up(&db, None).await?;
    println!("Migrations applied successfully");

    Ok(())
}

