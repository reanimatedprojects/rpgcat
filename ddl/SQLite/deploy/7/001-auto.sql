-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Sun Oct 21 01:37:28 2018
-- 

;
BEGIN TRANSACTION;
--
-- Table: accounts
--
CREATE TABLE accounts (
  account_id INTEGER PRIMARY KEY NOT NULL,
  email char(128) NOT NULL,
  password text,
  date_signup datetime NOT NULL,
  date_verified datetime,
  date_lastlogin datetime,
  date_last_password_change datetime,
  active int(1) NOT NULL
);
CREATE UNIQUE INDEX email ON accounts (email);
--
-- Table: items
--
CREATE TABLE items (
  item_id INTEGER PRIMARY KEY NOT NULL,
  item_name char(32) NOT NULL,
  item_type char(32) NOT NULL,
  item_data mediumtext NOT NULL
);
--
-- Table: maps
--
CREATE TABLE maps (
  map_id INTEGER PRIMARY KEY NOT NULL,
  map_x integer NOT NULL,
  map_y integer NOT NULL,
  map_z integer NOT NULL,
  tile_type_id integer NOT NULL,
  name char(64)
);
CREATE UNIQUE INDEX map_coords ON maps (map_x, map_y, map_z);
--
-- Table: roles
--
CREATE TABLE roles (
  role_id INTEGER PRIMARY KEY NOT NULL,
  role char(255) NOT NULL,
  description char(255)
);
--
-- Table: sessions
--
CREATE TABLE sessions (
  id char(72) NOT NULL,
  session_data mediumtext,
  expires integer,
  PRIMARY KEY (id)
);
--
-- Table: skills
--
CREATE TABLE skills (
  skill_id INTEGER PRIMARY KEY NOT NULL,
  skill_name char(32) NOT NULL,
  skill_requirements char(32) NOT NULL,
  skill_data mediumtext NOT NULL,
  skill_prerequisites mediumtext NOT NULL
);
--
-- Table: tile_types
--
CREATE TABLE tile_types (
  tile_type_id INTEGER PRIMARY KEY NOT NULL,
  name char(32) NOT NULL,
  colour_code char(6) NOT NULL,
  move_type char(10) NOT NULL
);
--
-- Table: reset_tokens
--
CREATE TABLE reset_tokens (
  reset_token_id INTEGER PRIMARY KEY NOT NULL,
  token char(64) NOT NULL,
  date_issued datetime NOT NULL,
  client_ip char(45),
  account_id integer NOT NULL,
  email char(255) NOT NULL,
  FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
CREATE INDEX reset_tokens_idx_account_id ON reset_tokens (account_id);
CREATE UNIQUE INDEX reset_tokens_token ON reset_tokens (token);
--
-- Table: tile_type_descriptions
--
CREATE TABLE tile_type_descriptions (
  tile_type_id INTEGER PRIMARY KEY NOT NULL,
  description mediumtext NOT NULL,
  FOREIGN KEY (tile_type_id) REFERENCES tile_types(tile_type_id) ON DELETE CASCADE
);
--
-- Table: account_roles
--
CREATE TABLE account_roles (
  account_id integer NOT NULL,
  role_id integer NOT NULL,
  PRIMARY KEY (account_id, role_id),
  FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (role_id) REFERENCES roles(role_id)
);
CREATE INDEX account_roles_idx_account_id ON account_roles (account_id);
CREATE INDEX account_roles_idx_role_id ON account_roles (role_id);
--
-- Table: characters
--
CREATE TABLE characters (
  character_id INTEGER PRIMARY KEY NOT NULL,
  character_name char(32) NOT NULL,
  account_id integer NOT NULL,
  character_health integer NOT NULL,
  character_exp integer NOT NULL,
  character_max_ap integer NOT NULL,
  character_ap integer NOT NULL,
  map_x integer NOT NULL,
  map_y integer NOT NULL,
  map_z integer NOT NULL,
  FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (map_x, map_y, map_z) REFERENCES maps(map_x, map_y, map_z)
);
CREATE INDEX characters_idx_account_id ON characters (account_id);
CREATE INDEX characters_idx_map_x_map_y_map_z ON characters (map_x, map_y, map_z);
CREATE UNIQUE INDEX character_name ON characters (character_name);
--
-- Table: inventories
--
CREATE TABLE inventories (
  character_id integer NOT NULL,
  item_id integer NOT NULL,
  item_quantity integer NOT NULL,
  PRIMARY KEY (character_id, item_id),
  FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES items(item_id)
);
CREATE INDEX inventories_idx_character_id ON inventories (character_id);
CREATE INDEX inventories_idx_item_id ON inventories (item_id);
--
-- Table: skillsets
--
CREATE TABLE skillsets (
  character_id integer NOT NULL,
  skill_id integer NOT NULL,
  item_quantity integer NOT NULL,
  PRIMARY KEY (character_id, skill_id),
  FOREIGN KEY (character_id) REFERENCES characters(character_id),
  FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
);
CREATE INDEX skillsets_idx_character_id ON skillsets (character_id);
CREATE INDEX skillsets_idx_skill_id ON skillsets (skill_id);
COMMIT;
