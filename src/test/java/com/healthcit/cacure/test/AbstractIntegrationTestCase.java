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

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.commons.lang.StringUtils;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.TestExecutionListeners;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;
import org.springframework.test.context.transaction.TransactionConfiguration;

@ContextConfiguration(
		locations={"file:src/main/webapp/WEB-INF/spring/app-config.xml",
					"file:src/main/webapp/WEB-INF/spring/dao-config.xml",
					"file:src/main/webapp/WEB-INF/spring/mailTemplates-config.xml" 
					}
,inheritLocations = true)
@TestExecutionListeners( { DataSetTestExecutionListener.class })
@TransactionConfiguration(defaultRollback=true, transactionManager = "transactionManager")
public class AbstractIntegrationTestCase extends AbstractTransactionalJUnit4SpringContextTests {
	
	private static final SimpleDateFormat DATE_TIME_FORMAT = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss.SSS");
	private static final int UUID_LENGTH = 36;
	
	protected Date date(final String date) {
		try {
			return DATE_TIME_FORMAT.parse(date);
		} catch (ParseException e) {
			throw new RuntimeException(e);
		}
	}
	
	protected String uuid(final String uuid) {
		return uuid + StringUtils.repeat(" ", UUID_LENGTH - uuid.length());
	}
	
	protected boolean existsInDb(final String tableName, final Long... id) {
		return 0 < simpleJdbcTemplate.queryForInt("select count(*) from " + tableName + " where id in (" + StringUtils.join(id, ",") + ")");
	}
}
