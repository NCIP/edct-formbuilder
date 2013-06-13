/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.businessdelegates;

import java.util.List;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.orm.jpa.EntityManagerHolder;

import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.ContentElement;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.model.QuestionElement;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.model.TableQuestion;
import com.healthcit.cacure.model.Answer.AnswerType;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;

@RunWith(SpringJUnit4ClassRunner.class)
//specifies the Spring configuration to load for this test fixture
//@ContextConfiguration(locations={"classpath:/WEB-INF/spring/app-config.xml", "classpath:/WEB-INF/spring/dao-config.xml"})
@ContextConfiguration(locations = {
		"file:src/main/webapp/WEB-INF/spring/app-config.xml",
		"file:src/main/webapp/WEB-INF/spring/dao-config.xml", 
		"file:src/main/webapp/WEB-INF/spring/mailTemplates-config.xml"  
//		"file:src/main/webapp/WEB-INF/spring/security-config.xml" 
		})
@TransactionConfiguration(transactionManager = "transactionManager", defaultRollback = false)
//@ContextConfiguration(locations={"classpath:test-app-config.xml", "classpath:test-dao-config.xml"})
public class QuestionAnswerManagerTest{
		
		@Autowired
		EntityManagerFactory emf;
		
		@Before
	    public void setUp() {
			EntityManager em = emf.createEntityManager();
			TransactionSynchronizationManager.bindResource(emf , new EntityManagerHolder(em));
	    }

	    @After
	    public void tearDown() throws Exception {
	    	TransactionSynchronizationManager.unbindResourceIfPossible(emf);
	    }


}
