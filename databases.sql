CREATE TABLE IF NOT EXISTS `owned_vehicles` (
  `owner` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `plate` varchar(12) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vehicle` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'car',
  `job` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stored` tinyint(1) NOT NULL DEFAULT 0,
  `parking` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `peopleWithKeys` longtext COLLATE utf8mb4_unicode_ci DEFAULT '[]',
  PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;