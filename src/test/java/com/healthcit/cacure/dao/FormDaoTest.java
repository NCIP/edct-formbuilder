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
package com.healthcit.cacure.dao;
import java.util.List;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.healthcit.cacure.dao.utils.TestDatabasePopulator;
import com.healthcit.cacure.enums.ItemOrderingAction;
import com.healthcit.cacure.model.QuestionnaireForm;

@RunWith(SpringJUnit4ClassRunner.class)
//specifies the Spring configuration to load for this test fixture
//@ContextConfiguration(locations={"classpath:/WEB-INF/spring/app-config.xml", "classpath:/WEB-INF/spring/dao-config.xml"})
@ContextConfiguration(locations={"classpath:test-app-config.xml", "classpath:test-dao-config.xml"})
public class FormDaoTest
{
	@Autowired
	private FormDao formDao;
	
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
	public void testGetAllFormQuestions() {
		List<QuestionnaireForm> questionForms = formDao.getModuleForms(50551l);
		Assert.assertEquals(3l, questionForms.size());
		for(QuestionnaireForm question : questionForms) {
			Assert.assertNotNull(question);
		}
	}

	@Test
	public void testGetAllFormQuestionsWhenFormIdDoesNotExist() {
		List<QuestionnaireForm> questionForms = formDao.getModuleForms(50551111l);
		Assert.assertNotNull(questionForms);
		Assert.assertEquals(0, questionForms.size());
	}
	
	@Test
	public void testGetShuffledModuleFormsDownOrder() {
		List<QuestionnaireForm> questionForms = formDao.getAdjacentPairOfForms(50501l, ItemOrderingAction.DOWN);
		Assert.assertNotNull(questionForms);
		Assert.assertEquals(2, questionForms.size());
		QuestionnaireForm questionnaireFormFirst = questionForms.get(0);
		QuestionnaireForm questionnaireFormSecond = questionForms.get(1);
		Assert.assertEquals(1, questionnaireFormFirst.getOrd().intValue());
		Assert.assertEquals(2, questionnaireFormSecond.getOrd().intValue());
	}
	
	@Test
	public void testGetShuffledModuleFormsUpOrder() {
		List<QuestionnaireForm> questionForms = formDao.getAdjacentPairOfForms(53500l, ItemOrderingAction.UP);
		Assert.assertNotNull(questionForms);
		Assert.assertEquals(2, questionForms.size());
		QuestionnaireForm questionnaireFormFirst = questionForms.get(0);
		QuestionnaireForm questionnaireFormSecond = questionForms.get(1);
		Assert.assertEquals(2, questionnaireFormFirst.getOrd().intValue());
		Assert.assertEquals(1, questionnaireFormSecond.getOrd().intValue());
	}
	

}
