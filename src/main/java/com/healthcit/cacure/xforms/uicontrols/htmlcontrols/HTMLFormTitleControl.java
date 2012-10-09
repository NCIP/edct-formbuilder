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

import com.healthcit.cacure.xforms.XFormsConstants;
import com.healthcit.cacure.xforms.XFormsUtils;
import com.healthcit.cacure.xforms.uicontrols.XFormUIControl;

public class HTMLFormTitleControl extends XFormUIControl
{

	@Override
	public List<Element> getControlElements()
	{

		Element formTitle = new Element(XFormsConstants.OUTPUT_TAG, XFormsConstants.XFORMS_NAMESPACE);
		formTitle.setAttribute("ref", XFormsUtils.getFormNameXPath());
		formTitle.setAttribute("class", XFormsConstants.FORM_TITLE_CSS_CLASS);
		
		List<Element> eList = new ArrayList<Element>();
		eList.add(formTitle);
		return eList;
	}

}
