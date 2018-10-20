-- Convert schema '/home/simon/rpgcat/ddl/_source/deploy/5/001-auto.yml' to '/home/simon/rpgcat/ddl/_source/deploy/6/001-auto.yml':;

;
BEGIN;

;
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
ALTER TABLE "reset_tokens" ADD CONSTRAINT "reset_tokens_fk_account_id" FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("account_id") DEFERRABLE;

;
ALTER TABLE accounts ADD COLUMN active smallint NOT NULL;

;

COMMIT;

