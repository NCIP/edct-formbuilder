package com.healthcit.cacure.xforms.uicontrols.htmlcontrols;

import java.util.ArrayList;
import java.util.List;

import org.jdom.Element;

import com.healthcit.cacure.xforms.uicontrols.XFormUIControl;

public class HTMLSubmissionControl extends XFormUIControl
{
    protected String submissionIDREF;
    protected String label;
    protected String cssClass;

	public HTMLSubmissionControl(SubmissionControls controls)
	{
		this.submissionIDREF = controls.getIdRef();
		this.label = controls.getLabel();
		HTMLSubmissionControls htmlControls = HTMLSubmissionControls.valueOf(controls.name());
		this.cssClass = htmlControls.getCssClass();
	}

	@Override
	public List<Element> getControlElements()
	{

		Element submitElement = new Element(SUBMIT_TAG, XFORMS_NAMESPACE);
		submitElement.setAttribute("submission", this.submissionIDREF);
		submitElement.setAttribute("class", cssClass);
		submitElement.addContent(createLabel(label));
		List<Element> eList = new ArrayList<Element>();
		eList.add(submitElement);
		return eList;
	}

}
