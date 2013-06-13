/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller;

public class InvalidStateException extends RuntimeException
{

	public InvalidStateException()
	{
		super();
	}

	public InvalidStateException(String message)
	{
		super(message);
	}

}
