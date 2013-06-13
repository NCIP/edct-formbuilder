/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.springframework.validation.BeanPropertyBindingResult;

import com.healthcit.cacure.model.UserCredentials;
import com.healthcit.cacure.web.controller.LoginController.UserCredentialsValidator;

public class UserCredentialsValidatorTest {
	private UserCredentialsValidator userCredentialsValidator;
	
	@Before
	public void setUp() {
		userCredentialsValidator = new LoginController().new UserCredentialsValidator();
	}

	@Test
	public void testSuccessValidation() {
		UserCredentials userCredentials = new UserCredentials();
		userCredentials.setUserName("Testing");
		userCredentials.setPassword("TestPassword");
		BeanPropertyBindingResult errors = new BeanPropertyBindingResult(userCredentialsValidator, "userCredentials");
		userCredentialsValidator.validate(userCredentials, errors);
		Assert.assertEquals(0, errors.getErrorCount());
		
	}
	
	@Test
	public void testUsernameNull() {
		UserCredentials userCredentials = new UserCredentials();
		userCredentials.setUserName(null);
		userCredentials.setPassword("TestPassword");
		BeanPropertyBindingResult errors = new BeanPropertyBindingResult(userCredentialsValidator, "userCredentials");
		userCredentialsValidator.validate(userCredentials, errors);
		Assert.assertEquals(1, errors.getErrorCount());
		
	}
	
	@Test
	public void testUsernameBlank() {
		UserCredentials userCredentials = new UserCredentials();
		userCredentials.setUserName("");
		userCredentials.setPassword("TestPassword");
		BeanPropertyBindingResult errors = new BeanPropertyBindingResult(userCredentialsValidator, "userCredentials");
		userCredentialsValidator.validate(userCredentials, errors);
		Assert.assertEquals(1, errors.getErrorCount());
		
	}
	
	@Test
	public void testUsernameMinCharsError() {
		UserCredentials userCredentials = new UserCredentials();
		userCredentials.setUserName("a");
		userCredentials.setPassword("TestPassword");
		BeanPropertyBindingResult errors = new BeanPropertyBindingResult(userCredentialsValidator, "userCredentials");
		userCredentialsValidator.validate(userCredentials, errors);
		Assert.assertEquals(1, errors.getErrorCount());
		
	}
	
	@Test
	public void testPasswordNull() {
		UserCredentials userCredentials = new UserCredentials();
		userCredentials.setUserName("Test");
		userCredentials.setPassword(null);
		BeanPropertyBindingResult errors = new BeanPropertyBindingResult(userCredentialsValidator, "userCredentials");
		userCredentialsValidator.validate(userCredentials, errors);
		Assert.assertEquals(1, errors.getErrorCount());
		
	}
	
	@Test
	public void testPasswordBlank() {
		UserCredentials userCredentials = new UserCredentials();
		userCredentials.setUserName("Test");
		userCredentials.setPassword("");
		BeanPropertyBindingResult errors = new BeanPropertyBindingResult(userCredentialsValidator, "userCredentials");
		userCredentialsValidator.validate(userCredentials, errors);
		Assert.assertEquals(1, errors.getErrorCount());
		
	}
	
	@Test
	public void testPasswordMinCharsError() {
		UserCredentials userCredentials = new UserCredentials();
		userCredentials.setUserName("Test");
		userCredentials.setPassword("a");
		BeanPropertyBindingResult errors = new BeanPropertyBindingResult(userCredentialsValidator, "userCredentials");
		userCredentialsValidator.validate(userCredentials, errors);
		Assert.assertEquals(1, errors.getErrorCount());
		
	}
}


