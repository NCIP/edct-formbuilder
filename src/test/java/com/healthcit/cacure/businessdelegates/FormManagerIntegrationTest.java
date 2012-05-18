package com.healthcit.cacure.businessdelegates;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertFalse;
import static junit.framework.Assert.assertNotNull;
import static junit.framework.Assert.assertTrue;

import java.io.IOException;

import org.dbunit.dataset.DataSetException;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.ExpectedException;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseForm.FormStatus;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.security.UnauthorizedException;
import com.healthcit.cacure.test.AbstractIntegrationTestCase;
import com.healthcit.cacure.test.DataSet;
import com.healthcit.cacure.test.User;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={"classpath:extend-and-override-config.xml"})
public class FormManagerIntegrationTest extends AbstractIntegrationTestCase {

	@Autowired
	protected FormManager formManager;

	@Autowired
	protected ModuleManager moduleManager;
	
	@Test
	@DataSet("FormManagerIntegrationTest.xml")
	public void testGetForm() {
		BaseForm form = formManager.getForm(11L);
		assertNotNull(form);
		assertTrue(form instanceof QuestionnaireForm);
		assertEquals(new Long(11), form.getId());
		assertEquals(new Long(2), form.getAuthor().getId());
		assertEquals(new Long(1), form.getLockedBy().getId());
		assertEquals(new Long(1), form.getLastUpdatedBy().getId());
		assertEquals(new Long(10), form.getModule().getId());
		assertEquals("questionnaire form 1", form.getName());
		assertEquals(new Integer(1), form.getOrd());
		assertEquals(FormStatus.IN_REVIEW, form.getStatus());
		assertEquals(date("2011-07-01 11:00"), form.getUpdateDate());
		assertEquals(uuid("uuid-form-11"), form.getUuid());
		
	}
	
	@Test
	@DataSet("FormManagerIntegrationTest.xml")
	@User("test")
	public void testDeleteForm() {
		assertEquals(4, countRowsInTable("form"));
		formManager.deleteForm(111L);
		assertEquals(3, countRowsInTable("form"));
		assertFalse(existsInDb("form", 111L));
	}
	
	@Test
	@DataSet("FormManagerIntegrationTest.xml")
	@User("lkagan")
	@ExpectedException(UnauthorizedException.class)
	public void testDeleteForm_unauthorized() {
		formManager.deleteForm(111L);
	}
	
	@Test
	@DataSet(value="classpath:data.xml")
	@User("lkagan")
	public void testAddNewForm() throws DataSetException, IOException {
		QuestionnaireForm form = new QuestionnaireForm();
		form.setName("new form");
		BaseModule module = moduleManager.getModule(555l);
		form.setModule(module);
		
		formManager.addNewForm(form);
		BaseForm form2 = formManager.getForm(form.getId());
		assertEquals(form, form2);
		/*int queryForInt = simpleJdbcTemplate.queryForInt("select count(*) from \"FormBuilder\".rpt_users");
		assertEquals(1, countRowsInTable("form"));*/
	}
	
	/*Long formId = 1l;
		BaseForm form = formManager.getForm(1002l);
		Assert.assertEquals("All Kind Of Elements Section", form.getName());
		Assert.assertNotNull(form);*/
	
	/*IDataSet expectedDataSet = new FlatXmlDataSetBuilder().build(new DefaultResourceLoader()
        .getResource("classpath:data.xml").getFile());
        ITable expectedTable = expectedDataSet.getTable("MODULE");
        Object value = expectedTable.getValue(0, "id");
        System.out.println(value);*/
}
