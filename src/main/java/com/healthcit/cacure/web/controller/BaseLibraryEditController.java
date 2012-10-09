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
package com.healthcit.cacure.web.controller;

import org.springframework.web.bind.annotation.ModelAttribute;

import com.healthcit.cacure.utils.Constants;

/**
 * Base class for libraries editing controllers
 *
 */
public class BaseLibraryEditController extends BaseModuleEditController {
	
	public static final String CANCEL_URL = "cancelUrl";
	
	@ModelAttribute(CANCEL_URL)
	public String getCancelUrl()
	{
		return Constants.LIBRARY_MANAGE_URI;
	}
}
