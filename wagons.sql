CREATE TABLE IF NOT EXISTS `player_wagons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` VARCHAR(50) NOT NULL,
  `charid` INT(11) NOT NULL,
  `selected` int(11) NOT NULL DEFAULT 0,
  `name` VARCHAR(100) NOT NULL,
  `model` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;