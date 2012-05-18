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
