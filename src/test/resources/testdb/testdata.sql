/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

--
-- PostgreSQL database dump
--

-- Started on 2011-05-31 12:15:13

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = "FormBuilderTest", pg_catalog;

--
-- TOC entry 1911 (class 0 OID 0)
-- Dependencies: 1542
-- Name: GENERIC_ID_SEQ; Type: SEQUENCE SET; Schema: FormBuilderTest; Owner: fbdev
--

SELECT pg_catalog.setval('"GENERIC_ID_SEQ"', 1069, true);


--
-- TOC entry 1912 (class 0 OID 0)
-- Dependencies: 1543
-- Name: RPT_USERS_SEQ; Type: SEQUENCE SET; Schema: FormBuilderTest; Owner: fbdev
--

SELECT pg_catalog.setval('"RPT_USERS_SEQ"', 12, true);


--
-- TOC entry 1905 (class 0 OID 37210)
-- Dependencies: 1557
-- Data for Name: rpt_users; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--

INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (7, 'ROLE_AUTHOR_USER', 'e0d8e47fc8bed0bfe0db233703aaad1b', '2011-05-31', 'role.author.user@test.healthcit.com');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (8, 'ROLE_APPROVER_USER', '09d7e4018dc445d10ab292e7782a1e65', '2011-05-31', 'role.approver.user@test.healthcit.com');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (9, 'ROLE_DEPLOYER_USER', 'd1ddd6bcad2c344e08f2826db37642c2', '2011-05-31', 'role.deployer.user@test.healthcit.com');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (10, 'ROLE_ADMIN_USER', 'bc93fa02c7691476007a85ddfefbb144', '2011-05-31', 'role.admin.user@test.healthcit.com');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (11, 'ROLE_LIBRARIAN_USER', '62009a42b18b662a7f9378bce505657b', '2011-05-31', 'role.librarian.user@test.healthcit.com');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (12, 'ALL_ROLES_USER', 'afce8983d0b0922d4b82a67286586bc6', '2011-05-31', 'all.roles.user@test.healthcit.com');


--
-- TOC entry 1900 (class 0 OID 37188)
-- Dependencies: 1552 1905
-- Data for Name: module; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--

INSERT INTO module (id, description, release_date, comments, update_date, author_user_id, status, is_library, module_type, completiontime) VALUES (1001, 'Questionnaire Module', NULL, 'Questionnaire Module Description', '2011-05-31 11:00:43.812+03', 1, 'IN_PROGRESS', false, 'module', '1/01/2020');


--
-- TOC entry 1896 (class 0 OID 37165)
-- Dependencies: 1547 1905 1905 1905 1900
-- Data for Name: form; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--

INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id, form_type) VALUES (1002, NULL, NULL, NULL, NULL, NULL, 'All Kind Of Elements Section', 1001, 1, 'IN_PROGRESS', '2011-05-31 11:02:50.828+03', 1, 'da1e9eaf-aafa-445c-9a82-57712caa128f', 1, 1, 'questionnaireForm');


--
-- TOC entry 1897 (class 0 OID 37168)
-- Dependencies: 1548 1896
-- Data for Name: form_element; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--

INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1004, 'It''s content. HTML is allowed.
<b>bold</b><i>italic</i>', 1002, 1, NULL, false, NULL, 'ef6315aa-8124-416c-8da6-627503dba6de', NULL, NULL, true, 'content', NULL, NULL, NULL, NULL, NULL);
INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1010, 'Number Question', 1002, 3, 'Simple Number From Element', false, NULL, '30761569-e975-40c2-bb43-704a2e55a960', NULL, NULL, true, 'question', NULL, NULL, NULL, NULL, NULL);
INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1014, 'Radio Question', 1002, 4, 'Radio Question Learn More', true, NULL, 'b0601ce3-527a-4c67-bcf8-26ec8814b1be', NULL, NULL, true, 'question', NULL, NULL, NULL, NULL, NULL);
INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1017, 'Dropdown Question', 1002, 5, 'Dropdown Question Learn More', false, NULL, '117a855a-525d-4657-bd0d-c632afa35c66', NULL, NULL, true, 'question', NULL, NULL, NULL, NULL, NULL);
INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1020, 'Year Question', 1002, 6, 'Year Question Learn More', true, NULL, '651438d4-3de8-4b9e-9c03-fcfd1fdac648', NULL, NULL, true, 'question', NULL, NULL, NULL, NULL, NULL);
INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1023, 'Monthyear Question', 1002, 7, 'Monthyear Question Learn More', false, NULL, 'b0f9012d-ac9f-465e-8035-9d8c5598082b', NULL, NULL, true, 'question', NULL, NULL, NULL, NULL, NULL);
INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1027, 'Date Question', 1002, 8, 'Date Question Learn More', true, NULL, '52dd5e3c-c85f-44f0-973d-ff4f2fc4a8cb', NULL, NULL, true, 'question', NULL, NULL, NULL, NULL, NULL);
INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1005, 'Text Question', 1002, 2, 'It''s simple test question with text answer type.', true, NULL, '18a23b86-e68a-49f4-8fe8-068bab9ae092', NULL, NULL, false, 'question', NULL, NULL, NULL, NULL, NULL);
INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1033, 'Checkbox Question', 1002, 9, 'Checkbox Question (Multi-Answer) Learn More', true, NULL, '09cfd092-e1ee-46a1-b701-6b4e0156598c', NULL, NULL, true, 'question', NULL, NULL, NULL, NULL, NULL);
INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1037, 'Simple Checkbox Table Question', 1002, 10, 'Simple Checkbox Table Question Learn More', true, NULL, 'ca5853a8-ca03-4157-81d7-091c11bc125c', NULL, NULL, true, 'table', NULL, NULL, NULL, NULL, 'SIMPLE');
INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1044, 'Static Table Question', 1002, 11, 'Static Table Question Learn More', false, NULL, 'c6a75d3f-2205-409d-b32f-c5ea098c2e89', NULL, NULL, true, 'table', NULL, NULL, NULL, NULL, 'STATIC');
INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1053, 'Dynamic Table Question', 1002, 12, 'Dynamic Table Question Learn More', false, NULL, 'dc44251b-9917-480c-be70-007e2a9e1d92', NULL, NULL, true, 'table', NULL, NULL, NULL, NULL, 'DYNAMIC');
INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1062, 'Question From QL', 1, 1, 'Question From QL Learn More', true, '''learn'':7C ''ql'':1A,6C ''question'':3A,4C ''text'':2A,8C,9C', '94c36ee1-4bf9-4885-a8c7-6419a2106498', NULL, NULL, true, 'question', NULL, NULL, NULL, NULL, NULL);
INSERT INTO form_element (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, is_visible, element_type, has_been_modified, answer_type, external_id, external_uuid, table_type) VALUES (1066, 'Question From QL', 1002, 13, NULL, false, NULL, '9d7ecc04-6a0e-464e-9b2c-f8b79b65ca6f', '94c36ee1-4bf9-4885-a8c7-6419a2106498', NULL, true, 'link', NULL, NULL, NULL, NULL, NULL);


--
-- TOC entry 1898 (class 0 OID 37174)
-- Dependencies: 1549 1897
-- Data for Name: question; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--

INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1007, 'b0c55f47-5a6a-4212-8e85-64668a056d74', 'txt_quest', 1005, NULL, NULL, 'question', 'SINGLE_ANSWER', NULL);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1012, '791bda91-a4e5-4bd5-9fea-a32ee80472c9', 'num_quest', 1010, NULL, NULL, 'question', 'SINGLE_ANSWER', NULL);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1016, '212bad9c-c6dd-4cf3-8d56-063ed5f4fec0', 'radio_quest', 1014, NULL, NULL, 'question', 'SINGLE_ANSWER', NULL);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1019, '47b9478d-f1f4-4bc3-8967-c0ff7557c3b5', 'dropdown_quest', 1017, NULL, NULL, 'question', 'SINGLE_ANSWER', NULL);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1022, '64c31ac6-737f-4121-b89a-3fbdda37bcf2', 'year_quest', 1020, NULL, NULL, 'question', 'SINGLE_ANSWER', NULL);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1025, '1fe19e1f-17d3-41a1-aa08-fb6b2144f3b7', 'monthyear_quest', 1023, NULL, NULL, 'question', 'SINGLE_ANSWER', NULL);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1029, 'bb78c2da-df6f-4852-a886-923498ebb43d', 'date_quest', 1027, NULL, NULL, 'question', 'SINGLE_ANSWER', NULL);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1035, '7bc731e8-5c85-4107-a601-b0526abdeba5', 'checkbox question', 1033, NULL, NULL, 'question', 'MULTI_ANSWER', NULL);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1039, '0e9f66e8-7626-4bec-9ee1-0712387c1bf5', 'rat 1', 1037, 1, 'Row Answer Text 1', 'tableQuestion', 'SINGLE_ANSWER', false);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1041, '6a0f7bf9-e7c3-4b4c-9e0c-dbbdf0ec8b6e', 'rat 2', 1037, 2, 'Row Answer Text 2', 'tableQuestion', 'SINGLE_ANSWER', false);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1042, 'f502528a-af1b-4c13-a294-0bf0cdf451cf', 'rat 3', 1037, 3, 'Row Answer Text 3', 'tableQuestion', 'SINGLE_ANSWER', false);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1055, '422b25c4-97c3-43ba-b67d-91f10c6ba6ae', 'id_col', 1053, 1, 'Identifing Column', 'tableQuestion', 'SINGLE_ANSWER', true);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1056, '6916fd72-9cd1-4ef4-b199-42d28070d805', 'text_column', 1053, 2, 'text', 'tableQuestion', 'SINGLE_ANSWER', false);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1057, '872ccee6-6b9f-4435-832c-165707626f2b', 'number_column', 1053, 3, 'number', 'tableQuestion', 'SINGLE_ANSWER', false);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1058, '2ea33e6b-58a5-4799-9ee7-ac0061cc4391', 'year_column', 1053, 4, 'year', 'tableQuestion', 'SINGLE_ANSWER', false);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1060, '75330d11-5f3d-4da8-8e47-d824d5c07c54', 'monthyear_column', 1053, 5, 'monthyear', 'tableQuestion', 'SINGLE_ANSWER', false);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1061, '1c6a70e2-04aa-4b31-9b1d-89995f2211ed', 'date_column', 1053, 6, 'date', 'tableQuestion', 'SINGLE_ANSWER', false);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1064, '10182993-22f7-4d58-9600-631c63010fcb', 'ql_text_question', 1062, NULL, NULL, 'question', 'SINGLE_ANSWER', NULL);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1069, 'b377a849-1338-4ad4-829e-473e054cf79a', '', 1044, 1, '', 'tableQuestion', 'SINGLE_ANSWER', true);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1046, '0412d5eb-819d-4f29-a033-0c8092f988c2', 'sn_text', 1044, 2, 'text', 'tableQuestion', 'SINGLE_ANSWER', false);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1047, '8b5ca725-59b3-4088-a576-07926a4615fb', 'sn_text', 1044, 3, 'number', 'tableQuestion', 'SINGLE_ANSWER', false);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1048, '4bd48754-8d19-4658-bb2a-ee2fca5205a4', 'sn_dropdown', 1044, 4, 'dropdown', 'tableQuestion', 'SINGLE_ANSWER', false);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1049, '2327acf1-b3f2-41de-9c2f-0e792fcb3879', 'sn_year', 1044, 5, 'year', 'tableQuestion', 'SINGLE_ANSWER', false);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1050, 'c55a4746-629e-4983-8ded-7e2f82a70f81', 'sn_monthyear', 1044, 6, 'monthyear', 'tableQuestion', 'SINGLE_ANSWER', false);
INSERT INTO question (id, uuid, short_name, parent_id, ord, description, question_type, type, is_identifying) VALUES (1052, '6e1ee310-ec3e-4235-a5cf-fb812647ec90', 'sn_date', 1044, 7, 'date', 'tableQuestion', 'SINGLE_ANSWER', false);


--
-- TOC entry 1893 (class 0 OID 37150)
-- Dependencies: 1544 1898
-- Data for Name: answer; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--

INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5040, 'TEXT', 'Text Answer', '', 1007, NULL, '', 'Medium', '99', 'c9f87c9c-77dc-4d39-84eb-a5786ff3eb7c');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5041, 'NUMBER', 'Number Answer', '', 1012, NULL, '', '', 'min:10;max:110', '184f7d02-b799-4ff3-b160-fd1ee7f2d856');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5042, 'RADIO', 'Radio Answer 1', '', 1016, NULL, '', 'Horizontal', NULL, '52a70205-02df-4bea-a97b-75a2d59bb1a6');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5043, 'DROPDOWN', 'Dropdown Answer 1', '', 1019, NULL, '', '', NULL, '9dfc8143-ec2e-46c8-8d70-abece0d5a375');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5044, 'YEAR', 'Year Answer', '', 1022, NULL, '', '', NULL, '80457844-5d16-4996-a854-61ae1c31c2f8');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5130, 'MONTHYEAR', 'Monthyear Answer', '', 1025, NULL, '', '', NULL, 'a5f732b9-c178-4af5-adbd-57f928f025f3');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5131, 'DATE', 'Date Answer', '', 1029, NULL, '', '', NULL, 'bc9b3d24-6a33-46b9-817f-40db978259a7');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5132, 'CHECKBOX', 'Checkbox Answer 1', '', 1035, NULL, '', 'Horizontal', NULL, '02836107-99c3-4769-94df-9bee202a93b7');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5133, 'CHECKBOX', '', '', 1039, NULL, '', '', NULL, '6d7ecd8b-e095-49dd-a6d2-a05e4df715f7');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5134, 'CHECKBOX', '', '', 1041, NULL, '', '', NULL, '134bb167-de63-49cc-af7f-e3126ad4780b');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5215, 'CHECKBOX', '', '', 1042, NULL, '', '', NULL, '6c485812-1669-4073-a88b-cf11e1fb0706');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5218, 'DROPDOWN', 'Table Dropdown Answer 1', '', 1048, NULL, '', '', NULL, '16ca5386-c2ba-4a09-ae79-c4ce2ccd0d7a');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5219, 'YEAR', '', '', 1049, NULL, '', '', NULL, '1b878393-644b-4244-9594-fb41978b6421');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5255, 'MONTHYEAR', '', '', 1050, NULL, '', '', NULL, '3ee34f54-42d9-42df-afe3-f3266350c5f8');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5256, 'DATE', '', '', 1052, NULL, '', '', NULL, '3b0b4d17-73b8-4286-9587-26aaec3d789e');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5257, 'DROPDOWN', 'Id Text 1', '', 1055, NULL, '', '', NULL, '4ae4287e-aaa5-4727-ac92-0d780cf8e7b6');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5258, 'TEXT', '', '', 1056, NULL, '', '', '', '156eb5b6-f2ce-43fe-abaf-af236d0969a9');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5259, 'NUMBER', '', '', 1057, NULL, '', '', '', 'f74951e5-4da1-453b-adf2-d61e4f99f8f8');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5295, 'YEAR', '', '', 1058, NULL, '', '', NULL, 'ecc0effa-16c6-4eb5-8f14-9a04fe2e06db');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5296, 'MONTHYEAR', '', '', 1060, NULL, '', '', NULL, '19fc656d-f026-4e23-b2fc-4d10a87555d3');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5297, 'DATE', '', '', 1061, NULL, '', '', NULL, '62118a8e-49b0-4736-9945-aaa1bea4c9d0');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5298, 'TEXT', 'text', '', 1064, NULL, '', 'Short', '30', '89f8da52-84b9-41e0-814e-e308143bde95');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5216, 'TEXT', '', '', 1046, NULL, '', '', NULL, '78862f9e-e535-4a86-a891-42451dfe359d');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5217, 'NUMBER', '', '', 1047, NULL, '', '', NULL, 'eeffc9d0-3c94-4079-abcc-2f600b91ed4b');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint, uuid) VALUES (5299, 'DROPDOWN', '', '', 1069, NULL, '', '', NULL, 'b38df339-7a1b-463b-9051-1138e90400c3');


--
-- TOC entry 1894 (class 0 OID 37156)
-- Dependencies: 1545
-- Data for Name: answer_skip_rule; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--



--
-- TOC entry 1895 (class 0 OID 37159)
-- Dependencies: 1546 1893
-- Data for Name: answer_value; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--

INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10092, '', '', 5041, 'Number Answer', 1, 'c30e4cc8-34ab-45ad-933a-a25ab1a7b405', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10093, '', 'Radio Answer Value 1', 5042, 'Radio Answer 1', 1, '8e326570-9b52-4971-8d8f-3b89fd251b3d', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10094, '', 'Radio Answer Value 2', 5042, 'Radio Answer 2', 2, '130c0d3f-3608-4cb5-b286-23bfe6b833b2', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10098, '', '', 5044, 'Year Answer', 1, '44869b16-122c-4968-a4a1-3b6abab44d3a', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10099, '', '', 5130, 'Monthyear Answer', 1, '8f8833e6-2fff-4395-b480-1ef275d44732', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10300, '', '', 5131, 'Date Answer', 1, '200b5fa9-68e4-457e-8c54-92363d56d8a9', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10301, '', '', 5040, 'Text Answer', 1, '7a073089-b60b-4dca-b04f-3e284fecb8a0', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10302, '', 'Dropdown Answer Value 1', 5043, 'Dropdown Answer 1', 1, '6d8abe3f-9b35-4a71-b960-f15771f8a2ac', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10303, '', 'Dropdown Answer Value 2', 5043, 'Dropdown Answer 2', 2, '3f7f4280-be46-4752-80d5-535d73dbceb1', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10304, '', 'Dropdown Answer Value 3', 5043, 'Dropdown Answer 3', 3, '570cdad4-1218-4439-a89c-6e9c1f068fb4', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10305, '', 'Checkbox Answer Value 1', 5132, 'Checkbox Answer 1', 1, 'bbf93530-5e72-46fd-a333-f40d7ed498e1', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10306, '', 'Checkbox Answer Value 2', 5132, 'Checkbox Answer 2', 2, '0ead5a0b-8af6-49b4-83a1-905b731843b8', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10307, '', 'Checkbox Answer Value 3', 5132, 'Checkbox Answer 3', 3, '6127fee1-8811-46da-a35e-05f5c32e512c', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10308, '', 'Checkbox Answer Value 4', 5132, 'Checkbox Answer 4', 4, '5521b407-0a19-48d1-9914-31a3f4a7b8d5', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10309, '', 'Simple Answer Value 1', 5133, 'Simple Answer Text 1', 1, 'c13258bc-d53b-4bc3-a9dd-7db6a5604bdd', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10400, '', 'Simple Answer Value 2', 5133, 'Simple Answer Text 2', 2, 'b7614561-23c7-4249-a71d-da8d0ed08090', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10401, '', 'Simple Answer Value 1', 5134, 'Simple Answer Text 1', 3, 'ed5d17a7-7737-432d-bad7-8611723752cc', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10402, '', 'Simple Answer Value 2', 5134, 'Simple Answer Text 2', 4, '7fd359c0-a9b2-4b47-bf05-dd07ec4134d2', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10403, '', 'Simple Answer Value 1', 5215, 'Simple Answer Text 1', 5, 'e050c9dc-42e9-4363-9ff3-f60b1f394c44', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10404, '', 'Simple Answer Value 2', 5215, 'Simple Answer Text 2', 6, 'fa096545-0265-4ee7-89fb-f7973a3c18be', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10407, '', 'Id Value 1', 5257, 'Id Text 1', 1, '0d3889d8-fa96-4d04-9161-6ef4f8b11d0d', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10408, '', 'Id Value 2', 5257, 'Id Text 2', 2, '66a63292-514a-4b05-a4c5-9df99dcf7d1c', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10409, '', 'Id Value 3', 5257, 'Id Text 3', 3, 'abff7c01-5fd9-4e57-80c7-08f0694690ec', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10650, '', '', 5298, 'text', 1, '1f1c8a3d-31c8-4321-b8c8-71e6f4078165', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10651, 'Row 1', 'Row 1', 5299, 'Row 1', 1, 'b7f94552-9290-43b9-93c6-de843c549d0f', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10652, 'Row 2', 'Row 2', 5299, 'Row 2', 2, 'f35bc941-e164-455f-9174-897e96567672', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10653, 'Row 3', 'Row 3', 5299, 'Row 3', 3, '7aea330d-7c25-491b-8d58-a435d8b4d3a9', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10405, '', 'Table Dropdown Answer Value 1', 5218, 'Table Dropdown Answer 1', 4, 'd05a5baa-a3f6-4bf4-8067-5a5ab3e2896c', NULL, NULL);
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id, cadsr_public_id, external_id) VALUES (10406, '', 'Table Dropdown Answer Value 2', 5218, 'Table Dropdown Answer 2', 5, '198882d2-a166-49db-ba9a-51f1ddf4654e', NULL, NULL);


--
-- TOC entry 1899 (class 0 OID 37185)
-- Dependencies: 1551
-- Data for Name: category; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--

INSERT INTO category (id, name, description) VALUES (2072, 'Category', 'Category Description');


--
-- TOC entry 1901 (class 0 OID 37195)
-- Dependencies: 1553 1899 1897
-- Data for Name: question_categries; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--

INSERT INTO question_categries (category_id, question_id) VALUES (58050, 1005);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 1017);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 1033);
INSERT INTO question_categries (category_id, question_id) VALUES (2072, 1033);
INSERT INTO question_categries (category_id, question_id) VALUES (2072, 1037);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 1044);


--
-- TOC entry 1902 (class 0 OID 37198)
-- Dependencies: 1554 1896
-- Data for Name: question_orig; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--



--
-- TOC entry 1903 (class 0 OID 37204)
-- Dependencies: 1555
-- Data for Name: question_skip_rule; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--

--
-- TOC entry 1906 (class 0 OID 37213)
-- Dependencies: 1558
-- Data for Name: skip_rule; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--

INSERT INTO skip_rule (id, parent_id, logical_op, parent_type) VALUES (1003, 1002, 'AND', 'formSkip');
INSERT INTO skip_rule (id, parent_id, logical_op, parent_type) VALUES (1013, 1010, 'AND', 'formElementSkip');
INSERT INTO skip_rule (id, parent_id, logical_op, parent_type) VALUES (1015, 1014, 'AND', 'formElementSkip');
INSERT INTO skip_rule (id, parent_id, logical_op, parent_type) VALUES (1021, 1020, 'AND', 'formElementSkip');
INSERT INTO skip_rule (id, parent_id, logical_op, parent_type) VALUES (1024, 1023, 'AND', 'formElementSkip');
INSERT INTO skip_rule (id, parent_id, logical_op, parent_type) VALUES (1028, 1027, 'AND', 'formElementSkip');
INSERT INTO skip_rule (id, parent_id, logical_op, parent_type) VALUES (1031, 1005, 'AND', 'formElementSkip');
INSERT INTO skip_rule (id, parent_id, logical_op, parent_type) VALUES (1032, 1017, 'AND', 'formElementSkip');
INSERT INTO skip_rule (id, parent_id, logical_op, parent_type) VALUES (1034, 1033, 'AND', 'formElementSkip');
INSERT INTO skip_rule (id, parent_id, logical_op, parent_type) VALUES (1038, 1037, 'AND', 'formElementSkip');
INSERT INTO skip_rule (id, parent_id, logical_op, parent_type) VALUES (1054, 1053, 'AND', 'formElementSkip');
INSERT INTO skip_rule (id, parent_id, logical_op, parent_type) VALUES (1063, 1062, 'AND', 'formElementSkip');
INSERT INTO skip_rule (id, parent_id, logical_op, parent_type) VALUES (1068, 1044, 'AND', 'formElementSkip');


--
-- TOC entry 1907 (class 0 OID 37225)
-- Dependencies: 1561
-- Data for Name: test; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--



--
-- TOC entry 1908 (class 0 OID 37228)
-- Dependencies: 1562 1904 1905
-- Data for Name: user_roles; Type: TABLE DATA; Schema: FormBuilderTest; Owner: fbdev
--

INSERT INTO user_roles (user_id, role_id) VALUES (3, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (1, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (1, 999);
INSERT INTO user_roles (user_id, role_id) VALUES (1, 20);
INSERT INTO user_roles (user_id, role_id) VALUES (5, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (4, 999);
INSERT INTO user_roles (user_id, role_id) VALUES (7, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (8, 30);
INSERT INTO user_roles (user_id, role_id) VALUES (9, 20);
INSERT INTO user_roles (user_id, role_id) VALUES (10, 999);
INSERT INTO user_roles (user_id, role_id) VALUES (11, 40);
INSERT INTO user_roles (user_id, role_id) VALUES (12, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (12, 30);
INSERT INTO user_roles (user_id, role_id) VALUES (12, 20);
INSERT INTO user_roles (user_id, role_id) VALUES (12, 999);
INSERT INTO user_roles (user_id, role_id) VALUES (12, 40);


-- Completed on 2011-05-31 12:15:15

--
-- PostgreSQL database dump complete
--

