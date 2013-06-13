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

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.ldap.userdetails.LdapUserDetailsImpl;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.healthcit.cacure.model.UserCredentials;
import com.healthcit.cacure.model.Role.RoleCode;

public class UserManagerService {  
	
	private String authType;

	@Autowired
	private LdapUserManager ldapUserMgr;
	
	@Autowired
	private UserManager userMgr;
	
	private LdapDatabaseManager mgr;
	
	public void setMgr(LdapDatabaseManager mgr) {
		this.mgr = mgr;
	}

	public UserCredentials getCurrentUser() {
		return mgr.getCurrentUser();	
	}
	
	public boolean isCurrentUserInRole(RoleCode role){
		return mgr.isCurrentUserInRole(role);
	}
	
	public EnumSet<RoleCode> getCurrentUserRoleCodes(){
		return mgr.getCurrentUserRoleCodes();
	}
	
	public String getAuthType() {
		return authType;
	}

	public void setAuthType(String authType) {		
		this.authType = authType;
		if(authType != null){
			if(authType.equalsIgnoreCase("ldap")){
				mgr = ldapUserMgr;
			} else {
				mgr = userMgr;
			}
		}
	}	
	
	public Set<UserCredentials> loadUsersByRole(RoleCode roleCode){
		return mgr.loadUsersByRole(roleCode);
	}
	
	public UserCredentials findByName(String userName){
		return mgr.findByName(userName);
	}
	
	public List<UserCredentials> getAllUsers(){
		return mgr.getAllUsers();
	}
	
}
