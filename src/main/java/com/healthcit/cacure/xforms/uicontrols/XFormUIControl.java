/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.xforms.uicontrols;

import java.util.List;

import org.jdom.Element;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.xforms.XFormsConstants;

public abstract class XFormUIControl implements XFormsConstants{
	
    protected QuestionAnswerManager qaManager;
	
	public abstract List<Element> getControlElements();
	
	protected Element createLabel(String text)
	{
		Element labelElem = new Element(LABEL_TAG, XFORMS_NAMESPACE);
		labelElem.setText(text);
		return labelElem;
	}
	
	protected Element createRefLabel(String xPathRef)
	{
		Element labelElem = new Element(LABEL_TAG, XFORMS_NAMESPACE);
		labelElem.setAttribute("ref", xPathRef);
		return labelElem;
	}
	
}
