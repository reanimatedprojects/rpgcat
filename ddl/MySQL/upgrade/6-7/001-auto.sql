-- Convert schema '/home/simon/rpgcat/ddl/_source/deploy/6/001-auto.yml' to '/home/simon/rpgcat/ddl/_source/deploy/7/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE accounts ADD COLUMN date_last_password_change datetime NULL;

;

COMMIT;

