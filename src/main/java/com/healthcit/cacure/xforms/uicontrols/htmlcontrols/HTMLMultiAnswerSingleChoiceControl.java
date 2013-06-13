/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.xforms.uicontrols.htmlcontrols;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.xforms.XFormsConstants;
import com.healthcit.cacure.xforms.XFormsConstructionException;
import com.healthcit.cacure.xforms.XFormsUtils;

public class HTMLMultiAnswerSingleChoiceControl extends HTMLMultiAnswerAnyChoiceControl
{

	public HTMLMultiAnswerSingleChoiceControl(TableElement fe, QuestionAnswerManager qaManager)
	{
		super(fe, qaManager);
	}

	@Override
	protected String getBaseCssClass(Answer answer)
	{
		return XFormsConstants.CSS_CLASS_ANSWER_RADIO;
	}
	
	@Override
	protected String getControlTextRef()
	{
		if(formElement instanceof TableElement)
		{
			return XFormsUtils.getTableQuestionTextXPath((TableElement)formElement);
	}
		else
			throw new XFormsConstructionException("Element is not a table '" + formElement.getUuid() + "'");
	
	}

}
