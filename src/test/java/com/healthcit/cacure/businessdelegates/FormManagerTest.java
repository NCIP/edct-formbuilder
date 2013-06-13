/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.businessdelegates;

import static org.easymock.EasyMock.expect;
import static org.easymock.classextension.EasyMock.createControl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.EnumSet;
import java.util.HashSet;
import java.util.List;

import junit.framework.TestCase;

import org.easymock.classextension.IMocksControl;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.healthcit.cacure.dao.FormDao;
import com.healthcit.cacure.dao.FormElementDao;
import com.healthcit.cacure.dao.QuestionElementDao;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseForm.FormStatus;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.BaseModule.ModuleStatus;
import com.healthcit.cacure.model.FormLibraryForm;
import com.healthcit.cacure.model.FormLibraryModule;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.model.QuestionsLibraryModule;
import com.healthcit.cacure.model.Role.RoleCode;
import com.healthcit.cacure.model.UserCredentials;
import com.healthcit.cacure.security.UnauthorizedException;
import com.healthcit.cacure.utils.MailSendingService;

public class FormManagerTest extends TestCase {

	private FormDao formDaoMock;
	private FormElementDao formElementDaoMock;
	private FormManager formManager;
	private IMocksControl control;
	private UserCredentials currentUserMock;
	private UserManager userManagerMock;
	private MailSendingService mailSendingServiceMock;
	private ModuleManager moduleManagerMock;
	private QuestionElementDao questionElementDaoMock;

	@Before
	public void setUp() {
		control = createControl();
		
		currentUserMock = control.createMock("userCredentials", UserCredentials.class);
		
		formManager = new FormManager();
		
		userManagerMock = control.createMock("userManager", UserManager.class);
		formManager.setUserManager(userManagerMock);
		
		formDaoMock = control.createMock("formDaoMock" ,FormDao.class);
		formManager.setFormDao(formDaoMock);
		
		mailSendingServiceMock = control.createMock("mailSendingService", MailSendingService.class);
		formManager.setMailSendingService(mailSendingServiceMock);
		
		moduleManagerMock = control.createMock("moduleManager", ModuleManager.class);
		formManager.setModuleManager(moduleManagerMock);
		
		/*formElementDaoMock = control.createMock("formElementDao", FormElementDao.class);
		formManager.setFormElementDao(formElementDaoMock);
		
		questionElementDaoMock = control.createMock("questionElementDao", QuestionElementDao.class);
		formManager.setQuestionElementDao(questionElementDaoMock);*/
	}
	
	@After
	public void tearDown() {
		control.verify();
	}

	@Test
	public void testGetModuleForms() {
		List moduleFormsMock = control.createMock(List.class);
		expect(formDaoMock.getModuleForms(1l)).andReturn(moduleFormsMock);
		
		control.replay();
		List<BaseForm> actualQuestions = formManager.getModuleForms(1l);
		assertSame(moduleFormsMock, actualQuestions);
	}

	@Test
	public void testAddNewForm() {
		BaseModule moduleMock = control.createMock(BaseModule.class);
		expect(moduleMock.getId()).andReturn(1l);
		
		BaseForm newFormMock = control.createMock(BaseForm.class);
		newFormMock.prepareForPersist();
		expect(newFormMock.getModule()).andReturn(moduleMock);
		newFormMock.setOrd(1);
		newFormMock.setAuthor(currentUserMock);
		newFormMock.setLockedBy(currentUserMock);
		newFormMock.setLastUpdatedBy(currentUserMock);
	
		expect(formDaoMock.calculateNextOrdNumber(1l)).andReturn(null);
		expect(userManagerMock.getCurrentUser()).andReturn(currentUserMock);
		formDaoMock.save(newFormMock);
		
		control.replay();
		formManager.addNewForm(newFormMock);
	}

	@Test
	public void testUpdateFormUnauthorizedException() {
		BaseForm formMock = control.createMock(BaseForm.class);
		expect(formMock.isEditable()).andReturn(false);
		control.replay();
		try {
			formManager.updateForm(formMock);
			fail("Unauthorized exception should be thrown.");
		} catch (UnauthorizedException e) {}
	}
	
