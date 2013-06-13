/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;

import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;

@Entity
@DiscriminatorValue("questionLibraryForm")
public class QuestionLibraryForm extends BaseForm
{

	public enum AllowedElements {QuestionElement, TableElement, ExternalQuestionelement, ContentElement}
	
	public QuestionLibraryForm()
	{
		status = FormStatus.QUESTION_LIBRARY;
	}
	@Override
	public  QuestionsLibraryModule getModule() {
		return (QuestionsLibraryModule)module;
	}

	public void setModule(QuestionsLibraryModule module) {
		this.module = module;
	}

	@Override
	protected EnumSet<FormStatus> getAllowedStatuses() {
		return EnumSet.of(FormStatus.QUESTION_LIBRARY);
	}
	
	@Override
	public void setElements(List<FormElement> elements) {
		//this.questions = questions;
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
