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
package com.healthcit.cacure.test;

import static java.lang.String.format;
import static org.apache.commons.lang.StringUtils.isNotBlank;
import static org.springframework.util.ClassUtils.getPackageName;
import static org.springframework.util.ClassUtils.getQualifiedName;

import java.lang.annotation.Annotation;
import java.lang.reflect.Method;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Collections;
import java.util.IdentityHashMap;
import java.util.Map;

import javax.sql.DataSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.dbunit.DefaultDatabaseTester;
import org.dbunit.IDatabaseTester;
import org.dbunit.database.DatabaseConnection;
import org.dbunit.dataset.ReplacementDataSet;
import org.dbunit.dataset.xml.FlatXmlDataSet;
import org.dbunit.operation.DatabaseOperation;
import org.springframework.core.Constants;
import org.springframework.core.annotation.AnnotationUtils;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.jdbc.datasource.DataSourceUtils;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.context.TestContext;
import org.springframework.test.context.support.AbstractTestExecutionListener;

/**
 * Spring test framework TestExecutionListener which looks for the DataSet
 * annotation and if found, attempts to load a data set (test fixture) before
 * the test is run.
 */
public class DataSetTestExecutionListener extends AbstractTestExecutionListener {

//  private static final String DEFAULT_TEST_DATASET = "classpath:/" + getQualifiedName(testClass).replace('.', '/') + ".xml";
  private static final String DEFAULT_TEST_DATASET = "classpath:/test_dataset.xml";

protected final Log log = LogFactory.getLog(getClass());
  
  private final Map<Method, Configuration> configurationCache =
    Collections
      .synchronizedMap(new IdentityHashMap<Method, Configuration>());
  
  private final static Constants databaseOperations =
    new Constants(DatabaseOperation.class);

  public void beforeTestMethod(TestContext testContext) throws Exception {
    // Determine if a dataset should be loaded, from where, and extract any
    // special configuration.
    Configuration configuration =
      determineConfiguration(testContext.getTestClass(), testContext
        .getTestMethod());

    if (configuration == null)
      return;

    SecurityContextHolder.getContext().setAuthentication(
            new UsernamePasswordAuthenticationToken(configuration.getUserName(), configuration.getUserPassword()));
    
    if(configuration.getLocation() == null)
    	return;
    
    configurationCache.put(testContext.getTestMethod(), configuration);

    // Find a single, unambiguous data source.
    DataSource dataSource = lookupDataSource(testContext);

    // Fetch a connection from the data source, using an existing one if we're
    // already participating in a transaction.
    Connection connection = DataSourceUtils.getConnection(dataSource);
    configuration.setConnectionTransactional(DataSourceUtils
      .isConnectionTransactional(connection, dataSource));
    
    // Load the data set.
    loadData(configuration, connection);
  }

  public void afterTestMethod(TestContext testContext) throws Exception {
    Configuration configuration =
      configurationCache.get(testContext.getTestMethod());

    if (configuration == null)
      return;

    if (log.isInfoEnabled()) {
      log.info(format("Tearing down dataset using operation '%s', %s.",
        configuration.getTeardownOperation(), configuration
          .isConnectionTransactional() ? "leaving database connection open"
          : "closing database connection"));
    }

    configuration.getDatabaseTester().onTearDown();

    if (!configuration.isConnectionTransactional()) {
      try {
        configuration.getDatabaseTester().getConnection().close();
      }
      catch (Exception e) {
        // do nothing: this connection is associated with an active transaction
        // and we assume the framework will close the connection.
      }
    }

    configurationCache.remove(testContext.getTestMethod());
  }

