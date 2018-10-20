-- Convert schema '/home/simon/rpgcat/ddl/_source/deploy/5/001-auto.yml' to '/home/simon/rpgcat/ddl/_source/deploy/6/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE reset_tokens (
  reset_token_id INTEGER PRIMARY KEY NOT NULL,
  token char(64) NOT NULL,
  date_issued datetime NOT NULL,
  client_ip char(45),
  account_id integer NOT NULL,
  email char(255) NOT NULL,
  FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

;
CREATE INDEX reset_tokens_idx_account_id ON reset_tokens (account_id);

;
CREATE UNIQUE INDEX reset_tokens_token ON reset_tokens (token);

;
ALTER TABLE accounts ADD COLUMN active int(1) NOT NULL;

;

COMMIT;

