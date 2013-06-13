/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.security;

public class UnauthorizedException extends RuntimeException {

	/**
	 * UID
	 */
	private static final long serialVersionUID = 1L;
	
	public UnauthorizedException() {
		super();
	}
	
	public UnauthorizedException(String message) {
		super(message);
	}
}
