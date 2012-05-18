package com.healthcit.cacure.businessdelegates;

import java.util.EnumSet;
import java.util.List;

import org.apache.commons.collections.CollectionUtils;
import org.apache.log4j.Logger;
import org.jboss.util.collection.CollectionsUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import com.healthcit.cacure.dao.ModuleDao;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.BaseModule.ModuleStatus;
import com.healthcit.cacure.model.Module;
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
		UserCredentials user = userManager.getCurrentUser();
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

		if(!userManager.isCurrentUserInRole(RoleCode.ROLE_APPROVER) && !this.userManager.isCurrentUserInRole(RoleCode.ROLE_ADMIN)) {
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

		if(!userManager.isCurrentUserInRole(RoleCode.ROLE_APPROVER) && !this.userManager.isCurrentUserInRole(RoleCode.ROLE_ADMIN)) {
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

		if(!userManager.isCurrentUserInRole(RoleCode.ROLE_APPROVER) && !this.userManager.isCurrentUserInRole(RoleCode.ROLE_ADMIN)) {
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

		if(!userManager.isCurrentUserInRole(RoleCode.ROLE_APPROVER) && !this.userManager.isCurrentUserInRole(RoleCode.ROLE_ADMIN)) {
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
		EnumSet<RoleCode> roleCodes = userManager.getCurrentUserRoleCodes();
		
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
}
