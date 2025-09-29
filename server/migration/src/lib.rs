pub use sea_orm_migration::prelude::*;

mod m000001_create_tables;

pub struct Migrator;

impl MigratorTrait for Migrator {
    fn migrations() -> Vec<Box<dyn MigrationTrait>> {
        vec![Box::new(m000001_create_tables::Migration)]
    }
}
