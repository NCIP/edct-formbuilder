/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

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
