/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller.question;

import com.healthcit.cacure.model.BaseForm;

public interface FormContextRequired
{
	public static final String FORM_ID_NAME = "formId";

	public void setFormId(Long formId);
	public void unsetFormId();
	public BaseForm getFormContext();
}
