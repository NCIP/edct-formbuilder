package com.healthcit.cacure.model;

import java.io.Serializable;
import java.util.UUID;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.PrePersist;
import javax.persistence.PreRemove;
import javax.persistence.PreUpdate;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;

import com.healthcit.cacure.utils.StringUtils;

/**
 * @author User
 *
 */
@Entity
@Table(name="ANSWER_VALUE")
//@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
@BatchSize(size=100)
public class AnswerValue implements StateTracker, Cloneable, Serializable {

	private static final long serialVersionUID = -7810074116364112601L;

	@Id
	@SequenceGenerator(name="genericSequence", sequenceName="\"GENERIC_ID_SEQ\"", allocationSize=10)
	@GeneratedValue(strategy=GenerationType.SEQUENCE, generator="genericSequence")
	private Long id;

	@Column(name="short_name", nullable=false)
	private String name;

	@Column(name="description")
	private String description;

	@Column(name="value")
	private String value;

	@Column(name="ord", nullable=false)
	private Integer ord=0;

	//TODO remove this property its not needed.
	@ManyToOne(cascade={CascadeType.MERGE, CascadeType.PERSIST, CascadeType.REFRESH})
	@JoinColumn(name="answer_id")
	private Answer answer;

	@Transient
	private boolean valid=true;

	@Column(name="permanent_id", nullable=false)
	private String permanentId;
	
	@Column(name="external_id")
	private String externalId;
	
	@Column(name="cadsr_public_id")
	private Long cadsrPublicId;
	
	@Column(name="default_value")
	private boolean defaultValue;

	/**
	 * Helper constructor to generate invalid objects
	 * @param valid
	 */
	public AnswerValue() {
	}

	/**
	 * Helper constructor to generate invalid objects
	 * @param valid
	 */
	public AnswerValue(boolean valid) {
		this.valid = valid;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public Integer getOrd() {
		return ord;
	}

	public void setOrd(Integer ord) {
		this.ord = ord;
	}

	public Answer getAnswer() {
		return answer;
	}

	public void setAnswer(Answer answer) {
		this.answer = answer;
	}

	public boolean isValid() {
		return valid;
	}

	public void setValid(boolean valid) {
		this.valid = valid;
	}

	public Long getCadsrPublicId() {
		return cadsrPublicId;
	}

	public void setCadsrPublicId(Long cadsrPublicId) {
		this.cadsrPublicId = cadsrPublicId;
	}

	@Override
	public boolean isNew() {
		return (id == null);
	}

	@Override
	public AnswerValue clone() {
		AnswerValue o = new AnswerValue();
//		o.setDescription(description);
//		o.setName(name);
//		o.setOrd(ord);
//		o.setValid(valid);
//		o.setValue(value);
//		o.setPermanentId(null);
		copy(this, o);
		return o;
	}
	
	public void resetId()
	{
		this.id = null;
	}
	
	public static void copy(AnswerValue source, AnswerValue target) {
		target.setDescription(source.getDescription());
		target.setName(source.getName());
		target.setOrd(source.getOrd());
		target.setValid(source.isValid());
		target.setValue(source.getValue());
		target.setExternalId(source.getExternalId());
		target.setPermanentId(null);
		target.setDefaultValue(source.isDefaultValue());
	}

	public String getPermanentId() {
		return permanentId;
	}

	public void setPermanentId(String permanentId) {
		this.permanentId = permanentId;
	}
	
	public String getExternalId() {
		return externalId;
	}

	public void setExternalId(String externalId) {
		this.externalId = externalId;
	}

	@PrePersist
	public void onPrePersist()
	{
		if ( this.getPermanentId() == null )
			this.setPermanentId(UUID.randomUUID().toString());
		setDescription(StringUtils.normalizeString(getDescription()));
		updateForm();
	}
	
	@PreUpdate
	@PreRemove
	@SuppressWarnings("unused")
	private void onUpdate() {
		setDescription(StringUtils.normalizeString(getDescription()));
		updateForm();
	}

	private void updateForm() {
		BaseForm form = getAnswer().getQuestion().getParent().getForm();
		form.setLastUpdatedBy(form.getLockedBy());
	}

	public boolean isDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(boolean defaultValue) {
		this.defaultValue = defaultValue;
	}


}
