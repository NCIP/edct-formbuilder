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

import javax.persistence.CascadeType;
import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToOne;
import javax.persistence.PreUpdate;
import javax.persistence.Transient;

import org.springframework.security.core.context.SecurityContextHolder;

import com.healthcit.cacure.model.BaseQuestion.ChildrenRemovalType;

@Entity
@DiscriminatorValue("questionnaireForm")
public class QuestionnaireForm extends BaseForm{
    
	@OneToOne(orphanRemoval=true,mappedBy="form",cascade=CascadeType.ALL)
	private FormSkipRule formSkipRule ;
	
	@Transient
	private List<QuestionSkipRule> externalSkips;
	
	@ManyToOne
	@JoinColumn(name = "form_library_form_id")
	private FormLibraryForm formLibraryForm;
	
	/**
	 * default constructor
	 */
	public QuestionnaireForm() {
		status = FormStatus.IN_PROGRESS;
	}

	@Override
	public BaseModule getModule() {
		return module;
	}


	public void setModule(BaseModule module) {
		this.module = module;
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
	public void addElement(FormElement element) {
		if (element != null)
		{
			element.setForm(this);
			this.elements.add(element);
		}
	}

	public FormSkipRule getFormSkipRule() {
		return formSkipRule;
	}

	public void setFormSkipRule(FormSkipRule rule)
	{
		this.formSkipRule = rule;
		if(rule != null)
		{
			this.formSkipRule.setForm(this);
		}
	}

	@Override
	protected EnumSet<FormStatus> getAllowedStatuses() {
		return EnumSet.of(FormStatus.IN_PROGRESS, FormStatus.IN_REVIEW, FormStatus.APPROVED);
	}

	/*
	 * Returns a list of all the external questions which trigger skips in this form
	 */	
	public List<QuestionSkipRule> getCrossFormSkips() {
		if ( externalSkips == null ) {
			externalSkips = new ArrayList<QuestionSkipRule>();
			for(FormElement element: elements)
			{
				FormElementSkipRule skipRule = element.getSkipRule();
				if(skipRule != null)
				{
					for (QuestionSkipRule questionSkip: skipRule.getQuestionSkipRules())
					{
						if ( questionSkip.isExternalSkip(element) ) {
							externalSkips.add( questionSkip );
						}
					}
				}
			}
//			for ( Iterator<FormElement> iterA = elements.iterator(); iterA.hasNext(); ) {
//				for ( Iterator<QuestionSkipRule> iterB = ((iterA.next()).getQuestionSkip()).iterator(); iterB.hasNext(); ){
//					QuestionSkipRule questionSkip = iterB.next();
//					if ( questionSkip.isExternalSkip(element) ) {
//						externalSkips.add( questionSkip );
//					}
//				}				
//			}
		
		}
		return externalSkips;
	}

	/**
	 * skip pattern is empty if it's Id is null and its valid flag is set to false
	 */
	private void removeExtraneousSkipPatterns(ChildrenRemovalType removalType)
	{
		if (formSkipRule == null)
			return;

		// going in normal way, as itertor goes however through each item
		/*
		Iterator<FormSkip> iter = this.formSkip.iterator();
		while (iter.hasNext())
		{
			FormSkip sp = iter.next();
			if(
				(removalType == ChildrenRemovalType.EMPTY_CHILDREN && sp.isEmpty()) ||
				(removalType == ChildrenRemovalType.INVALID_CHILDREN && ! sp.isValid())
			  )
				{
					iter.remove();
				}
		}
		*/

	}


	@Override
	public void removeExtraneousChildren(ChildrenRemovalType removalType)
	{
		removeExtraneousSkipPatterns(removalType);
	}

	/**
	 * Determines whether the form is editable by the current user in the
	 * context of the approval workflow (forms locking and submission). In this
	 * context a module is only editable when all these conditions are set:
	 * 1. The module to which it belongs is in IN_PROGRESS state
	 *    and
	 * 2a. It is unlocked, or locked by the current user.
	 * 3a. The form is not in APPROVED state
	 *    or
	 * 2b The form is new
	 * @return whether the form is editable
	 */
	@Override
	public boolean isEditable() {
		String curUsername = SecurityContextHolder.getContext().getAuthentication().getName();
		return getModule().isEditable() //Form is editable when module (owner of this form) is editable + 
				&& (this.isNew() //form is new (just created and not saved yet) 
						|| status == FormStatus.IN_PROGRESS 
							&& (lockedBy != null && lockedBy.getUserName().equals(curUsername)) //or in progress and meet lock rules
					);
	}

	public FormLibraryForm getFormLibraryForm() {
		return formLibraryForm;
	}


	public void setFormLibraryForm(FormLibraryForm formLibraryForm) {
		this.formLibraryForm = formLibraryForm;
	}

	@PreUpdate
	@SuppressWarnings("unused")
	private void preUpdate() {
		setFormLibraryForm(null);
	}
}
