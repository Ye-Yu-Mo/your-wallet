use sea_orm::{ActiveModelTrait, ColumnTrait, DatabaseConnection, EntityTrait, QueryFilter, Set};
use crate::models::account;
use sea_orm::prelude::Decimal;

pub async fn create_account(
    db: &DatabaseConnection,
    user_id: i32,
    name: String,
    account_type: String,
    balance: Decimal,
    currency: String,
) -> Result<account::Model, sea_orm::DbErr> {
    let active = account::ActiveModel {
        user_id: Set(user_id),
        name: Set(name),
        account_type: Set(account_type),
        balance: Set(balance),
        currency: Set(currency),
        ..Default::default()
    };
    active.insert(db).await
}

pub async fn get_account_by_id(
    db: &DatabaseConnection,
    id: i32,
) -> Result<Option<account::Model>, sea_orm::DbErr> {
    account::Entity::find_by_id(id).one(db).await
}

pub async fn find_accounts_by_user(
    db: &DatabaseConnection,
    user_id: i32,
) -> Result<Vec<account::Model>, sea_orm::DbErr> {
    account::Entity::find()
        .filter(account::Column::UserId.eq(user_id))
        .all(db)
        .await
}

pub async fn update_account(
    db: &DatabaseConnection,
    id: i32,
    name: Option<String>,
    account_type: Option<String>,
    balance: Option<Decimal>,
    currency: Option<String>,
) -> Result<Option<account::Model>, sea_orm::DbErr> {
    if let Some(model) = account::Entity::find_by_id(id).one(db).await? {
        let mut active: account::ActiveModel = model.into();
        if let Some(v) = name { active.name = Set(v); }
        if let Some(v) = account_type { active.account_type = Set(v); }
        if let Some(v) = balance { active.balance = Set(v); }
        if let Some(v) = currency { active.currency = Set(v); }
        let updated = active.update(db).await?;
        Ok(Some(updated))
    } else {
        Ok(None)
    }
}

pub async fn delete_account(
    db: &DatabaseConnection,
    id: i32,
) -> Result<u64, sea_orm::DbErr> {
    let res = account::Entity::delete_by_id(id).exec(db).await?;
    Ok(res.rows_affected)
}