	@Test
	public void testUpdateForm() {
		expect(userManagerMock.getCurrentUser()).andReturn(currentUserMock);
		
		BaseForm formMock = control.createMock(BaseForm.class);
		expect(formMock.isEditable()).andReturn(true);
		formMock.setLastUpdatedBy(currentUserMock);
		
		formMock.prepareForUpdate();
		formDaoMock.save(formMock);
		
		control.replay();
		BaseForm returnedForm = formManager.updateForm(formMock);
		assertSame(returnedForm, formMock);
	}

	@Test
	public void testDeleteFormUnauthorizedException() {
		BaseForm formMock = control.createMock(BaseForm.class);
		expect(formMock.isEditable()).andReturn(false);
		control.replay();
		try {
			formManager.deleteForm(formMock);
			fail("Unauthorized exception should be thrown.");
		} catch (UnauthorizedException e) {}
	}
	
	@Test
	public void testDeleteForm() {
		control.checkOrder(true);
		BaseForm formMock = control.createMock(BaseForm.class);
		expect(formMock.isEditable()).andReturn(true);
		formMock.prepareForDelete();
		formDaoMock.delete(formMock);
		
		control.replay();
		formManager.deleteForm(formMock);
	}
	
	@Test
	public void testGetForm() {
		FormLibraryForm formMock = control.createMock(FormLibraryForm.class);
		expect(formDaoMock.getById(1l)).andReturn(formMock);
		
		control.replay();
		BaseForm actualQuestions = formManager.getForm(1l);
		assertSame(formMock, actualQuestions);
	}
	
	@Test
	public void testAreAllModuleFormsApproved() {
		boolean expected = true;
		expect(formDaoMock.areAllModuleFormsApproved(1l)).andReturn(expected);
		
		control.replay();
		boolean actual = formManager.areAllModuleFormsApproved(1l);
		assertEquals(expected, actual);
	}
	
	@Test
	public void testDeleteFormWithEmptyQuestions() {
		formDaoMock.deleteFormWithEmptyQuestions(1l);
		
		control.replay();
		formManager.deleteForm(1l);
	}

	@Test
	public void testUnlockForm() {
		final int[] updated = new int[1];
		formManager = new FormManager() {
			public BaseForm updateForm(BaseForm form) {
				updated[0]++;
				return form;
			}
		};
		formManager.setFormDao(formDaoMock);
		formManager.setUserManager(userManagerMock);
		
		expect(userManagerMock.getCurrentUser()).andReturn(currentUserMock);
		
		expect(currentUserMock.getId()).andReturn(2l).anyTimes();
		
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		formMock.setLockedBy(null);
		expect(formMock.getLockedBy()).andReturn(currentUserMock);
		expect(formMock.isLocked()).andReturn(true);
		
		expect(formDaoMock.getById(1l)).andReturn(formMock);
		
		control.replay();
		BaseForm returnedForm = formManager.unlockForm(1l);
		assertSame(returnedForm, formMock);
		assertEquals("updateForm should be called once", 1, updated[0]);
	}
	
	@Test
	public void testUnlockFormUnauthorized() {
		expect(userManagerMock.getCurrentUser()).andReturn(currentUserMock);
		
		expect(currentUserMock.getId()).andReturn(2l).anyTimes();
		
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		UserCredentials otherUser = new UserCredentials();
		otherUser.setId(3l);
		expect(formMock.getLockedBy()).andReturn(otherUser );
		expect(formMock.isLocked()).andReturn(true);
		
		expect(formDaoMock.getById(1l)).andReturn(formMock);
		
		control.replay();
		try {
			formManager.unlockForm(1l);
			fail("Unauthorized exception should be thrown.");
		} catch (UnauthorizedException e) {}
	}
	
	@Test
	public void testUnlockFormNotLocked() {
		expect(userManagerMock.getCurrentUser()).andReturn(currentUserMock);
		
		expect(currentUserMock.getId()).andReturn(2l).anyTimes();
		
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		expect(formMock.getLockedBy()).andReturn(currentUserMock).anyTimes();
		expect(formMock.isLocked()).andReturn(false);
		
		expect(formDaoMock.getById(1l)).andReturn(formMock);
		
		control.replay();
		try {
			formManager.unlockForm(1l);
			fail("runtime exception should be thrown.");
		} catch (RuntimeException e) {}
	}
	
