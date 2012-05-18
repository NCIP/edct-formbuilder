package com.healthcit.cacure.model;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;

import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;

@Entity
@DiscriminatorValue("formLibrary")
public class FormLibraryModule extends BaseModule{

	public enum AllowedeStatus {FORM_LIBRARY}
	
	public FormLibraryModule()
	{
		isLibrary = true;
		status = ModuleStatus.FORM_LIBRARY;
	}
	
	@Override
	protected EnumSet<ModuleStatus> getAllowedStatuses() {
		return EnumSet.of(ModuleStatus.FORM_LIBRARY);
	}
	
	public void setForms(List<FormLibraryForm> forms) {
		for (FormLibraryForm f: forms)
		{
			this.forms = new ArrayList<BaseForm>();
			this.forms.add(f);
			f.setModule(this);
		}
	}
	public void addForm(FormLibraryForm form)
	{
		form.setModule(this);
		this.forms.add(form);
	}
	@Override
	public boolean isEditable()
	{
		return true;
	}

	@Override
	public BaseForm newForm() {
		FormLibraryForm newForm = new FormLibraryForm();
		newForm.setModule(this);
		return newForm;
	}
}
