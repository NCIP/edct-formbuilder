/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller;

import java.util.Map;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.ModelAndView;

import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.businessdelegates.ModuleManager;
import com.healthcit.cacure.model.BaseModule;

public class BaseModuleEditController implements EditControllable{

	private static final Logger log = Logger.getLogger(BaseModuleEditController.class);

	public static final String COMMAND_NAME = "moduleCmd";

	@Autowired
    protected ModuleManager moduleMgr;

	@Autowired
	protected FormManager formManager;

	/**
	 * Determines whether the current entity is open to modifications in the current
	 * context
	 * @param module
	 * @return true when editable
	 */
	public boolean isEditable( BaseModule module) {
		return moduleMgr.isEditableInCurrentContext(module);
	}

	@Override
	@SuppressWarnings("unchecked")
	public boolean isModelEditable(ModelAndView mav)
	{

		Map map = mav.getModel();
		// get form from model
		Object o = map.get(COMMAND_NAME);
		if (o != null && o instanceof BaseModule )
		{
			return isEditable((BaseModule)o);
		}
		return false;
	}

	public void setModuleMgr(ModuleManager moduleMgr) {
		this.moduleMgr = moduleMgr;
	}

	public void setFormManager(FormManager formManager) {
		this.formManager = formManager;
	}
}
