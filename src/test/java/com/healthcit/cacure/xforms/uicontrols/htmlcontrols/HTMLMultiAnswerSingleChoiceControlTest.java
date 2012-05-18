package com.healthcit.cacure.xforms.uicontrols.htmlcontrols;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import org.jdom.Element;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.test.AbstractIntegrationTestCase;
import com.healthcit.cacure.test.DataSet;

@RunWith(SpringJUnit4ClassRunner.class)
@TransactionConfiguration(defaultRollback=false)
@ContextConfiguration(locations={"classpath:extend-and-override-config.xml"})
public class HTMLMultiAnswerSingleChoiceControlTest extends AbstractIntegrationTestCase {

	@Autowired
	protected QuestionAnswerManager qaManager;
	
	@PersistenceContext
	private EntityManager em;
	
	@Test
	@DataSet("classpath:skips_on_tables.xml")
	public void testGetAnswerElementsWithEmbeddedTags() {
		TableElement radioTable = (TableElement) qaManager.getFormElement(1012L);
		HTMLMultiAnswerSingleChoiceControl control = new HTMLMultiAnswerSingleChoiceControl(radioTable, qaManager);
		List<Element> elements = control.getAnswerElementsWithEmbeddedTags();
	}
	
}
