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
public class FormLibraryModuleTest extends AbstractIntegrationTestCase {

	@PersistenceContext
	private EntityManager em;
	
	@Test
	@DataSet
	public void testRead() {
		FormLibraryModule qlModule = em.find(FormLibraryModule.class, 2L);
		assertNotNull(qlModule);
		assertEquals("Form Library", qlModule.getDescription());
		assertEquals(date("2011-05-20 16:55:08.171"), qlModule.getUpdateDate());
		assertEquals(ModuleStatus.FORM_LIBRARY, qlModule.getStatus());
		assertEquals("Form Library Comments", qlModule.getComments());
		assertEquals(new Long(1), qlModule.getAuthor().getId());
		assertTrue(qlModule.isLibrary());
		
		assertNotNull(qlModule.getForms());
		assertEquals(1, qlModule.getForms().size());
		assertEquals(new Long(1111), qlModule.getForms().get(0).getId());
	}
	
	@Test
	public void testStatuses() {
		FormLibraryModule module = new FormLibraryModule();
		assertEquals(ModuleStatus.FORM_LIBRARY, module.getStatus());
		
//		Ignored statuses
		module.setStatus(null);
		assertEquals(ModuleStatus.FORM_LIBRARY, module.getStatus());
		module.setStatus(ModuleStatus.QUESTION_LIBRARY);
		assertEquals(ModuleStatus.FORM_LIBRARY, module.getStatus());
		module.setStatus(ModuleStatus.IN_PROGRESS);
		assertEquals(ModuleStatus.FORM_LIBRARY, module.getStatus());
		module.setStatus(ModuleStatus.APPROVED_FOR_PILOT);
		assertEquals(ModuleStatus.FORM_LIBRARY, module.getStatus());
		module.setStatus(ModuleStatus.APPROVED_FOR_PRODUCTION);
		assertEquals(ModuleStatus.FORM_LIBRARY, module.getStatus());
		module.setStatus(ModuleStatus.RELEASED);
		assertEquals(ModuleStatus.FORM_LIBRARY, module.getStatus());
	}
	
	@Test
	public void testNewForm() {
		FormLibraryModule module = new FormLibraryModule();
		BaseForm newForm = module.newForm();
		assertNotNull(newForm);
		assertTrue(newForm instanceof FormLibraryForm);
		assertEquals(module, newForm.getModule());
	}
	
	@Test
	@DataSet("classpath:users_roles_dataset.xml")
	public void testIsNew() {
		FormLibraryModule module = new FormLibraryModule();
		module.setAuthor(em.find(UserCredentials.class, 1L));
		assertTrue(module.isNew());
		
		em.persist(module);
		assertFalse(module.isNew());
	}
	
	@Test
	public void testIsLibrary() {
		FormLibraryModule module = new FormLibraryModule();
		assertTrue(module.isLibrary());
	}
	
	@Test
	public void testIsEditable() {
		FormLibraryModule module = new FormLibraryModule();
		assertTrue(module.isEditable());
	}
}
