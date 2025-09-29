use sea_orm::{ActiveModelTrait, ColumnTrait, DatabaseConnection, EntityTrait, QueryFilter, Set};
use crate::models::asset;
use sea_orm::prelude::Decimal;

pub async fn create_asset(
    db: &DatabaseConnection,
    user_id: i32,
    symbol: String,
    name: String,
    quantity: Decimal,
    avg_price: Decimal,
    asset_type: String,
) -> Result<asset::Model, sea_orm::DbErr> {
    let active = asset::ActiveModel {
        user_id: Set(user_id),
        symbol: Set(symbol),
        name: Set(name),
        quantity: Set(quantity),
        avg_price: Set(avg_price),
        asset_type: Set(asset_type),
        ..Default::default()
    };
    active.insert(db).await
}

pub async fn get_asset_by_id(
    db: &DatabaseConnection,
    id: i32,
) -> Result<Option<asset::Model>, sea_orm::DbErr> {
    asset::Entity::find_by_id(id).one(db).await
}

pub async fn find_assets_by_user(
    db: &DatabaseConnection,
    user_id: i32,
) -> Result<Vec<asset::Model>, sea_orm::DbErr> {
    asset::Entity::find()
        .filter(asset::Column::UserId.eq(user_id))
        .all(db)
        .await
}

pub async fn update_asset(
    db: &DatabaseConnection,
    id: i32,
    name: Option<String>,
    quantity: Option<Decimal>,
    avg_price: Option<Decimal>,
    asset_type: Option<String>,
) -> Result<Option<asset::Model>, sea_orm::DbErr> {
    if let Some(model) = asset::Entity::find_by_id(id).one(db).await? {
        let mut active: asset::ActiveModel = model.into();
        if let Some(v) = name { active.name = Set(v); }
        if let Some(v) = quantity { active.quantity = Set(v); }
        if let Some(v) = avg_price { active.avg_price = Set(v); }
        if let Some(v) = asset_type { active.asset_type = Set(v); }
        let updated = active.update(db).await?;
        Ok(Some(updated))
    } else {
        Ok(None)
    }
}

pub async fn delete_asset(
    db: &DatabaseConnection,
    id: i32,
) -> Result<u64, sea_orm::DbErr> {
    let res = asset::Entity::delete_by_id(id).exec(db).await?;
    Ok(res.rows_affected)
}
