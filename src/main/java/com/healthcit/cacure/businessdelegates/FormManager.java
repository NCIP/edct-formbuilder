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
package com.healthcit.cacure.businessdelegates;

import java.util.ArrayList;
import java.util.Collection;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import net.sf.json.JSONObject;

import org.apache.commons.collections.CollectionUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;

import com.healthcit.cacure.dao.FormDao;
import com.healthcit.cacure.dao.FormElementDao;
import com.healthcit.cacure.dao.QuestionDao;
import com.healthcit.cacure.dao.QuestionElementDao;
import com.healthcit.cacure.dao.SkipPatternDao;
import com.healthcit.cacure.model.AnswerSkipRule;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseForm.FormStatus;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.BaseModule.ModuleStatus;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.ContentElement;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.FormElementSkipRule;
import com.healthcit.cacure.model.FormLibraryForm;
import com.healthcit.cacure.model.FormLibraryModule;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.model.QuestionElement;
import com.healthcit.cacure.model.QuestionSkipRule;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.model.QuestionsLibraryModule;
import com.healthcit.cacure.model.Role.RoleCode;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.UserCredentials;
import com.healthcit.cacure.security.UnauthorizedException;
import com.healthcit.cacure.utils.MailSendingService;

public class FormManager {
	private static final Logger logger = Logger.getLogger(FormManager.class);
	private static final String NON_EMPTY_FORMS = "nonEmptyForms";

	@Autowired
	private FormDao formDao;
	
	@Autowired
	private FormElementDao formElementDao;

	@Autowired
	SkipPatternDao skipDao;
	
	@Autowired
	QuestionDao questionDao;

	@Autowired
	QuestionElementDao questionElementDao;

	@Autowired
	private UserManager userManager;
	
	@Autowired
	private UserManagerService userService;
	

	@Autowired
	private ModuleManager moduleManager;
	
	@Autowired
	private QuestionAnswerManager qaManager;

	@Autowired
	private MailSendingService mailSendingService;

    private ExecutorService executorService = Executors.newSingleThreadExecutor();
    
	public List<BaseForm> getModuleForms(long moduleId) {
		return formDao.getModuleForms(moduleId);
	}

	public boolean areAllModuleFormsApproved(Long moduleId) {
		boolean areAllFormsApproved =
			formDao.areAllModuleFormsApproved(moduleId);
		return areAllFormsApproved;
	}

	@Transactional
	public void addNewForm(BaseForm form) {

		form.prepareForPersist();

		//calculate Next Ord Number from table
		Integer ord = formDao.calculateNextOrdNumber(form.getModule().getId());
		if (ord == null) {
			ord = 1;
		}

		form.setOrd(ord);
		UserCredentials currentUser = userService.getCurrentUser();

		form.setAuthor(currentUser);
		// Forms are created locked by default.
		form.setLockedBy(currentUser);
		form.setLastUpdatedBy(currentUser);
		//persist in DB
		formDao.save(form);
	}

	/**
	 * Method to be called when the only changes on the form is its position
	 * or locking status, so there should be no locking/author check
	 * @param form
	 * @return
	 */

	@Transactional
	public BaseForm updateForm(BaseForm form ){
		if(!form.isEditable()) {
			throw new UnauthorizedException("This form is currently not editable");
		}
		UserCredentials currentUser = userService.getCurrentUser();
		form.setLastUpdatedBy(currentUser);
		form.prepareForUpdate();
		formDao.save(form);
		skipDao.skipPatternCleanup();
		return form;
	}
	
	@Transactional
	public JSONObject getFormStatusesJson(Long formId){
		JSONObject object = new JSONObject();
		BaseForm form = getForm(formId);
		object.put("elementSize", form.getElements().size());
		String curUsername = SecurityContextHolder.getContext().getAuthentication().getName();
		object.put("locked", form.isLocked());
		if(form.isLocked()) {
			object.put("lockedByUser", form.getLockedBy().getUserName());
		}
		object.put("requestedByUser", curUsername);
		object.put("formStatus", form.getStatus());
		object.put("moduleStatus", form.getModule().getStatus());
		long skipTriggerQuestionsCount = formDao.getSkipTriggerQuestionsCount(formId);
		object.put("skipTriggerQuestionsCount", skipTriggerQuestionsCount);
		return object;
	}
	
	@Transactional
	public BaseForm getForm(Long id) {
		return formDao.getById(id);
	}
	
	public BaseForm getForm(String uuid) {
		return formDao.getByUuid(uuid);
	}