  Configuration determineConfiguration(Class<?> testClass,
    Method testMethod) {
    DataSet annotation = (DataSet) findAnnotation(testMethod, DataSet.class);
    User userAnnotation = (User) findAnnotation(testMethod, User.class);

    if (annotation == null && userAnnotation == null)
      return null;

    Configuration configuration = new Configuration();

    if(annotation != null) {
    	// Dataset source value.
    	String location = annotation.value();
    	
    	if (location != null) {
    		if ("".equals(location)) {
    			location =
    				DEFAULT_TEST_DATASET;
    		}
    		else
    			if (!location.contains(":") && !location.contains("/")) {
    				location =
    					"classpath:/" + getPackageName(testClass).replace('.', '/') + "/"
    					+ location;
    			}
    	}
    	
    	configuration.setLocation(location);
    	
    	// Setup and teardown operations.
        if (isNotBlank(annotation.setupOperation()))
          configuration.setSetupOperation(annotation.setupOperation());

        if (isNotBlank(annotation.teardownOperation()))
          configuration.setTeardownOperation(annotation.teardownOperation());
    }

    if(userAnnotation != null) {
    	if(userAnnotation.value() != null)
    		configuration.setUserName(userAnnotation.value());
    	if(userAnnotation.password() != null)
    		configuration.setUserPassword(userAnnotation.password());
    }

    return configuration;
  }

  /**
   * Looks for a single, unambiguous datasource in the test's application
   * context.
   * 
   * @param testContext
   *          the current test context
   * @return the only datasource in the current application context
   */
  DataSource lookupDataSource(TestContext testContext) {
    /*String[] dsNames =
      testContext.getApplicationContext().getBeanNamesForType(DataSource.class);
    if (dsNames.length != 1) {
      final String s =
        "A single, unambiguous DataSource must be defined in the application context.";
      log.error(s);
      throw new IllegalStateException(s);
    }
    return (DataSource) testContext.getApplicationContext().getBean(dsNames[0]);
    */
	 return (DataSource) testContext.getApplicationContext().getBean("dataSource");
  }

  /**
   * Given the location of the dataset and the datasource.
   * 
   * @param configuration
   *          the spring-style resource location of the dataset to be loaded
   * @param connection
   *          the connection to use for loading the dataset
   * @throws Exception
   *           if an error occurs when loading the dataset
   */
  void loadData(Configuration configuration, Connection connection)
    throws Exception {
    if (log.isInfoEnabled()) {
      log.info(format(
        "Loading dataset from location '%s' using operation '%s'.",
        configuration.getLocation(), configuration.getSetupOperation()));
    }

    ReplacementDataSet dataSet =
      new ReplacementDataSet(new FlatXmlDataSet(new DefaultResourceLoader()
        .getResource(configuration.getLocation()).getInputStream()));
    dataSet.addReplacementObject("[NULL]", null);

    IDatabaseTester tester =
      new DefaultDatabaseTester(new DatabaseConnection(connection) {

        public void close() throws SQLException {
          // do nothing: this will be closed later if necessary.
        }
      });

    configuration.setDatabaseTester(tester);
    tester.setDataSet(dataSet);
    tester.setSetUpOperation((DatabaseOperation) databaseOperations
      .asObject(configuration.getSetupOperation()));
    tester.setTearDownOperation((DatabaseOperation) databaseOperations
      .asObject(configuration.getTeardownOperation()));
    tester.onSetup();
  }

  Annotation findAnnotation(Method method,
    Class<? extends Annotation> annotationType) {
    Annotation annotation =
      AnnotationUtils.findAnnotation(method, annotationType);
    return annotation == null ? AnnotationUtils.findAnnotation(method
      .getDeclaringClass(), annotationType) : annotation;
  }

  static class Configuration {

    private String location;
    private String setupOperation;
    private String teardownOperation;
    private IDatabaseTester databaseTester;
    private boolean connectionTransactional;
    
    private String userName;
    private String userPassword;
    
    public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getUserPassword() {
		return userPassword;
	}

	public void setUserPassword(String userPassword) {
		this.userPassword = userPassword;
	}

    public String getLocation() {
      return location;
    }

    public void setLocation(String location) {
      this.location = location;
    }

    public String getSetupOperation() {
      return setupOperation;
    }

    public void setSetupOperation(String setupOperation) {
      this.setupOperation = setupOperation;
    }

    public String getTeardownOperation() {
      return teardownOperation;
    }

    public void setTeardownOperation(String teardownOperation) {
      this.teardownOperation = teardownOperation;
    }

    public IDatabaseTester getDatabaseTester() {
      return databaseTester;
    }

    public void setDatabaseTester(IDatabaseTester databaseTester) {
      this.databaseTester = databaseTester;
    }

    public boolean isConnectionTransactional() {
      return connectionTransactional;
    }

    public void setConnectionTransactional(boolean connectionTransactional) {
      this.connectionTransactional = connectionTransactional;
    }
  }

}
