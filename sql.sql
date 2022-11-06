ALTER TABLE `player_vehicles`
ADD COLUMN `actualCarryCapacity` int(50) DEFAULT '60000',
ADD COLUMN `weightUpgrades` LONGTEXT DEFAULT NULL;