	public void setFormDao(FormDao aFormDao) {
		this.formDao = aFormDao;
	}

	public void setMailSendingService(MailSendingService mailSendingService) {
		this.mailSendingService = mailSendingService;
	}

	public void setUserManager(UserManager userManager) {
		this.userManager = userManager;
	}

	public void setModuleManager(ModuleManager moduleManager) {
		this.moduleManager = moduleManager;
	}

	public QuestionAnswerManager getQaManager() {
		return qaManager;
	}

	public void setQaManager(QuestionAnswerManager qaManager) {
		this.qaManager = qaManager;
	}
	
	/**
	 * Deletes only form with empty questions, otherwise throws NoResultException exception.
	 * @param formId Long
	 */
	@Transactional
	public void deleteForm(Long formId) {
		BaseForm form = getForm(formId);
		EnumSet<RoleCode> currentUserRoleCodes = userService.getCurrentUserRoleCodes();
		boolean isAdmin = currentUserRoleCodes.contains(RoleCode.ROLE_ADMIN);
		if(!isAdmin && !isEditableInCurrentContext(form)) {
			throw new UnauthorizedException("The form is not editable in the current context");
		}
		boolean formHasNoElements = form.getElements().isEmpty();
		if(!isAdmin && !formHasNoElements) {
			throw new UnauthorizedException("You have no rights to delete non-empty form.");
		}
//		formDao.deleteFormWithEmptyQuestions(formId);
		form.prepareForDelete();
		unlinkForms(form);
		formDao.delete(form);
		if(!formHasNoElements) {
			skipDao.skipPatternCleanup();
		}
	}

	private void unlinkForms(BaseForm form) {
		if (form instanceof FormLibraryForm) {
			FormLibraryForm formLibraryForm = (FormLibraryForm) form;
			List<QuestionnaireForm> copies = new ArrayList<QuestionnaireForm>(formLibraryForm.getCopies());
			for (QuestionnaireForm questionnaireForm : copies) {
				questionnaireForm.setFormLibraryForm(null);
			}
			formLibraryForm.getCopies().clear();
		}
	}

	/**
	 * Unlocks the form
	 * @param form the form to be unlocked
	 */
	@Transactional
	public BaseForm unlockForm(Long formId) {
		UserCredentials currentUser = userService.getCurrentUser();
		BaseForm form = this.getForm(formId);
		if(!form.isLocked())
			throw new RuntimeException("The form is already unlocked.");
		if(form.getLockedBy().getId().equals(currentUser.getId()) || this.userService.isCurrentUserInRole(RoleCode.ROLE_ADMIN)) {			
			form.setLockedBy(null);
			form.setLastUpdatedBy(currentUser);
			form.prepareForUpdate();
			formDao.save(form);
		} else {
			throw new UnauthorizedException("Only the user who had locked the form or administrator, is allowed to unlock it");
		}
		
		return form;
	}

	/**
	 * Locks the form by the current user
	 * @param formId the form to be locked
	 */
	@Transactional
	public void lockForm(Long formId) {
		BaseForm form = this.getForm(formId);
		UserCredentials currentUser = userService.getCurrentUser();

		if(!form.isLocked()) {
			if(form instanceof QuestionnaireForm) {
				form.setLockedBy(currentUser);
				form.setLastUpdatedBy(currentUser);
				form.prepareForUpdate();
				formDao.save(form);
			} else {
				throw new RuntimeException("This operation is aproprate only for questionnaire form.");
			}
		} else {
			// TODO: Think up a better way !!
			throw new RuntimeException("The form is already locked.");
		}
	}

	/**
	 * This method submits is called when a form is submitted for approval.
	 * It marks the form as submitted for approval and notifies the Approvers
	 * of that via e-mail.
	 *
	 * @param form the form to be submitted for approval
	 */
	public void submitForApproval(final QuestionnaireForm form, final String webAppUri) {

		UserCredentials currentUser = userService.getCurrentUser();
		
		if(logger.isDebugEnabled()) {
			logger.debug("Entering submitForApproval form.id = " + form.getId() + " user.id = " + currentUser.getId() + (form.isLocked() ? "locked by user.id = " + form.getLockedBy().getId() : ""));
		}

		if(form.isLocked() && !form.getLockedBy().getId().equals(currentUser.getId()) && !this.userService.isCurrentUserInRole(RoleCode.ROLE_ADMIN)) {
			throw new UnauthorizedException("Only the author of the form can submit it for review");
		}
		
		if(form.getStatus() == FormStatus.IN_PROGRESS) {

			form.prepareForUpdate();

			form.setStatus(FormStatus.IN_REVIEW);

			final Set<UserCredentials> approvers = userService.loadUsersByRole(RoleCode.ROLE_APPROVER);
			
			Set<UserCredentials> administrators = userService.loadUsersByRole(RoleCode.ROLE_ADMIN);
			
			approvers.addAll(administrators);			

			formDao.save(form);
			
			executorService.submit(new Runnable() {
				@Override
				public void run() {
					for(UserCredentials approver: approvers) {
						mailSendingService.sendSubmittedSectionNotification(form, approver.getEmail(), webAppUri);
					}
				}
			});

		} else {
			throw new RuntimeException("The form must be in IN_PROGRESS state in order to be submited for review");
		}
	}


