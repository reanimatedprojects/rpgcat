-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Sat Oct 20 15:23:45 2018
-- 
;
--
-- Table: accounts
--
CREATE TABLE "accounts" (
  "account_id" serial NOT NULL,
  "email" character(128) NOT NULL,
  "password" text,
  "date_signup" timestamp NOT NULL,
  "date_verified" timestamp,
  "date_lastlogin" timestamp,
  "active" smallint NOT NULL,
  PRIMARY KEY ("account_id"),
  CONSTRAINT "email" UNIQUE ("email")
);

;
--
-- Table: items
--
CREATE TABLE "items" (
  "item_id" serial NOT NULL,
  "item_name" character(32) NOT NULL,
  "item_type" character(32) NOT NULL,
  "item_data" text NOT NULL,
  PRIMARY KEY ("item_id")
);

;
--
-- Table: maps
--
CREATE TABLE "maps" (
  "map_id" serial NOT NULL,
  "map_x" integer NOT NULL,
  "map_y" integer NOT NULL,
  "map_z" integer NOT NULL,
  "tile_type_id" integer NOT NULL,
  "name" character(64),
  PRIMARY KEY ("map_id"),
  CONSTRAINT "map_coords" UNIQUE ("map_x", "map_y", "map_z")
);

;
--
-- Table: roles
--
CREATE TABLE "roles" (
  "role_id" serial NOT NULL,
  "role" character(255) NOT NULL,
  "description" character(255),
  PRIMARY KEY ("role_id")
);

;
--
-- Table: sessions
--
CREATE TABLE "sessions" (
  "id" character(72) NOT NULL,
  "session_data" text,
  "expires" integer,
  PRIMARY KEY ("id")
);

;
--
-- Table: skills
--
CREATE TABLE "skills" (
  "skill_id" serial NOT NULL,
  "skill_name" character(32) NOT NULL,
  "skill_requirements" character(32) NOT NULL,
  "skill_data" text NOT NULL,
  "skill_prerequisites" text NOT NULL,
  PRIMARY KEY ("skill_id")
);

;
--
-- Table: tile_types
--
CREATE TABLE "tile_types" (
  "tile_type_id" serial NOT NULL,
  "name" character(32) NOT NULL,
  "colour_code" character(6) NOT NULL,
  "move_type" character(10) NOT NULL,
  PRIMARY KEY ("tile_type_id")
);

;
--
-- Table: reset_tokens
--
CREATE TABLE "reset_tokens" (
  "reset_token_id" serial NOT NULL,
  "token" character(64) NOT NULL,
  "date_issued" timestamp NOT NULL,
  "client_ip" character(45),
  "account_id" integer NOT NULL,
  "email" character(255) NOT NULL,
  PRIMARY KEY ("reset_token_id"),
  CONSTRAINT "reset_tokens_token" UNIQUE ("token")
);
CREATE INDEX "reset_tokens_idx_account_id" on "reset_tokens" ("account_id");

;
--
-- Table: tile_type_descriptions
--
CREATE TABLE "tile_type_descriptions" (
  "tile_type_id" serial NOT NULL,
  "description" text NOT NULL,
  PRIMARY KEY ("tile_type_id")
);

;
--
-- Table: account_roles
--
CREATE TABLE "account_roles" (
  "account_id" integer NOT NULL,
  "role_id" integer NOT NULL,
  PRIMARY KEY ("account_id", "role_id")
);
CREATE INDEX "account_roles_idx_account_id" on "account_roles" ("account_id");
CREATE INDEX "account_roles_idx_role_id" on "account_roles" ("role_id");

;
--
-- Table: characters
--
CREATE TABLE "characters" (
  "character_id" serial NOT NULL,
  "character_name" character(32) NOT NULL,
  "account_id" integer NOT NULL,
  "character_health" integer NOT NULL,
  "character_exp" integer NOT NULL,
  "character_max_ap" integer NOT NULL,
  "character_ap" integer NOT NULL,
  "map_x" integer NOT NULL,
  "map_y" integer NOT NULL,
  "map_z" integer NOT NULL,
  PRIMARY KEY ("character_id"),
  CONSTRAINT "character_name" UNIQUE ("character_name")
);
CREATE INDEX "characters_idx_account_id" on "characters" ("account_id");
CREATE INDEX "characters_idx_map_x_map_y_map_z" on "characters" ("map_x", "map_y", "map_z");

;
--
-- Table: inventories
--
CREATE TABLE "inventories" (
  "character_id" integer NOT NULL,
  "item_id" integer NOT NULL,
  "item_quantity" integer NOT NULL,
  PRIMARY KEY ("character_id", "item_id")
);
CREATE INDEX "inventories_idx_character_id" on "inventories" ("character_id");
CREATE INDEX "inventories_idx_item_id" on "inventories" ("item_id");

;
--
-- Table: skillsets
--
CREATE TABLE "skillsets" (
  "character_id" integer NOT NULL,
  "skill_id" integer NOT NULL,
  "item_quantity" integer NOT NULL,
  PRIMARY KEY ("character_id", "skill_id")
);
CREATE INDEX "skillsets_idx_character_id" on "skillsets" ("character_id");
CREATE INDEX "skillsets_idx_skill_id" on "skillsets" ("skill_id");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "reset_tokens" ADD CONSTRAINT "reset_tokens_fk_account_id" FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("account_id") DEFERRABLE;

;
ALTER TABLE "tile_type_descriptions" ADD CONSTRAINT "tile_type_descriptions_fk_tile_type_id" FOREIGN KEY ("tile_type_id")
  REFERENCES "tile_types" ("tile_type_id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "account_roles" ADD CONSTRAINT "account_roles_fk_account_id" FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("account_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "account_roles" ADD CONSTRAINT "account_roles_fk_role_id" FOREIGN KEY ("role_id")
  REFERENCES "roles" ("role_id") DEFERRABLE;

;
ALTER TABLE "characters" ADD CONSTRAINT "characters_fk_account_id" FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("account_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "characters" ADD CONSTRAINT "characters_fk_map_x_map_y_map_z" FOREIGN KEY ("map_x", "map_y", "map_z")
  REFERENCES "maps" ("map_x", "map_y", "map_z") DEFERRABLE;

;
ALTER TABLE "inventories" ADD CONSTRAINT "inventories_fk_character_id" FOREIGN KEY ("character_id")
  REFERENCES "characters" ("character_id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "inventories" ADD CONSTRAINT "inventories_fk_item_id" FOREIGN KEY ("item_id")
  REFERENCES "items" ("item_id") DEFERRABLE;

;
ALTER TABLE "skillsets" ADD CONSTRAINT "skillsets_fk_character_id" FOREIGN KEY ("character_id")
  REFERENCES "characters" ("character_id") DEFERRABLE;

;
ALTER TABLE "skillsets" ADD CONSTRAINT "skillsets_fk_skill_id" FOREIGN KEY ("skill_id")
  REFERENCES "skills" ("skill_id") ON DELETE CASCADE DEFERRABLE;

;
