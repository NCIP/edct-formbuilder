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
package com.healthcit.cacure.businessdelegates;

import org.apache.commons.lang.StringUtils;

public class DuplicateResultBean {
	private final DuplicateResultType result;
	private final String[] shortNames;

	public DuplicateResultBean(DuplicateResultType result, String[] shortNames) {
		super();
		this.result = result;
		this.shortNames = shortNames;
	}

	public DuplicateResultType getResult() {
		return result;
	}

	public String[] getShortNames() {
		return shortNames;
	}

	@Override
	public String toString() {
		return "DuplicateResultBean [result=" + result + ", shortNames="
				+ StringUtils.join(shortNames, ",") + "]";
	}
}