	/**
	 * This method is supposed to be executed by a ROLE_APPROVER user on a form,
	 * whose status is IN_REVIEW.
	 *
	 * @param form the form to be approved/rejected
	 * @param approve whether to approve or reject the form
	 */
	@Transactional
	public void decideApproval(QuestionnaireForm form, boolean approve) {

		if(logger.isDebugEnabled()) {
			logger.debug("Entering decideApproval form.id = " + form.getId() + " approve = " + approve);
		}

		EnumSet<RoleCode> currentUserRoleCodes = userService.getCurrentUserRoleCodes();
		if(!currentUserRoleCodes.contains(RoleCode.ROLE_APPROVER) && !currentUserRoleCodes.contains(RoleCode.ROLE_ADMIN)) {
			throw new UnauthorizedException("The user does not posses the appropriate role to approve/reject forms");
		}

		if(form.getStatus() == FormStatus.IN_REVIEW){
			form.prepareForUpdate();
			if(approve) {
				form.setStatus(FormStatus.APPROVED);
			} else {
				form.setStatus(FormStatus.IN_PROGRESS);
			}
			formDao.update(form);
		}
		// If all the forms are approved, we implicitly set the module status to approved
		if(form.getStatus() == FormStatus.APPROVED && form.getModule() instanceof Module) {

			Module module = (Module)form.getModule();
			boolean areAllFormsApproved = areAllModuleFormsApproved(module.getId());

			if(areAllFormsApproved) {
				moduleManager.approveForPilot(module);
			}
		}
	}
	
	/**
	 * Determines whether the current form is editable in the current context
	 * (current user, locking and approval status, etc).
	 * @param form The current form
	 * @return true if editable
	 */
	public Boolean isEditableInCurrentContext(BaseForm form) {
		EnumSet<RoleCode> roleCodes = userService.getCurrentUserRoleCodes();
		
		boolean hasPermissions = form.isLibraryForm() ? 
				roleCodes.contains(RoleCode.ROLE_ADMIN) || roleCodes.contains(RoleCode.ROLE_LIBRARIAN)
				: roleCodes.contains(RoleCode.ROLE_ADMIN) || roleCodes.contains(RoleCode.ROLE_AUTHOR);
				
		if(form.isNew()) {
			if(logger.isDebugEnabled()) {
				logger.debug("isEditableInCurrentContext: New Form; hasPermissions = " + hasPermissions);
			}
			return hasPermissions;
		} else {
			boolean isFormEditable = form.isEditable();
			return isFormEditable && hasPermissions;
		}
	}

	public void reorderForms(Long sourceFormId, Long targetFormId,
			boolean before) {
		
		BaseForm form = getForm(sourceFormId);
		BaseModule module = form.getModule();
		
		if(module instanceof Module)
		{
			if(((Module)module).getStatus() == ModuleStatus.RELEASED) {
			throw new RuntimeException(
					"No form movement is possible after the module is released");
		}
		}
		formDao.reorderForms(sourceFormId, targetFormId, before);
	}
	
	public BaseForm getQuestionLibraryForm()
	{
		BaseForm form = null;
		BaseModule libraryModule = this.getLibraryModule(QuestionsLibraryModule.class);
		if(libraryModule != null && libraryModule.getForms() != null && libraryModule.getForms().size() > 0)
		{
			form = libraryModule.getForms().get(0);
		}

		return form;
	}
	
