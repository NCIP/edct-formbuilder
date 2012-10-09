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
