use sea_orm::{ActiveModelTrait, ColumnTrait, DatabaseConnection, EntityTrait, QueryFilter, Set};
use crate::models::transaction;
use sea_orm::prelude::Decimal;

pub async fn create_transaction(
    db: &DatabaseConnection,
    account_id: i32,
    transaction_type: String,
    amount: Decimal,
    description: String,
    category: Option<String>,
) -> Result<transaction::Model, sea_orm::DbErr> {
    let active = transaction::ActiveModel {
        account_id: Set(account_id),
        transaction_type: Set(transaction_type),
        amount: Set(amount),
        description: Set(description),
        category: Set(category),
        ..Default::default()
    };
    active.insert(db).await
}

pub async fn get_transaction_by_id(
    db: &DatabaseConnection,
    id: i32,
) -> Result<Option<transaction::Model>, sea_orm::DbErr> {
    transaction::Entity::find_by_id(id).one(db).await
}

pub async fn find_transactions_by_account(
    db: &DatabaseConnection,
    account_id: i32,
) -> Result<Vec<transaction::Model>, sea_orm::DbErr> {
    transaction::Entity::find()
        .filter(transaction::Column::AccountId.eq(account_id))
        .all(db)
        .await
}

pub async fn update_transaction(
    db: &DatabaseConnection,
    id: i32,
    transaction_type: Option<String>,
    amount: Option<Decimal>,
    description: Option<String>,
    category: Option<String>,
) -> Result<Option<transaction::Model>, sea_orm::DbErr> {
    if let Some(model) = transaction::Entity::find_by_id(id).one(db).await? {
        let mut active: transaction::ActiveModel = model.into();
        if let Some(v) = transaction_type { active.transaction_type = Set(v); }
        if let Some(v) = amount { active.amount = Set(v); }
        if let Some(v) = description { active.description = Set(v); }
        // Note: None means do not change category. To clear, set Some(String::new()) or add a dedicated clear function.
        if let Some(v) = category { active.category = Set(Some(v)); }
        let updated = active.update(db).await?;
        Ok(Some(updated))
    } else {
        Ok(None)
    }
}

pub async fn delete_transaction(
    db: &DatabaseConnection,
    id: i32,
) -> Result<u64, sea_orm::DbErr> {
    let res = transaction::Entity::delete_by_id(id).exec(db).await?;
    Ok(res.rows_affected)
}
