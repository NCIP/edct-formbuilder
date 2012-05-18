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

public class HTMLSingleAnswerSingleChoiceControl extends HTMLXFormUIControl
{

	public HTMLSingleAnswerSingleChoiceControl(FormElement fe, QuestionAnswerManager qaManager)
	{
		super(fe, qaManager);
		// TODO Auto-generated constructor stub
	}

	@Override
	protected List<Element> getAnswerElements()
	{
		List<Element> elemList = new ArrayList<Element>();
        List<? extends BaseQuestion> questions = formElement.getQuestions();
        for (BaseQuestion question : questions)
        {
			Answer answer = question.getAnswer();
		Element inputElem = new Element(getSelectControlName(), XFORMS_NAMESPACE);
		inputElem.setAttribute("ref", XFormsUtils.getQuestionAnswerXPath(question));
		inputElem.setAttribute("appearance", getSelectControlAppearance(answer.getType()));
		inputElem.setAttribute("class", getEntryCssClasses(answer));
		
		Element itemsElement = new Element("itemset", XFORMS_NAMESPACE);
			itemsElement.setAttribute("nodeset", XFormsUtils.getXpathRef(XFormsUtils.getQuestionAnswerSetInstanceIDREF( question.getUuid()), "/answer"));
		itemsElement.addContent(createRefLabel("@text", getCssLabelClass(answer)));
		Element valueElem = new Element("value", XFORMS_NAMESPACE);
		valueElem.setAttribute("ref", ".");
		itemsElement.addContent(valueElem);
	
		inputElem.addContent(itemsElement);
		addSkips(question, inputElem);
		elemList.add(inputElem);
        }
		return elemList;
	}
	
	@Override
	protected String getBaseCssClass( Answer answer ) 
	{
		return XFormsConstants.CSS_CLASS_ANSWER_RADIO;
	}

	@Override
	protected String getSelectControlName()
	{
		return SELECT1_TAG;
	}

	protected String getSelectControlAppearance(AnswerType answerType)
	{
		return (answerType == AnswerType.RADIO)?"full":"minimal";
	}
}
