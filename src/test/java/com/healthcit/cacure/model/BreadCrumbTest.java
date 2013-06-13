/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import junit.framework.TestCase;

import org.junit.Test;

public class BreadCrumbTest extends TestCase {

	private BreadCrumb breadCrumb;
	
	@Override
	public void setUp() throws SecurityException, NoSuchMethodException, IllegalArgumentException, InstantiationException, IllegalAccessException, InvocationTargetException {
		Constructor<BreadCrumb> c = BreadCrumb.class.getDeclaredConstructor();
		c.setAccessible(true);
		breadCrumb = c.newInstance();
	}
	
	@SuppressWarnings("unchecked")
	@Test
	public void testModuleBreadCrumbs() {
		List breadCrumbs = breadCrumb.buildBreadCrumbList(createModule(1l));
		assertEquals(2, breadCrumbs.size());
	}
    
	@SuppressWarnings("unchecked")
	@Test
	public void testQuestionFormBreadCrumbs() {
		List breadCrumbs = breadCrumb.buildBreadCrumbList(createMockQuestionForm(1l, 1));
		assertEquals(3, breadCrumbs.size());
	}
	
	@SuppressWarnings("unchecked")
	@Test
	public void testQuestionBreadCrumbs() {
		List breadCrumbs = breadCrumb.buildBreadCrumbList(createMockQuestion(1l));
		assertEquals(4, breadCrumbs.size());
	}
	
	
    private QuestionnaireForm createMockQuestionForm(Long id, Integer ordId) {
		QuestionnaireForm mockQuestionnaireForm = new QuestionnaireForm();
		mockQuestionnaireForm.setId(id);
		mockQuestionnaireForm.setName("xxxxxx yyyy xxxxx zzzzzzzz llll ppppp mmmmmm");
		mockQuestionnaireForm.setOrd(ordId);
		mockQuestionnaireForm.setModule(createModule(1l));
		return mockQuestionnaireForm;
	}

	private Module createModule(long id) {
		Module module = new Module();
		module.setId(id);
		module.setReleaseDate(new Date());
		return module;
	}

	private Question createMockQuestion(long id) {
		Question question = new Question();
		question.setId(id);
		question.setDescription("xxxxxxxxxxxxxxxxxxxxxxxxxxxxyyyyyyyy yyyyyyyy ssssssssss");
		question.setShortName("How is this unit test?");
		question.setAnswers(createAnswers());
		question.setForm(createMockQuestionForm(1l, 2));
		return question;
	}

	private List<Answer> createAnswers() {
		List<Answer> answers = new ArrayList<Answer>();
		answers.add(createAnswer(1l));
		answers.add(createAnswer(2l));
		return answers;
	}
	
	private Answer createAnswer(long id) {
		Answer answer = new Answer();
		answer.setId(id);
		answer.setAnswerValues(createAnswerValues());
		return answer;
	}

	private List<AnswerValue> createAnswerValues() {
		List<AnswerValue> answerValues = new ArrayList<AnswerValue>();
		answerValues.add(createMockAnswerValue(1l));
		answerValues.add(createMockAnswerValue(2l));
		return answerValues;
	}

	private AnswerValue createMockAnswerValue(Long l) {
		AnswerValue answerValue = new AnswerValue();
		answerValue.setName("Unit test is good");
		
		return answerValue;
	}

}
