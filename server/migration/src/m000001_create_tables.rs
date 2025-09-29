use sea_orm_migration::prelude::*;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        // users
        manager
            .create_table(
                Table::create()
                    .table(Users::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(Users::Id)
                            .integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(
                        ColumnDef::new(Users::Username)
                            .string()
                            .not_null()
                            .unique_key(),
                    )
                    .col(
                        ColumnDef::new(Users::Email)
                            .string()
                            .not_null()
                            .unique_key(),
                    )
                    .col(ColumnDef::new(Users::PasswordHash).string().not_null())
                    .col(
                        ColumnDef::new(Users::CreatedAt)
                            .date_time()
                            .not_null()
                            .default(Expr::current_timestamp()),
                    )
                    .col(
                        ColumnDef::new(Users::UpdatedAt)
                            .date_time()
                            .not_null()
                            .default(Expr::current_timestamp()),
                    )
                    .to_owned(),
            )
            .await?;

        // accounts
        manager
            .create_table(
                Table::create()
                    .table(Accounts::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(Accounts::Id)
                            .integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(Accounts::UserId).integer().not_null())
                    .col(ColumnDef::new(Accounts::Name).string().not_null())
                    .col(ColumnDef::new(Accounts::AccountType).string().not_null())
                    .col(ColumnDef::new(Accounts::Balance).decimal_len(16, 8).not_null().default("0"))
                    .col(ColumnDef::new(Accounts::Currency).string().not_null())
                    .col(
                        ColumnDef::new(Accounts::CreatedAt)
                            .date_time()
                            .not_null()
                            .default(Expr::current_timestamp()),
                    )
                    .foreign_key(
                        ForeignKey::create()
                            .name("fk_accounts_user")
                            .from(Accounts::Table, Accounts::UserId)
                            .to(Users::Table, Users::Id)
                            .on_delete(ForeignKeyAction::Cascade)
                            .on_update(ForeignKeyAction::Cascade),
                    )
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx_accounts_user_id")
                    .table(Accounts::Table)
                    .col(Accounts::UserId)
                    .to_owned(),
            )
            .await?;

        // transactions
        manager
            .create_table(
                Table::create()
                    .table(Transactions::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(Transactions::Id)
                            .integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(Transactions::AccountId).integer().not_null())
                    .col(ColumnDef::new(Transactions::TransactionType).string().not_null())
                    .col(ColumnDef::new(Transactions::Amount).decimal_len(16, 8).not_null())
                    .col(ColumnDef::new(Transactions::Description).string().not_null())
                    .col(ColumnDef::new(Transactions::Category).string().null())
                    .col(
                        ColumnDef::new(Transactions::CreatedAt)
                            .date_time()
                            .not_null()
                            .default(Expr::current_timestamp()),
                    )
                    .foreign_key(
                        ForeignKey::create()
                            .name("fk_transactions_account")
                            .from(Transactions::Table, Transactions::AccountId)
                            .to(Accounts::Table, Accounts::Id)
                            .on_delete(ForeignKeyAction::Cascade)
                            .on_update(ForeignKeyAction::Cascade),
                    )
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx_transactions_account_id")
                    .table(Transactions::Table)
                    .col(Transactions::AccountId)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx_transactions_created_at")
                    .table(Transactions::Table)
                    .col(Transactions::CreatedAt)
                    .to_owned(),
            )
            .await?;

        // assets
        manager
            .create_table(
                Table::create()
                    .table(Assets::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(Assets::Id)
                            .integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(Assets::UserId).integer().not_null())
                    .col(ColumnDef::new(Assets::Symbol).string().not_null())
                    .col(ColumnDef::new(Assets::Name).string().not_null())
                    .col(ColumnDef::new(Assets::Quantity).decimal_len(16, 8).not_null().default("0"))
                    .col(ColumnDef::new(Assets::AvgPrice).decimal_len(16, 8).not_null().default("0"))
                    .col(ColumnDef::new(Assets::AssetType).string().not_null())
                    .col(
                        ColumnDef::new(Assets::CreatedAt)
                            .date_time()
                            .not_null()
                            .default(Expr::current_timestamp()),
                    )
                    .col(
                        ColumnDef::new(Assets::UpdatedAt)
                            .date_time()
                            .not_null()
                            .default(Expr::current_timestamp()),
                    )
                    .foreign_key(
                        ForeignKey::create()
                            .name("fk_assets_user")
                            .from(Assets::Table, Assets::UserId)
                            .to(Users::Table, Users::Id)
                            .on_delete(ForeignKeyAction::Cascade)
                            .on_update(ForeignKeyAction::Cascade),
                    )
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx_assets_user_id")
                    .table(Assets::Table)
                    .col(Assets::UserId)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("u_assets_user_symbol")
                    .table(Assets::Table)
                    .col(Assets::UserId)
                    .col(Assets::Symbol)
                    .unique()
                    .to_owned(),
            )
            .await?;

        // asset_prices (latest price per symbol)
        manager
            .create_table(
                Table::create()
                    .table(AssetPrices::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(AssetPrices::Id)
                            .integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(AssetPrices::Symbol).string().not_null())
                    .col(ColumnDef::new(AssetPrices::Price).decimal_len(16, 8).not_null())
                    .col(ColumnDef::new(AssetPrices::Currency).string().not_null())
                    .col(
                        ColumnDef::new(AssetPrices::UpdatedAt)
                            .date_time()
                            .not_null()
                            .default(Expr::current_timestamp()),
                    )
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("u_asset_prices_symbol")
                    .table(AssetPrices::Table)
                    .col(AssetPrices::Symbol)
                    .unique()
                    .to_owned(),
            )
            .await?;

        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(AssetPrices::Table).to_owned())
            .await?;
        manager
            .drop_table(Table::drop().table(Transactions::Table).to_owned())
            .await?;
        manager
            .drop_table(Table::drop().table(Assets::Table).to_owned())
            .await?;
        manager
            .drop_table(Table::drop().table(Accounts::Table).to_owned())
            .await?;
        manager
            .drop_table(Table::drop().table(Users::Table).to_owned())
            .await?;
        Ok(())
    }
}

#[derive(Iden)]
enum Users {
    Table,
    Id,
    Username,
    Email,
    PasswordHash,
    CreatedAt,
    UpdatedAt,
}

#[derive(Iden)]
enum Accounts {
    Table,
    Id,
    UserId,
    Name,
    AccountType,
    Balance,
    Currency,
    CreatedAt,
}

#[derive(Iden)]
enum Transactions {
    Table,
    Id,
    AccountId,
    TransactionType,
    Amount,
    Description,
    Category,
    CreatedAt,
}

#[derive(Iden)]
enum Assets {
    Table,
    Id,
    UserId,
    Symbol,
    Name,
    Quantity,
    AvgPrice,
    AssetType,
    CreatedAt,
    UpdatedAt,
}

#[derive(Iden)]
enum AssetPrices {
    Table,
    Id,
    Symbol,
    Price,
    Currency,
    UpdatedAt,
}
