/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

CREATE OR REPLACE VIEW "FormBuilder".form_element_links_count_vw AS 
select fe.id, count(fe.id) from form_element fe, form_element link where fe.element_type!='link' and link.link_id = fe.uuid group by fe.id;
ALTER TABLE "FormBuilder".form_element_links_count_vw OWNER TO fbdev;


CREATE OR REPLACE VIEW "FormBuilder".fe_approved_links_count_vw AS 
select fe.id, fc.cnt
from form_element fe, form_element link , (select frm1.id as id, (select count(frm2.*) from form frm2 where frm2.status='APPROVED' and frm2.id = frm1.id) as cnt from form frm1 ) fc
where fe.element_type!='link' and link.link_id = fe.uuid and fc.id = link.form_id
group by  fe.id, fc.cnt;
ALTER TABLE "FormBuilder".form_element_links_count_vw OWNER TO fbdev;