package com.healthcit.cacure.web.controller.question;

import com.healthcit.cacure.model.BaseForm;

public interface FormContextRequired
{
	public static final String FORM_ID_NAME = "formId";

	public void setFormId(Long formId);
	public void unsetFormId();
	public BaseForm getFormContext();
}
