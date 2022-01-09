ALTER TABLE `player_vehicles`
ADD COLUMN `maxweight` int(50) DEFAULT '10000',
ADD COLUMN `weightUpgrades` LONGTEXT DEFAULT NULL;