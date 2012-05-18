INSERT INTO "FormBuilder".module(id, description, release_date, comments, update_date, author_user_id, status, is_library, module_type, completiontime)
VALUES (1, 'Question Library', NULL, NULL, clock_timestamp(), 1, 'QUESTION_LIBRARY', TRUE, 'questionLibrary', NULL);
INSERT INTO "FormBuilder".module(id, description, release_date, comments, update_date, author_user_id, status, is_library, module_type, completiontime)
VALUES (2, 'Form Library', NULL, NULL, clock_timestamp(), 1, 'FORM_LIBRARY', TRUE, 'formLibrary', NULL);

INSERT INTO "FormBuilder".form(id, "name", module_id, ord, status, update_date, author_user_id, uuid, last_updated_by_user_id, form_type)
VALUES (1, 'Question Form', 1, 1, 'QUESTION_LIBRARY', clock_timestamp(), 1, '2eb81d8c-8587-43f7-b324-a78f1780634e', 1, 'questionLibraryForm');

ALTER TABLE "FormBuilder".skip_pattern drop column description;