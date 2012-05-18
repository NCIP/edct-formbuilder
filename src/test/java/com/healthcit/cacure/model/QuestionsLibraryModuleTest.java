package com.healthcit.cacure.model;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;

import com.healthcit.cacure.model.BaseModule.ModuleStatus;
import com.healthcit.cacure.test.AbstractIntegrationTestCase;
import com.healthcit.cacure.test.DataSet;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={"classpath:extend-and-override-config.xml"})
@TransactionConfiguration(defaultRollback=true)
public class QuestionsLibraryModuleTest extends AbstractIntegrationTestCase {

	@PersistenceContext
	private EntityManager em;
	
	@Test
	@DataSet
	public void testRead() {
		QuestionsLibraryModule qlModule = em.find(QuestionsLibraryModule.class, 1L);
		assertNotNull(qlModule);
		assertEquals("Question Library", qlModule.getDescription());
		assertEquals(date("2011-05-20 16:55:08.171"), qlModule.getUpdateDate());
		assertEquals(ModuleStatus.QUESTION_LIBRARY, qlModule.getStatus());
		assertEquals("Question Library Comments", qlModule.getComments());
		assertEquals(new Long(1), qlModule.getAuthor().getId());
		assertTrue(qlModule.isLibrary());
		
		assertNotNull(qlModule.getForms());
		assertEquals(1, qlModule.getForms().size());
		assertEquals(new Long(1), qlModule.getForms().get(0).getId());
	}
	
	@Test
	public void testStatuses() {
		QuestionsLibraryModule module = new QuestionsLibraryModule();
		assertEquals(ModuleStatus.QUESTION_LIBRARY, module.getStatus());
		
//		Ignored statuses
		module.setStatus(null);
		assertEquals(ModuleStatus.QUESTION_LIBRARY, module.getStatus());
		module.setStatus(ModuleStatus.FORM_LIBRARY);
		assertEquals(ModuleStatus.QUESTION_LIBRARY, module.getStatus());
		module.setStatus(ModuleStatus.IN_PROGRESS);
		assertEquals(ModuleStatus.QUESTION_LIBRARY, module.getStatus());
		module.setStatus(ModuleStatus.APPROVED_FOR_PILOT);
		assertEquals(ModuleStatus.QUESTION_LIBRARY, module.getStatus());
		module.setStatus(ModuleStatus.APPROVED_FOR_PRODUCTION);
		assertEquals(ModuleStatus.QUESTION_LIBRARY, module.getStatus());
		module.setStatus(ModuleStatus.RELEASED);
		assertEquals(ModuleStatus.QUESTION_LIBRARY, module.getStatus());
	}
	
	@Test
	public void testNewForm() {
		QuestionsLibraryModule module = new QuestionsLibraryModule();
		BaseForm newForm = module.newForm();
		assertNotNull(newForm);
		assertTrue(newForm instanceof QuestionLibraryForm);
		assertEquals(module, newForm.getModule());
	}
	
	@Test
	@DataSet("classpath:users_roles_dataset.xml")
	public void testIsNew() {
		QuestionsLibraryModule module = new QuestionsLibraryModule();
		module.setAuthor(em.find(UserCredentials.class, 1L));
		assertTrue(module.isNew());
		
		em.persist(module);
		assertFalse(module.isNew());
	}
	
	@Test
	public void testIsLibrary() {
		QuestionsLibraryModule module = new QuestionsLibraryModule();
		assertTrue(module.isLibrary());
	}
	
	@Test
	public void testIsEditable() {
		QuestionsLibraryModule module = new QuestionsLibraryModule();
		assertTrue(module.isEditable());
	}
}
