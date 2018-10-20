-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Sat Oct 20 15:23:44 2018
-- 
;
SET foreign_key_checks=0;
--
-- Table: `accounts`
--
CREATE TABLE `accounts` (
  `account_id` integer unsigned NOT NULL auto_increment,
  `email` char(128) NOT NULL,
  `password` text NULL,
  `date_signup` datetime NOT NULL,
  `date_verified` datetime NULL,
  `date_lastlogin` datetime NULL,
  `active` integer(1) NOT NULL,
  PRIMARY KEY (`account_id`),
  UNIQUE `email` (`email`)
) ENGINE=InnoDB;
--
-- Table: `items`
--
CREATE TABLE `items` (
  `item_id` integer unsigned NOT NULL auto_increment,
  `item_name` char(32) NOT NULL,
  `item_type` char(32) NOT NULL,
  `item_data` mediumtext NOT NULL,
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB;
--
-- Table: `maps`
--
CREATE TABLE `maps` (
  `map_id` integer unsigned NOT NULL auto_increment,
  `map_x` integer NOT NULL,
  `map_y` integer NOT NULL,
  `map_z` integer NOT NULL,
  `tile_type_id` integer NOT NULL,
  `name` char(64) NULL,
  PRIMARY KEY (`map_id`),
  UNIQUE `map_coords` (`map_x`, `map_y`, `map_z`)
) ENGINE=InnoDB;
--
-- Table: `roles`
--
CREATE TABLE `roles` (
  `role_id` integer unsigned NOT NULL auto_increment,
  `role` char(255) NOT NULL,
  `description` char(255) NULL,
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB;
--
-- Table: `sessions`
--
CREATE TABLE `sessions` (
  `id` char(72) NOT NULL,
  `session_data` mediumtext NULL,
  `expires` integer NULL,
  PRIMARY KEY (`id`)
);
--
-- Table: `skills`
--
CREATE TABLE `skills` (
  `skill_id` integer unsigned NOT NULL auto_increment,
  `skill_name` char(32) NOT NULL,
  `skill_requirements` char(32) NOT NULL,
  `skill_data` mediumtext NOT NULL,
  `skill_prerequisites` mediumtext NOT NULL,
  PRIMARY KEY (`skill_id`)
) ENGINE=InnoDB;
--
-- Table: `tile_types`
--
CREATE TABLE `tile_types` (
  `tile_type_id` integer unsigned NOT NULL auto_increment,
  `name` char(32) NOT NULL,
  `colour_code` char(6) NOT NULL,
  `move_type` char(10) NOT NULL,
  PRIMARY KEY (`tile_type_id`)
) ENGINE=InnoDB;
--
-- Table: `reset_tokens`
--
CREATE TABLE `reset_tokens` (
  `reset_token_id` integer unsigned NOT NULL auto_increment,
  `token` char(64) NOT NULL,
  `date_issued` datetime NOT NULL,
  `client_ip` char(45) NULL,
  `account_id` integer unsigned NOT NULL,
  `email` char(255) NOT NULL,
  INDEX `reset_tokens_idx_account_id` (`account_id`),
  PRIMARY KEY (`reset_token_id`),
  UNIQUE `reset_tokens_token` (`token`),
  CONSTRAINT `reset_tokens_fk_account_id` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`account_id`)
) ENGINE=InnoDB;
--
-- Table: `tile_type_descriptions`
--
CREATE TABLE `tile_type_descriptions` (
  `tile_type_id` integer unsigned NOT NULL auto_increment,
  `description` mediumtext NOT NULL,
  INDEX (`tile_type_id`),
  PRIMARY KEY (`tile_type_id`),
  CONSTRAINT `tile_type_descriptions_fk_tile_type_id` FOREIGN KEY (`tile_type_id`) REFERENCES `tile_types` (`tile_type_id`) ON DELETE CASCADE
) ENGINE=InnoDB;
--
-- Table: `account_roles`
--
CREATE TABLE `account_roles` (
  `account_id` integer unsigned NOT NULL,
  `role_id` integer unsigned NOT NULL,
  INDEX `account_roles_idx_account_id` (`account_id`),
  INDEX `account_roles_idx_role_id` (`role_id`),
  PRIMARY KEY (`account_id`, `role_id`),
  CONSTRAINT `account_roles_fk_account_id` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `account_roles_fk_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`)
) ENGINE=InnoDB;
--
-- Table: `characters`
--
CREATE TABLE `characters` (
  `character_id` integer unsigned NOT NULL auto_increment,
  `character_name` char(32) NOT NULL,
  `account_id` integer unsigned NOT NULL,
  `character_health` integer unsigned NOT NULL,
  `character_exp` integer unsigned NOT NULL,
  `character_max_ap` integer unsigned NOT NULL,
  `character_ap` integer unsigned NOT NULL,
  `map_x` integer NOT NULL,
  `map_y` integer NOT NULL,
  `map_z` integer NOT NULL,
  INDEX `characters_idx_account_id` (`account_id`),
  INDEX `characters_idx_map_x_map_y_map_z` (`map_x`, `map_y`, `map_z`),
  PRIMARY KEY (`character_id`),
  UNIQUE `character_name` (`character_name`),
  CONSTRAINT `characters_fk_account_id` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `characters_fk_map_x_map_y_map_z` FOREIGN KEY (`map_x`, `map_y`, `map_z`) REFERENCES `maps` (`map_x`, `map_y`, `map_z`)
) ENGINE=InnoDB;
--
-- Table: `inventories`
--
CREATE TABLE `inventories` (
  `character_id` integer unsigned NOT NULL,
  `item_id` integer unsigned NOT NULL,
  `item_quantity` integer unsigned NOT NULL,
  INDEX `inventories_idx_character_id` (`character_id`),
  INDEX `inventories_idx_item_id` (`item_id`),
  PRIMARY KEY (`character_id`, `item_id`),
  CONSTRAINT `inventories_fk_character_id` FOREIGN KEY (`character_id`) REFERENCES `characters` (`character_id`) ON DELETE CASCADE,
  CONSTRAINT `inventories_fk_item_id` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`)
) ENGINE=InnoDB;
--
-- Table: `skillsets`
--
CREATE TABLE `skillsets` (
  `character_id` integer unsigned NOT NULL,
  `skill_id` integer unsigned NOT NULL,
  `item_quantity` integer unsigned NOT NULL,
  INDEX `skillsets_idx_character_id` (`character_id`),
  INDEX `skillsets_idx_skill_id` (`skill_id`),
  PRIMARY KEY (`character_id`, `skill_id`),
  CONSTRAINT `skillsets_fk_character_id` FOREIGN KEY (`character_id`) REFERENCES `characters` (`character_id`),
  CONSTRAINT `skillsets_fk_skill_id` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`skill_id`) ON DELETE CASCADE
) ENGINE=InnoDB;
SET foreign_key_checks=1;
