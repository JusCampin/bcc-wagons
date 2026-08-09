CREATE TABLE IF NOT EXISTS `bcc_player_wagons` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `charid` INT NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `model` VARCHAR(100) NOT NULL,
    `condition` INT NOT NULL DEFAULT 100,
    `is_selected` TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_bcc_player_wagons_charid` (`charid`),
    KEY `idx_bcc_player_wagons_selected` (`charid`, `is_selected`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bcc_wagon_hunting_cargo` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `wagon_id` INT UNSIGNED NOT NULL,
    `carcass_key` VARCHAR(64) NOT NULL,
    `model_hash` BIGINT NOT NULL,
    `cargo_units` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `quality` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Player-facing carcass quality: 1=poor, 2=good, 3=perfect',
    `is_skinned` TINYINT(1) NOT NULL DEFAULT 0,
    `outfit_hash` BIGINT NOT NULL DEFAULT 0,
    `meta_tags` LONGTEXT NULL,
    `stored_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_bcc_hunting_carcass` (`wagon_id`, `carcass_key`),
    KEY `idx_bcc_hunting_wagon` (`wagon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `items` (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`)
VALUES ('bcc_repair_hammer', 'Repair Hammer', 1, 1, 'item_standard', 1, 'Tool used for wagon repairs.')
ON DUPLICATE KEY UPDATE
    `label` = VALUES(`label`),
    `limit` = VALUES(`limit`),
    `can_remove` = VALUES(`can_remove`),
    `type` = VALUES(`type`),
    `usable` = VALUES(`usable`),
    `desc` = VALUES(`desc`);
