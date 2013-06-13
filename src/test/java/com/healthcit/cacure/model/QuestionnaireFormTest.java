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

import com.healthcit.cacure.model.BaseForm.FormStatus;
import com.healthcit.cacure.model.BaseModule.ModuleStatus;
import com.healthcit.cacure.test.AbstractIntegrationTestCase;
import com.healthcit.cacure.test.DataSet;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={"classpath:extend-and-override-config.xml"})
@TransactionConfiguration(defaultRollback=true)
public class QuestionnaireFormTest extends AbstractIntegrationTestCase {

	@PersistenceContext
	private EntityManager em;
	
	@Test
	@DataSet
	public void testRead() {
		QuestionnaireForm form = em.find(QuestionnaireForm.class, 1002L);
		assertNotNull(form);
		assertEquals("All Kind Of Elements Section", form.getName());
		assertNotNull(form.getModule());
		assertEquals(new Long(1001), form.getModule().getId());
		assertEquals(new Integer(2), form.getOrd());
		assertEquals(FormStatus.IN_PROGRESS, form.getStatus());
		assertEquals(date("2011-05-31 11:02:50.828"), form.getUpdateDate());
		assertEquals(new Long(1), form.getAuthor().getId());
		assertEquals(uuid("da1e9eaf-aafa-445c-9a82-57712caa128f"), form.getUuid());
		assertEquals(new Long(1), form.getLockedBy().getId());
		assertEquals(new Long(1), form.getLastUpdatedBy().getId());
		assertNotNull(form.getElements());
		assertEquals(13, form.getElements().size());
		assertEquals(new Long(1005), form.getElements().get(0).getId());
		assertEquals(new Long(1004), form.getElements().get(1).getId());
		assertEquals(new Long(1010), form.getElements().get(2).getId());
		assertEquals(new Long(1003), form.getFormSkipRule().getId());
	}
	
	@Test
	@DataSet("classpath:test_dataset.xml")
	public void testPersist() {
		QuestionnaireForm form = new QuestionnaireForm();
		form.setModule(em.find(Module.class, 1001L));
		form.setName("New Questionnaire Form");
		form.setOrd(999);
		UserCredentials author = em.find(UserCredentials.class, 2L);
		form.setAuthor(author);
		form.setLockedBy(author);
		
		ContentElement contentElement = new ContentElement();
		contentElement.setDescription("New Content Description");
		contentElement.setOrd(100);
		form.addElement(contentElement);
		
		QuestionElement questionElement = new QuestionElement();
		questionElement.setDescription("New Question Description");
		questionElement.setOrd(99);
		form.addElement(questionElement);
		
		em.persist(form);
		em.flush();
		
		/*assertEqualsEntity(module);
		
		assertEquals(2, countRowsInTable("form"));
		assertTrue(existsInDb("form", form1.getId(), form2.getId()));
		assertEquals(module, form1.getModule());
		assertEquals(module, form2.getModule());*/
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
