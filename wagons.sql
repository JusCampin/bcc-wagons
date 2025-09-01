CREATE TABLE IF NOT EXISTS `player_wagons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` VARCHAR(50) NOT NULL,
  `charid` INT(11) NOT NULL,
  `selected` int(11) NOT NULL DEFAULT 0,
  `name` VARCHAR(100) NOT NULL,
  `model` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `player_wagons` ADD COLUMN IF NOT EXISTS (`condition` INT(11) NOT NULL DEFAULT 100);

INSERT INTO
    `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`)
VALUES
    ('bcc_repair_hammer', 'Repair Hammer', 1, 1, 'item_standard', 1, 'Tool used for repairs.')
ON DUPLICATE KEY UPDATE
    `item` = VALUES(`item`),
    `label` = VALUES(`label`),
    `limit` = VALUES(`limit`),
    `can_remove` = VALUES(`can_remove`),
    `type` = VALUES(`type`),
    `usable` = VALUES(`usable`),
    `desc` = VALUES(`desc`);