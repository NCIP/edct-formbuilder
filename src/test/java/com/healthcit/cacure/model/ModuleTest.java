/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.PersistenceException;

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
public class ModuleTest extends AbstractIntegrationTestCase {

	@PersistenceContext
	private EntityManager em;
	
	@Test
	@DataSet
	public void testRead() {
		Module module = em.find(Module.class, 1001L);
		assertNotNull(module);
		assertEquals("Questionnaire Module", module.getDescription());
		assertEquals(date("2011-05-31 11:00:43.812"), module.getUpdateDate());
		assertEquals(ModuleStatus.IN_PROGRESS, module.getStatus());
		assertEquals("Questionnaire Module Comments", module.getComments());
		assertEquals(new Long(1), module.getAuthor().getId());
		
		assertNotNull(module.getForms());
		assertEquals(2, module.getForms().size());
		assertEquals(new Long(1070), module.getForms().get(0).getId());
		assertEquals(new Long(1002), module.getForms().get(1).getId());
		
		assertEquals("1/01/2020", module.getCompletionTime());
//		Date data type
		assertEquals(date("2011-08-30 00:00:00.000"), module.getReleaseDate());
		
	}
	
	@Test
	@DataSet("classpath:users_roles_dataset.xml")
	public void testPersist() {
		Module module = new Module();
		module.setDescription("test module 3");
		module.setStatus(ModuleStatus.APPROVED_FOR_PILOT);
		module.setComments("test comments 3");
		UserCredentials author = em.find(UserCredentials.class, 1L);
		module.setAuthor(author);
		
		List<QuestionnaireForm> forms = new ArrayList<QuestionnaireForm>();
		
		QuestionnaireForm form1 = (QuestionnaireForm) module.newForm();
		form1.setName("form1");
		form1.setOrd(3);
		form1.setAuthor(author);
		forms.add(form1);
		
		QuestionnaireForm form2 = (QuestionnaireForm) module.newForm();
		form2.setName("form2");
		form2.setOrd(2);
		form2.setAuthor(author);
		forms.add(form2);
		
		module.getForms().addAll(forms);
		
		module.setCompletionTime("completion time");
		module.setReleaseDate(date("2011-09-10 00:00:00.000"));
//		TODO Date
		assertEquals(0, countRowsInTable("form"));
		em.persist(module);
		em.flush();
		
		assertEqualsEntity(module);
		
		assertEquals(2, countRowsInTable("form"));
		assertTrue(existsInDb("form", form1.getId(), form2.getId()));
		assertEquals(module, form1.getModule());
		assertEquals(module, form2.getModule());
	}
	
	@Test
	@DataSet
	public void testRemove() {
		Module module = em.find(Module.class, 1001L);
		
		em.remove(module);
		em.flush();
		
		assertFalse(existsInDb("module", 1001L));
		assertFalse(existsInDb("form", 1002L, 1070L));
		
	}
	
	@Test
	@DataSet
	public void testMerge() {
		Module module = em.find(Module.class, 1001L);
		String newDescription = "Changed Module Description";
		module.setDescription(newDescription);
		String newName = "Changed Form Name";
		module.getForms().get(0).setName(newName);
		UserCredentials author = new UserCredentials();
		author.setUserName("dvfdv");
		author.setPassword("XXX");
		module.setAuthor(author);
		em.merge(module);
		em.flush();
		
		assertTrue(1 == simpleJdbcTemplate.queryForInt("select count(*) from module where description = ?", newDescription));
		assertTrue(1 == simpleJdbcTemplate.queryForInt("select count(*) from form where name = ?", newName));
	}
	
	public void assertEqualsEntity(Module module) {
		assertNotNull(module.getId());
		List<Map<String, Object>> list0 = simpleJdbcTemplate.queryForList("select * from module where id = " + module.getId());
		Map<String, Object> row = list0.get(0);
		assertEquals(module.getDescription(), row.get("description"));
		assertEquals(module.getComments(), row.get("comments"));
		assertEquals(module.getUpdateDate(), row.get("update_date"));
		assertEquals(module.getAuthor().getId(), row.get("author_user_id"));
		assertEquals(module.getCompletionTime(), row.get("completiontime"));
		assertEquals(module.getReleaseDate(), row.get("release_date"));
		assertEquals(module.getStatus().toString(), row.get("status"));
		assertEquals(module.isLibrary(), row.get("is_library"));
	}
	
	@Test(expected=PersistenceException.class)
	public void testNotNullAuthor() {
		Module module = new Module();
		module.setAuthor(null);
		
		em.persist(module);
		em.flush();
	}
	
	@Test
	public void testStatuses() {
		Module module = new Module();
		assertEquals(ModuleStatus.IN_PROGRESS, module.getStatus());
		
//		Ignored statuses
		module.setStatus(null);
		assertEquals(ModuleStatus.IN_PROGRESS, module.getStatus());
		module.setStatus(ModuleStatus.QUESTION_LIBRARY);
		assertEquals(ModuleStatus.IN_PROGRESS, module.getStatus());
		module.setStatus(ModuleStatus.FORM_LIBRARY);
		assertEquals(ModuleStatus.IN_PROGRESS, module.getStatus());
		
//		Allowed statuses		
		module.setStatus(ModuleStatus.IN_PROGRESS);
		assertEquals(ModuleStatus.IN_PROGRESS, module.getStatus());
		module.setStatus(ModuleStatus.APPROVED_FOR_PILOT);
		assertEquals(ModuleStatus.APPROVED_FOR_PILOT, module.getStatus());
		module.setStatus(ModuleStatus.APPROVED_FOR_PRODUCTION);
		assertEquals(ModuleStatus.APPROVED_FOR_PRODUCTION, module.getStatus());
		module.setStatus(ModuleStatus.RELEASED);
		assertEquals(ModuleStatus.RELEASED, module.getStatus());
	}
	
	@Test
	public void testNewForm() {
		Module module = new Module();
		BaseForm newForm = module.newForm();
		assertNotNull(newForm);
		assertTrue(newForm instanceof QuestionnaireForm);
		assertEquals(module, newForm.getModule());
	}
	
	@Test
	@DataSet("classpath:users_roles_dataset.xml")
	public void testIsNew() {
		Module module = new Module();
		module.setAuthor(em.find(UserCredentials.class, 1L));
		assertTrue(module.isNew());
		
		em.persist(module);
		assertFalse(module.isNew());
	}
	
	@Test
	public void testIsLibrary() {
		Module module = new Module();
		assertFalse(module.isLibrary());
	}
	
	@Test
	public void testIsEditable() {
		Module module = new Module();
		assertTrue(module.isEditable());
		module.setStatus(ModuleStatus.IN_PROGRESS);
		assertTrue(module.isEditable());
		module.setStatus(ModuleStatus.APPROVED_FOR_PILOT);
		assertFalse(module.isEditable());
		module.setStatus(ModuleStatus.APPROVED_FOR_PRODUCTION);
		assertFalse(module.isEditable());
		module.setStatus(ModuleStatus.RELEASED);
		assertFalse(module.isEditable());
	}

}
