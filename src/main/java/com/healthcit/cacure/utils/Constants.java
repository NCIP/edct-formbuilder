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

/**
 * @author Suleman Choudhry
 * @version
 */

public class Constants {

	//properties for development
	public static final String ENVIRONMENT = "dev";  // dev environment
	public static final String USER_REPORTS_PATH = "/_work/_projects/HOW/reports/";  //dev

	//properties for production
	/* public static final String ENVIRONMENT = "prod";  // production env.
	public static final String USER_REPORTS_PATH = "/var/upload/sftp/shealthC/DataExports/"; // production
 	public static final String DATABASE_SERVER_NAME = "10.12.0.11"; //copy of production databse */

	public static final String CREDENTIALS = "Credentials";
	public static final String CURRENT_USER = "CurrentUser";
	public static final String USER_REPORT_NAME = "useranswers.txt";

	public static final String EMAIL_FROM_ADDRESS = "how@dslrf.org";
	//public static final String EMAIL_TO_ADDRESS = "schoudhry@healthcit.com";
	public static final String EMAIL_SUBJECT = "HOW Reports";

	//data object references
	public static final String MODULE_INFO_ARRAY = "moduleInfoArray";
	public static final String FORM_INFO_ARRAY = "formInfoArray";
	public static final String FORM_INFO = "formInfo";
	public static final String QUESTION_INFO_ARRAY = "questionInfoArray";

	public static final String MODULE_ID = "moduleId";
	public static final String FORM_ID = "formId";
	public static final String QUESTION_ID = "questionId";

	public static final String BREADCRUMB_COMMAND = "breadCrumbCmd";
	
	/**
	 * Breadcrumb model attribute name
	 */
	public static final String BREAD_CRUMB = "bread_crumb";

	/** Can't use ModelAttribute interdependency. The code below is not
	* guaranteed to work until Spring 3.1 See https://jira.springframework.org/browse/SPR-6299
	* @ModelAttribute("foo")
	* public Object getFoo() { ...}
	* @ModelAttribute("bar")
	* public Object getBar(@ModelAttribute("foo") Object foo) {
	* if( some condition of foo ){ do stuff }
	* }
	*/
	public static final String IS_EDITABLE = "isEditable";

	// default values
	public static final long INVALID_ID = -1L;
	public static final int MAX_ANSWERS_IN_QUESTION = 100;
	public static final int MAX_SKIP_IN_QUESTION = 25;

	// controller URIs
	public static final String DELETE_CMD_PARAM = "del";
	public static final String LOGOUT_URI = "/logout";
	public static final String HOME_URI = "/home";

	public final static String LIBRARY_MANAGE_URI = "/libraryManage.view";
	public final static String QUESTION_LIBRARY_EDIT_URI = "/questionLibrary.edit";
	public final static String FORM_LIBRARY_EDIT_URI = "/formLibrary.edit";
	public final static String QUESTION_LIBRARY_FORM_EDIT_URI = "/qFormLibrary.edit";
	public final static String FORM_LIBRARY_FORM_EDIT_URI = "/fFormLibrary.edit";
	
	public static final String MODULE_LISTING_URI = "/moduleList.view";
	public static final String MODULE_EDIT_URI = "/module.edit";
	public static final String MODULE_COPY_URI = "/module.copy";

	public static final String QUESTIONNAIREFORM_LISTING_URI = "/formList.view";
	public static final String QUESTIONNAIREFORM_EDIT_URI = "/form.edit";

	public final static String QUESTION_LISTING_URI = "/questionList.view";
	public final static String LINK_EDIT_URI = "/link.edit";
	public final static String QUESTION_EDIT_URI = "/question.edit";
	public final static String EXTERNAL_QUESTION_EDIT_URI = "/externalQuestion.edit";
	public final static String QUESTION_TABLE_EDIT_URI = "/questionTable.edit";
	public final static String QTE_AJAX_GET_ANASWERS_PARAM = "getAns";

	public final static String CONTENT_EDIT_URI = "/content.edit";

	public final static String QUESTION_LISTING_SKIP_URI = "/questionListSkip.view";
	public final static String FORM_LISTING_SKIP_URI = "/formListSkip.view";

	public final static String CATEGORY_LISTING_URI = "/categoryList.view";
	public static final String ADD_QUESTION_TO_LIBRARY_URI = "/addToQuestionsLibrary";
	public static final String ADD_FORM_TO_LIBRARY_URI = "/addToFormsLibrary";
	public static final String DELETE_FORM_URI = "/deleteForm";
	public static final String FORM_EXPORT_URI = "/form.export";
	public static final String MODULE_XML_EXPORT_URI = "/moduleXml.export";

	// Admin URLs
	public static final String USER_LISTING_URI = "/admin/userList.view";
	public static final String LDAP_LISTING_URI = "/ldap/ldapList.view";
	public static final String USER_EDIT_URI = "/admin/user.edit";
	public static final String GENERATE_SAMPLE_DATA_URI = "/admin/generateSampleData.view";
	public static final String PREFERENCES_URI = "/admin/preferences.view";

	//Preview URLs
	public static final String XFORM_PREVIEW_URI = "/preview/xform.view";
	
	//XForm Processing URLs
	public static final String XFORM_PROCESS_URI = "/process/xform.save";
	
	// HTML Generation
	public static final String HORIZONTAL = "Horizontal";
	public static final String VERTICAL = "Vertical";
	
	//Data Export
	public static enum ExportFormat {XML, EXCEL};
	public static final String EXPORT_EXCEL_XSLT_FILE ="export.excel_xslt_file";
	
	// CADSR
	public static final String CADSR_APP_QUERY_URL = "http://localhost:8080/caDSR/CADSRServlet";
	public static final String CADSR_QUESTION_DELETED_INDICATOR_PROPERTY = "deletedIndicator";
	public static final String CADSR_QUESTION_LATEST_VERSION_PROPERTY = "latestVersionIndicator";
	public static final String CADSR_QUESTION_LONG_NAME_PROPERTY = "longName";
	public static final String CADSR_REFERENCE_DOCUMENT_COLLECTION_PROPERTY = "referenceDocumentCollection";
	public static final String CADSR_VALUE_DOMAIN_PERMISSIBLE_VALUES_PROPERTY = "valueDomainPermissibleValueCollection";
	public static final String CADSR_VALUE_DOMAIN_PROPERTY = "valueDomain";
	public static final String CADSR_PREFFERD_QUESTION_TEXT = "Preferred Question Text";
	public static final int CADSR_SEARCH_FAILED_HTTPCODE = 599;
	public static final String ANS_VALUE = "ansValue";
	
	public static final String LDAP_AUTH_VALUE = "ldap";
	public static final String DB_AUTH_VALUE = "db";
	
	//LDAP
	public static final String LDAP_GROUP_UNIQUE_MEMBER = "uniqueMember";
	public static final String LDAP_GROUPS = ",ou=groups";
	public static final String LDAP_GROUP_CN = "cn=";
	public static final String LDAP_ROLE_PREFIX = "ROLE_";
	public static final String LDAP_UID = "uid";
	public static final String LDAP_USER_SEARCH_FILTER = "(uid={0})";

	
}
