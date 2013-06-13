/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

-- Function: "FormBuilder".refresh_question_ts_data(integer)

-- DROP FUNCTION "FormBuilder".refresh_question_ts_data(integer);

CREATE OR REPLACE FUNCTION "FormBuilder".refresh_question_ts_data(qid integer)
  RETURNS integer AS
$BODY$
DECLARE
    f RECORD;
    q RECORD;
    a RECORD;
    av RECORD;
    data TSVECTOR;
begin
	SELECT fe.id as id, fe.description as description, fe.learn_more as learn_more INTO f FROM "FormBuilder".form_element fe inner join "FormBuilder".form frm on fe.form_id=frm.id WHERE frm.form_type='questionLibraryForm' AND fe.id = qid;

	if (f is NULL) then
		RETURN qid;
	end if;

	data = setweight(to_tsvector('"FormBuilder".ts_config', coalesce(f.description,'')), 'A') ||
		setweight(to_tsvector('"FormBuilder".ts_config', coalesce(f.learn_more,'')), 'C');
		
	FOR q IN SELECT * FROM "FormBuilder".question WHERE parent_id = f.id LOOP
		data = data ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.short_name,'')), 'A') ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.description,'')), 'C') ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.short_name,'')), 'D');

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
	END LOOP;
	UPDATE "FormBuilder".form_element set ts_data = data WHERE id = f.id;

	RETURN q.id;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "FormBuilder".refresh_question_ts_data(integer) OWNER TO fbdev;
