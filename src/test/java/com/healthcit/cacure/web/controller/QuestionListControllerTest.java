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
package com.healthcit.cacure.web.controller;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.easymock.classextension.EasyMock;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.enums.ItemOrderingAction;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.web.controller.question.FormElementListController;


public class QuestionListControllerTest {
	private FormManager formManager;
	QuestionAnswerManager qaManager;
	private FormElementListController questionListController;


	@Before
	public void setUp() {
		questionListController = new FormElementListController();
		formManager = EasyMock.createMock(FormManager.class);
		qaManager = EasyMock.createMock(QuestionAnswerManager.class);
		//TODO fix the test case.
		/*questionListController.setFormManager(formManager);
		questionListController.setQaManager(qaManager);*/
	}

	@Test
	public void testShowQuestions() {
		Long formId = 1l;
		EasyMock.expect(qaManager.getAllFormQuestionsWithChildren(formId)).andReturn(createMockQuestions());
		EasyMock.replay(qaManager);
		ModelAndView expected = createMockModelAndView(1l);
		ModelAndView actual = questionListController.showQuestions(1l);
		Assert.assertNotNull(actual);
		Assert.assertNotNull(expected.getModelMap().get("form"));
		Assert.assertEquals(((QuestionnaireForm)expected.getModelMap().get("form")).getQuestions().size(), ((QuestionnaireForm)actual.getModelMap().get("form")).getQuestions().size());
	}

	@Test
	public void testShowFormsForFormWithoutQuestions() {
		Long formId = 1l;
		EasyMock.expect(qaManager.getAllFormQuestionsWithChildren(formId)).andReturn(new ArrayList<Question>());
		EasyMock.replay(qaManager);
		EasyMock.expect(formManager.getForm(formId)).andReturn(createMockQuestionForm(formId, 1));
		EasyMock.replay(formManager);
		ModelAndView actual = questionListController.showQuestions(1l);
		ModelAndView expected = createMockModelAndView(formId);
		Assert.assertNotNull(actual);
		Assert.assertNotNull(expected.getModelMap().get("form"));
		Assert.assertEquals(((QuestionnaireForm)expected.getModelMap().get("form")).getQuestions().size(), ((QuestionnaireForm)actual.getModelMap().get("form")).getQuestions().size());
	}

	@Test
	public void testShowSkipQuestionList() {
		Long formId = 1l;
		EasyMock.expect(formManager.getForm(formId)).andReturn(createMockQuestionForm(formId, 1));
		EasyMock.replay(formManager);
		ModelAndView actual = questionListController.showSkipQuestionList(1l, 1l);

		ModelAndView expected = new ModelAndView("questionListSkip");
		ModelMap model = expected.getModelMap();
		model.addAttribute("form", createMockQuestionForm(formId, 1));
		Assert.assertNotNull(actual);
		Assert.assertNotNull(expected.getModelMap().get("form"));
		Assert.assertEquals(((QuestionnaireForm)expected.getModelMap().get("form")).getQuestions().size(), ((QuestionnaireForm)actual.getModelMap().get("form")).getQuestions().size());
	}

	@Test
	public void testSwapQuestionsForUp() {
		//TODO fix the test case.
		/*qaManager.moveQuestionInForm(1l, ItemOrderingAction.UP);
		EasyMock.expectLastCall();
		EasyMock.expect(qaManager.getAllFormQuestionsWithChildren(1l)).andReturn(createMockQuestions());
		EasyMock.replay(qaManager);
		RedirectView expected = new RedirectView(Constants.QUESTION_LISTING_URI + "?formId=" + 1, true);

		RedirectView actual = (RedirectView) questionListController.swapQuestions(1l, 1l, 1);
		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getUrl(), actual.getUrl());*/
	}

	@Test
	public void testSwapQuestionsForDown() {
		//TODO fix the test case.
		/*qaManager.moveQuestionInForm(1l, ItemOrderingAction.DOWN);
		EasyMock.expectLastCall();
		EasyMock.expect(qaManager.getAllFormQuestionsWithChildren(1l)).andReturn(createMockQuestions());
		EasyMock.replay(qaManager);
		RedirectView expected = new RedirectView(Constants.QUESTION_LISTING_URI + "?formId=" + 1, true);
		RedirectView actual = (RedirectView) questionListController.swapQuestions(1l, 1l, -1);
		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getUrl(), actual.getUrl());*/
	}

	//Removed this method as moveAnswerInQuestion method deprcated and swapAnswers method is removed.
//	@Test
//	public void testSwapAnswersForUp() {
//		qaManager.moveAnswerInQuestion(1l, ItemOrderingAction.UP);
//		EasyMock.expectLastCall();
//		EasyMock.expect(qaManager.getAllFormQuestionsWithChildren(1l)).andReturn(createMockQuestions());
//		EasyMock.replay(qaManager);
//		ModelAndView expected = createMockModelAndView(1l);
//		ModelAndView actual = questionListController.swapAnswers(1l, 1l, 1l, 1);
//		Assert.assertNotNull(actual);
//		Assert.assertNotNull(expected.getModelMap().get("form"));
//		Assert.assertEquals(((QuestionnaireForm)expected.getModelMap().get("form")).getQuestions().size(), ((QuestionnaireForm)actual.getModelMap().get("form")).getQuestions().size());
//	}

	//Removed this method as moveAnswerInQuestion method deprcated and swapAnswers method is removed.
//	@Test
//	public void testSwapAnswersForDown() {
//		qaManager.moveAnswerInQuestion(1l, ItemOrderingAction.DOWN);
//		EasyMock.expectLastCall();
//		EasyMock.expect(qaManager.getAllFormQuestionsWithChildren(1l)).andReturn(createMockQuestions());
//		EasyMock.replay(qaManager);
//		ModelAndView expected = createMockModelAndView(1l);
//		ModelAndView actual = questionListController.swapAnswers(1l, 1l, 1l, -1);
//		Assert.assertNotNull(actual);
//		Assert.assertNotNull(expected.getModelMap().get("form"));
//		Assert.assertEquals(((QuestionnaireForm)expected.getModelMap().get("form")).getQuestions().size(), ((QuestionnaireForm)actual.getModelMap().get("form")).getQuestions().size());
//	}

	private ModelAndView createMockModelAndView(long id) {
		ModelAndView mav = new ModelAndView("questionList");
		ModelMap model = mav.getModelMap();
		model.addAttribute("form", createMockQuestionForm(id, 1));
		return mav;
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

	private Question createMockQuestion(long id) {
		Question question = new Question();
		question.setId(id);
		question.setShortName("How is this unit test?");
		question.setForm(new QuestionnaireForm());
		question.setAnswers(createAnswers());
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


