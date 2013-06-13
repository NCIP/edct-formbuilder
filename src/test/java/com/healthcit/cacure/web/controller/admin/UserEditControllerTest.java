/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller.admin;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.easymock.classextension.EasyMock;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.businessdelegates.UserManager;
import com.healthcit.cacure.model.Role;
import com.healthcit.cacure.model.UserCredentials;
import com.healthcit.cacure.model.Role.RoleCode;
import com.healthcit.cacure.utils.Constants;


public class UserEditControllerTest {
	private UserManager userManager;
	private UserEditController userEditController;


	@Before
	public void setUp() {
		userEditController = new UserEditController();
		userManager = EasyMock.createMock(UserManager.class);
		userEditController.setUserMgr(userManager);
	}

	@Test
	public void testCreateMainModelWithFormIdNotNull() {
		EasyMock.expect(userManager.findById(1l)).andReturn(createMockUserCredentials(1l));
		EasyMock.replay(userManager);
		UserCredentials expected = createMockUserCredentials(1l);
		UserCredentials actual = userEditController.createCommand(1l);
		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getId(), actual.getId());
	}


	@Test
	public void testCreateMainModelWithFormIdNull() {
		UserCredentials actual = userEditController.createCommand(null);
		Assert.assertNotNull(actual);
	}

	@SuppressWarnings("unchecked")
	@Test
	public void testInitLookupData() {
		EasyMock.expect(userManager.getAllRoles()).andReturn(new ArrayList<Role>());
		EasyMock.replay(userManager);
		Map actual = userEditController.initLookupData();
		Assert.assertNotNull(actual);
		Assert.assertEquals(0, ((List<Role>)actual.get("allRoles")).size());
	}

	@Test
	public void testOnSubmitForCreate() {
		UserCredentials newUser = createMockUserCredentials(null);
		EasyMock.expect(userManager.createUser(newUser)).andReturn(createMockUserCredentials(1l));
		EasyMock.replay(userManager);
		RedirectView expected = new RedirectView (Constants.USER_LISTING_URI, true);
		//RedirectView actual = (RedirectView) userEditController.onSubmit(newUser);

		//Assert.assertNotNull(actual);
		//Assert.assertEquals(expected.getUrl(), actual.getUrl());
	}

	@Test
	public void testOnSubmitForUpdate() {
		UserCredentials newUser = createMockUserCredentials(1l);
		EasyMock.expect(userManager.updateUser(newUser)).andReturn(createMockUserCredentials(1l));
		EasyMock.replay(userManager);
		RedirectView expected = new RedirectView (Constants.USER_LISTING_URI, true);
		//RedirectView actual = (RedirectView) userEditController.onSubmit(newUser);
		//Assert.assertNotNull(actual);
		//Assert.assertEquals(expected.getUrl(), actual.getUrl());
	}

	private UserCredentials createMockUserCredentials(Long id) {
		UserCredentials user =new UserCredentials();
		user.setId(id);
		Role author = new Role();
		author.setRoleCode(RoleCode.ROLE_ADMIN);
		user.addRole(author);
		return user;
	}
}

