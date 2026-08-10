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

INSERT INTO `items` (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`)
VALUES ('bcc_repair_hammer', 'Repair Hammer', 1, 1, 'item_standard', 1, 'Tool used for wagon repairs.')
ON DUPLICATE KEY UPDATE
    `label` = VALUES(`label`),
    `limit` = VALUES(`limit`),
    `can_remove` = VALUES(`can_remove`),
    `type` = VALUES(`type`),
    `usable` = VALUES(`usable`),
    `desc` = VALUES(`desc`);
