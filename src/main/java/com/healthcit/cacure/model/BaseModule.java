package com.healthcit.cacure.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.EnumSet;
import java.util.List;
import java.util.UUID;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.DiscriminatorColumn;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;
import javax.persistence.PrePersist;
import javax.persistence.PreUpdate;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.Proxy;


@Entity
@Table(name="MODULE")
@Inheritance(strategy=InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name="MODULE_TYPE")
@Proxy(lazy=false)
public abstract class BaseModule implements StateTracker
{
	public enum ModuleStatus {IN_PROGRESS, APPROVED_FOR_PILOT, APPROVED_FOR_PRODUCTION, RELEASED, QUESTION_LIBRARY, FORM_LIBRARY}
	
	@Id
	@SequenceGenerator(name="genericSequence", sequenceName="\"GENERIC_ID_SEQ\"", allocationSize=1)
	@GeneratedValue(strategy=GenerationType.SEQUENCE, generator="genericSequence")
	protected Long id;

	@Column(name="uuid", nullable=false)
	protected String uuid;
	
	protected String description;

	protected String comments;
	
	@Column(name="update_date")
	private Date updateDate;

	@OneToMany(mappedBy="module", cascade = CascadeType.ALL)
	@OrderBy("ord")
	protected List<BaseForm> forms = new ArrayList<BaseForm>();
	
	@ManyToOne
	@JoinColumn(name="author_user_id")
	private UserCredentials author;

	@Enumerated (EnumType.STRING)
	@Column(nullable=false)
	protected ModuleStatus status = ModuleStatus.IN_PROGRESS;
	
	@Column(name="is_library")
	protected boolean isLibrary = false;
	
	@Column(name = "show_please_select_option")
	protected boolean showPleaseSelectOptionInDropDown = false;
	
	@Column(name = "insert_check_all_that_apply")
	protected boolean insertCheckAllThatApplyForMultiSelectAnswers = false;
	
	public ModuleStatus getStatus() {
		return status;
	}

	protected EnumSet<ModuleStatus> getAllowedStatuses() {
		return EnumSet.allOf(ModuleStatus.class);
	}
	
	public void setStatus(ModuleStatus status) {
		if(status != null && getAllowedStatuses().contains(status)) {
			this.status = status;
		}
	}
	
	public boolean isLibrary()
	{
		return isLibrary;
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
	
	/**
	 * @return the comments
	 */
	public String getComments() {
		return comments;
	}
	/**
	 * @param comments the comments to set
	 */
	public void setComments(String comments) {
		this.comments = comments;
	}

	/**
	 * @return the questionInfo
	 */
	public List<BaseForm> getForms() {
		return forms;
	}

	/**
	 * Retrieves the user who has created this module
	 * @return
	 */
	public UserCredentials getAuthor() {
		return author;
	}

	/**
	 * sets the user who has created this module
	 * @param author
	 */
	public void setAuthor(UserCredentials author) {
		this.author = author;
	}
	
	/**
	 * Retrieves timestamp of the module's last update
	 * @return
	 */
	public Date getUpdateDate() {
		return updateDate;
	}

	@PreUpdate
	private void setUpdateDate() {
		this.updateDate = new Date();
	}

	@PrePersist
	public void onPrePersist() {
		if ( this.getUuid() == null )
			this.setUuid(UUID.randomUUID().toString());
		setUpdateDate();
	}
	
	@Override
	public boolean isNew() {
		return (id == null);
	}
	
	public abstract boolean isEditable();
	/**
	 * Creates forms corresponding to this module
	 * @return
	 */
	public abstract BaseForm newForm();

	public boolean isShowPleaseSelectOptionInDropDown() {
		return showPleaseSelectOptionInDropDown;
	}

	public void setShowPleaseSelectOptionInDropDown(boolean showPleaseSelectOptionInDropDown) {
		this.showPleaseSelectOptionInDropDown = showPleaseSelectOptionInDropDown;
	}

	public String getUuid() {
		return uuid;
	}

	public void setUuid(String uuid) {
		this.uuid = uuid;
	}

	public boolean isInsertCheckAllThatApplyForMultiSelectAnswers() {
		return insertCheckAllThatApplyForMultiSelectAnswers;
	}

	public void setInsertCheckAllThatApplyForMultiSelectAnswers(
			boolean insertCheckAllThatApplyForMultiSelectAnswers) {
		this.insertCheckAllThatApplyForMultiSelectAnswers = insertCheckAllThatApplyForMultiSelectAnswers;
	}
}
