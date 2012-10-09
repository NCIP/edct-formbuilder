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
package com.healthcit.cacure.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.BatchUpdateException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.sql.DataSource;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.postgresql.util.PSQLException;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.jdbc.datasource.DataSourceUtils;

public class DBSchemaUpdater implements InitializingBean {

	private static Logger log = Logger.getLogger(DBSchemaUpdater.class);
	private static final String PATH_TO_UPPERS_FOLDER = "/db";
	private DataSource dataSource;

	@Override
	public void afterPropertiesSet() throws Exception {
		Connection connection = DataSourceUtils.getConnection(dataSource);
		connection.setAutoCommit(false);
		try {
			Statement statement = connection.createStatement();
			try {
				long version = 0;
				try {
					ResultSet rs = statement.executeQuery("select schema_version from sys_variables limit 1;");
					try {
						if(!rs.next()) {
							throw new RuntimeException("Seems there is no any row in sys_variables table.");
						}
						version = rs.getLong(1);
					} finally {
						rs.close();
					}
				} catch (PSQLException e) {
//					it's needed for executing more scripts successfully
					connection.rollback();
					log.info("Can't find sys_variables tables. Appling initial script.");
					String initialScriptStatements = getStatementsFor(0);
					if(initialScriptStatements == null) {
						throw new RuntimeException("Can't find initial script.");
					}
					statement.executeUpdate(initialScriptStatements);
					//there is already schema_version at 0
					connection.commit();
					log.info("Initial script succesfully executed.");
				}
				for (long v = version + 1; ; v++) {
					String statements = getStatementsFor(v);
					if(statements == null) {
						break;
					}
					log.info("Updating schema to " + v + " version...");
					statement.execute(statements);
					statement.executeUpdate("update sys_variables set schema_version = " + v + ";");
					connection.commit();
					log.info("OK");
				}
			} catch (BatchUpdateException e) {
				if(e.getNextException() != null) {
					e.getNextException().printStackTrace();
				}
				e.printStackTrace();
			} catch (Exception e) {
				e.printStackTrace();
				connection.rollback();
			} finally {
				statement.close();
			}
		} finally {
			DataSourceUtils.releaseConnection(connection, dataSource);
		}
	}
/**
 * Returns sql statements from upper file for passed version.
 * If correspondent upper file is not found it returns null;
 * @param version
 * @return
 * @throws IOException
 */
	private String getStatementsFor(final long version) throws IOException {
		InputStream resourceAsStream = this.getClass().getResourceAsStream(PATH_TO_UPPERS_FOLDER + "/" + version + ".up.sql");
		if(resourceAsStream == null) {
			return null;
		}
		BufferedReader br = new BufferedReader(new InputStreamReader(resourceAsStream));
		StringBuffer sb = new StringBuffer();
		try {
			String line;
			while((line = br.readLine()) != null) {
				if(StringUtils.isNotBlank(line) && !line.trim().startsWith("--")) {
					sb.append(line);
					sb.append("\n");
				}
			}
		} finally {
			br.close();
		}
		return sb.toString();
	}
	
	public DataSource getDataSource() {
		return dataSource;
	}

	public void setDataSource(DataSource dataSource) {
		this.dataSource = dataSource;
	}

}
