/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.businessdelegates;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.List;

import org.apache.commons.collections.CollectionUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import com.healthcit.cacure.dao.ModuleDao;
import com.healthcit.cacure.model.AnswerSkipRule;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.BaseModule.ModuleStatus;
import com.healthcit.cacure.model.FormLibraryForm;
import com.healthcit.cacure.model.FormLibraryModule;
import com.healthcit.cacure.model.FormSkipRule;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.model.QuestionSkipRule;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.model.Role.RoleCode;
import com.healthcit.cacure.model.UserCredentials;
import com.healthcit.cacure.security.UnauthorizedException;

public class ModuleManager {

	private static final Logger logger = Logger.getLogger(ModuleManager.class);

	@Autowired
	private ModuleDao moduleDao;

	@Autowired
	private UserManager userManager;

	@Autowired
	private FormManager formManager;
	
	@Autowired
	private UserManagerService userService;

	public void setUserManager(UserManager userManager) {
		this.userManager = userManager;
	}

	public List<Module> getAllModules() {
		return moduleDao.getOrderedModuleList();
	}
	
	public List<BaseModule> getLibraryModules()
	{
		return moduleDao.getLibraryModules();
	}

	public void addNewModule(BaseModule module) {
		UserCredentials user = userService.getCurrentUser();
		module.setAuthor(user);
		moduleDao.create(module);
	}
	
	@Transactional
	public void updateModule(BaseModule module){		
		moduleDao.save(module);
	}

	public void deleteModule(BaseModule module){
		moduleDao.delete(module);
	}

	public BaseModule getModule(Long id){
		return moduleDao.getById(id);
	}

	public BaseModule getModule(String uuid){
		return moduleDao.getByUUID(uuid);
	}
	/**
	 * Deletes only module with empty forms, otherwise throws NoResultException exception.
	 * @param moduleId Long
	 */
	@Transactional
	public void deleteModuleWithEmptyForms(Long moduleId) {
		moduleDao.deleteModuleWithEmptyForms(moduleId);
	}


	public void setModuleDao(ModuleDao aModuleDao) {
		this.moduleDao = aModuleDao;
	}

	public void setFormManager(FormManager formManager) {
		this.formManager = formManager;
	}

	@Transactional
	public void setToInProgress(Module module) {
		if(logger.isDebugEnabled()) {
			logger.debug("Entering decideApproval module.id = " + module.getId());
		}

		if(!userService.isCurrentUserInRole(RoleCode.ROLE_APPROVER) && !this.userService.isCurrentUserInRole(RoleCode.ROLE_ADMIN)) {
			throw new UnauthorizedException("The user must be in approver role in order to set statuse for modules.");
		}

		module.setStatus(ModuleStatus.IN_PROGRESS);
		updateModule(module);
	}

	@Transactional
	public void approveForPilot(Module module) {

		if(logger.isDebugEnabled()) {
			logger.debug("Entering approveForPilot module.id = " + module.getId());
		}

		if(!userService.isCurrentUserInRole(RoleCode.ROLE_APPROVER) && !this.userService.isCurrentUserInRole(RoleCode.ROLE_ADMIN)) {
			throw new UnauthorizedException("The user must be in approver role in order to set statuse for modules.");
		}

		boolean allModuleFormsApproved = formManager.areAllModuleFormsApproved(module.getId());
		if(!allModuleFormsApproved) {
			throw new RuntimeException("There must be at least one form in the module "
					+ " and all its forms must be in approved status");
		}

		if(module.getStatus() == ModuleStatus.IN_PROGRESS) {			
			module.setStatus(ModuleStatus.APPROVED_FOR_PILOT);
			updateModule(module);
		} else {
			throw new RuntimeException("The module must be in IN_PROGRESS state");
		}
	}

