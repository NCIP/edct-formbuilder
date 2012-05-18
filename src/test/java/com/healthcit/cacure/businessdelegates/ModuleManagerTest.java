package com.healthcit.cacure.businessdelegates;

import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.expectLastCall;
import static org.easymock.classextension.EasyMock.createMock;
import static org.easymock.classextension.EasyMock.replay;
import static org.easymock.classextension.EasyMock.verify;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import junit.framework.TestCase;

import org.junit.Test;

import com.healthcit.cacure.dao.ModuleDao;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.model.UserCredentials;

public class ModuleManagerTest extends TestCase {
	private ModuleManager moduleManager;
	private ModuleDao moduleDaoMock;
	private UserCredentials currentUserMock;
	private UserManager userManagerMock;
	
	public void setUp() {
		currentUserMock = createMock("userCredentials", UserCredentials.class);
		
		moduleDaoMock = createMock("moduleDao", ModuleDao.class);
		
		moduleManager = new ModuleManager();
		moduleManager.setModuleDao(moduleDaoMock);
		
		userManagerMock = createMock("userManager", UserManager.class);
		moduleManager.setUserManager(userManagerMock);
	}
	
	@Test
	public void testGetAllModules() {
		List<Module> expectedModules = createModules();
		expect(moduleDaoMock.getOrderedModuleList()).andReturn(expectedModules);
		replay(moduleDaoMock);
		List<Module> actuals = moduleManager.getAllModules();
		assertNotNull(actuals);
		assertEquals(expectedModules.size(), actuals.size());
	}
	
	@Test
	public void testAddNewModule() {
		Module inputModule = createModule(null);
		expect(userManagerMock.getCurrentUser()).andReturn(currentUserMock);
		inputModule.setAuthor(currentUserMock);
		expect(moduleDaoMock.create(inputModule)).andReturn(inputModule);
		
		replay(moduleDaoMock);
		moduleManager.addNewModule(inputModule);
		verify(moduleDaoMock);
	}
	
	@Test
	public void testGetModule() {
		Module expectedModule = createModule(1l);
		expect(moduleDaoMock.getById(1l)).andReturn(expectedModule);
		replay(moduleDaoMock);
		BaseModule actualModule = moduleManager.getModule(1l);
		assertSame(expectedModule, actualModule);
	}
	
	@Test
	public void testUpdateModule() {
		Module inputModule = createMock(Module.class);
		moduleDaoMock.save(inputModule);
		replay(moduleDaoMock);
		moduleManager.updateModule(inputModule);
		verify(moduleDaoMock);
	}
	
	@Test
	public void testDeleteModule() {
		Module inputModule = createModule(1l);
		moduleDaoMock.delete(inputModule);
		expectLastCall();
		replay(moduleDaoMock);
		moduleManager.deleteModule(inputModule);
		assertNotNull(inputModule);
	}
	private Module createModule(Long id) {
		Module module = new Module();
		module.setId(id);
		module.setReleaseDate(new Date());
		return module;
	}

	private List<Module> createModules() {
		List<Module> modules = new ArrayList<Module>();
		modules.add(createModule(1l));
		modules.add(createModule(1l));
		return modules;
	}

}
