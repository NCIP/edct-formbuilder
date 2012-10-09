/*******************************************************************************
 * Copyright (c) 2012 HealthCare It, Inc.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the BSD 3-Clause license
 * which accompanies this distribution, and is available at
 * http://directory.fsf.org/wiki/License:BSD_3Clause
 * 
 * Contributors:
 *     HealthCare It, Inc - initial API and implementation
 ******************************************************************************/
package com.healthcit.cacure.web.controller.question;

import com.healthcit.cacure.model.BaseForm;

public interface FormContextRequired
{
	public static final String FORM_ID_NAME = "formId";

	public void setFormId(Long formId);
	public void unsetFormId();
	public BaseForm getFormContext();
}