	@SuppressWarnings("unchecked")
	public Map<Long, Boolean> getAddToLibraryAvailability(BaseModule module,Map attributes)
	{
		Map<Long, Boolean> availabilityMap = new HashMap<Long, Boolean>();
		List<Long> nonEmptyFormIds = (List<Long>)attributes.get( NON_EMPTY_FORMS );
		if ( nonEmptyFormIds == null ) nonEmptyFormIds = getNonEmptyFormIDs( module.getId() );
		BaseForm questionLibraryForm = getQuestionLibraryForm();
		BaseModule formLibraryModule = getLibraryModule(FormLibraryModule.class);
		boolean requiredLibraryElementsExist = questionLibraryForm != null && formLibraryModule != null;
		boolean isLibraryModule = module.isLibrary();
		for(BaseForm form : module.getForms())
		{
			if(isLibraryModule)
			{
				availabilityMap.put(form.getId(), Boolean.FALSE);
				continue;
			}
			
			if(!requiredLibraryElementsExist)
			{
				availabilityMap.put(form.getId(), Boolean.FALSE);
				continue;
			}
			
			availabilityMap.put(form.getId(), nonEmptyFormIds.contains(form.getId()));
		}
		return availabilityMap;
	}
	
	public BaseModule getLibraryModule(Class<? extends BaseModule> moduleClass)
	{
		BaseModule libraryModule = null;
		for (BaseModule module : this.moduleManager.getLibraryModules()) 
		{
			if(module.getClass().equals(moduleClass))
			{
				libraryModule = module;
				break;
			}
		}
		return libraryModule;
	}
	
	/**
	 * Returns a list of form IDs associated with this module
	 * which have FormElements associated with them
	 */
	public List<Long> getNonEmptyFormIDs( Long moduleId )
	{
		if ( moduleId == null ) return new ArrayList<Long>();
		return formDao.getNonEmptyFormIDs( moduleId );
	}
	
	/**
	 * Adds question with <code>questionId</code> identifier to the questions library.<br/>
	 * The following steps performs:
	 * <ul>
	 * 	<li>Put original element to the first form of the questions library module and replace <code>uuid</code> with newly generated;</li>
	 *  <li>In original element create link to the created library element;</li>
	 *  <li>Update all element questions by replacing parent with newly generated id of the library element. </li>
	 * </ul>
	 * 
	 * @param question
	 *            - question to add to the library
	 * @return form element added to the library
	 */
	@Transactional
	public void addQuestionToQuestionLibrary(Long questionId)
	{
		this.addQuestionToQuestionLibraryImpl(questionId);
	}
		
	private void addQuestionToQuestionLibraryImpl(Long questionId) {
		BaseForm libraryForm = this.getQuestionLibraryForm();
		if (libraryForm != null) {
			FormElement formElement = this.formElementDao.getById(questionId);
			if(!(formElement instanceof QuestionElement || formElement instanceof TableElement)) {
				throw new RuntimeException("Only simple and table questions could be added to question library.");
			}
			BaseForm questionForm = formElement.getForm();
			String originalUuid = formElement.getUuid();
			formElement.setUuid(null);
			Integer originalOrd = formElement.getOrd();
			formElement.setOrd(this.questionElementDao
					.calculateNextOrdNumber(libraryForm.getId()));
			formElement.setForm(libraryForm);
			this.formElementDao.update(formElement);

			LinkElement link = new LinkElement();
			link.setLearnMore(formElement.getLearnMore());
			link.setRequired(formElement.isRequired());
			link.setReadonly(formElement.isReadonly());
			link.setVisible(formElement.isVisible());
			link.setDescription(formElement.getDescription());
			link.setForm(questionForm);
			link.setSource(formElement);
			link.setUuid(originalUuid);
			link.setOrd(originalOrd);
			link.setDescription(formElement.getDescription());
			
			//Check skips
			this.formElementDao.create(link);
			
			link.setSkipRule(formElement.getSkipRule());
			formElementDao.save(link);
		}
	}
	
	/**
	 * Adds form with <code>formId</code> identifier to the forms library.<br/>
	 * The following steps performs:<br>
	 * <ul>
	 * 	<li>Add all non link form elements to the questions libraries and replace those question with links;</li>
	 * 	<li>Create new form with the same name as original in forms library;</li>
	 *  <li>Fill library form with links to question created on first step.</li>
	 *  <li>External questions should be copied.</li>
	 *  <li>Skips will be recreated</li>
	 * </ul>
	 * 
	 * @param formId - form identifier to be added to the library
	 */
	@Transactional
	public void addFormToFormLibrary(Long formId)
	{
		if(!this.userService.isCurrentUserInRole(RoleCode.ROLE_ADMIN) && !this.userService.isCurrentUserInRole(RoleCode.ROLE_LIBRARIAN))
		{
			throw new UnauthorizedException("You have no permissions to add form to the library.");
		}
		FormLibraryModule formLibraryModule = (FormLibraryModule)this.getLibraryModule(FormLibraryModule.class);
		BaseForm originalForm = this.formDao.getById(formId);
		importFormToModule(formLibraryModule, originalForm, true, null);
	}
	
