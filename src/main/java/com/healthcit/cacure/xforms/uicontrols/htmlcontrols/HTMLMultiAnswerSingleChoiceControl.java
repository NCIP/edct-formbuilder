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
