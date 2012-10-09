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
package com.healthcit.cacure.web.controller;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.validation.Errors;
import org.springframework.validation.Validator;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import com.healthcit.cacure.model.UserCredentials;


/**
 * @author vetali
 *
 */
@Controller
@RequestMapping(value="/login")
public class LoginController {
	
	private static final Logger log = Logger.getLogger(LoginController.class);
	private static final String ATTR_VALIDATION_ERR = "validationErr";
	private static final int USER_NAME_MIN_CHARS = 2;
	private static final int PASSW_MIN_CHARS = 2;

	@RequestMapping(method = RequestMethod.GET)
	public ModelAndView showForm() {		
	     return new ModelAndView("login", "userCredentials", new UserCredentials());
	}

	@RequestMapping(method = RequestMethod.POST)
    public String onSubmit(UserCredentials userCredentials, BindingResult result, HttpServletRequest req, HttpServletResponse resp) {
    
		Validator validator = new UserCredentialsValidator();
		validator.validate(userCredentials, result);
		
		if (result.hasErrors()) {
			req.setAttribute(ATTR_VALIDATION_ERR, Boolean.TRUE);
			return "login";
		}
    	
 		StringBuilder jSecurityRedirect = new StringBuilder("j_security_check");
 		jSecurityRedirect.append("?userName=").append(userCredentials.getUserName());
 		jSecurityRedirect.append("&password=").append(userCredentials.getPassword());    	
		try {
			resp.sendRedirect(jSecurityRedirect.toString());
		} catch (IOException e) {
			log.error("could not redirect to j_security_check");
		}
    	
    	return "login";
	}	
    
    
    /**
     * inner class UserCredentialsValidator.
     * @author vetali
     *
     */
    class UserCredentialsValidator implements Validator {

        @Override
		public boolean supports(Class clazz) {
            if (clazz.equals(UserCredentials.class)) {
                return true;
            } else {
                return false;
            }
        }

        @Override
		public void validate(Object target, Errors errors) {
        	UserCredentials user = (UserCredentials) target;
    		//validate userName
        	String userName = user.getUserName();
        	if (userName == null || userName.isEmpty()) {
        		errors.reject("err.userName.required"); 
        		return;
        	}
        	if (userName.length() < USER_NAME_MIN_CHARS) {
        		errors.reject("err.userName.min"); 
        		return;    		
        	}
        	//validate password
        	String password = user.getPassword();
        	if (password == null || password.isEmpty()) {
        		errors.reject("err.passw.required"); 
        		return;
        	}
        	if (password.length() < PASSW_MIN_CHARS) {
        		errors.reject("err.passw.required"); 
        		return;    		
        	}
        }

    } //end inner class
	
}
