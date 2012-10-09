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
package com.healthcit.cacure.dao.utils;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.DataSource;

import org.springframework.beans.factory.FactoryBean;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.core.io.Resource;

public class TestDatabasePopulator implements FactoryBean, InitializingBean {
	/**
	 * Populates a in memory data source with test data.
	 */
	
		private DataSource dataSource;
		
		private Resource schemaLocation;

		private Resource testDataLocation;
		
		private final static String DEV_SCHEMA_NAME = "FormBuilder" ;
		
		private final static String TEST_SCHEMA_NAME = "FormBuilderTest" ;
		
		public TestDatabasePopulator() {
		}

		/**
		 * Creates a new test database populator.
		 * @param dataSource the test data source that will be populated.
		 */
		public TestDatabasePopulator(DataSource dataSource) {
			this.dataSource = dataSource;
		}

		/**
		 * Populate the test database by creating the database schema from 'FormBuilder.sql' and insert data using testdata.sql.
		 */
		public void populate() {
			Connection connection = null;
			try {
				connection = dataSource.getConnection();
				createDatabaseSchema(connection);
				insertTestData(connection);
			} catch (SQLException e) {
				throw new RuntimeException("SQL exception occurred acquiring connection", e);
			} finally {
				if (connection != null) {
					try {
						connection.close();
					} catch (SQLException e) {
					}
				}
			}
		}
		
		/**
		 * Drop FormBuilder schema.
		 */ 
		public void dropTestDatabase() {
			Connection connection = null;
			try {
				connection = dataSource.getConnection();
				executeSql("DROP SCHEMA \"FormBuilderTest\" CASCADE", connection);
			} catch (SQLException e) {
				throw new RuntimeException("SQL exception occurred acquiring connection", e);
			} finally {
				if (connection != null) {
					try {
						connection.close();
					} catch (SQLException e) {
					}
				}
			}
		}

		// create the application's database schema (tables, indexes, etc.)
		private void createDatabaseSchema(Connection connection) {
			try {
				String sql = parseSqlIn(schemaLocation);
				//Changing sql query in order to create separate schema fro test phase, but use development scripts.
				sql = sql.replaceAll(DEV_SCHEMA_NAME, TEST_SCHEMA_NAME);
				executeSql(sql, connection);
			} catch (IOException e) {
				throw new RuntimeException("I/O exception occurred accessing the database schema file", e);
			} catch (SQLException e) {
				throw new RuntimeException("SQL exception occurred exporting database schema", e);
			}
		}

		// populate the tables with test data
		private void insertTestData(Connection connection) {
			try {
				String sql = parseSqlIn(testDataLocation);
				executeSql(sql, connection);
			} catch (IOException e) {
				throw new RuntimeException("I/O exception occurred accessing the test data file", e);
			} catch (SQLException e) {
				throw new RuntimeException("SQL exception occurred loading test data", e);
			}
		}

		// utility method to read a .sql txt input stream
        private String parseSqlIn(Resource resource) throws IOException {
			InputStream is = null;
			try {
				is = resource.getInputStream();
				BufferedReader reader = new BufferedReader(new InputStreamReader(is));
				
				StringWriter sw = new StringWriter();
				BufferedWriter writer = new BufferedWriter(sw);
			
				for (int c=reader.read(); c != -1; c=reader.read()) {
					writer.write(c);
				}
				writer.flush();
				return sw.toString();
				
			} finally {
				if (is != null) {
					is.close();
				}
			}
		}

		// utility method to run the parsed sql
		private void executeSql(String sql, Connection connection) throws SQLException {
			Statement statement = connection.createStatement();
			statement.execute(sql);
		}

		public void setDataSource(DataSource dataSource) {
			this.dataSource = dataSource;
		}

		public void setSchemaLocation(Resource schemaLocation) {
			this.schemaLocation = schemaLocation;
		}

		public void setTestDataLocation(Resource testDataLocation) {
			this.testDataLocation = testDataLocation;
		}

		public void afterPropertiesSet() {
			if (dataSource == null) {
				throw new IllegalArgumentException("datasource is required in order to create DB schema");
			}
			if (schemaLocation == null) {
				throw new IllegalArgumentException("The path to the database schema DDL is required");
			}
			if (testDataLocation == null) {
				throw new IllegalArgumentException("The path to the test data set is required");
			}
			
		}

		// implementing FactoryBean

		// this method is automatically called by Spring to expose the DataSource as a bean
		public Object getObject() throws Exception {
			return dataSource;
		}

		public Class getObjectType() {
			return DataSource.class;
		}

		public boolean isSingleton() {
			return true;
		}

}
