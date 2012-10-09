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
package com.healthcit.cacure.xforms.uicontrolfactory;

import java.util.ArrayList;
import java.util.List;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.xforms.XFormsConstants.SubmissionControls;
import com.healthcit.cacure.xforms.uicontrols.XFormUIControl;

public abstract class BaseXFormUIControlFactory {
	public XFormUIControl createXFormUIControl(FormElement fe, QuestionAnswerManager qaManager){
		return null;
	}	

	public XFormUIControl createSubmissionControl(SubmissionControls s){
		return null;
	}
	
	public XFormUIControl createFormTitleControl(){
		return null;
	}
	
	@SuppressWarnings("rawtypes")
	public List createCustomJSScripts() {
		return new ArrayList();
	}
}
