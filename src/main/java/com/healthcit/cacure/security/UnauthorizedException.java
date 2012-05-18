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
