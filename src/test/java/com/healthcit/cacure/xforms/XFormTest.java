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
package com.healthcit.cacure.xforms;

import static org.junit.Assert.fail;

import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.model.QuestionElement;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.BaseQuestion.QuestionType;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.xforms.XForm.XFormContainerType;

public class XFormTest
{

	private QuestionnaireForm testForm;
	@SuppressWarnings("unused")
	private String xFormText;
	@Before
	public void setUp() throws Exception
	{
		testForm = createTestForm();
		xFormText = initxFormResult();
	}

	@After
	public void tearDown() throws Exception
	{
	}

	@Test
	public void testWrite()
	{
		XForm xForm = new XForm(testForm,XFormContainerType.HTML, null);
		// initialize writer

		StringWriter writer = new StringWriter(5000);
		try
		{
			xForm.write(writer);
		}
		catch (Exception e)
		{
			fail (e.getMessage());
		}
		String xFormTestResult = writer.toString();
		System.out.print(xFormTestResult);
		fail("Not yet implemented");
	}

	/**
	 * populate string with final XForms result for assertion
	 * @return
	 */
	private String initxFormResult()
	{
		return "";
	}

	/**
	 * creating testing model
	 * @return
	 */
	private QuestionnaireForm createTestForm()
	{
		QuestionnaireForm qf = new QuestionnaireForm();
		qf.setId(10L);
		qf.setName("About You");
		qf.setOrd(2);

		// Simple text question
		Question q1 = createQuestion(
				100L, 12, false,  QuestionType.SINGLE_ANSWER,
				"YourThoughts", "Please tell us what you think",
				"Just type in <b>your</b> opinion" );
		
		q1.setAnswer(createSingleValueEntryAnswer(1000L, 1, AnswerType.TEXT, "ThoughtsAnswer", "Enter here:", null));

		// Simple RADIO question
		Question q2 = createQuestion(
				200L, 1, true,  QuestionType.SINGLE_ANSWER,
				"EducationLevel", "What is your highest level of education?",
				null );
		List<AnswerValue> avList1 = new ArrayList<AnswerValue>();
		avList1.add(createAnswerValue(2001L, "None", "No formal education", new Long(0)));
		avList1.add(createAnswerValue(2002L, "HS", "High School", "HS"));
		avList1.add(createAnswerValue(2003L, "BA/BS", "Bachelors", "B"));
		avList1.add(createAnswerValue(2004L, "MA/MS", "Masters", "M"));
		q2.setAnswer(createSelectAnswer(2000L, 1, AnswerType.RADIO, "EdLevelAnswer", null, Constants.VERTICAL, avList1 ));

		// Simple CHECKBOX question
		Question q3 = createQuestion(
				300L, 4, true,  QuestionType.MULTI_ANSWER,
				"Diet", "What do you eat every day?",
				null );
		List<AnswerValue> avList2 = new ArrayList<AnswerValue>();
		avList2.add(createAnswerValue(3001L, "RM", "Red meat", "1"));
		avList2.add(createAnswerValue(3002L, "FR", "Fruits", "2"));
		avList2.add(createAnswerValue(3003L, "VG", "Vegies", "3"));
		avList2.add(createAnswerValue(3004L, "EG", "Eggs", "4"));
		avList2.add(createAnswerValue(3005L, "DR", "Dairy", "5"));
		avList2.add(createAnswerValue(3006L, "PL", "Poultry", "6"));
		q3.setAnswer(createSelectAnswer(3000L, 1, AnswerType.CHECKBOX, "DietAnswer", null, Constants.HORIZONTAL, avList2 ));

		// Simple Content
		Question q4 = createQuestion(400L, 3, false, QuestionType.CONTENT, "ContTest",
				"One special option with this form control is when the selection  attribute is specified " +
				"as open. This indicates that \"free entry\" is allowed, so that the user can either pick " +
				"from the list or use input-style data entry to enter a value not originally in the list " +
				"of items. The entered value is still subject to all the validation rules in XForms, " +
				"including XML Schema datatype validation.", null);


		// Simple RADIO TABLE question
		Question q5 = createQuestion(
				500L, 1, true,  QuestionType.SINGLE_ANSWER,
				"AlcoholConsumption", "How much alcohol do you use daily?",
				null );
		List<AnswerValue> avList5 = new ArrayList<AnswerValue>();
		avList5.add(createAnswerValue(5101L, "None", "None", new Long(0)));
		avList5.add(createAnswerValue(5102L, "1", "One", new Long(1)));
		avList5.add(createAnswerValue(5103L, "2-3", "2-3", new Long(3)));
		avList5.add(createAnswerValue(5104L, "4-5", "4-5", new Long(5)));
		avList5.add(createAnswerValue(5104L, "5+", "More than 5", new Long(6)));
		q5.setAnswer(createSelectAnswer(5100L, 1, AnswerType.RADIO, "BEER", "Beer", Constants.HORIZONTAL, avList5 ));
		q5.setAnswer(createSelectAnswer(5200L, 1, AnswerType.RADIO, "WINE", "Wine", Constants.HORIZONTAL, copyAV(avList5, 5200L) ));
		q5.setAnswer(createSelectAnswer(5300L, 1, AnswerType.RADIO, "MIXED", "Mixed drinks", Constants.HORIZONTAL, copyAV(avList5, 5300L) ));
		q5.setAnswer(createSelectAnswer(5400L, 1, AnswerType.RADIO, "SPIRITS", "Vodka, Scotch, etc.", Constants.HORIZONTAL, copyAV(avList5, 5400L) ));
		
		QuestionElement qe1 = new QuestionElement();
		qe1.setQuestion(q1);
		qf.addElement(qe1);
		
		QuestionElement qe2 = new QuestionElement();
		qe2.setQuestion(q2);
		qf.addElement(qe2);
		
		QuestionElement qe3 = new QuestionElement();
		qe3.setQuestion(q3);
		qf.addElement(qe3);
		
		QuestionElement qe4 = new QuestionElement();
		qe4.setQuestion(q4);
		qf.addElement(qe4);
		
		QuestionElement qe5 = new QuestionElement();
		qe5.setQuestion(q5);
		qf.addElement(qe5);

		return qf;
	}

