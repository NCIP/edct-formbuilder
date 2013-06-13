/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

-- add PostgreSQL text search

CREATE LANGUAGE plpgsql;
CREATE TEXT SEARCH CONFIGURATION "FormBuilder".ts_config ( COPY = pg_catalog.english );

ALTER TABLE "FormBuilder".question ADD COLUMN ts_data tsvector;
CREATE INDEX question_ts_data_idx ON "FormBuilder".question USING gin(ts_data);

CREATE OR REPLACE FUNCTION "FormBuilder".refresh_question_ts_data(qid int) RETURNS INTEGER AS $$
DECLARE
    q RECORD;
    a RECORD;
    av RECORD;
    data TSVECTOR;
begin
	SELECT * INTO q FROM "FormBuilder".question WHERE id = qid;

	if (q is NULL) then
		RETURN qid;
	end if;

	data = setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.short_name,'')), 'A') ||
		setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.description,'')), 'B') ||
		setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.learn_more,'')), 'C');

	FOR a IN SELECT * FROM "FormBuilder".answer WHERE question_id = q.id LOOP

		data = data ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(a.description,'')), 'C') ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(a.group_name,'')), 'D');

		FOR av IN SELECT * FROM "FormBuilder".answer_value WHERE answer_id = a.id LOOP

			data = data ||
				setweight(to_tsvector('"FormBuilder".ts_config', coalesce(av.description,'')), 'C') ||
				setweight(to_tsvector('"FormBuilder".ts_config', coalesce(av.short_name,'')), 'D');

		END LOOP;

	END LOOP;

	UPDATE "FormBuilder".question set ts_data = data WHERE id = q.id;

	RETURN q.id;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "FormBuilder".refresh_question_ts_data() RETURNS INTEGER AS $$
DECLARE
	qid INTEGER;
	count INTEGER := 0;
begin
	FOR qid IN SELECT * FROM "FormBuilder".question LOOP
		PERFORM "FormBuilder".refresh_question_ts_data(qid);
		count := count + 1;
	END LOOP;

	RETURN count;
end
$$ LANGUAGE plpgsql;

select refresh_question_ts_data();


-- mod to module table
ALTER TABLE "FormBuilder".MODULE ADD COLUMN update_date TIMESTAMP WITH TIME ZONE;
update "FormBuilder".MODULE set update_date = now();
ALTER TABLE "FormBuilder".MODULE ALTER COLUMN update_date SET NOT NULL;

ALTER TABLE "FormBuilder".MODULE ADD COLUMN author_user_id BIGINT;
update "FormBuilder".MODULE set author_user_id = 1;
ALTER TABLE "FormBuilder".MODULE ALTER COLUMN author_user_id SET NOT NULL;

ALTER TABLE ONLY module
    ADD CONSTRAINT fb_module_author_user_fk FOREIGN KEY (author_user_id)
      REFERENCES "FormBuilder".rpt_users (id)
      ON UPDATE NO ACTION ON DELETE NO ACTION;

-- mods to form table
ALTER TABLE "FormBuilder".form ADD COLUMN status character varying(30);
update "FormBuilder".form set status = 'IN_PROGRESS';
ALTER TABLE "FormBuilder".form ALTER COLUMN status SET NOT NULL;

ALTER TABLE "FormBuilder".form ADD COLUMN update_date timestamp with time zone;
update "FormBuilder".form set update_date = now();
ALTER TABLE "FormBuilder".form ALTER COLUMN update_date SET NOT NULL;

ALTER TABLE "FormBuilder".form ADD COLUMN author_user_id bigint;
update "FormBuilder".form set author_user_id = 1;
ALTER TABLE "FormBuilder".form ALTER COLUMN author_user_id SET NOT NULL;

ALTER TABLE "FormBuilder".form
    ADD CONSTRAINT fb_form_author_user_fk FOREIGN KEY (author_user_id)
      REFERENCES "FormBuilder".rpt_users (id)
      ON UPDATE NO ACTION ON DELETE NO ACTION;


-- functions to generate uuids
CREATE OR REPLACE FUNCTION from_hex(t text) RETURNS integer
    AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN EXECUTE 'SELECT x'''||t||'''::integer AS hex' LOOP
        RETURN r.hex;
    END LOOP;
END
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION generate_uuid_v3(namespace varchar, name varchar) RETURNS uuid
    AS $$
DECLARE
    value varchar(36);
    bytes varchar;
BEGIN
    bytes = md5(decode(namespace, 'hex') || decode(name, 'escape'));
    value = substr(bytes, 1+0, 8);
    value = value || '-';
    value = value || substr(bytes, 1+2*4, 4);
    value = value || '-';
    value = value || lpad(to_hex((from_hex(substr(bytes, 1+2*6, 2)) & 15) | 48), 2, '0');
    value = value || substr(bytes, 1+2*7, 2);
    value = value || '-';
    value = value || lpad(to_hex((from_hex(substr(bytes, 1+2*8, 2)) & 63) | 128), 2, '0');
    value = value || substr(bytes, 1+2*9, 2);
    value = value || '-';
    value = value || substr(bytes, 1+2*10, 12);
    return value::uuid;
END;
$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;

-- add uuid to questions
ALTER TABLE "FormBuilder".question  ADD COLUMN uuid character(36);
update "FormBuilder".question set uuid = (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://www.heathcit.com/FormBuilder/' || id))::character(36);
ALTER TABLE "FormBuilder".question  Alter COLUMN uuid set not null;
-- add uuid to forms
ALTER TABLE "FormBuilder".form  ADD COLUMN uuid character(36);
update "FormBuilder".form set uuid = (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://www.heathcit.com/FormBuilder/' || id))::character(36);
ALTER TABLE "FormBuilder".form  Alter COLUMN uuid set not null;

-- add form locking
ALTER TABLE "FormBuilder".form ADD COLUMN locked_by_user_id bigint;

ALTER TABLE "FormBuilder".form
    ADD CONSTRAINT fb_form_locked_by_fk FOREIGN KEY (locked_by_user_id)
      REFERENCES "FormBuilder".rpt_users (id)
      ON UPDATE NO ACTION ON DELETE NO ACTION;

-- add view used in form generation
CREATE OR REPLACE VIEW "FormBuilder".skip_pattern_answer_value_vw AS
select s.id "id",
      (case s.parent_type when 'questionSkip' then s.parent_id else null end) "question_id",
      (case s.parent_type when 'formSkip' then s.parent_id else null end) "form_id",
       s.answer_value_id "skip_item",
       av.value "skip_item_value",
       a.question_id "skip_item_question",
       q.form_id "skip_item_form",
       a.id "skip_item_answer_id"
from skip_pattern s, answer_value av, answer a, question q
where s.answer_value_id = av.permanent_id and av.answer_id = a.id and q.id = a.question_id;
ALTER TABLE "FormBuilder".skip_pattern_answer_value_vw OWNER TO fbdev;

-- question linking
ALTER TABLE "FormBuilder".question ADD COLUMN link_id character varying(255);
ALTER TABLE "FormBuilder".question ADD COLUMN link_source character varying(30);

ALTER TABLE "FormBuilder".question DROP CONSTRAINT "uniqueQuestionOrd";

-- module status
ALTER TABLE "FormBuilder".module ADD COLUMN status CHARACTER VARYING(30) NOT NULL DEFAULT 'IN_PROGRESS';