	@Transactional
	public void importFormToModule(final BaseModule module, final BaseForm form) {
		importFormToModule(module, form, false, null);
	}
	
	@Transactional
	public BaseForm importFormToModule(final BaseModule module, final BaseForm form, boolean importToQuestionLibrary, HashMap<String, String> oldAnswerValueIdsNewAnswerValueIdsMap) {
		BaseForm newForm = module.newForm();			
		newForm.setName(form.getName());
		this.addNewForm(newForm);
		Map<String, String> _oldAnswerValueIdsNewAnswerValueIdsMap = importQuestionsToForms(form,newForm,importToQuestionLibrary,true);
		
		
		if(oldAnswerValueIdsNewAnswerValueIdsMap != null) {
			oldAnswerValueIdsNewAnswerValueIdsMap.putAll(_oldAnswerValueIdsNewAnswerValueIdsMap);
		}
		
		if(module instanceof Module && form instanceof FormLibraryForm) {
			formDao.updateFormLibraryForm((QuestionnaireForm) newForm, (FormLibraryForm) form);
		} else if(module instanceof FormLibraryModule  && form instanceof QuestionnaireForm) {
			formDao.updateFormLibraryForm((QuestionnaireForm) form, (FormLibraryForm) newForm);
		}
		return newForm;
	}
	
	
	private FormElementSkipRule cloneFormElementSkipRule(final BaseForm newForm, final FormElement formElement) {
		//Have to retrieve it by Id otherwise the skip details do not load
		Long elementId = formElement.getId();
		FormElement fe = formElementDao.getById(elementId);
		FormElementSkipRule skipRule = fe.getSkipRule();
		
		FormElementSkipRule newSkipRule = null;
		if(skipRule != null) {
			newSkipRule = new FormElementSkipRule();
			newSkipRule.setLogicalOp(skipRule.getLogicalOp());
			
			List<QuestionSkipRule> skips = skipRule.getQuestionSkipRules();
			
			for(QuestionSkipRule skip: skips) {
				List<AnswerSkipRule> answerSkipRules = skip.getAnswerSkipRules();
				if(CollectionUtils.isNotEmpty(answerSkipRules)) {
					//Inner form skip
					if (answerSkipRules.get(0).getFormId().equals(formElement.getForm().getId())) {
						logger.debug("parent question belongs to this form.");
						QuestionSkipRule clonedSkip = skip.clone();
						String answerValueIds = skip.getAnswerValueId();
						
						clonedSkip.setAnswerValue(answerValueIds, newForm.getId());
						newSkipRule.addQuestionSkipRule(clonedSkip);
					}
				}
			}
		}
		return newSkipRule;
	}
	
	@Transactional
	public Collection<FormLibraryForm> findLibraryForms(String query)
	{
		return this.formDao.findLibraryForms(query);
	}
	
	@Transactional
	public Collection<FormLibraryForm> getAllLibraryForms()
	{
		return this.formDao.getAllLibraryForms();
	}

	@Transactional
	public void importForms(long moduleId, String[] formSet) {
		BaseModule module = this.moduleManager.getModule(moduleId);
		for (String formUuid : formSet) {
			BaseForm form = this.formDao.getByUuid(formUuid);
			importFormToModule(module, form);
		}
	}

	public Boolean isFormWithTheSameNameExistInLibrary(final String formName) {
		return this.formDao.isFormWithTheSameNameExistInLibrary(formName);
	}
	
	public FormLibraryForm getFormLibraryFormByName(final String formName) {
		return this.formDao.getFormLibraryFormByName(formName);
	}

	@Transactional
	public void setToInProgress(Long formId) {
		EnumSet<RoleCode> currentUserRoleCodes = userService.getCurrentUserRoleCodes();
		if(!currentUserRoleCodes.contains(RoleCode.ROLE_ADMIN) && !currentUserRoleCodes.contains(RoleCode.ROLE_APPROVER)) {
			throw new UnauthorizedException("Setting to 'In Progress' is possible for user with admin/approver role.");
		}
		
		BaseForm form = getForm(formId);
		if(form instanceof QuestionnaireForm)
		{
			form.setStatus(FormStatus.IN_PROGRESS);
			formDao.save(form);
			moduleManager.setToInProgress((Module) form.getModule());
		}
		else
		{
			throw new RuntimeException("Only QuestionnaireForm can be setted to 'In Progress' status");
		}
	}

