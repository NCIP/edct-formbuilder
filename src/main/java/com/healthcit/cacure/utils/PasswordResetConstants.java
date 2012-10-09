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
public interface PasswordResetConstants {

	
	
	String PASSWORDRESET_FROMADDR = "Help@bct.org";
	String PASSWORDRESET_SUBJECT  = "Account Administration";
	String PASSWORDRESET_MESSAGE  = "\n Below is your password for the Health of Women Study website.";
	String PASSWORDRESET_MESSAGE1 = "\n Dear ";
	String PASSWORDRESET_MESSAGE2 = "\n password:";
	String PASSWORDRESET_MESSAGE3 = "\n User Name:";
	String PASSWORDRESET_MESSAGE4 = "\n Thank you for contacting us and please let us know if you have any other questions.\n\n Thank you.\n The Dr. Susan Love Research Foundation.";

	//MIK 
	String PASSWORD_CRYPT_SEED = "HOW"; 
}
