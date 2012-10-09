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

import java.util.ArrayList;
import java.util.List;

import org.jdom.Element;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.xforms.XFormsConstants;
import com.healthcit.cacure.xforms.XFormsUtils;

public class HTMLSingleAnswerEntryControl extends HTMLXFormUIControl
{

	public HTMLSingleAnswerEntryControl(FormElement q, QuestionAnswerManager qaManager)
	{
		super(q, qaManager);
		// TODO Auto-generated constructor stub
	}

	@Override
	protected List<Element> getAnswerElements()
	{
		List<Element> elemList = new ArrayList<Element>();

		/* This should be only for single question elements */
		List<? extends BaseQuestion> questions = formElement.getQuestions();
		if (questions != null)
		{
			BaseQuestion question = questions.get(0);
			Answer answer = question.getAnswer();
			AnswerType answerType = answer.getType();
			Element controlElem = answerType.equals( AnswerType.TEXTAREA ) ? 
					            new Element(TEXTAREA_TAG, XFORMS_NAMESPACE) : 
					            new Element(INPUT_TAG, XFORMS_NAMESPACE);
			controlElem.setAttribute("bind", XFormsUtils.getQuestionIDREF(question));
			controlElem.setAttribute("class", getEntryCssClasses(answer));
			controlElem.addContent(createLabel(answer.getDescription(), getCssLabelClass(answer)));
			addSkips(question, controlElem);
			elemList.add(controlElem);
		}
		return elemList;
	}

	@Override
	protected String getControlTextClass()
	{
		StringBuilder cssClass  = new StringBuilder(100);
		cssClass.append(XFormsConstants.CSS_CLASS_QUESTION_TEXT);
		return cssClass.toString();
	}

	@Override
	protected String getBaseCssClass(Answer answer)
	{
		return XFormsConstants.CSS_CLASS_ANSWER_ENTRY + (answer.getType() == null ? "" : " " + answer.getType().toString().toLowerCase());
	}

}
