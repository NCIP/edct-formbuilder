package com.healthcit.cacure.model;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.OneToOne;
import javax.persistence.Transient;

import org.apache.log4j.Logger;


@Entity
@DiscriminatorValue("question")
public class QuestionElement extends FormElement {
	@Transient
	private static final Logger logger = Logger.getLogger(QuestionElement.class);

	@OneToOne(orphanRemoval = true, mappedBy="questionElement",cascade=CascadeType.ALL, fetch=FetchType.LAZY)
	private Question question = null;

	/* default constructor
	 *
	 */
	public QuestionElement()
	{
	}
	public Question getQuestion()
	{
		return question;
	}


	public void setQuestion(Question question)
	{
		question.setQuestionElement(this);
		this.question = question;
		
	}
	

	/**
	 * uuid is generate and must not be reset by the application
	 * @param uuid
	 */

	public void removeExtraneousChildren(ChildrenRemovalType removalType)
	{
		removeExtraneousSkipPatterns(removalType);
		//super.removeExtraneousCategories();
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

	@Override
	public void prepareForPersist() {
		question.prepareForPersist();
		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
	}

	@Override
	public void prepareForUpdate() {
		question.prepareForUpdate();
		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
	}
	@Override
	public void prepareForDelete() {
		question.prepareForDelete();
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

//	/**
//	 * Returns whether or not this question has any skips associated with it
//	 */
//	public boolean hasSkips() {
//		boolean hasSkips = false;
//		BaseSkipRule skipRule = getSkipRule();
//		if(skipRule != null)
//		{
//			if(skipRule.getQuestionSkipRules().isEmpty())
//			{
//				hasSkips = true;
//			}
//		}
//		return hasSkips;
//	}


	/**
	 * Returns whether or not this entity represents a Pure Content entity
	 *
	 */
	@Override
	public boolean isPureContent(){
		return false;
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
		return true;
	}
	
	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder(500);
        builder.append(super.toString());
        if(question != null)
        {
        	builder.append("Question: " + question.toString() + "\n");
        }
		return builder.toString();
	}
	
	@Override
	public QuestionElement clone()
	{
		QuestionElement newQuestionElement = new QuestionElement();
		deepCopy(this, newQuestionElement);
		return newQuestionElement;
	}

	public static void copy(QuestionElement source, QuestionElement target)
	{
		FormElement.copy(source, target);
//		Question newQuestion = source.getQuestion().clone();
//		target.setQuestion(newQuestion);
	}
	
	public static void deepCopy(QuestionElement source, QuestionElement target)
	{
		FormElement.copy(source, target);
		Question newQuestion = source.getQuestion().clone();
		target.setQuestion(newQuestion);
	}

	public void resetId()
	{
		this.id = null;
		question.resetId();
	}
	
	@Override
	public List<BaseQuestion> getQuestions()
	{
		List<BaseQuestion> questions = new ArrayList<BaseQuestion>();
		questions.add(question);
		return questions;
	}

}