	@Transactional
	public void approveForProduction(Module module) {
		if(logger.isDebugEnabled()) {
			logger.debug("Entering approveForProduction module.id = " + module.getId());
		}

		if(!userService.isCurrentUserInRole(RoleCode.ROLE_APPROVER) && !this.userService.isCurrentUserInRole(RoleCode.ROLE_ADMIN)) {
			throw new RuntimeException("The user must be in approver role in order to set statuse for modules.");
		}

		boolean allModuleFormsApproved = formManager.areAllModuleFormsApproved(module.getId());
		if(!allModuleFormsApproved) {
			throw new RuntimeException("There must be at least one form in the module "
					+ " and all its forms must be in approved status");
		}

		if(module.getStatus() == ModuleStatus.APPROVED_FOR_PILOT) {			
			module.setStatus(ModuleStatus.APPROVED_FOR_PRODUCTION);			
			updateModule(module);
		} else {
			throw new UnauthorizedException("The module must be in APPROVED_FOR_PILOT state");
		}
	}
	
	@Transactional
	public void release(Module module) {
		if(logger.isDebugEnabled()) {
			logger.debug("Entering release form.id = " + module.getId());
		}

		if(!userService.isCurrentUserInRole(RoleCode.ROLE_APPROVER) && !this.userService.isCurrentUserInRole(RoleCode.ROLE_ADMIN)) {
			throw new UnauthorizedException("The user must be in approver role in order to set statuse for modules.");
		}

		boolean allModuleFormsApproved = formManager.areAllModuleFormsApproved(module.getId());
		if(!allModuleFormsApproved) {
			throw new RuntimeException("There must be at least one form in the module "
					+ " and all its forms must be in approved status");
		}

		if(module.getStatus() == ModuleStatus.APPROVED_FOR_PILOT || module.getStatus() == ModuleStatus.APPROVED_FOR_PRODUCTION) {
			module.setStatus(ModuleStatus.RELEASED);
			updateModule(module);
		} else {
			throw new RuntimeException("The module must be in APPROVED_FOR_PRODUCTION state");
		}
	}

	/**
	 * Determines whether the current entity is open to modifications in the current
	 * context
	 * @param module
	 * @return true when editable
	 */
	public Boolean isEditableInCurrentContext(BaseModule module) {
		EnumSet<RoleCode> roleCodes = userService.getCurrentUserRoleCodes();
		
		boolean hasPermissions = module.isLibrary() ? 
				roleCodes.contains(RoleCode.ROLE_ADMIN) || roleCodes.contains(RoleCode.ROLE_LIBRARIAN)
				: roleCodes.contains(RoleCode.ROLE_AUTHOR) || roleCodes.contains(RoleCode.ROLE_ADMIN);

		if(module.isNew()) {

			if(logger.isDebugEnabled()) {
				logger.debug("isEditableInCurrentContext: New module; hasPermissions = " + hasPermissions);
			}

			return hasPermissions;

		} else {
			boolean isModuleInProperStateStatus = module.isEditable() || (CollectionUtils.isEmpty(module.getForms()) && roleCodes.contains(RoleCode.ROLE_ADMIN));

// for modules - as long as you are allowed (see logic above) you can modify it
// does not have to be a module owner
//			UserCredentials user = userManager.getCurrentUser();
//			boolean isUserModuleAuthor =
//				module.getAuthor().getUserName().equals(user.getUserName());

			if(logger.isDebugEnabled()) {
				logger.debug("isEditableInCurrentContext: " +
						"moduleId = " + module.getId()
						+ " isModuleInProgress = " + isModuleInProperStateStatus
//						+ " isUserModuleAuthor = " + isUserModuleAuthor
						+ " hasPermissions = " + hasPermissions);
			}

			return hasPermissions && isModuleInProperStateStatus;
			//&&	isUserModuleAuthor;
		}
	}
	
