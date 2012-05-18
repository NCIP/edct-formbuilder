package com.healthcit.cacure.test;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.sql.SQLException;

import javax.sql.DataSource;

import junit.framework.Assert;

import org.dbunit.DatabaseUnitException;
import org.dbunit.database.DatabaseConnection;
import org.dbunit.database.IDatabaseConnection;
import org.dbunit.dataset.IDataSet;
import org.dbunit.dataset.xml.FlatDtdWriter;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

public class RecreateDBUnitDTDTestCase extends AbstractIntegrationTestCase {
	
	@Autowired
	protected DataSource dataSource;
	
	@Test
	public void doRecreate() throws DatabaseUnitException, SQLException, FileNotFoundException {
		IDatabaseConnection dconnection = new DatabaseConnection(dataSource.getConnection());
		IDataSet dataSet = dconnection.createDataSet();
		File file = new File("formbuilder-dataset.dtd");
		
		Assert.assertTrue("DTD file can not be deleted.", !file.exists() || file.delete());
		
		Writer out = new OutputStreamWriter(new FileOutputStream(file));
		FlatDtdWriter datasetWriter = new FlatDtdWriter(out);
		datasetWriter.setContentModel(FlatDtdWriter.CHOICE);
		// You could also use the sequence model which is the default
		// datasetWriter.setContentModel(FlatDtdWriter.SEQUENCE);
		datasetWriter.write(dataSet);
		
		Assert.assertTrue("DTD file did not created.", file.exists());
	}
}