	@Test
	public void testLockForm() {
		final int[] updated = new int[1];
		formManager = new FormManager() {
			public BaseForm updateForm(BaseForm form) {
				updated[0]++;
				return form;
			}
		};
		formManager.setFormDao(formDaoMock);
		formManager.setUserManager(userManagerMock);
		
		expect(userManagerMock.getCurrentUser()).andReturn(currentUserMock);
		
		expect(currentUserMock.getId()).andReturn(2l).anyTimes();
		
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		formMock.setLockedBy(currentUserMock);
		expect(formMock.isLocked()).andReturn(false);
		expect(formMock.getStatus()).andReturn(FormStatus.IN_PROGRESS);
		
		expect(formDaoMock.getById(1l)).andReturn(formMock);
		
		control.replay();
		formManager.lockForm(1l);
		assertEquals("updateForm should be called once", 1, updated[0]);
	}
	
	@Test
	public void testLockFormNotInProgress() {
		expect(userManagerMock.getCurrentUser()).andReturn(currentUserMock);
		
		expect(currentUserMock.getId()).andReturn(2l).anyTimes();
		
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		expect(formMock.isLocked()).andReturn(false).anyTimes();
		expect(formMock.getStatus()).andReturn(FormStatus.APPROVED);
		
		expect(formDaoMock.getById(1l)).andReturn(formMock);
		
		control.replay();
		try {
			formManager.lockForm(1l);
			fail("runtime exception should be thrown.");
		} catch (RuntimeException e) {}
	}
	
	@Test
	public void testLockFormNotLocked() {
		expect(userManagerMock.getCurrentUser()).andReturn(currentUserMock);
		
		expect(currentUserMock.getId()).andReturn(2l).anyTimes();
		
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		expect(formMock.isLocked()).andReturn(true);
		expect(formMock.getStatus()).andReturn(FormStatus.IN_PROGRESS).anyTimes();
		
		expect(formDaoMock.getById(1l)).andReturn(formMock);
		
		control.replay();
		try {
			formManager.lockForm(1l);
			fail("runtime exception should be thrown.");
		} catch (RuntimeException e) {}
	}
	
	@Test
	public void testSubmitForApproval() {
		String webAppUri = "http://www.non-exist.test";
		String approver1Email = "approver1.approver.test";
		String approver2Email = "approver2.approver.test";
		
		HashSet<UserCredentials> users = new HashSet<UserCredentials>();
		UserCredentials approver1 = new UserCredentials();
		approver1.setEmail(approver1Email);
		users.add(approver1);
		UserCredentials approver2 = new UserCredentials();
		approver2.setEmail(approver2Email);
		users.add(approver2);
		
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		expect(formMock.getId()).andReturn(1l).anyTimes();
		expect(formMock.getStatus()).andReturn(FormStatus.IN_PROGRESS);
		expect(formMock.getLockedBy()).andReturn(currentUserMock);
		formMock.prepareForUpdate();
		formMock.setStatus(FormStatus.IN_REVIEW);
		
		expect(userManagerMock.getCurrentUser()).andReturn(currentUserMock);
		expect(userManagerMock.loadUsersByRole(RoleCode.ROLE_APPROVER)).andReturn(users);
		expect(currentUserMock.getId()).andReturn(2l).anyTimes();
		
		mailSendingServiceMock.sendSubmittedSectionNotification(formMock, approver1Email, webAppUri);
		mailSendingServiceMock.sendSubmittedSectionNotification(formMock, approver2Email, webAppUri);
		
		formDaoMock.save(formMock);
		
		control.replay();
		formManager.submitForApproval(formMock, webAppUri);
	}
	
	@Test
	public void testSubmitForApprovalUnauthorized() {
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		expect(formMock.getId()).andReturn(1l).anyTimes();
		UserCredentials otherUser = new UserCredentials();
		otherUser.setId(3l);
		expect(formMock.getLockedBy()).andReturn(otherUser);
		
		expect(userManagerMock.getCurrentUser()).andReturn(currentUserMock);
		expect(currentUserMock.getId()).andReturn(2l).anyTimes();
		
		control.replay();
		try {
			formManager.submitForApproval(formMock, "none");
			fail("unauthorized exception should be thrown.");
		} catch (UnauthorizedException e) {}
	}
	
	@Test
	public void testSubmitForApprovalNotInProgress() {
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		expect(formMock.getId()).andReturn(1l).anyTimes();
		expect(formMock.getStatus()).andReturn(FormStatus.IN_REVIEW);
		expect(formMock.getLockedBy()).andReturn(currentUserMock);
		
		expect(userManagerMock.getCurrentUser()).andReturn(currentUserMock);
		expect(currentUserMock.getId()).andReturn(2l).anyTimes();
		
		control.replay();
		try {
			formManager.submitForApproval(formMock, "none");
			fail("runtime exception should be thrown.");
		} catch (RuntimeException e) {}
	}
	
