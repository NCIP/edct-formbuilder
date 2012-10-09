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
