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
package com.healthcit.cacure.web.controller.admin;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;
import org.directwebremoting.annotations.RemoteMethod;
import org.directwebremoting.annotations.RemoteProxy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.authentication.encoding.MessageDigestPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.businessdelegates.UserManager;
import com.healthcit.cacure.model.Role;
import com.healthcit.cacure.model.UserCredentials;
import com.healthcit.cacure.utils.Constants;


@Controller
@RequestMapping(value=Constants.USER_EDIT_URI)
@Service
@RemoteProxy
public class UserEditController {

	private static final Logger log = Logger.getLogger(UserEditController.class);
	public static final String COMMAND_NAME = "userCmd";
	public static final String LOOKUP_DATA = "lookupData";
	public static final String PARAM_SELECTED_ROLES  = "selectedRoles";
	public static final String KEY_ALL_ROLES  = "allRoles";
	public static final String PARAM_NEW_PASSW  = "newPassword";
	public static final String PARAM_CONFIRM_PASSW  = "confirmPassword";
	public static final String PARAM_CHANGE_PASSW  = "changePassword";

	public static final String NULL = "null";
	public static final int USER_NAME_MIN_CHARS = 6;
	public static final int PASSW_MIN_CHARS = 6;

	private static final int ERR_CODE_NAME = 1;
	private static final int ERR_CODE_PASSW = 2;
	private static final int ERR_CODE_EMAIL = 3;
	private static final int ERR_CODE_NAME_EXIST = 5;
	private static final int ERR_CODE_NEW_PASSW = 7;
	private static final int ERR_CODE_PASSW_CONFIRM = 8;

	private static final String	EMAIL_REGEX	= "^[-a-z0-9!#$%&'*+/=?^_`{|}~]+(?:\\.[-a-z0-9!#$%&'*+/=?^_`{|}~]+)*@(?:[a-z0-9]([-a-z0-9]{0,61}[a-z0-9])?\\.)*(?:aero|arpa|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|[a-z][a-z])$";



	@Autowired
    private UserManager userMgr;
	
	@Autowired
	@Qualifier("passwordEncoder")
	private MessageDigestPasswordEncoder passwordEncoder;
	
	public void setPasswordEncoder(MessageDigestPasswordEncoder passwordEncoder) {
		this.passwordEncoder = passwordEncoder;
	}

	@ModelAttribute(LOOKUP_DATA)
	public Map<String, List<Role>> initLookupData()
	{
		Map<String, List<Role>> lookupData = new HashMap<String, List<Role>>();

		log.info("************ in initLookupData");

		//Long id = qaManager.getQuestion(questionId).getForm().getId();

		lookupData.put(KEY_ALL_ROLES, userMgr.getAllRoles());


		//lookupData.put(ANSWER_TYPES, new Answer().getAnswerTypes());
		return lookupData;
	}

	@ModelAttribute(COMMAND_NAME)
	public UserCredentials createCommand(
			@RequestParam(value = "id", required = false) Long id)
	{
		// TODO: Error handling!
		if (id == null)
		{
			UserCredentials user =new UserCredentials();
			Role author = userMgr.getRole(10L);
			user.addRole(author);
			return user;
		}
		else
			return userMgr.findById(id);
	}

	/**
	 * show edit form for new or update
	 * @param module
	 * @return
	 */
	@RequestMapping(method = RequestMethod.GET)
	public String showForm(
			@ModelAttribute(COMMAND_NAME) UserCredentials user,
			@ModelAttribute(LOOKUP_DATA) Map<String, List<Role>> lookupData)
	{

		return ("userEdit");
	}

	/**
	 * Process data submitted from edit form
	 * @param module
	 * @return
	 */
    @RequestMapping(method = RequestMethod.POST)
    public View onSubmit(
    		@ModelAttribute(COMMAND_NAME) UserCredentials user,
    		@ModelAttribute(LOOKUP_DATA) Map<String, List<Role>> lookupData,
    		@RequestParam(value = PARAM_SELECTED_ROLES, required = false) String roleIds,
    		@RequestParam(value = PARAM_NEW_PASSW, required = false) String newPassword)
    {

		//register the selected categories
		Set<Role> selectedRoles = new LinkedHashSet<Role>();
		if (roleIds != null && !roleIds.isEmpty()) {
			List<Role> roles = (List<Role>) lookupData.get(KEY_ALL_ROLES);
			for (Role role : roles) {
				for (String id : roleIds.split(",")) {
					if (role.getId().equals(Long.valueOf(id))) {
						selectedRoles.add(role);
						break;
					}
				}
			}
		}
		user.setRoles(selectedRoles);

		if (user.isNew()) {
			
			String inputPassword = user.getPassword();
			String encodedPassword = 
				passwordEncoder.encodePassword(inputPassword, null);
			user.setPassword(encodedPassword);
			
			userMgr.createUser(user);
			
		} else {
			
			if (newPassword != null) {
				String encodedPassword = 
					passwordEncoder.encodePassword(newPassword, null);
    			user.setPassword(encodedPassword);
			}
			
			userMgr.updateUser(user);
		}

		// after question is saved - return to question listing
		return new RedirectView (Constants.USER_LISTING_URI, true);
    }

	public void setUserMgr(UserManager userMgr) {
		this.userMgr = userMgr;
	}

	@RemoteMethod
	public List<Integer> validate(String userId, String username, String password, String email, String newPassword, String confirmPassword) {
		List<Integer> errCodes = new ArrayList<Integer>();
		int nrOfErr = 0;

		//username
		if (username.isEmpty() || username.length() < USER_NAME_MIN_CHARS) {
			nrOfErr++;
			errCodes.add(ERR_CODE_NAME);
		}
		//email
		Pattern p = Pattern.compile(EMAIL_REGEX);
		if (!p.matcher(email).matches()) {
			nrOfErr++;
			errCodes.add(ERR_CODE_EMAIL);
		}
		//password
		if (!password.equals(NULL) && (password.isEmpty() || password.length() < PASSW_MIN_CHARS)) {
			nrOfErr++;
			errCodes.add(ERR_CODE_PASSW);
		}
		//newPassword
		if (!newPassword.equals(NULL) && (newPassword.isEmpty() || newPassword.length() < PASSW_MIN_CHARS)) {
			nrOfErr++;
			errCodes.add(ERR_CODE_NEW_PASSW);
		}
		//confirmPassword
		if (!confirmPassword.equals(NULL) && !confirmPassword.equals(newPassword)) {
			nrOfErr++;
			errCodes.add(ERR_CODE_PASSW_CONFIRM);
		}
		//didn't pass simple validation
		if (nrOfErr > 0) {
			return errCodes;
		}

		Long userIdasLong = null;
		try {
			userIdasLong = Long.valueOf(userId.toString());
		} catch (Exception e) {
			log.debug(e.getMessage());
		}

		//username already exist
		if (userIdasLong == null) {
			UserCredentials user = userMgr.findByName(username);
			if (user != null) {
				errCodes.add(ERR_CODE_NAME_EXIST);
			}
		}

		return errCodes;
	}



}
