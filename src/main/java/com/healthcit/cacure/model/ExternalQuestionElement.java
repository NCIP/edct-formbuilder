package com.healthcit.cacure.model;

import java.util.ArrayList;
import java.util.List;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.OneToOne;
import javax.persistence.Transient;

import org.apache.log4j.Logger;

import com.healthcit.cacure.model.Answer.AnswerType;

@Entity
@DiscriminatorValue("externalQuestion")
public class ExternalQuestionElement extends FormElement {
	
	public enum QuestionSource {CA_DSR}
	
	@Transient
	private static final Logger logger = Logger.getLogger(ExternalQuestionElement.class);

	@OneToOne(orphanRemoval = true, mappedBy="questionElement",cascade=CascadeType.ALL, fetch=FetchType.LAZY)
	private ExternalQuestion question;
	
	@Column(name="external_id")
	private String externalId;
	
	@Column(name="external_uuid")
	private String externalUuid;
	
	@Column(name="external_version")
	private Float externalVersion;

	@Column(name="link_id")
	private String linkId;
	
	@Enumerated (EnumType.STRING)
	@Column(name="link_source")
	private QuestionSource externalLinkSource;


	public ExternalQuestion getQuestion()
	{
		return question;
	}


	public void setQuestion(ExternalQuestion question)
	{
		this.question = question;
		question.setQuestionElement(this);
	}
	/* default constructor
	 *
	 */
	public ExternalQuestionElement()
	{
	}

	public void setAnswerType(AnswerType answerType)
	{
		this.answerType = answerType.toString();
	}
	public void setExternalLinkSource(QuestionSource source)
	{
	    this.externalLinkSource = source;	
	}
	
	public QuestionSource getExternalLinkSource()
	{
		return externalLinkSource;
	}
	public String getSourceId() {
		return externalId;
	}

	public void setSourceId(String externalId) {
		this.externalId = externalId;
	}
	
	
	public String getExternalUuid() {
		return externalUuid;
	}

	public void setExternalUuid(String externalUuid) {
		this.externalUuid = externalUuid;
	}
	
	public void setLink(QuestionSource source, String linkId)
	{
		    this.linkId = linkId;
		    this.externalId = linkId;
		    this.externalLinkSource = source;
	}

	public String getLinkId()
	{
		return linkId;
	}

   public void unlink()
   {
	   linkId = null;
   }   
	
	public Float getExternalVersion() {
		return externalVersion;
	}
	
	
	public void setExternalVersion(Float externalVersion) {
		this.externalVersion = externalVersion;
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

	/**
	 * Returns whether or not this question has any skips associated with it
	 */
//	public boolean hasSkips() {
//		return !getQuestionSkip().isEmpty();
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
	public boolean isTable(){
		return false;
	}
	@Override
	public boolean isLink()
	{
		return true;
	}
	@Override
	public boolean isExternalQuestion()
	{
		return true;
	}
	@Override
	public boolean isSimpleQuestion() {
		return false;
	}
	@Override
	public ExternalQuestionElement clone()
	{
		ExternalQuestionElement newQuestionElement = new ExternalQuestionElement();
		deepCopy(this, newQuestionElement);
		return newQuestionElement;
	}

	@Override
	public void resetId()
	{
		this.id = null;
		question.resetId();
	}
	public static void copy(ExternalQuestionElement source, ExternalQuestionElement target)
	{
		FormElement.copy(source, target);
		target.setLink(source.getExternalLinkSource(), source.getSourceId());
		target.setExternalUuid(source.getExternalUuid());
	}
	public static void deepCopy(ExternalQuestionElement source, ExternalQuestionElement target)
	{
		FormElement.copy(source, target);
		target.setLink(source.getExternalLinkSource(), source.getSourceId());
		target.setExternalUuid(source.getExternalUuid());
		ExternalQuestion newQuestion = source.getQuestion().clone();
		target.setQuestion(newQuestion);
	}
	
   @Override
public List<? extends BaseQuestion> getQuestions()
	{
		List<BaseQuestion> questions = new ArrayList<BaseQuestion>();
		questions.add(question);
		return questions;
	}
}
