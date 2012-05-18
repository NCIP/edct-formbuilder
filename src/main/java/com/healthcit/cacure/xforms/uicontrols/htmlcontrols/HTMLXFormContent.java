package com.healthcit.cacure.xforms.uicontrols.htmlcontrols;

import java.util.ArrayList;
import java.util.List;

import org.jdom.Element;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.ContentElement;
import com.healthcit.cacure.model.ContentElement.ContentType;
import com.healthcit.cacure.xforms.XFormsUtils;

public class HTMLXFormContent extends HTMLXFormUIControl
{

	public HTMLXFormContent(ContentElement ce, QuestionAnswerManager qaManager)
	{
		super(ce, qaManager);
		// TODO Auto-generated constructor stub
	}

	@Override
	protected String getControlTextClass()
	{
		ContentType type = ((ContentElement) formElement).getType();
		if(type == null) {
			type = ContentElement.DEFAULT_TYPE;
		}
		return "hcit-content-" + type.toString().toLowerCase() + "-text";
	}


	@Override
	protected String getControlTextRef()
	{
		return XFormsUtils.getContentXPath((ContentElement)formElement);
	}

	/**
	 * returns Empty List - no answers for a collection
	 */
	@Override
	protected List<Element> getAnswerElements()
	{
		return new ArrayList<Element>();
	}


}
