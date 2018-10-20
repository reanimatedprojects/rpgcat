-- Convert schema '/home/simon/rpgcat/ddl/_source/deploy/5/001-auto.yml' to '/home/simon/rpgcat/ddl/_source/deploy/6/001-auto.yml':;

;
BEGIN;

;
SET foreign_key_checks=0;

;
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

;
SET foreign_key_checks=1;

;
ALTER TABLE accounts ADD COLUMN active integer(1) NOT NULL;

;

COMMIT;

