use sea_orm::{ActiveModelTrait, ColumnTrait, DatabaseConnection, EntityTrait, QueryFilter, Set};
use crate::models::user;

pub async fn create_user(
    db: &DatabaseConnection,
    username: String,
    email: String,
    password_hash: String,
) -> Result<user::Model, sea_orm::DbErr> {
    let active = user::ActiveModel {
        username: Set(username),
        email: Set(email),
        password_hash: Set(password_hash),
        ..Default::default()
    };
    active.insert(db).await
}

pub async fn get_user_by_id(
    db: &DatabaseConnection,
    id: i32,
) -> Result<Option<user::Model>, sea_orm::DbErr> {
    user::Entity::find_by_id(id).one(db).await
}

pub async fn get_user_by_username(
    db: &DatabaseConnection,
    username: &str,
) -> Result<Option<user::Model>, sea_orm::DbErr> {
    user::Entity::find()
        .filter(user::Column::Username.eq(username))
        .one(db)
        .await
}

pub async fn get_user_by_email(
    db: &DatabaseConnection,
    email: &str,
) -> Result<Option<user::Model>, sea_orm::DbErr> {
    user::Entity::find()
        .filter(user::Column::Email.eq(email))
        .one(db)
        .await
}

pub async fn update_user(
    db: &DatabaseConnection,
    id: i32,
    new_username: Option<String>,
    new_email: Option<String>,
) -> Result<Option<user::Model>, sea_orm::DbErr> {
    if let Some(model) = user::Entity::find_by_id(id).one(db).await? {
        let mut active: user::ActiveModel = model.into();
        if let Some(v) = new_username { active.username = Set(v); }
        if let Some(v) = new_email { active.email = Set(v); }
        let updated = active.update(db).await?;
        Ok(Some(updated))
    } else {
        Ok(None)
    }
}

pub async fn update_user_password(
    db: &DatabaseConnection,
    id: i32,
    new_password_hash: String,
) -> Result<Option<user::Model>, sea_orm::DbErr> {
    if let Some(model) = user::Entity::find_by_id(id).one(db).await? {
        let mut active: user::ActiveModel = model.into();
        active.password_hash = Set(new_password_hash);
        let updated = active.update(db).await?;
        Ok(Some(updated))
    } else {
        Ok(None)
    }
}

pub async fn delete_user(
    db: &DatabaseConnection,
    id: i32,
) -> Result<u64, sea_orm::DbErr> {
    let res = user::Entity::delete_by_id(id).exec(db).await?;
    Ok(res.rows_affected)
}
