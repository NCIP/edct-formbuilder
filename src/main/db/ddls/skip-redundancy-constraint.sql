/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

ALTER TABLE "FormBuilder".skip_pattern ADD CONSTRAINT skip_redundancy_constraint UNIQUE (parent_id, answer_value_id);