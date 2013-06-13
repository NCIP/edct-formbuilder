/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.dao;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.hibernate.LazyInitializationException;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.healthcit.cacure.dao.utils.TestDatabasePopulator;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.model.QuestionnaireForm;

@RunWith(SpringJUnit4ClassRunner.class)
//specifies the Spring configuration to load for this test fixture
//@ContextConfiguration(locations={"classpath:/WEB-INF/spring/app-config.xml", "classpath:/WEB-INF/spring/dao-config.xml"})
@ContextConfiguration(locations={"classpath:test-app-config.xml", "classpath:test-dao-config.xml"})
public class BaseJpaDaoTest {
	@Autowired
	private FormDao baseJpaDao;
	private Long newlyInsertedId = 53500l;
	@PersistenceContext
	protected EntityManager em;
	
	@Autowired
	private TestDatabasePopulator testDatabasePopulator;
	
	@Before
	public void setUp() {
		//Creates test data base
		testDatabasePopulator.populate();
	}
	
	@After
	public void tearDown() {
		//Drop test data base
		testDatabasePopulator.dropTestDatabase();
	}

	@Test
	public void testCreate() {
		QuestionnaireForm inputQuestionnaireForm = createMockQuestionForm(null, 4, true);
		QuestionnaireForm questionForm = (QuestionnaireForm) baseJpaDao.create(inputQuestionnaireForm);
		Assert.assertNotNull(questionForm.getId());
		newlyInsertedId = questionForm.getId();
		for(Question question : questionForm.getQuestions()) {
			Assert.assertNotNull(question);
			Assert.assertNotNull(question.getId());
			for(Answer answer : question.getAnswers()) {
				Assert.assertNotNull(answer.getId());
			}
		}
	}

	@Test
	public void testGetById() {
		QuestionnaireForm actualQuestionnaireForm = baseJpaDao.getById(53500l);
		Assert.assertNotNull(actualQuestionnaireForm);
		Assert.assertNotNull(actualQuestionnaireForm.getId());
	}

	@Test
	public void testGetByIdLazyInitializeException() {
		QuestionnaireForm actualQuestionnaireForm = baseJpaDao.getById(53500l);
		Assert.assertNotNull(actualQuestionnaireForm);
		Assert.assertNotNull(actualQuestionnaireForm.getId());
		try {
			actualQuestionnaireForm.getQuestions().get(0);
			Assert.fail("Questions should be lazily initialized");
		} catch (LazyInitializationException e) {
			Assert.assertNotNull(actualQuestionnaireForm.getQuestions());
		}
	}

	@Test
	public void testUpdate() {
		QuestionnaireForm inputQuestionnaireForm = baseJpaDao.getById(newlyInsertedId);
		inputQuestionnaireForm.setName("Junit Test updated");
		baseJpaDao.update(inputQuestionnaireForm);
		QuestionnaireForm actualQuestionnaireForm = baseJpaDao.getById(newlyInsertedId);
		Assert.assertNotNull(actualQuestionnaireForm);
		Assert.assertNotNull(actualQuestionnaireForm.getId());
		Assert.assertEquals("Junit Test updated", actualQuestionnaireForm.getName());
	}

	@Test
	public void testSaveNewEntity() {
		QuestionnaireForm inputQuestionnaireForm = createMockQuestionForm(null, 4, true);
		QuestionnaireForm questionForm = (QuestionnaireForm) baseJpaDao.save(inputQuestionnaireForm);
		Assert.assertNotNull(questionForm.getId());
		newlyInsertedId = questionForm.getId();
		for(Question question : questionForm.getQuestions()) {
			Assert.assertNotNull(question);
			Assert.assertNotNull(question.getId());
			for(Answer answer : question.getAnswers()) {
				Assert.assertNotNull(answer.getId());
			}
		}
	}

	@Test
	public void testSaveExistingEntity() {
		QuestionnaireForm inputQuestionnaireForm =  baseJpaDao.getById(newlyInsertedId);
		inputQuestionnaireForm.setName("Junit saved exisitng entity");
		baseJpaDao.save(inputQuestionnaireForm);

		QuestionnaireForm actualQuestionnaireForm = baseJpaDao.getById(newlyInsertedId);
		Assert.assertNotNull(actualQuestionnaireForm);
		Assert.assertNotNull(actualQuestionnaireForm.getId());
		Assert.assertEquals("Junit saved exisitng entity", actualQuestionnaireForm.getName());
	}

	@Test
	public void testList() {
		List<QuestionnaireForm> actualQuestionnaireForms = baseJpaDao.list();
		Assert.assertNotNull(actualQuestionnaireForms);
		Assert.assertTrue(actualQuestionnaireForms.size() != 0);;
	}

	@SuppressWarnings("unchecked")
	@Test
	public void testDelete() {
		String jpql = "from QuestionnaireForm frm where frm.id is not null";
		Query query = em.createQuery(jpql);
		 List<QuestionnaireForm> questionFroms = query.getResultList();
		 for(QuestionnaireForm questionnaireForm : questionFroms) {
			 baseJpaDao.delete(questionnaireForm.getId());
		 }

		QuestionnaireForm actualQuestionnaireForm = baseJpaDao.getById(newlyInsertedId);
		Assert.assertNull(actualQuestionnaireForm);
	}



	private QuestionnaireForm createMockQuestionForm(Long id, Integer ordId, boolean isNew) {
		QuestionnaireForm mockQuestionnaireForm = new QuestionnaireForm();
		if(isNew) {
			mockQuestionnaireForm.setId(null);
			mockQuestionnaireForm.setModule(createModule(null));
		} else {
			mockQuestionnaireForm.setId(id);
			mockQuestionnaireForm.setModule(createModule(id));
		}
		mockQuestionnaireForm.setQuestions(createMockQuestions(isNew));
		mockQuestionnaireForm.setOrd(ordId);
		mockQuestionnaireForm.setName("Junit Question");
		return mockQuestionnaireForm;
	}

	private List<Question> createMockQuestions(boolean isNew) {
		List<Question> mockQuestions = new ArrayList<Question>();
		if(!isNew) {
			mockQuestions.add(createMockQuestion(null, isNew));
			mockQuestions.add(createMockQuestion(null, isNew));
		}
		return mockQuestions;
	}

	private Question createMockQuestion(Long id, boolean isNew) {
		Question question = new Question();
		question.setId(id);
		question.setShortName("How is this unit test?");
		question.setAnswers(createAnswers(isNew));
		return question;
	}

	private List<Answer> createAnswers(boolean isNew) {
		List<Answer> answers = new ArrayList<Answer>();
		if(!isNew) {
			answers.add(createAnswer(1l));
			answers.add(createAnswer(2l));
		} else {
			answers.add(createAnswer(null));
			answers.add(createAnswer(null));
		}
		return answers;
	}

	private Answer createAnswer(Long id) {
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

	private Module createModule(Long id) {
		Module module = new Module();
		module.setId(id);
		module.setReleaseDate(new Date());
		return module;
	}

//	@SuppressWarnings("unchecked")
//	private Long getJunitModuleFormId(String name) {
//		String jpql = "from QuestionnaireForm frm where frm.name like :name";
//		Query query = em.createQuery(jpql);
//		query.setParameter("name", name);
//		List<QuestionnaireForm> questionForms =  query.getResultList();
//		if(questionForms.size() > 0) {
//			return questionForms.get(0).getId();
//		} else {
//			return null;
//		}
//
//	}

	public void setTestDatabasePopulator(TestDatabasePopulator testDatabasePopulator) {
		this.testDatabasePopulator = testDatabasePopulator;
	}



}
