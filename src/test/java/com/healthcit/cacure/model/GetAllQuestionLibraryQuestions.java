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
package com.healthcit.cacure.model;


import static org.junit.Assert.*;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;

import org.hibernate.Session;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.orm.jpa.EntityManagerHolder;
import org.springframework.orm.jpa.support.SharedEntityManagerBean;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.dao.FormDao;
import com.healthcit.cacure.dao.ModuleDao;


@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {
		"file:src/main/webapp/WEB-INF/spring/app-config.xml",
		"file:src/main/webapp/WEB-INF/spring/dao-config.xml", 
		"file:src/main/webapp/WEB-INF/spring/mailTemplates-config.xml"  
//		"file:src/main/webapp/WEB-INF/spring/security-config.xml" 
		})
@TransactionConfiguration(transactionManager = "transactionManager", defaultRollback = false)
public class GetAllQuestionLibraryQuestions {
//
//	@Autowired
//	ModuleDao moduleDao;
//		
//	@Autowired
//	FormDao formDao;

	@Autowired
	EntityManagerFactory emf;

	@Autowired
	SharedEntityManagerBean em;

	protected Session session;
	
	@Autowired
	QuestionAnswerManager qaManager;
	
	
	@Before
    public void setUp() {
//		EntityManagerFactory emf = (EntityManagerFactory)context.getBean("entityManagerFactory");
		EntityManager em = emf.createEntityManager();
		TransactionSynchronizationManager.bindResource(emf , new EntityManagerHolder(em));
    }
	
	   @After
	    public void tearDown() throws Exception {
	    	TransactionSynchronizationManager.unbindResourceIfPossible(emf);
//	        TransactionSynchronizationManager.unbindResource(this.sessionFactory);
//	        SessionFactoryUtils.releaseSession(this.session, this.sessionFactory);
	    }
	   
	   
//	@Test
//	public void getLibraries()
//	{
//		List<BaseModule> modules = moduleDao.getLibraryModules();
//		assertNotNull(modules);
//		for(BaseModule module : modules)
//		{
//			if(module instanceof QuestionsLibraryModule)
//			{
//				getQuestions((QuestionsLibraryModule)module);
//			}
//		}
//	}
	
//	@Test
//	public void getQuestions()
//	{
//		BaseForm form = formDao.getById(1l);
//		List<FormElement> elements = form.getElements();
//		assertNotNull(elements);
//		
//	}
	@Test
	public void getAllChildren()
	{
		List<FormElement> elements = qaManager.getAllFormElementsWithChildren(1l);
		assertNotNull(elements);
	}

}
