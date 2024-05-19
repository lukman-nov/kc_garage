ALTER TABLE `owned_vehicles` ADD COLUMN `shared` LONGTEXT NULL;
ALTER TABLE `owned_vehicles` ADD COLUMN `job` LONGTEXT NULL;
ALTER TABLE `owned_vehicles` ADD COLUMN `peopleWithKeys` LONGTEXT NULL;
ALTER TABLE `owned_vehicles` ADD COLUMN `km` varchar(255) NOT NULL DEFAULT '0';