	public int updateFormLibraryForm(QuestionnaireForm qForm, FormLibraryForm flForm) {
		return formDao.updateFormLibraryForm(qForm, flForm);
	}
	
	
	private boolean isQuestionAlreadyExists(Long formId, FormElement formElement){
		String uuid = null;
		if(formElement instanceof ContentElement)	{
			//uuid = formElement.getUuid();
			//return qaManager.isContentQuestionAlreadyExistsInForm(Long.parseLong(formId), uuid);
			return false;
		} else if(formElement instanceof ExternalQuestionElement){
			uuid = ((ExternalQuestionElement)formElement).getSourceId();
		} else {
			uuid = ((LinkElement)formElement).getSourceId();
		}
		return qaManager.isQuestionAlreadyExistsInForm(formId, uuid);
	}
	
	
	@Transactional
	public void getFormQuestions(String formUuid, String formId){	
		BaseForm form = this.formDao.getByUuid(formUuid);
		BaseForm destForm = this.formDao.getById(Long.parseLong(formId));		
		importQuestionsToForms(form,destForm,false,false);
	}
	
	
	@Transactional
	private Map<String, String> importQuestionsToForms(final BaseForm form, BaseForm newForm,boolean importToQuestionLibrary, boolean importFormToModule){
				
		List<FormElement> elements = new ArrayList<FormElement>(form.getElements());
		Map<String, String> _oldAnswerValueIdsNewAnswerValueIdsMap = new HashMap<String, String>();
		for (FormElement formElement : elements) {
			boolean questionExists = false;
			if(! importFormToModule){
				questionExists = isQuestionAlreadyExists(newForm.getId(),formElement);
			}
			
			if(!questionExists){
				FormElementSkipRule newSkipRule = cloneFormElementSkipRule(newForm, formElement);
				
				FormElement copy;
				if(formElement instanceof ContentElement)	{
					copy = formElement.clone();
				} else if(formElement instanceof ExternalQuestionElement)	{
					copy = formElement.clone();
					BaseQuestion question = copy.getQuestions().get(0);
					question.setShortName((question.getShortName() == null ? "" : question.getShortName()) + newForm.getId());
					_oldAnswerValueIdsNewAnswerValueIdsMap.putAll(qaManager.regenerateAnswerValuesPermanentIds(copy));
				} else {
					LinkElement link =  new LinkElement();
					copy = link;
					link.setOrd(formElement.getOrd());
					link.setLearnMore(formElement.getLearnMore());
					link.setDescription(formElement.getDescription());
					if (!(formElement instanceof LinkElement)) {
						if(importToQuestionLibrary) {
							this.addQuestionToQuestionLibraryImpl(formElement.getId());
						}
						link.setSource(formElement);
					} else {
						link.setSource(((LinkElement)formElement).getSourceElement());
						link.setDescription(link.getSourceElement().getDescription());
					}
				}
				
				
				if (newSkipRule != null && newSkipRule.getQuestionSkipRules().size() > 0) {
					List<QuestionSkipRule> questionSkipRules = newSkipRule.getQuestionSkipRules();
					for (QuestionSkipRule questionSkipRule : questionSkipRules) {
						List<AnswerSkipRule> answerSkipRules = questionSkipRule.getAnswerSkipRules();
						for (AnswerSkipRule answerSkipRule : answerSkipRules) {
							if(_oldAnswerValueIdsNewAnswerValueIdsMap.containsKey(answerSkipRule.getAnswerValueId())) {
								answerSkipRule.setAnswerValueId(_oldAnswerValueIdsNewAnswerValueIdsMap.get(answerSkipRule.getAnswerValueId()));
							}
						}
					}
					copy.setSkipRule(newSkipRule);
				}
				
				if(! importFormToModule){
					Integer ord = questionElementDao.calculateNextOrdNumber(newForm.getId());
					copy.setOrd(ord);
				} 					
				
				copy.setForm(newForm);
				formElementDao.save(copy);
				newForm.getElements().add(copy);
				
			}
		}
		
		return _oldAnswerValueIdsNewAnswerValueIdsMap;
	}
	
	
	

}
