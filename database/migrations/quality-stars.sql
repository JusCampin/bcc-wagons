-- Run once on databases that stored hunting-wagon quality as 0=poor,
-- 1=good, 2=perfect. New installations already store visible stars (1-3).
UPDATE `bcc_wagon_hunting_cargo`
SET `quality` = LEAST(3, `quality` + 1);

ALTER TABLE `bcc_wagon_hunting_cargo`
    MODIFY `quality` TINYINT UNSIGNED NOT NULL DEFAULT 1
    COMMENT 'Player-facing carcass quality: 1=poor, 2=good, 3=perfect';
