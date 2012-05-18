CREATE TABLE "FormBuilder".roles
(
  id bigint NOT NULL,
  "name" character varying(20),
  CONSTRAINT roles_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "FormBuilder".roles OWNER TO fbdev;

CREATE TABLE "FormBuilder".user_roles
(
  id bigint NOT NULL,
  user_id bigint NOT NULL,
  role_id bigint NOT NULL,
  CONSTRAINT user_roles_pkey PRIMARY KEY (id),
  CONSTRAINT "fk_roleId_user_roles" FOREIGN KEY (role_id)
      REFERENCES "FormBuilder".roles (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "fk_userId_user_roles" FOREIGN KEY (user_id)
      REFERENCES "FormBuilder".rpt_users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "FormBuilder".user_roles OWNER TO fbdev;

INSERT INTO "FormBuilder"."roles" (id,name) VALUES (10,'ROLE_AUTHOR');
INSERT INTO "FormBuilder"."roles" (id,name) VALUES (20,'ROLE_DEPLOYER');
INSERT INTO "FormBuilder"."roles" (id,name) VALUES (30,'ROLE_APPROVER');

INSERT INTO "FormBuilder"."rpt_users" (id,username,password,created_date) 
	VALUES (nextval('"RPT_USERS_SEQ"'),'test','9ddc44f3f7f78da5781d6cab571b2fc5',now());

