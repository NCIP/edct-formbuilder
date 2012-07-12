package com.healthcit.cacure.businessdelegates.export;

import static org.junit.Assert.*;

import java.io.File;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.omg.PortableInterceptor.SUCCESSFUL;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.orm.jpa.EntityManagerHolder;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import com.healthcit.cacure.export.model.Cure;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {
		"file:src/main/webapp/WEB-INF/spring/app-config.xml",
		"file:src/main/webapp/WEB-INF/spring/dao-config.xml", 
		"file:src/main/webapp/WEB-INF/spring/mailTemplates-config.xml"  
//		"file:src/main/webapp/WEB-INF/spring/security-config.xml" 
		})
@TransactionConfiguration(transactionManager = "transactionManager", defaultRollback = false)

public class DataExportTest {

	
	@Autowired
	EntityManagerFactory emf;
	
	@Autowired
	DataExport dataExport; 
	
	@Before
    public void setUp() {
		EntityManager em = emf.createEntityManager();
		TransactionSynchronizationManager.bindResource(emf , new EntityManagerHolder(em));
    }

    @After
    public void tearDown() throws Exception {
    	TransactionSynchronizationManager.unbindResourceIfPossible(emf);
    }

	@Test
	public void testConstructFormXML() throws JAXBException{
		assertNotNull(dataExport);
		JAXBContext jc = JAXBContext.newInstance("com.healthcit.cacure.export.model");
		Marshaller m = jc.createMarshaller();
	    //long formId = 9712;
	    //long formId = 9724;
	    long formId = 9731;
		//long formId = 9833;
		Cure xml = dataExport.constructFormXML(formId);
		//Cure xml = dataExport.constructFormXML(9724);
		//Cure xml = dataExport.constructFormXML(9731);
		//m.marshal(xml, new File("C:\\temp\\caure-9724.xml"));
		m.marshal(xml, new File("C:\\temp\\cure-"+ formId + ".xml"));
	}

}
