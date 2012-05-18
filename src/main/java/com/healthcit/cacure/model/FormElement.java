package com.healthcit.cacure.model;

import java.io.Serializable;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import javax.persistence.Basic;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.DiscriminatorColumn;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.OneToOne;
import javax.persistence.PrePersist;
import javax.persistence.PreRemove;
import javax.persistence.PreUpdate;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.Formula;
import org.hibernate.annotations.Proxy;

import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.utils.StringUtils;

@Entity
@Table(name="FORM_ELEMENT")
@Inheritance(strategy=InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name="ELEMENT_TYPE")
//@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
@BatchSize(size=250)
@Proxy(lazy=false)
public abstract class FormElement  implements StateTracker, Cloneable, Serializable
{
    @Transient
	private long serialVersionUID = 1l;
	public enum ChildrenRemovalType {INVALID_CHILDREN, EMPTY_CHILDREN}
	
	@Id
	@SequenceGenerator(name="genericSequence", sequenceName="\"GENERIC_ID_SEQ\"", allocationSize=1)
	@GeneratedValue(strategy=GenerationType.SEQUENCE, generator="genericSequence")
	protected Long id;
	
	protected String description;
	
	@Column(name="is_readonly", nullable=false)
	protected boolean readonly = false;

	@Column(name="uuid", nullable=false)
	protected String uuid;
	
	@Column(name="ord", nullable=false)
	protected Integer ord;

	@Column(name="learn_more", nullable=true)
	protected String learnMore;

	@Column(name="is_required", nullable=false)
	protected boolean required = false;

	@Column(name="is_visible", nullable=false)
	protected boolean visible = true;

	@ManyToMany(fetch = FetchType.LAZY)
	@JoinTable(name = "question_categries", joinColumns = @JoinColumn(name = "question_id"), inverseJoinColumns = @JoinColumn(name = "category_id"))
	protected Set<Category> categories = new LinkedHashSet<Category>();
	
	@Formula(value="(select a.type from answer a, question q where a.question_id = q.id and q.parent_id = id limit 1)")
	@Basic(fetch=FetchType.LAZY)
	protected String answerType = null;
	
	@Formula(value="(select lc.count from form_element_links_count_vw lc where lc.id=id)")
	@Basic(fetch=FetchType.LAZY)
	protected Integer linkCount = null;
	
	@Formula(value="(select lc.cnt from fe_approved_links_count_vw lc where lc.id=id)")
	@Basic(fetch=FetchType.LAZY)
	protected Integer approvedLinkCount = null;
	
	@ManyToOne(cascade={CascadeType.MERGE, CascadeType.PERSIST, CascadeType.REFRESH}, fetch=FetchType.LAZY)
	@JoinColumn(name="form_id")
	private BaseForm form =  null;

//	@OneToMany(orphanRemoval=true, mappedBy="element",cascade={CascadeType.ALL}, fetch=FetchType.LAZY )
//	@OrderBy("id ASC")
//	private List<FormElementSkip> questionSkip = new ArrayList<FormElementSkip>();
//	@OneToOne(orphanRemoval=true, mappedBy="element",cascade={CascadeType.ALL})
	@OneToOne(mappedBy="element",cascade={CascadeType.ALL},fetch=FetchType.LAZY)
	private FormElementSkipRule skipRule = null;
	
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
	
	public Integer getLinkCount()
	{
		return linkCount == null ? 0 : linkCount;
	}
	
