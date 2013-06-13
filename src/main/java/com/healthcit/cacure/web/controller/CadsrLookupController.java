/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;


@Controller
@RequestMapping(value="/cadsrLookUp.form")
public class CadsrLookupController {

	private static final Logger log = Logger.getLogger(CadsrLookupController.class);
	
	@RequestMapping(method = RequestMethod.GET)
	public ModelAndView showForm() {
		 
		 //TODO
	     return new ModelAndView("?????");
	}	
}

