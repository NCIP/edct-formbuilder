/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.web.controller;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.easymock.classextension.EasyMock;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.businessdelegates.CategoryManager;
import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.Category;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.web.controller.question.QuestionElementEditController;


public class QuestionEditControllerTest {
	private FormManager formManager;
	private QuestionAnswerManager qaManager;
	private QuestionElementEditController questionEditController;
	private CategoryManager categoryManager;


	@Before
	public void setUp() {
		questionEditController = new QuestionElementEditController();
		formManager = EasyMock.createMock(FormManager.class);
		qaManager = EasyMock.createMock(QuestionAnswerManager.class);
		categoryManager = EasyMock.createMock(CategoryManager.class);
		//TODO fix the test case.
		/*questionEditController.setQaManager(qaManager);
		questionEditController.setFormManager(formManager);
		questionEditController.setCategoryManager(categoryManager);*/
	}

	@Test
	public void testCreateMainModelWithFormIdNotNull() {
		EasyMock.expect(categoryManager.getAllCategories()).andReturn(Arrays.asList(new Category()));
		EasyMock.replay(categoryManager);

		EasyMock.expect(qaManager.getQuestion(1l)).andReturn(createMockQuestion(1l));
		EasyMock.replay(qaManager);

		Question expected = createMockQuestion(1l);
		Question actual = questionEditController.createMainModel(1l);
		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getId(), actual.getId());
	}

	@Test
	public void testCreateMainModelWithFormIdNull() {
		EasyMock.expect(qaManager.getQuestion(1l)).andReturn(createMockQuestion(null));
		EasyMock.replay(qaManager);
		Question actual = questionEditController.createMainModel(null);
		Assert.assertNotNull(actual);
		Assert.assertNull(actual.getId());
		Assert.assertEquals(Constants.MAX_ANSWERS_IN_QUESTION, actual.getAnswers().size());
	}

	@SuppressWarnings("unchecked")
	@Test
	public void testInitLookupDataWithNull() {
		//TODO fix the test case.
		/*
		Map actual = questionEditController.initLookupData(null, null);
		Assert.assertNull(actual.get(QuestionEditController.FORM_ID_NAME));*/
	}

	@SuppressWarnings("unchecked")
	@Test
	public void testInitLookupDataWithoutNull() {
		//TODO fix the test case
		/*Map actual = questionEditController.initLookupData(1l, 1l);
		Assert.assertNotNull(actual.get(QuestionEditController.FORM_ID_NAME));
		Assert.assertEquals(new Long(1l), actual.get(QuestionEditController.FORM_ID_NAME));*/
	}

//	@Test
//	public void testDelete() {
//		Long formId = 1l;
//		Question inputQuestion = createMockQuestion(formId);
//		inputQuestion.setForm(createMockQuestionForm(1l, 1));
//		qaManager.deleteQestion(inputQuestion);
//		EasyMock.expectLastCall();
//		EasyMock.replay(qaManager);
//		RedirectView expected = new RedirectView (Constants.QUESTION_LISTING_URI+ "?formId=" + formId, true);
//		RedirectView actual = (RedirectView) questionEditController.delete(inputQuestion);
//
//		Assert.assertNotNull(actual);
//		Assert.assertEquals(expected.getUrl(), actual.getUrl());
//	}

	@SuppressWarnings("unchecked")
	@Test
	public void testShowForm() {
		//TODO fix the test case.
		/*Map lookUpData = new HashMap();
		Question question = createMockQuestion(1l);
		String actual = questionEditController.showForm(question, lookUpData, true);
		Assert.assertNotNull(actual);
		Assert.assertEquals("questionEdit", actual);*/
	}

	@SuppressWarnings("unchecked")
	@Test
	public void testOnSubmitForCreate() {
		Long formId = 1l;
		Map lookUpData = new HashMap();
		lookUpData.put(QuestionElementEditController.FORM_ID_NAME, formId);
		Question inputQuestion = createMockQuestion(null);
		MockHttpServletRequest request = new MockHttpServletRequest();

		EasyMock.expect(formManager.getForm(1l)).andReturn(createMockQuestionForm(formId, 1));
		EasyMock.replay(formManager);
		EasyMock.expect(qaManager.addNewQestion(inputQuestion, formId)).andReturn(createMockQuestion(1l));
		EasyMock.replay(qaManager);
		RedirectView expected = new RedirectView (Constants.QUESTION_LISTING_URI + "?formId=" + formId, true);
		RedirectView actual = (RedirectView) questionEditController.onSubmit(inputQuestion, lookUpData, null, null, request, null);

		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getUrl(), actual.getUrl());
	}

	@Test
	public void testOnSubmitForUpdate() {
		Long formId = 1l;
		Question inputQuestion = createMockQuestion(1l);
		inputQuestion.setForm(createMockQuestionForm(1l, 1));

		EasyMock.expect(qaManager.updateQuestion(inputQuestion)).andReturn(inputQuestion);
		EasyMock.replay(qaManager);
		RedirectView expected = new RedirectView (Constants.QUESTION_LISTING_URI + "?formId=" + formId, true);
		MockHttpServletRequest request = new MockHttpServletRequest();
		RedirectView actual = (RedirectView) questionEditController.onSubmit(inputQuestion, null, null, null, request, null);

		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getUrl(), actual.getUrl());
	}

	private QuestionnaireForm createMockQuestionForm(Long id, Integer ordId) {
		QuestionnaireForm mockQuestionnaireForm = new QuestionnaireForm();
		mockQuestionnaireForm.setId(id);
		mockQuestionnaireForm.setQuestions(createMockQuestions());
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

	private List<Question> createMockQuestions() {
		List<Question> mockQuestions = new ArrayList<Question>();
		mockQuestions.add(createMockQuestion(1l));
		mockQuestions.add(createMockQuestion(2l));
		return mockQuestions;
	}

	private Question createMockQuestion(Long id) {
		Question question = new Question();
		question.setId(id);
		question.setShortName("How is this unit test?");
		question.setAnswers(createAnswers());
		//question.setForm(createMockQuestionForm(1L, 1));
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

