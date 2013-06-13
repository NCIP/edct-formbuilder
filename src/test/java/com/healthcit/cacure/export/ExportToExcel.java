/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.export;

import java.io.File;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.Unmarshaller;
import javax.xml.bind.util.JAXBSource;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.springframework.beans.factory.annotation.Autowired;
import com.healthcit.cacure.businessdelegates.export.DataExporter;
import com.healthcit.cacure.export.model.Cure;

import javax.xml.bind.JAXBException;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.orm.jpa.EntityManagerHolder;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;
import org.springframework.transaction.support.TransactionSynchronizationManager;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {
		"file:src/main/webapp/WEB-INF/spring/app-config.xml",
		"file:src/main/webapp/WEB-INF/spring/dao-config.xml", 
		"file:src/main/webapp/WEB-INF/spring/mailTemplates-config.xml"  
//		"file:src/main/webapp/WEB-INF/spring/security-config.xml" 
		})
@TransactionConfiguration(transactionManager = "transactionManager", defaultRollback = false)

public class ExportToExcel {
	
	@Autowired
	EntityManagerFactory emf;
	
	@Autowired
	DataExporter dataExporter;
	
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
	public void export() throws JAXBException, TransformerException
	{
		JAXBContext jc = JAXBContext.newInstance("com.healthcit.cacure.export.model");
		File iFile = new File("C:\\temp\\moduleTest1.xml");
		//File iFile = new File("C:\\temp\\formExportTest.xml");
		//File iFile = new File("C:\\temp\\section1.1.xml");
		//File iFile = new File("C:\\temp\\complexSkip2.xml");
		//File iFile = new File("C:\\temp\\section3.1.xml");
		File oFile = new File("C:\\temp\\Book2.xml");
		Unmarshaller m = jc.createUnmarshaller();
		Cure xml = (Cure)m.unmarshal(iFile);
	    StreamSource xslSource = new StreamSource("src//main//resources//xls.xsl");
	    //long formId = 9979;
		
		//Cure xml = dataExporter.constructFormXML(formId);
	    JAXBSource xmlSource = new JAXBSource(jc, xml);
		Transformer transformer = TransformerFactory.newInstance().newTransformer(xslSource);
		transformer.transform(xmlSource,new StreamResult(oFile));
	}

}
