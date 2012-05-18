package com.healthcit.cacure.model;

import java.util.EnumSet;

import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;

@Entity
@DiscriminatorValue("questionLibrary")
public class QuestionsLibraryModule extends BaseModule
{

	public enum AllowedeStatus {QUESTION_LIBRARY}
	public QuestionsLibraryModule()
	{
		isLibrary = true;
		status = ModuleStatus.QUESTION_LIBRARY;
	}
	
	@Override
	protected EnumSet<ModuleStatus> getAllowedStatuses() {
		return EnumSet.of(ModuleStatus.QUESTION_LIBRARY);
	}
	
	@Override
	public boolean isEditable()
	{
		return true;
	}
	
	@Override
	public BaseForm newForm() {
		QuestionLibraryForm newForm = new QuestionLibraryForm();
		newForm.setModule(this);
		return newForm;
	}
	
}
