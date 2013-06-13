/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

-- Function: "FormBuilder".generate_metadata_for_table_question(character varying)

-- DROP FUNCTION "FormBuilder".generate_metadata_for_table_question(character varying);

-- Function: "FormBuilder".generate_metadata_for_table_question(character varying)

-- DROP FUNCTION "FormBuilder".generate_metadata_for_table_question(character varying);

CREATE OR REPLACE FUNCTION "FormBuilder".generate_metadata_for_table_question(table_question_id character varying)
  RETURNS text AS
$BODY$
 DECLARE _record record;
 DECLARE table_text character varying(2000);
 DECLARE column_header character varying(500);
 DECLARE question_id character(36);
 DECLARE table_type character varying(15);
 DECLARE table_short_name character varying(250);
 DECLARE table_question_is_identifying boolean;
 DECLARE metadata text;
 DECLARE column_data text;
 DECLARE column_ctr bigint;
 DECLARE question_ord bigint;
 DECLARE answer_ord bigint;
 DECLARE identifying_column_uuid character(36);

BEGIN
 metadata := '';
 column_data := '';
 column_ctr := 0;
 FOR _record IN 
 select q.uuid,
	fe.description,
	av.description as "description2",
	fe.table_type,
	fe.table_short_name,
	q.is_identifying,
	q.ord,
	av.ord as "ord2"
	from form f, module m, form_element fe, form_element fe2, question q, answer a
	left join answer_value av on a.id = coalesce(av.answer_id,-111)
	where f.module_id = m.id 
	and fe2.form_id = f.id
	and ((coalesce(fe2.link_id,'')<>'' and coalesce(fe2.link_id,'') = fe.uuid) or (coalesce(fe2.link_id,'')='' and fe.id = fe2.id))
	and q.parent_id = fe.id
	and q.id = a.question_id
	and (a.id = av.answer_id or av.answer_id is null)
	and fe.element_type = 'table'
	and fe.uuid=table_question_id
	order by q.ord,coalesce(av.ord,-1)
 LOOP
	 table_text := _record.description;
	 column_header := _record.description2;
	 question_id := _record.uuid;
	 table_type := _record.table_type;
	 table_short_name := _record.table_short_name;
	 table_question_is_identifying := _record.is_identifying;
	 question_ord := _record.ord;
	 answer_ord := _record.ord2;

	 /*****************************************************************/
	 /* SIMPLE TABLE QUESTIONS 			                  */
	 /*****************************************************************/
	IF table_type = 'SIMPLE' THEN
		-- Set up column headers
		IF column_header IS NOT NULL THEN
			EXIT WHEN position(column_header in column_data) > 0;
			column_ctr := column_ctr + 1;
			IF column_ctr > 1 THEN
				column_data := column_data || ',';
			END IF;
			column_data := column_data || '"' || column_header || '"';
		END IF;
	 END IF;
	 /*****************************************************************/
	 /* END processing SIMPLE TABLE QUESTIONS			  */
	 /*****************************************************************/

	 /*****************************************************************/
	 /* DYNAMIC/STATIC TABLE QUESTIONS 			                  */
	 /*****************************************************************/
	 IF table_type = 'DYNAMIC' OR table_type='STATIC' THEN
		-- Set up column order
		IF position(question_id in column_data) = 0 THEN
			column_ctr := column_ctr + 1;
			IF column_ctr > 1 THEN
				column_data := column_data || ',';
			END IF;
			column_data := column_data || '"' || question_id || '"';
		END IF;

		-- Set identifying column
		IF table_question_is_identifying IS TRUE THEN
			identifying_column_uuid := question_id;
		END IF;
	 END IF;

	 /*****************************************************************/
	 /* END processing DYNAMIC/STATIC TABLE QUESTIONS 		  */
	 /*****************************************************************/
 
 END LOOP;

-- set up metadata

 /*****************************************************************/
 /* SIMPLE TABLE QUESTIONS 			                  */
 /*****************************************************************/
 IF table_type = 'SIMPLE' THEN
	metadata := '"table_text":"' || "temp".remove_space_characters(table_text) || '", "short_name":"' || table_short_name || '"';
	metadata := metadata || ', "uuid":"' || table_question_id || '", "metadata": {' || metadata ||  ',"column_headers":[' || column_data || ']}';
 END IF;
 /*****************************************************************/
 /* END processing SIMPLE TABLE QUESTIONS			  */
 /*****************************************************************/

 /*****************************************************************/
 /* DYNAMIC/STATIC TABLE QUESTIONS 			                  */
 /*****************************************************************/
 IF table_type = 'DYNAMIC' OR table_type='STATIC' THEN
	-- Set up column order
	metadata := '"table_text":"' || "temp".remove_space_characters(table_text) || '", "short_name":"' || table_short_name || '"';
	IF identifying_column_uuid IS NOT NULL THEN
		metadata := metadata || ',"ident_column_uuid":"' || identifying_column_uuid || '"' ;
	END IF;
	metadata := metadata || ', "columns_order":[' || column_data || ']';
	metadata := '"uuid":"' || table_question_id || '", "metadata": {' || metadata || '}';
 END IF;

 /*****************************************************************/
 /* END processing DYNAMIC/STATIC TABLE QUESTIONS 		   */
 /*****************************************************************/
		

 RETURN metadata;
 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "FormBuilder".generate_metadata_for_table_question(character varying) OWNER TO fbdev;

