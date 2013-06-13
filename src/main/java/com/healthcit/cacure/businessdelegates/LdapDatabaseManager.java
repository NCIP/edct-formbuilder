/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


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
