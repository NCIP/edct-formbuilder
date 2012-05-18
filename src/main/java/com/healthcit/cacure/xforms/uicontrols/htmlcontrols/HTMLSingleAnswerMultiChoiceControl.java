package com.healthcit.cacure.xforms.uicontrols.htmlcontrols;


import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.xforms.XFormsConstants;

public class HTMLSingleAnswerMultiChoiceControl extends HTMLSingleAnswerSingleChoiceControl
{

	public HTMLSingleAnswerMultiChoiceControl(FormElement q, QuestionAnswerManager qaManager)
	{
		super(q, qaManager);
	}

	@Override
	protected String getBaseCssClass(Answer answer)
	{
		return XFormsConstants.CSS_CLASS_ANSWER_CHECKBOX;
	}

	@Override
	protected String getSelectControlAppearance(AnswerType answerType)
	{
		return (answerType == AnswerType.CHECKBOX)?"full":"minimal";
	}

	@Override
	protected String getSelectControlName()
	{
		return SELECT_TAG;
	}

}
