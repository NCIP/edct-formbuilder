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

import java.util.ArrayList;
import java.util.Collection;
import java.util.EnumSet;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;

import org.apache.log4j.Logger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ldap.core.ContextMapper;
import org.springframework.ldap.core.DirContextOperations;
import org.springframework.ldap.core.DistinguishedName;
import org.springframework.ldap.core.support.AbstractContextMapper;
import org.springframework.ldap.core.support.BaseLdapPathContextSource;
import org.springframework.ldap.filter.EqualsFilter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.GrantedAuthorityImpl;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.ldap.userdetails.LdapUserDetailsMapper;
import org.springframework.security.ldap.userdetails.PersonContextMapper;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.ldap.search.FilterBasedLdapUserSearch;
import org.springframework.security.ldap.search.LdapUserSearch;

import com.healthcit.cacure.dao.RoleDao;
import com.healthcit.cacure.model.Role;
import com.healthcit.cacure.model.UserCredentials;
import com.healthcit.cacure.model.Role.RoleCode;
import com.healthcit.cacure.utils.Constants;

public class LdapUserManager extends LdapUserDetailsMapper implements
		LdapUserSearch, LdapDatabaseManager {

	private static final Logger log = Logger.getLogger(LdapUserManager.class);	
	private BaseLdapPathContextSource contextSource;

	@Autowired
	private UserManagerService userService;

	@Autowired
	private UserManager userMgr;

	FilterBasedLdapUserSearch users = null;
	
	private UserDetails userDetails;
	
	

	public UserDetails mapUserFromContext(DirContextOperations ctx,
			String username, Collection<GrantedAuthority> authority) {
		
		userService.setAuthType(Constants.LDAP_AUTH_VALUE);
		
		// local inner class
		class GrantedAuthorityImpl implements GrantedAuthority {
			private static final long serialVersionUID = -4708051153956036063L;
			private final String role;

			public GrantedAuthorityImpl(String role) {
				this.role = role;
			}

			@Override
			public String getAuthority() {
				return role;
			}

			@SuppressWarnings("unused")
			public int compareTo(Object o) {
				if (o instanceof GrantedAuthority) {
					return role
							.compareTo(((GrantedAuthority) o).getAuthority());
				}
				return -1;
			}
		}

		UserDetails originalUser = super.mapUserFromContext(ctx, username,
				authority);

		// Current authorities come from LDAP groups
		Collection<GrantedAuthority> newAuthorities = originalUser
				.getAuthorities();

		List<GrantedAuthority> grantedAuthorityList = new ArrayList<GrantedAuthority>();
		if (newAuthorities != null && !newAuthorities.isEmpty()) {

			for (GrantedAuthority currentUserRoles : newAuthorities) {
				grantedAuthorityList.add(new GrantedAuthorityImpl(
						currentUserRoles.getAuthority()));
			}
		}

		UserDetails res = new User(originalUser.getUsername(),
				originalUser.getPassword(), true, true, true, true,
				grantedAuthorityList);
		
		this.userDetails = res;
		return res;
	}

	public UserCredentials getCurrentUser() {
		String username = SecurityContextHolder.getContext()
				.getAuthentication().getName();

		UserCredentials currentUser = findByName(username);
		return currentUser;

	}

	public UserCredentials findByName(String username) {

		UserCredentials user = null;
		
		DirContextOperations dir = searchForUser(username);
		if (dir != null) {
			user = getUserFromDatabase(username);			
		}
		
		return user;
	}
	
	private UserCredentials getUserFromDatabase(String userName){
		UserCredentials user = new UserCredentials();
		user.setUserName(userName);
		UserCredentials dbUser = userMgr.findByName(userName);
		if (dbUser == null) {
			log.debug("user not found in database...");
			dbUser = createDbUser(userName);
			user.setId(dbUser.getId());
		} else {
			log.debug("user found..." + dbUser.getId());
			
			user.setId(dbUser.getId());
		}
		return user;
	}

	private UserCredentials createDbUser(String userName) {
		UserCredentials user = new UserCredentials();
		user.setUserName(userName);
		return userMgr.createUser(user);
	}

	public DirContextOperations searchForUser(String username) {
		try {
			return users.searchForUser(username);
		} catch (UsernameNotFoundException e) {
			return null;
		}
	}

	public LdapUserManager(BaseLdapPathContextSource contextSource) {
		this.contextSource = contextSource;
		users = new FilterBasedLdapUserSearch("", Constants.LDAP_USER_SEARCH_FILTER, contextSource);
		
	}
	
	public EnumSet<RoleCode> getCurrentUserRoleCodes() {
		ArrayList<RoleCode> userRoleCodes = new ArrayList<Role.RoleCode>();		
		
		Collection<GrantedAuthority> currentUserRoles1 = SecurityContextHolder.getContext().getAuthentication().getAuthorities();
		for(GrantedAuthority currentUserRoles: currentUserRoles1){			
			userRoleCodes.add(RoleCode.valueOf(currentUserRoles.getAuthority()));
		}	
		 
		
		return EnumSet.copyOf(userRoleCodes);
	}
	
	public boolean isCurrentUserInRole(RoleCode role) {
		if(getCurrentUserRoleCodes().contains(role)){
			return true;
		}
		
		return false;		
	}
	
	
	@Autowired
	private RoleDao roleDao;
	public Set<UserCredentials> loadUsersByRole(RoleCode roleCode) {
		Role role = roleDao.getByRoleCode(roleCode);
		
		String groupFilter = createGroupFilter(roleCode);
			
		Set<UserCredentials> userCredentials = new HashSet<UserCredentials>();
		
		try {			
			Attributes attrs = contextSource.getReadOnlyContext().getAttributes(groupFilter);
			Attribute memAttr = attrs.get(Constants.LDAP_GROUP_UNIQUE_MEMBER);								
				
			NamingEnumeration<?> elements = memAttr.getAll();
			while(elements.hasMoreElements()){	
				DistinguishedName dn = new DistinguishedName((String)elements.nextElement());
				String userName = dn.getValue(Constants.LDAP_UID);
				DirContextOperations dir = searchForUser(userName);
				String email = dir.getStringAttribute("mail");				
				UserCredentials user = getUserFromDatabase(userName);
				user.setEmail(email);
				userCredentials.add(user);		
			}
			
			
		} catch (NamingException e) {
			log.error(e.getMessage());
		}
			
		
		return userCredentials;
	}
	
	private String createGroupFilter(RoleCode roleCode){
		String role = roleCode.toString();
		role = role.replace(Constants.LDAP_ROLE_PREFIX, "");
		StringBuilder groupFilter = new StringBuilder(Constants.LDAP_GROUP_CN);		
		groupFilter.append(role);
		groupFilter.append(Constants.LDAP_GROUPS);
		return groupFilter.toString().toLowerCase();
	}
	
	public List<UserCredentials> getAllUsers(){
		
		List<UserCredentials> userCredentials = new ArrayList<UserCredentials>();
		
		try {
			
			SearchControls searchCtls = new SearchControls();
			String returnedAtts[]={"uid"};
			searchCtls.setReturningAttributes(returnedAtts);
			searchCtls.setSearchScope(SearchControls.SUBTREE_SCOPE);
			String searchFilter = "(&(objectClass=person))";
								
			NamingEnumeration<SearchResult> elements = contextSource.getReadOnlyContext().search("", searchFilter, searchCtls);
			
			while(elements.hasMoreElements()){		
				DistinguishedName dn = new DistinguishedName(elements.nextElement().getName());
				String userName = dn.getValue("uid");		
				userCredentials.add(getUserFromDatabase(userName));		
			}			
			
		} catch (org.springframework.ldap.NamingException e) {
			e.printStackTrace();
			return null;
		} catch (NamingException e) {
			e.printStackTrace();
			return null;
		}	
		
		return userCredentials;
		
	}
	
	
	
	
}
