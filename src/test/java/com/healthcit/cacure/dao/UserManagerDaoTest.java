/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.dao;
import java.util.List;

import javax.persistence.NoResultException;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.healthcit.cacure.dao.utils.TestDatabasePopulator;
import com.healthcit.cacure.model.Role;
import com.healthcit.cacure.model.UserCredentials;

@RunWith(SpringJUnit4ClassRunner.class)
//specifies the Spring configuration to load for this test fixture
//@ContextConfiguration(locations={"classpath:/WEB-INF/spring/app-config.xml", "classpath:/WEB-INF/spring/dao-config.xml"})
@ContextConfiguration(locations={"classpath:test-app-config.xml", "classpath:test-dao-config.xml"})
public class UserManagerDaoTest
{
	@Autowired
	private UserManagerDao userManagerDao;
	
	@Autowired
	private TestDatabasePopulator testDatabasePopulator;
	
	@Before
	public void setUp() {
		//Creates test data base
		testDatabasePopulator.populate();
	}
	
	@After
	public void tearDown() {
		//Drop test data base
		testDatabasePopulator.dropTestDatabase();
	}
	
	@Test
	public void testFindByName() {
		UserCredentials userCredentials = userManagerDao.findByName("test");
		Assert.assertNotNull(userCredentials);
		Assert.assertEquals("9ddc44f3f7f78da5781d6cab571b2fc5", userCredentials.getPassword());
	}
	
	@Test
	public void testFindByNameNotExistedUser() {
		UserCredentials userCredentials = null;
		try {
			userCredentials = userManagerDao.findByName("notExisted");
			Assert.fail("Expected that user should not be exist, but actual user is existed");
		} catch (NoResultException e) {
			Assert.assertNull(userCredentials);
		}
	}
	
	@Test
	public void testGetUserRoles() {
		UserCredentials userCredentials = userManagerDao.findByName("test");
		List<Role> roles = userManagerDao.getUserRoles(userCredentials);
		Assert.assertNotNull(roles);
		Assert.assertEquals(3, roles.size());
	}
	
	@Test
	public void testGetUserRolesDoesNotExist() {
		UserCredentials userCredentialsDoesNotExist = new UserCredentials();
		userCredentialsDoesNotExist.setId(0l);
		List<Role> roles = userManagerDao.getUserRoles(userCredentialsDoesNotExist);
		Assert.assertNotNull(roles);
		Assert.assertEquals(0, roles.size());
	}
}

