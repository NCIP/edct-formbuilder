/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.dao;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;

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

import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.QuestionElement;


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
public class QuestionDaoTest {
	@Autowired
//	private QuestionDao questionDao;
	private QuestionElementDao questionElementDao;
	@Autowired
	private TableElementDao tableElementDao;
	@Autowired
	private LinkElementDao linkDao;
	
	@Autowired
	private ContentElementDao contentElementDao;
	
	@Autowired
	private FormDao formDao;
	
	@Autowired
	private QuestionDao questionDao;
	@Autowired
	private QuestionTableDao tableQuestionDao;
	
	@Autowired
	EntityManagerFactory emf;

//	@Autowired
//	SharedEntityManagerBean em;

//	protected Session session;


	@Before
    public void setUp() {
//		EntityManagerFactory emf = (EntityManagerFactory)context.getBean("entityManagerFactory");
		EntityManager em = emf.createEntityManager();
		TransactionSynchronizationManager.bindResource(emf , new EntityManagerHolder(em));
    }

    @After
    public void tearDown() throws Exception {
    	TransactionSynchronizationManager.unbindResourceIfPossible(emf);
//        TransactionSynchronizationManager.unbindResource(this.sessionFactory);
//        SessionFactoryUtils.releaseSession(this.session, this.sessionFactory);
    }

    @Test
    public void createLinkElement()
    {
    	BaseForm form =  formDao.getById(3867l);
    	LinkElement link = new LinkElement();
		QuestionElement questionElement = questionElementDao.getById(4007L);
    	link.setSource(questionElement);
    	link.setOrd(10);
    	linkDao.create(link);
    	Assert.assertNotNull("UUID is null", link.getUuid());

    }
    
}