	private Question createQuestionElement(
			long id, int ord, boolean required, QuestionType type,
			String shortName, String descr, String learnMore )
	{
		QuestionElement qe = new QuestionElement();
		Question q = new Question();
		qe.setRequired(required);
		qe.setOrd(ord);
		qe.setDescription(descr);
		qe.setLearnMore(learnMore);
		
		q.setId(id);
		q.setType(type);
		q.setShortName(shortName);
		return q;
	}
	
	private Question createQuestion(
			long id, int ord, boolean required, QuestionType type,
			String shortName, String descr, String learnMore )
	{
		Question q = new Question();
		q.setId(id);
		q.getParent().setRequired(required);
		q.setType(type);
		q.getParent().setOrd(ord);
		q.setShortName(shortName);
		q.getParent().setDescription(descr);
		q.getParent().setLearnMore(learnMore);
		return q;
	}

	private Answer createSingleValueEntryAnswer(long id, int ord, AnswerType type,
			String shorName, String descr, Object value)
	{
		Answer a = new Answer();
		a.setId(id);
		a.setDescription(descr);
		a.setType(type);
		AnswerValue av = createAnswerValue(++id, shorName, descr, value);
		a.addAnswerValues(av);

		return a;
	}

	private Answer createSelectAnswer(
			long id, int ord, AnswerType type,
			String shorName, String descr, String displayStyle, List<AnswerValue> avList)
	{
		Answer a = new Answer();
		a.setId(id);
		a.setDescription(descr);
		a.setType(type);
		a.setDisplayStyle( displayStyle );
		for (AnswerValue av: avList)
		{
			a.addAnswerValues(av);
		}

		return a;
	}


	private AnswerValue createAnswerValue(long id, String name,	String descr, Object value)
	{
		AnswerValue av = new AnswerValue();
		av.setId(id);
		av.setDescription(descr);
		av.setName(name);
		av.setValue(String.valueOf(value));
		return av;
	}


	private List<AnswerValue> copyAV(List<AnswerValue> avListSource, long answerID)
	{
		List<AnswerValue> avList = new ArrayList<AnswerValue>();
		for (AnswerValue avSource: avListSource)
		{
			avList.add(createAnswerValue(++answerID, avSource.getName(), avSource.getDescription(), avSource.getValue()));
		}

		return avList;
	}


}
