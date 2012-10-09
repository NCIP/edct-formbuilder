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
import com.healthcit.cacure.enums.ItemOrderingAction;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.utils.Constants;


public class FormListControllerTest {
	private FormManager formManager;
	private FormListController formListController;


	@Before
	public void setUp() {
		formListController = new FormListController();
		formManager = EasyMock.createMock(FormManager.class);
		formListController.setFormManager(formManager);
	}

	@Test
	public void testShowForms() {
		EasyMock.expect(formManager.getModuleForms(1l)).andReturn(createMockQuestionForms());
		EasyMock.replay(formManager);
		ModelAndView expected = createMockModelAndView(1l);
		ModelAndView actual = formListController.showForms(1l);
		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getModelMap().get("moduleId"), actual.getModelMap().get("moduleId"));
	}

	@Test
	public void testShowFormsWithModuleIdNull() {
		ModelAndView actual = null;
		try {
			actual = formListController.showForms(null);
			Assert.fail("Module Id is required value in request param");
		} catch (Exception e) {
			Assert.assertNull(actual);
		}
	}

	//TODO fix the test case
	@Test
	public void testSwapFormsForUp() {
		//formManager.moveFormInModule(1l, ItemOrderingAction.UP);
		EasyMock.expectLastCall();
		EasyMock.expect(formManager.getModuleForms(1l)).andReturn(createMockQuestionForms());
		EasyMock.replay(formManager);
		RedirectView expected = new RedirectView (Constants.QUESTIONNAIREFORM_LISTING_URI + "?moduleId=" + 1l, true);
		//RedirectView actual = (RedirectView) formListController.swapForms(1l, 1l, 1);
		//Assert.assertNotNull(actual);
		//Assert.assertEquals(expected.getUrl(), actual.getUrl());

	}

	//TODO fix the test case.
	@Test
	public void testSwapFormsForDown() {

		//formManager.moveFormInModule(1l, ItemOrderingAction.DOWN);
		EasyMock.expectLastCall();
		RedirectView expected = new RedirectView (Constants.QUESTIONNAIREFORM_LISTING_URI + "?moduleId=" + 1l, true);
		//RedirectView actual = (RedirectView) formListController.swapForms(1l, 1l, 1);
		//Assert.assertNotNull(actual);
		//Assert.assertEquals(expected.getUrl(), actual.getUrl());
	}

	@Test
	public void testDeleteForm() {
		formManager.deleteForm(11l);
		EasyMock.expectLastCall();
		EasyMock.replay(formManager);
		RedirectView expected = new RedirectView(Constants.QUESTIONNAIREFORM_LISTING_URI + "?moduleId=1", true);
		RedirectView actual = (RedirectView) formListController.deleteForm(11L, 1L, true);

		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getUrl(), actual.getUrl());
	}

	@Test
	public void testDeleteFormWithoutDelete() {
		EasyMock.expect(formManager.getModuleForms(1l)).andReturn(createMockQuestionForms());
		EasyMock.replay(formManager);
		RedirectView expected = new RedirectView (Constants.QUESTIONNAIREFORM_LISTING_URI + "?moduleId=" + 1l, true);
		RedirectView actual = (RedirectView) formListController.deleteForm(1l, 1l, false);
		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getUrl(), actual.getUrl());
	}

	private ModelAndView createMockModelAndView(long moduleId) {
		ModelAndView modelAndView = new ModelAndView("formList");
		ModelMap modelMap = modelAndView.getModelMap();
		modelMap.addAttribute("moduleId", moduleId);
		modelMap.addAttribute("moduleForms", createMockQuestionForms());
		return modelAndView;
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

	private List<QuestionnaireForm> createMockQuestionForms() {
		List<QuestionnaireForm> mockQuestions = new ArrayList<QuestionnaireForm>();
		mockQuestions.add(createMockQuestionForm(1l, 1));
		mockQuestions.add(createMockQuestionForm(2l, 2));
		return mockQuestions;
	}
}

