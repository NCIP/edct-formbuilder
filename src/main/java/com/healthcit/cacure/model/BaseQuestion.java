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
import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.DiscriminatorColumn;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.hibernate.annotations.Proxy;

import com.healthcit.cacure.model.Answer.AnswerType;


@Entity
@Table(name="QUESTION")
@Inheritance(strategy=InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name="QUESTION_TYPE")
//@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
//@BatchSize(size=200)
@Proxy(lazy=false)
public abstract class BaseQuestion  extends DescriptionHolder implements StateTracker, Cloneable 
{

	@Transient
	private static final Logger logger = Logger.getLogger(BaseQuestion.class);
	
	
	public enum ChildrenRemovalType {INVALID_CHILDREN, EMPTY_CHILDREN}
//	public enum QuestionSource {LOCAL, CA_DSR}
	public enum QuestionType {CONTENT, SINGLE_ANSWER, MULTI_ANSWER}
	
	@Transient
	private static final List<ValueLabelPair<String, String>> listOfTypes;

	static
	{
		listOfTypes = new ArrayList<ValueLabelPair<String, String>>();
		for(QuestionType qt:  QuestionType.values())
		{
			listOfTypes.add(new ValueLabelPair<String, String>(qt.name(), qt.name()));
		}
	}
	@Id
	@SequenceGenerator(name="genericSequence", sequenceName="\"GENERIC_ID_SEQ\"", allocationSize=1)
	@GeneratedValue(strategy=GenerationType.SEQUENCE, generator="genericSequence")
	protected Long id;
		
	@Enumerated (EnumType.STRING)
	@Column(nullable=false)
	protected QuestionType type = QuestionType.SINGLE_ANSWER;

	@Column(name="uuid", nullable=false)
	String uuid;

	@Column(name="short_name")
	protected String shortName;

//	@OneToOne(orphanRemoval=true,mappedBy="question",cascade=CascadeType.ALL, fetch=FetchType.LAZY)
	@OneToOne(orphanRemoval=true,mappedBy="question",cascade=CascadeType.ALL, fetch=FetchType.EAGER)
	//@Transient
	protected Answer answer;
	/**
	 * skipAffectees refers to the set of questions whose skip patterns are based on this question's answer value(s)
	 */
	@OneToMany( mappedBy="skipTriggerQuestion", fetch=FetchType.LAZY)
	protected Set<BaseSkipPatternDetail> skipAffectees = new LinkedHashSet<BaseSkipPatternDetail>();
	
	/**
	 * @return the type
	 */
	public QuestionType getType() {
		return type;
	}
	/**
	 * @param type the type to set
	 */
	public void setType(QuestionType type) {
		this.type = type;
	}
	
	@Transient
	public String getTypeAsString() {
		return type.name();
	}

@Override
public boolean isNew() {
		return (id == null);

	}
	/**
	 * @return the id
	 */
	public Long getId() {
		return id;
	}
	/**
	 * @param id the id to set
	 */
	public void setId(Long id) {
		this.id = id;
	}
	
	public String getUuid()
	{
		return uuid;
	}
	/**
	 * uuid is generate and must not be reset by the application
	 * @param uuid
	 */
	public void setUuid(String uuid)
	{
		this.uuid = uuid;
	}

	public String getShortName() {
		return shortName;
	}

	public List<ValueLabelPair<String, String>> getQuestionTypes()
	{
		return listOfTypes;
	}
	
	public Set<BaseSkipPatternDetail> getSkipAffectees() {
		return skipAffectees;
	}
	public void setSkipAffectees(Set<BaseSkipPatternDetail> skipAffectees) {
		this.skipAffectees = skipAffectees;
	}
	/**
	 * @param shortName the shortName to set
	 */
	public void setShortName(String shortName) {
		this.shortName = shortName;
	}
	
	public Answer getAnswer()
	{
		return answer;
	}
	
	public void setAnswer(Answer answer)
	{
		answer.setQuestion(this);
		this.answer = answer;
	}
	
