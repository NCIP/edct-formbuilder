/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


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