	@Transactional
	public Module copyModule(Module moduleToCopy) {
		EnumSet<RoleCode> roleCodes = userService.getCurrentUserRoleCodes();
		if(roleCodes.contains(RoleCode.ROLE_ADMIN) || roleCodes.contains(RoleCode.ROLE_LIBRARIAN)) {
			List<BaseForm> formsToCopy = new ArrayList<BaseForm>(moduleToCopy.getForms());
			Module copiedModule = new Module();
			Module.copyInformationFields(moduleToCopy, copiedModule);
			addNewModule(copiedModule);
			FormLibraryModule formLibraryModule = (FormLibraryModule) formManager.getLibraryModule(FormLibraryModule.class);
			HashMap<Long, Long> oldFormIdsNewFormIdsMap = new HashMap<Long, Long>();
			HashMap<String, String> oldAnswerValueIdsNewAnswerValueIdsMap = new HashMap<String, String>();
			for (BaseForm formToCopy : formsToCopy) {
				QuestionnaireForm questionnaireFormToCopy = (QuestionnaireForm) formToCopy;
				FormLibraryForm importedFormLibraryForm = questionnaireFormToCopy.getFormLibraryForm(); 
				if(importedFormLibraryForm == null) {
					importedFormLibraryForm = (FormLibraryForm) formManager.importFormToModule(formLibraryModule, formToCopy, true, oldAnswerValueIdsNewAnswerValueIdsMap);
				}
				QuestionnaireForm copiedForm = (QuestionnaireForm) formManager.importFormToModule(copiedModule, importedFormLibraryForm, false, oldAnswerValueIdsNewAnswerValueIdsMap);
				oldFormIdsNewFormIdsMap.put(copiedForm.getId(), importedFormLibraryForm.getId());
				if(questionnaireFormToCopy.getFormSkipRule() != null) {
					FormSkipRule clonedFormSkipRule = cloneFormSkipRule(questionnaireFormToCopy, copiedForm, oldFormIdsNewFormIdsMap, oldAnswerValueIdsNewAnswerValueIdsMap);
					copiedForm.setFormSkipRule(clonedFormSkipRule);
					formManager.updateFormLibraryForm(copiedForm, importedFormLibraryForm);
				}
			}
			return copiedModule;
		} else {
			throw new UnauthorizedException("The user must have either ADMIN or LIBRARIAN role in order to copy modules.");
		}
	}
	
	private FormSkipRule cloneFormSkipRule(final QuestionnaireForm form, final QuestionnaireForm newForm, final HashMap<Long, Long> oldFormIdsNewFormIdsMap, HashMap<String, String> oldAnswerValueIdsNewAnswerValueIdsMap) {
		FormSkipRule formSkipRuleToClone = form.getFormSkipRule();
		
		FormSkipRule clonedFormSkipRule = null;
		if(formSkipRuleToClone != null) {
			clonedFormSkipRule = new FormSkipRule();
			clonedFormSkipRule.setLogicalOp(formSkipRuleToClone.getLogicalOp());
			
			List<QuestionSkipRule> questionSkipRulesToClone = formSkipRuleToClone.getQuestionSkipRules();
			
			for(QuestionSkipRule questionSkipRuleToClone: questionSkipRulesToClone) {
				QuestionSkipRule clonedQuestionSkipRule = questionSkipRuleToClone.clone();
				clonedQuestionSkipRule.setLogicalOp(questionSkipRuleToClone.getLogicalOp());
				List<AnswerSkipRule> skipPartsToClone = questionSkipRuleToClone.getSkipParts();
				for (AnswerSkipRule skipPartToClone : skipPartsToClone) {
					AnswerSkipRule clonedSkipPart = new AnswerSkipRule();
					String answerValueId = oldAnswerValueIdsNewAnswerValueIdsMap.containsKey(skipPartToClone.getAnswerValueId()) 
							? oldAnswerValueIdsNewAnswerValueIdsMap.get(skipPartToClone.getAnswerValueId())
							: skipPartToClone.getAnswerValueId();
					clonedSkipPart.setAnswerValueId(answerValueId);
					Long formId = oldFormIdsNewFormIdsMap.containsKey(skipPartToClone.getFormId())
							? oldFormIdsNewFormIdsMap.get(skipPartToClone.getFormId())
							: skipPartToClone.getFormId();
					clonedSkipPart.setFormId(formId);
					clonedSkipPart.setParentSkip(clonedQuestionSkipRule);
					clonedQuestionSkipRule.getSkipParts().add(clonedSkipPart);
				}
				clonedFormSkipRule.addQuestionSkipRule(clonedQuestionSkipRule);
			}
		}
		return clonedFormSkipRule;
	}
}
