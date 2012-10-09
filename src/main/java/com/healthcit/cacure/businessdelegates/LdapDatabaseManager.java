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

import java.util.EnumSet;
import java.util.List;
import java.util.Set;

import com.healthcit.cacure.model.UserCredentials;
import com.healthcit.cacure.model.Role.RoleCode;

public interface LdapDatabaseManager {
	
	public UserCredentials findByName(String username);
	public UserCredentials getCurrentUser();
	public boolean isCurrentUserInRole(RoleCode role);
	public EnumSet<RoleCode> getCurrentUserRoleCodes();
	public Set<UserCredentials> loadUsersByRole(RoleCode roleCode);
	public List<UserCredentials> getAllUsers();
}
