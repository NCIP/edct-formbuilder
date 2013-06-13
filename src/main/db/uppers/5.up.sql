/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

CREATE OR REPLACE VIEW "FormBuilder".fe_approved_links_count_vw AS 
 select sub1.id, COALESCE(sub2.cnt1, 0) as cnt
from (select distinct id from form_element where element_type::text <> 'link'::text) sub1
left outer join ( SELECT fe.id as id, count(fe.id) as cnt1  FROM form_element fe, form_element links, form f
		  where links.link_id = fe.uuid and f.id = links.form_id and f.status::text = 'APPROVED'::text
                  GROUP BY fe.id) sub2
on (sub1.id = sub2.id);

ALTER TABLE "FormBuilder".fe_approved_links_count_vw OWNER TO fbdev;