	@Test
	public void testDecideApproval() {
		final long[] checkedModuleId = new long[1];
		formManager = new FormManager() {
			public boolean areAllModuleFormsApproved(Long moduleId) {
				checkedModuleId[0] = moduleId;
				return true;
			}
		};
		formManager.setFormDao(formDaoMock);
		formManager.setUserManager(userManagerMock);
		formManager.setModuleManager(moduleManagerMock);
		
		Module module = new Module();
		long expectedModuleId = 4l;
		module.setId(expectedModuleId);
		
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		expect(formMock.getId()).andReturn(1l).anyTimes();
		expect(formMock.getStatus()).andReturn(FormStatus.IN_REVIEW).andReturn(FormStatus.APPROVED);
		expect(formMock.getModule()).andReturn(module).anyTimes();
		formMock.setStatus(FormStatus.APPROVED);
		formMock.prepareForUpdate();
		
		expect(userManagerMock.getCurrentUserRoleCodes()).andReturn(EnumSet.of(RoleCode.ROLE_ADMIN));
		expect(currentUserMock.getId()).andReturn(2l).anyTimes();
		
		moduleManagerMock.approveForPilot(module);
		
		formDaoMock.update(formMock);
		
		control.replay();
		formManager.decideApproval(formMock, true);
		assertEquals(expectedModuleId, checkedModuleId[0]);
	}
	
	public void testDecideApprovalUnauthorized() {
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		expect(formMock.getId()).andReturn(1l).anyTimes();
		
		expect(userManagerMock.getCurrentUserRoleCodes()).andReturn(EnumSet.of(RoleCode.ROLE_AUTHOR, RoleCode.ROLE_DEPLOYER, RoleCode.ROLE_LIBRARIAN));
		expect(currentUserMock.getId()).andReturn(2l).anyTimes();
		
		control.replay();
		try {
			formManager.decideApproval(formMock, true);
			fail("unauthorized exception should be thrown.");
		} catch (UnauthorizedException e) {}
	}
	
	@Test
	public void testDecideApprovalDisapprove() {
		Module module = new Module();
		long expectedModuleId = 4l;
		module.setId(expectedModuleId);
		
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		expect(formMock.getId()).andReturn(1l).anyTimes();
		expect(formMock.getStatus()).andReturn(FormStatus.IN_REVIEW).andReturn(FormStatus.IN_PROGRESS);
		expect(formMock.getModule()).andReturn(module).anyTimes();
		formMock.setStatus(FormStatus.IN_PROGRESS);
		formMock.prepareForUpdate();
		
		expect(userManagerMock.getCurrentUserRoleCodes()).andReturn(EnumSet.of(RoleCode.ROLE_ADMIN));
		expect(currentUserMock.getId()).andReturn(2l).anyTimes();
		
		formDaoMock.update(formMock);
		
		control.replay();
		formManager.decideApproval(formMock, false);
	}
	
	@Test
	public void testIsEditableInCurrentContextNewLibraryForm() {
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		expect(formMock.isNew()).andReturn(true);
		expect(formMock.isLibraryForm()).andReturn(true);
		
		expect(userManagerMock.getCurrentUserRoleCodes()).andReturn(EnumSet.of(RoleCode.ROLE_LIBRARIAN));
		
		control.replay();
		Boolean actual = formManager.isEditableInCurrentContext(formMock);
		assertEquals(Boolean.TRUE, actual);
	}
	
	@Test
	public void testIsEditableInCurrentContextLibraryForm() {
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		expect(formMock.isNew()).andReturn(false);
		expect(formMock.isEditable()).andReturn(false);
		expect(formMock.isLibraryForm()).andReturn(true);
		
		expect(userManagerMock.getCurrentUserRoleCodes()).andReturn(EnumSet.of(RoleCode.ROLE_LIBRARIAN));
		
		control.replay();
		Boolean actual = formManager.isEditableInCurrentContext(formMock);
		assertEquals(Boolean.FALSE, actual);
	}
	
