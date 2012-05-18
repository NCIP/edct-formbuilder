package com.healthcit.cacure.model;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;

import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;

@Entity
@DiscriminatorValue("formLibraryForm")
public class FormLibraryForm extends BaseForm{

	public enum AllowedElements {LinkElement, ExternalQuestionElement, ContentElement}
	
	public FormLibraryForm()
	{
		status = FormStatus.FORM_LIBRARY;
	}
	
	@Override
	public  FormLibraryModule getModule() {
		return (FormLibraryModule)module;
	}

	public void setModule(FormLibraryModule module) {
		this.module = module;
	}

	@Override
	protected EnumSet<FormStatus> getAllowedStatuses() {
		return EnumSet.of(FormStatus.FORM_LIBRARY);
	}
	
	@Override
	public void setElements(List<FormElement> elements) {
		this.elements = new ArrayList<FormElement>();
		for (FormElement q: elements)
		{
			addElement(q);
		}
	}

	@Override
	public void addElement(FormElement element)
	{
		if(element != null && AllowedElements.valueOf(element.getClass().getSimpleName())!= null)
		{
			element.setForm(this);
			this.elements.add(element);
		}
	}
	@Override
	public boolean isEditable()
	{
		return true;
	}
	@Override
	public boolean isLibraryForm()
	{
		return true;
	}
}
