/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller.admin;


import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.healthcit.cacure.businessdelegates.UserManager;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.UserCredentials;
import com.healthcit.cacure.utils.Constants;

@Controller
public class LdapListController {
	
	@RequestMapping(value=Constants.LDAP_LISTING_URI)
	public ModelAndView showLdapList() {
		return this.getModel();
	}
	
	/**
	 * @param moduleId Long
	 * @return view with list of QuestionnaireForm items
	 */
	private ModelAndView getModel() {		
		ModelAndView mav = new ModelAndView("ldapList"); // initialize with view name
		
		return mav;
	}


}	

