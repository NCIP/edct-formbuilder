package com.healthcit.cacure.businessdelegates;

/**
 * @author Suleman Choudhry
 * @version
 */

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;

import javax.persistence.NoResultException;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import com.healthcit.cacure.dao.RoleDao;
import com.healthcit.cacure.dao.UserManagerDao;
import com.healthcit.cacure.model.Role;
import com.healthcit.cacure.model.Role.RoleCode;
import com.healthcit.cacure.model.UserCredentials;

public class UserManager implements UserDetailsService {

	private static final Logger log = Logger.getLogger(UserManager.class);

	@Autowired
	private UserManagerDao userManagerDao;

	@Autowired
	private RoleDao roleDao;
	
	public UserCredentials authenticateUser(String username, String password ) {
		UserCredentials userCred = userManagerDao.findByName(username);
		if (userCred != null && userCred.getPassword().equals(password))
			return userCred;
		else
			return null;
		
	}
	
	public UserCredentials createUser( String username, String password ) {
		UserCredentials userCred = new UserCredentials();
		userCred.setUserName(username);
		userCred.setPassword(password);
		
		userManagerDao.save(userCred);

		return userCred;
	}
	
	public boolean changePassword( String username, String password ) {

		UserCredentials userCred = userManagerDao.findByName(username);
		if (userCred != null)
		{
			userCred.setPassword(password);
			userManagerDao.save(userCred);
			return true;
		}
		else
			return false;
	}

	public UserCredentials createUser( UserCredentials user ) 
	{
		userManagerDao.save(user);
		return user;
	}

	public UserCredentials updateUser( UserCredentials user ) 
	{
		userManagerDao.save(user);
		return user;
	}

	public UserCredentials findById(Long id) {
		return userManagerDao.getById(id);
	}

	public UserCredentials findByName(String username) {
		UserCredentials user = null;
		try {
			user = userManagerDao.findByName(username);			
		} catch (NoResultException e) {
			log.info("entity not found with username = " + username);
		}
		return user;
	}

	public List<UserCredentials> getAllUsers() {
		return userManagerDao.list();
	}

	public Role getRole(Long id) {
		return roleDao.getById(id);
	}

	public List<Role> getAllRoles() {
		return roleDao.list();
	}

	
	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException, DataAccessException {
		UserCredentials user = findByName(username);
		if (user == null ) {
			throw new UsernameNotFoundException("Username not found");
		}
		
		//local inner class
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
					return role.compareTo(((GrantedAuthority) o).getAuthority());
				}
				return -1;
			}			
		}
		
		//getting user Roles
		List<Role> roles = userManagerDao.getUserRoles(user);
		List<GrantedAuthority> grantedAuthorityList = new ArrayList<GrantedAuthority>();
		if (roles != null && !roles.isEmpty()) {
			for (Role role : roles) {
				grantedAuthorityList.add(new GrantedAuthorityImpl(role.getName()));
			}
		}
		UserDetails res = new User(user.getUserName(), user.getPassword(), 
				true, true, true, true, grantedAuthorityList); 
				
		return res;
	}
	
	/**
	 * Retrieves users by the roleCode
	 * @param roleCode RoleCode enum value
	 * @return list, containing all the users, who are in this role 
	 */
	public Set<UserCredentials> loadUsersByRole(RoleCode roleCode) {
		Role role = roleDao.getByRoleCode(roleCode);
		return role.getUsers();
	}

	/**
	 * Retrieves the current user from the SecurityContext
	 * @return the current user
	 */
	public UserCredentials getCurrentUser() {
		String username = 
			SecurityContextHolder.getContext().getAuthentication().getName();
		UserCredentials currentUser = findByName(username);
		return currentUser;
	}

	public boolean isCurrentUserInRole(RoleCode role) {
		UserCredentials currentUser = getCurrentUser();
		List<Role> currentUserRoles = 
			userManagerDao.getUserRoles(currentUser);

		for(Role userRole : currentUserRoles) {
			if(userRole.getRoleCode() == role) 
				return true;
		}
		return false;
	}
	
	public EnumSet<RoleCode> getCurrentUserRoleCodes() {
		UserCredentials currentUser = getCurrentUser();
		List<Role> currentUserRoles = userManagerDao.getUserRoles(currentUser);

		ArrayList<RoleCode> userRoleCodes = new ArrayList<Role.RoleCode>();
		for(Role userRole : currentUserRoles) {
			userRoleCodes.add(userRole.getRoleCode()); 
		}
		
		return EnumSet.copyOf(userRoleCodes);
	}
	
}
