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
package com.healthcit.cacure.businessdelegates;

import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.healthcit.cacure.test.AbstractIntegrationTestCase;
import com.healthcit.cacure.test.DataSet;
import com.healthcit.cacure.test.User;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={"classpath:extend-and-override-config.xml"})
public class QuestionAnswerManagerIntegrationTest extends AbstractIntegrationTestCase {

	@Autowired
	protected QuestionAnswerManager questionAnswerManager;
	
	@Test
	@DataSet("classpath:link_del.xml")
	@User("lkagan")
	public void testDeleteForm() {
		questionAnswerManager.deleteFormElementByID(1009L);
		Assert.assertEquals(1, countRowsInTable("skip_rule"));
//		questionAnswerManager.deleteFormElementByID(1009L);
	}
}
