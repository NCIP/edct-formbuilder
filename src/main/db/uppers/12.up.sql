update question
set short_name = short_name || id
where  exists(select fe.id from form_element fe where lower(fe.table_short_name) = lower(question.short_name))
or exists(select q2.id from question q2 where lower(q2.short_name) = lower(question.short_name) and q2.id != question.id);

update form_element
set table_short_name = table_short_name || id
where  exists(select fe.id from form_element fe where lower(fe.table_short_name) = lower(form_element.table_short_name) and form_element.id != fe.id)
or exists(select q.id from question q where lower(q.short_name) = lower(form_element.table_short_name));