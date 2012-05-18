-- Function: "FormBuilder".refresh_question_ts_data(integer)

-- DROP FUNCTION "FormBuilder".refresh_question_ts_data(integer);

CREATE OR REPLACE FUNCTION "FormBuilder".refresh_question_ts_data(qid integer)
  RETURNS integer AS
$BODY$
DECLARE
    q RECORD;
    a RECORD;
    av RECORD;
    data TSVECTOR;
begin
	SELECT qe.id as id, qe.short_name as short_name, qe.description as description, fe.learn_more as learn_more, fe.id as fid INTO q FROM "FormBuilder".form_element fe inner join "FormBuilder".question qe on fe.ord = qe.ord and fe.uuid= qe.uuid WHERE qe.id = qid;

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

	UPDATE "FormBuilder".form_element set ts_data = data WHERE id = q.fid;

	RETURN q.id;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION "FormBuilder".refresh_question_ts_data(integer) OWNER TO fbdev;
