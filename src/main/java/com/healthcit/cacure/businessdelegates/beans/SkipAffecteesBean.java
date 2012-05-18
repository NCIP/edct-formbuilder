package com.healthcit.cacure.businessdelegates.beans;

import java.util.HashSet;
import java.util.Set;

import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.FormElement;

public class SkipAffecteesBean {
	
	private Set<FormElement> formElements;
	private Set<BaseForm> forms;
	
	public SkipAffecteesBean() {
		super();
		this.formElements = new HashSet<FormElement>();
		this.forms = new HashSet<BaseForm>();
	}
	
	public SkipAffecteesBean(Set<FormElement> formElements, Set<BaseForm> forms) {
		super();
		this.formElements = formElements;
		this.forms = forms;
	}
	
	public SkipAffecteesBean(SkipAffecteesBean bean) {
		super();
		this.formElements = bean.formElements;
		this.forms = bean.forms;
	}
	
	public void add(SkipAffecteesBean bean) {
		this.formElements.addAll(bean.formElements);
		this.forms.addAll(bean.forms);
	}
	
	public void add(BaseForm form) {
		this.forms.add(form);
	}
	
	public void add(FormElement formElement) {
		this.formElements.add(formElement);
	}
	
	public Set<FormElement> getFormElements() {
		return formElements;
	}
	public Set<BaseForm> getForms() {
		return forms;
	}
}
