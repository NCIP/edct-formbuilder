/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.model;

import java.util.Set;

import static org.junit.Assert.*;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;

import com.healthcit.cacure.test.AbstractIntegrationTestCase;
import com.healthcit.cacure.test.DataSet;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={"classpath:extend-and-override-config.xml"})
@TransactionConfiguration(defaultRollback=false)
public class TableQuestionTest extends AbstractIntegrationTestCase {

	@PersistenceContext
	private EntityManager em;
	
	@Test
	@DataSet("classpath:skips_on_tables.xml")
	public void testGetSkipAffectees_single() {
		TableQuestion tquest = em.find(TableQuestion.class, 1014L);
		Set<BaseSkipPatternDetail> skipAffectees = tquest.getSkipAffectees();
		assertNotNull(skipAffectees);
		assertEquals(1, skipAffectees.size());
		BaseSkipPatternDetail detail = skipAffectees.toArray(new BaseSkipPatternDetail[0])[0];
		assertEquals(new Long(1050), detail.getId());
		assertEquals(new Long(1050), detail.getSkip().getId());
		assertEquals(new Long(1031), detail.getFormElementId());
		assertNull(detail.getFormId());
		assertEquals(new Long(1008), detail.getSkipTriggerForm().getId());
		assertEquals(new Long(1014), detail.getSkipTriggerQuestion().getId());
	}
	
	@Test
	@DataSet("classpath:skips_on_tables.xml")
	public void testGetSkipAffectees_multi() {
		TableQuestion tquest = em.find(TableQuestion.class, 1020L);
		Set<BaseSkipPatternDetail> skipAffectees = tquest.getSkipAffectees();
		assertNotNull(skipAffectees);
		assertEquals(1, skipAffectees.size());
		BaseSkipPatternDetail detail = skipAffectees.toArray(new BaseSkipPatternDetail[0])[0];
		assertEquals(new Long(1055), detail.getId());
		assertEquals(new Long(1055), detail.getSkip().getId());
		assertEquals(new Long(1035), detail.getFormElementId());
		assertNull(detail.getFormId());
		assertEquals(new Long(1008), detail.getSkipTriggerForm().getId());
		assertEquals(new Long(1020), detail.getSkipTriggerQuestion().getId());
	}
	
	@Test
	@DataSet("classpath:skips_on_tables.xml")
	public void testGetSkipAffectees_static() {
		TableQuestion tquest = em.find(TableQuestion.class, 1027L);
		Set<BaseSkipPatternDetail> skipAffectees = tquest.getSkipAffectees();
		assertNotNull(skipAffectees);
		assertEquals(2, skipAffectees.size());
		BaseSkipPatternDetail[] array = skipAffectees.toArray(new BaseSkipPatternDetail[0]);
		BaseSkipPatternDetail detail0 = array[0];
		BaseSkipPatternDetail detail1 = array[1];
		assertArrayEquals(new long[] {10232, 10233}, new long[] {detail0.getSkip().getIdentifyingAnswerValue().getId(),
				detail1.getSkip().getIdentifyingAnswerValue().getId()});
	}
	
}