	@Test
	public void testIsEditableInCurrentContext_NotLibraryForm_ForNotAuthorRole() {
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		expect(formMock.isNew()).andReturn(false);
		expect(formMock.isEditable()).andReturn(true);
		expect(formMock.isLibraryForm()).andReturn(false);
		
		expect(userManagerMock.getCurrentUserRoleCodes()).andReturn(EnumSet.of(RoleCode.ROLE_LIBRARIAN, RoleCode.ROLE_ADMIN));
		
		control.replay();
		Boolean actual = formManager.isEditableInCurrentContext(formMock);
		assertEquals(Boolean.FALSE, actual);
	}
	
	@Test
	public void testIsEditableInCurrentContextNotLibraryForm() {
		QuestionnaireForm formMock = control.createMock(QuestionnaireForm.class);
		expect(formMock.isNew()).andReturn(false);
		expect(formMock.isEditable()).andReturn(true);
		expect(formMock.isLibraryForm()).andReturn(false);
		
		expect(userManagerMock.getCurrentUserRoleCodes()).andReturn(EnumSet.of(RoleCode.ROLE_AUTHOR));
		
		control.replay();
		Boolean actual = formManager.isEditableInCurrentContext(formMock);
		assertEquals(Boolean.TRUE, actual);
	}
	
	@Test
	public void testReorderForms() {
		final QuestionnaireForm qform = new QuestionnaireForm();
		Module module = new Module();
		module.setStatus(ModuleStatus.IN_PROGRESS);
		qform.setModule(module);
		formManager = new FormManager() {
			public BaseForm getForm(Long id) {
				return qform;
			}
		};
		formManager.setFormDao(formDaoMock);
		
		long sourceFormId = 1l;
		long targetFormId = 2l;
		boolean before = true;
		
		formDaoMock.reorderForms(sourceFormId, targetFormId, before);
		
		control.replay();
		formManager.reorderForms(sourceFormId, targetFormId, before);
	}
	
	@Test
	public void testReorderFormsReleasedQuestionnaireModule() {
		final QuestionnaireForm qform = new QuestionnaireForm();
		Module module = new Module();
		module.setStatus(ModuleStatus.RELEASED);
		qform.setModule(module);
		formManager = new FormManager() {
			public BaseForm getForm(Long id) {
				return qform;
			}
		};
		formManager.setFormDao(formDaoMock);
		
		long sourceFormId = 1l;
		long targetFormId = 2l;
		boolean before = true;
		
		control.replay();
		try {
			formManager.reorderForms(sourceFormId, targetFormId, before);
			fail("runtime exception should be thrown.");
		} catch (RuntimeException e) {}
	}
	
	@Test
	public void testGetLibraryModule() {
		ArrayList<BaseModule> modules = new ArrayList<BaseModule>();
		QuestionsLibraryModule qlModule = new QuestionsLibraryModule();
		qlModule.setId(1l);
		modules.add(qlModule);
		FormLibraryModule flModule = new FormLibraryModule();
		flModule.setId(2l);
		modules.add(flModule);
		expect(moduleManagerMock.getLibraryModules()).andReturn(modules);
		control.replay();
		
		BaseModule libraryModule = formManager.getLibraryModule(QuestionsLibraryModule.class);
		assertTrue("object should be instance of requsted class", libraryModule instanceof QuestionsLibraryModule);
		assertSame(qlModule, libraryModule);
	}
	
	@Test
	public void testFindLibraryForms() {
		List moduleFormsMock = control.createMock(List.class);
		expect(formDaoMock.findLibraryForms("query")).andReturn(moduleFormsMock);
		
		control.replay();
		Collection<FormLibraryForm> actualQuestions = formManager.findLibraryForms("query");
		assertSame(moduleFormsMock, actualQuestions);
	}
	
	@Test
	public void testGetAllLibraryForms() {
		List moduleFormsMock = control.createMock(List.class);
		expect(formDaoMock.getAllLibraryForms()).andReturn(moduleFormsMock);
		
		control.replay();
		Collection<FormLibraryForm> actualQuestions = formManager.getAllLibraryForms();
		assertSame(moduleFormsMock, actualQuestions);
	}
	
	@Test
	public void testIsFormWithTheSameNameExistInLibrary() {
		expect(formDaoMock.isFormWithTheSameNameExistInLibrary("forName")).andReturn(true);
		
		control.replay();
		Boolean actual = formManager.isFormWithTheSameNameExistInLibrary("forName");
		assertSame(true, actual);
	}
	
//	TODO
//	addQuestionToQuestionLibrary
//	addFormToFormLibrary
//	importFormToModule
//	importForms
}