	public Integer getApprovedLinkCount()
	{
		return approvedLinkCount == null ? 0 : approvedLinkCount;
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
	
	/**
	 * @return the description
	 */
	public String getDescription() {
		return description;
	}
	/**
	 * @param description the description to set
	 */
	public void setDescription(String description) {
		this.description = description;
	}

	public BaseForm getForm() {
		return form;
	}

	public void setForm(BaseForm form) {
		this.form = form;
	}
/*	public String getShortName() {
		return shortName;
	}
*/
	public Integer getOrd() {
		return ord;
	}

	public void setOrd(Integer ord) {
		this.ord = ord;
	}

	/* FormElement only has a getter for the answerType,
	 * to prevent setting the AnswerType for objects 
	 * that do not have answer of it's own such as Content and Link
	 */
	public AnswerType getAnswerType()
	{
	
		if(answerType != null)
		{
			return AnswerType.valueOf(answerType);
		}
		else 
		{
			return null;
		}
	}
	
	public void setAnswerType(String answerType)
	{
		this.answerType = answerType;
	}
	
	/**
	 * @param shortName the shortName to set
	 */
/*	public void setShortName(String shortName) {
		this.shortName = shortName;
	}
	*/
	/*
	public QuestionSource getSource() {
	    return linkSource;
	}

	public void setSource( QuestionSource source ) {
		this.linkSource = source;
	}	
	*/
	/**
	 * @return the learnMore
	 */
	public String getLearnMore() {
		return learnMore;
	}

	/**
	 * @param learnMore the learnMore to set
	 */
	public void setLearnMore(String learnMore) {
		this.learnMore = learnMore;
	}


	public Set<Category> getCategories() {
		return categories;
	}

	public void setCategories(Set<Category> categories) {
		this.categories = categories;
	}

  /**
	 * Returns whether or not this question shares the same form with otherQuestion
	 */
	public boolean hasSameForm( FormElement otherFromElement ) {
		if ( form == null || otherFromElement.getForm() == null )
			return ( form == otherFromElement.getForm() );
		return form.getId().equals( otherFromElement.getForm().getId() );
	}

	public boolean isVisible() {
		return visible;
	}

	public void setVisible(boolean visible) {
		this.visible = visible;
	}

	public boolean isRequired() {
		return required;
	}

	public void setRequired(boolean required) {
		this.required = required;
	}
	
	public boolean isReadonly() {
		return readonly;
	}

	public void setReadonly(boolean readonly) {
		this.readonly = readonly;
	}
	
//	public List<FormElementSkip> getQuestionSkip() {
//		return questionSkip;
//	}
	public FormElementSkipRule getSkipRule()
	{
		return skipRule;
	}
//	public void setQuestionSkip(List<FormElementSkip> questionSkipSet) {
//		//this.questionSkip = questionSkip;
//		if ( questionSkipSet != null ) {
//			if ( this.questionSkip != null ) this.questionSkip.clear();
//			for ( FormElementSkip qs : questionSkipSet )
//			{
//				if ( qs.isValid() ) addQuestionSkip( qs );
//			}
//		}
//	}

//	public void addQuestionSkip(FormElementSkip questionSkip) {
//		this.questionSkip.add(questionSkip);
//		questionSkip.setFormElement(this);
//	}

	public void setSkipRule(FormElementSkipRule rule)
	{
//		if(rule == null)
//		{
//			removeSkipRule();
//		}
		this.skipRule = rule;
		if(rule != null)
		{
			this.skipRule.setFormElement(this);
		}
	}
	
	public void removeSkipRule()
	{
//		if(this.skipRule != null)
//		{
//			this.skipRule.setFormElement(null);
//		}
		this.skipRule = null;
	}
	/**
	 * skip pattern is empty if it's Id is null and its valid flag is set to false
	 */
	protected void removeExtraneousSkipPatterns(ChildrenRemovalType removalType)
	{
		if (skipRule == null)
			return;

//		// going in normal way, as itertor goes however through each item
//		Iterator<FormElementSkip> iter = this.questionSkip.iterator();
//		while (iter.hasNext())
//		{
//			FormElementSkip sp = iter.next();
//			if(
//				(removalType == ChildrenRemovalType.EMPTY_CHILDREN && sp.isEmpty()) ||
//				(removalType == ChildrenRemovalType.INVALID_CHILDREN && ! sp.isValid())
//			  )
//				{
//					iter.remove();
//				}
//		}

	}
	
	@SuppressWarnings("unused")
	@Deprecated
	protected void removeExtraneousCategories() {
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
	
	@PrePersist
	public void onPrePersist()
	{
		if ( this.getUuid() == null )
			this.setUuid(UUID.randomUUID().toString());
		setDescription(StringUtils.normalizeString(getDescription()));
		updateForm();
	}

	@PreUpdate
	@PreRemove
	@SuppressWarnings("unused")
	private void onUpdate() {
		//updateForm();
		this.onPrePersist();
	}
	
	private void updateForm() {
		BaseForm form = getForm();
		form.setLastUpdatedBy(form.getLockedBy());
	}
	
	/**
	 * Returns whether or not this question has any skips associated with it
	 */
	public boolean hasSkips() {
		boolean hasSkips = false;
		
		if(skipRule != null)
		{
			if(skipRule.getQuestionSkipRules().isEmpty())
			{
				hasSkips = true;
			}
		}
		return hasSkips;
	}
	
	/**
	 * Returns whether or not this refers to a Table Question
	 * @author Oawofolu
	 * @return
	 */
	public abstract boolean isPureContent();
	
	public abstract boolean isTable();
	
	public abstract boolean isLink();
	
	public abstract boolean isExternalQuestion();
	
	public abstract boolean isSimpleQuestion();
	
	//public abstract QuestionType getType();
	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder(500);
		builder.append("Id: " + id);
		builder.append("Description: " + description);
		builder.append("Uuid: " + uuid);
		builder.append("Form's Id: " + form.getId());
		builder.append("Form's uuid: " + form.getUuid());
		builder.append("Learn More: " + learnMore);
		return builder.toString();
	}
	
	public abstract void prepareForPersist(); 

	public abstract void prepareForUpdate();

	public abstract void prepareForDelete();
	
	@Override
	public abstract FormElement clone();
		
	public static void copy(FormElement source, FormElement target)
	{
		target.setDescription(source.getDescription());
		target.setOrd(source.getOrd());
		target.setLearnMore(source.getLearnMore());
		target.setRequired(source.isRequired());
		target.setVisible(source.isVisible());
		if(source.getCategories()!= null)
		{
		target.setCategories(new LinkedHashSet<Category>(source.getCategories()));
		}
		if(source.getAnswerType()!= null)
		{
			target.setAnswerType(source.getAnswerType().name());
		}
	}
	public abstract List<? extends BaseQuestion> getQuestions();
	public abstract void resetId();
}