	public abstract FormElement getParent();
	/**
	 * Returns whether or not this question is associated with answers with multiple values
	 */
	/*
	public boolean getHasMultiAnswerType(){
		if ( CollectionUtils.isEmpty( getAnswers() )) return false;
		Answer firstAnswer = getAnswers().get( 0 );
		return firstAnswer.getType().getAnswerValueType().equals( AnswerValueType.MULTIPLE );
	}
	
	public List<Answer> getAnswers() {
		return answers;
	}
	public void setAnswers(List<Answer> answers) {
			this.answers.clear();
			for (Answer a : answers)
				addAnswer(a);
	}

	@Transient
	public Answer getFirstAnswer()
	{
		if (answers != null && answers.size() > 0)
		{
			return answers.get(0);
		}
		else
			return null;
	}
	public void addAnswer(Answer answer)
	{
		this.answers.add(answer);
		answer.setQuestion(this);
	}
	*/
	/*
	private void removeExtraneousAnswers(ChildrenRemovalType removalType)
	{
		if (answers == null)
			return;
		// going in reverse, as most invalid answers are in the back
		ListIterator<Answer> iter = this.answers.listIterator(answers.size());
		while (iter.hasPrevious())
		{
			Answer a = iter.previous();
			if(
				(removalType == ChildrenRemovalType.EMPTY_CHILDREN && a.isEmpty()) ||
				(removalType == ChildrenRemovalType.INVALID_CHILDREN && ! a.isValid())
			  )
			{
				iter.remove();
			}
		}

	}
*/
	public void setAnswerType( String answerType ){
		if ( answerType != null ) {
			AnswerType at = AnswerType.valueOf( answerType );
			setType( CollectionUtils.containsAny( Arrays.asList( at.getQuestionTypes() ),
					                 Arrays.asList( QuestionType.MULTI_ANSWER)) ?
					                 QuestionType.MULTI_ANSWER : QuestionType.SINGLE_ANSWER );
			
				answer.setType( at );
			
		}
	}
	/**
	 * This method sets correct order for answers without order
	 * This even should really never happen!
	 */
	private void processAnswers() {
		/* The JPA calls back is not fired prior to merge, but rather prior to commit,
		*  there though the method to convert constraint to a string has to be called manually
		*/
		answer.storeConstraint();
		for ( int j = 0; j < answer.getAnswerValues().size(); ++j )
		{
			AnswerValue answerValue = answer.getAnswerValues().get(j);
			if ( answerValue.getOrd() == null )
			{
				logger.error( "Forcing order onto an answer value - CHECK LOGIC - It should never happen" );
				answerValue.setOrd( j + 1 );
			}
		}		
	}
	
/*
	  public void removeExtraneousChildren(ChildrenRemovalType removalType)
		{
			removeExtraneousAnswers(removalType);
		}
		*/
	/**
	 * Returns the answer associated with this answer value
	 * @author Oawofolu
	 */
	/*
	public Answer getAssociatedAnswer(String answerValuePermanentId)
	{
		for ( Answer answer : answers )
		{
			for ( AnswerValue answerValue : answer.getAnswerValues() )
			{
				if ( answerValue.getPermanentId().equals(answerValuePermanentId)) {
					return answer;
				}
			}
		}
		return null;
	}
	*/
	/**
	 * Removes the answer value with the specified uuid from memory.
	 * (NOTE: Changes made here do NOT get persisted to the database
	 * until the entity is saved elsewhere.)
	 * @author Oawofolu
	 */
	
	public void removeAnswerValuesByUuid( String uidCommaDelimitedList )
	{
		for ( Iterator<AnswerValue> iterator = answer.getAnswerValues().iterator(); iterator.hasNext(); )
		{
			AnswerValue answerValue=iterator.next();
			if ( StringUtils.contains( uidCommaDelimitedList, answerValue.getPermanentId() ) ) {
				logger.debug("Removing answer value "+answerValue.getPermanentId());
				iterator.remove();
				uidCommaDelimitedList = uidCommaDelimitedList.replaceAll( ",?" + answerValue.getPermanentId() +",?", "");
				if ( StringUtils.isBlank( uidCommaDelimitedList ) ) return;
			}
		}
		
	}
	
	public void prepareForPersist() {
//		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
		processAnswers();
	}

	public void prepareForUpdate() {
//		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
		processAnswers();
	}

	public void prepareForDelete() {
//		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
		processAnswers();
	}

	@Override
	public abstract BaseQuestion clone();
	public abstract BaseQuestion copy();
	public static void deepCopy(BaseQuestion source, BaseQuestion target)
	{
		copy(source, target);
		Answer sourceAnswer = source.getAnswer();
		Answer targetAnswer = sourceAnswer.clone();
		target.setAnswer(targetAnswer);


	}
	public static void copy(BaseQuestion source, BaseQuestion target)
	{
		target.setShortName(source.getShortName());
		target.setType(source.getType());
	}
	
	public void resetId()
	{
		this.id = null;
		if(answer!=null)
		{
			answer.resetId();
		}
	}
	/**
	 * Returns the full list of questions whose visibility could possibly be affected
	 * when this question is hidden.
	 * This list will consist of:
	 * a) The list of skip affectees for this question,
	 * b) The list of skip affectees for each of the skip affectees in (a),
	 * c) The list of skip affectees for each of the skip affectees in (b), etc.
	 * @author Oawofolu
	 */


		
		// return a Set in order to remove duplicates that may exist
		
//		return tree.keySet();
		
	
	
	public boolean isCadsrQuestion()
	{
		return false;
	}
}
