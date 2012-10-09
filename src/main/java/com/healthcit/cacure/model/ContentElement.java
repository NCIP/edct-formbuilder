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

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.Transient;

import org.apache.log4j.Logger;

@Entity
@DiscriminatorValue("content")
public class ContentElement extends FormElement {
	@Transient
	private static final Logger logger = Logger.getLogger(ContentElement.class);

	@Transient
	private static final List<ValueLabelPair<String, String>> listOfTypes;

	static
	{
		listOfTypes = new ArrayList<ValueLabelPair<String, String>>();
		for(ContentType qt:  ContentType.values())
		{
			listOfTypes.add(new ValueLabelPair<String, String>(qt.name(), qt.message));
		}
	}
	
	public enum ContentType {
		HEADING("Heading"),
		SUBHEADING("Subheading"),
		REGULAR("Regular"),
		CUSTOM("Custom");
		
		private ContentType(String message) {
			this.message = message;
		}

		private final String message;

		public String getMessage() {
			return message;
		}
		
	}
	
	public static ContentType DEFAULT_TYPE = ContentType.HEADING;
//	TODO Need to rename "table_type" db field to just "type". We are going to reuse this.
	@Column(name="table_type")
	@Enumerated (EnumType.STRING)
	private ContentType type = DEFAULT_TYPE;
	
	/**
	 * @return the type
	 */
	public ContentType getType() {
		return type;
	}
	/**
	 * @param type the type to set
	 */
	public void setType(ContentType type) {
		this.type = type;
	}

	/**
	 * @param description the description to set
	 */

	public List<ValueLabelPair<String, String>> getContentTypes()
	{
		return listOfTypes;
	}

	/**
	 * uuid is generate and must not be reset by the application
	 * @param uuid
	 */

  public void removeExtraneousChildren(ChildrenRemovalType removalType)
	{
		removeExtraneousSkipPatterns(removalType);
		super.removeExtraneousCategories();
	}


/*	@SuppressWarnings("unused")
	@Deprecated
	private void removeExtraneousCategories() {
		if (categories == null || categories.isEmpty()) {
			return;
		}
		Iterator<Category> iter = this.categories.iterator();
		while (iter.hasNext()) {
			Category category = iter.next();
			if (!category.isValid()) {
				iter.remove();
			}
		}
	}
*/

	/**
	 * skip pattern is empty if it's Id is null and its valid flag is set to false
	 */
/*	private void removeExtraneousSkipPatterns(ChildrenRemovalType removalType)
	{
		if (questionSkip == null)
			return;

		// going in normal way, as itertor goes however through each item
		Iterator<QuestionSkip> iter = this.questionSkip.iterator();
		while (iter.hasNext())
		{
			QuestionSkip sp = iter.next();
			if(
				(removalType == ChildrenRemovalType.EMPTY_CHILDREN && sp.isEmpty()) ||
				(removalType == ChildrenRemovalType.INVALID_CHILDREN && ! sp.isValid())
			  )
				{
					iter.remove();
				}
		}

	}
*/
	/**
	 * @return the learnMore
	 */

	@Transient
	public String getTypeAsString() {
		return type.name();
	}

	@Override
	public void prepareForPersist() {
		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
	}

	@Override
	public void prepareForUpdate() {
		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
	}

	@Override
	public void prepareForDelete() {
		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
	}

/*	public QuestionElement clone() {
		QuestionElement o = new QuestionElement();
		copy(this, o);
		return o;
	}
*/
	/**
	 * Returns whether or not this refers to a Table Question
	 * @author Oawofolu
	 * @return
	 */
	public boolean isTableQuestion(){
		return false ;
	}



	@Override
	public boolean isTable()
	{
		return false;
	}
	@Override
	public boolean isLink()
	{
		return false;
	}
	
	@Override
	public boolean isExternalQuestion()
	{
		return false;
	}
	
	@Override
	public boolean isSimpleQuestion() {
		return false;
	}
	
	/**
	 * Returns whether or not this entity represents a Pure Content entity
	 */
	@Override
	public boolean isPureContent(){
		return true;
	}
	@Override
	public ContentElement clone()
	{
		ContentElement newQuestionElement = new ContentElement();
		copy(this, newQuestionElement);
		return newQuestionElement;
	}

	public void resetId()
	{
		this.id = null;
	}
	public static void copy(ContentElement source, ContentElement target)
	{
		FormElement.copy(source, target);
	} 
	
	@Override
	public List<? extends BaseQuestion> getQuestions()
	{
		return null;
	}
	
	public Set<FormElement> getAllPossibleSkipAffectees()
	{
		/*Map<FormElement, String> tree = new HashMap<FormElement, String>();
		//if called from outside add itself as root
		tree.put(this, null);
		getAllPossibleSkipAffectees(tree);
		return tree.keySet();
		*/
		return null;
	}
	
	protected void getAllPossibleSkipAffectees(Map<FormElement, String> tree)
	{
		/*for(TableQuestion question: questions)
		{
			question.getAllPossibleSkipAffectees(tree);
		}
		*/
		
	}
}
