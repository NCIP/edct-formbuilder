/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.businessdelegates.export;

import static org.junit.Assert.*;

import java.io.File;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.orm.jpa.EntityManagerHolder;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import com.healthcit.cacure.businessdelegates.ModuleManager;
import com.healthcit.cacure.export.model.Cure;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.Module;


@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {
		"file:src/main/webapp/WEB-INF/spring/app-config.xml",
		"file:src/main/webapp/WEB-INF/spring/dao-config.xml", 
		"file:src/main/webapp/WEB-INF/spring/mailTemplates-config.xml"  
//		"file:src/main/webapp/WEB-INF/spring/security-config.xml" 
		})
@TransactionConfiguration(transactionManager = "transactionManager", defaultRollback = false)
public class DataImporterTest {

	@Autowired
	EntityManagerFactory emf;
	
	@Autowired
	DataImporter dataImporter; 
	
	@Autowired
	ModuleManager moduleManager;
	
	@Before
    public void setUp() {
		EntityManager em = emf.createEntityManager();
		TransactionSynchronizationManager.bindResource(emf , new EntityManagerHolder(em));
		login("lkagan", "koala");
    }

    @After
    public void tearDown() throws Exception {
    	TransactionSynchronizationManager.unbindResourceIfPossible(emf);
    }

    protected void login(String username, String password) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(username, password));
 
 //       logger.debug("User:" + username + " logged in");
    }
	@Test
	public void testConstructFormXML() throws JAXBException{
		assertNotNull(dataImporter);
		JAXBContext jc = JAXBContext.newInstance("com.healthcit.cacure.export.model");
		Unmarshaller m = jc.createUnmarshaller();
		//String formId = "9712";
		//String formId = "9724";
		String formId = "9731";
		//long formId = 9833;
		long moduleId = 9750;
		String fileName = "C:\\temp\\cure-" + formId + ".xml";
		//Cure xml = dataExport.constructFormXML(9712l);
		//Cure xml = dataExport.constructFormXML(9724);
		//m.marshal(xml, new File("C:\\temp\\caure-9724.xml"));
		//m.unmarshal( new File("C:\\temp\\caure-9731.xml"));
		Module module = (Module)moduleManager.getModule(moduleId);
		List<BaseForm> forms = module.getForms();
		int lastFormIndex = 0;
		if(forms != null)
		{ 
			lastFormIndex = forms.size();
		}
		Cure cure = (Cure)m.unmarshal( new File(fileName));
		dataImporter.importData(cure, module, lastFormIndex + 1);
	}
}
