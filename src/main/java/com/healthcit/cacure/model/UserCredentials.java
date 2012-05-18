package com.healthcit.cacure.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.OneToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Transient;

@Entity
@Table(name = "RPT_USERS")
public class UserCredentials implements StateTracker {

	@Id
	@SequenceGenerator(name = "userSequence", sequenceName = "\"RPT_USERS_SEQ\"", allocationSize=1)
	@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "userSequence")
	private Long id;

	private String username = "";
	private String password = "";

	@Column(name = "created_date")
	private Date createdDate = new Date();

	@Column(name = "email_addr")
	private String email = "";

	@Transient
	private String msg = "";
	@Transient
	private boolean status = false;

	@ManyToMany(fetch = FetchType.LAZY)
	@JoinTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"), inverseJoinColumns = @JoinColumn(name = "role_id"))
	private Set<Role> roles;

	@OneToMany(mappedBy="author", fetch=FetchType.LAZY)
	private List<BaseModule> authoredModules;

	@OneToMany(mappedBy="author", fetch=FetchType.LAZY)
	private List<BaseForm> authoredForms;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	/**
	 * @return the msg
	 */
	public String getMsg() {
		return msg;
	}

	/**
	 * @param msg
	 *            the msg to set
	 */
	public void setMsg(String msg) {
		this.msg = msg;
	}

	/**
	 * @return the status
	 */
	public boolean isStatus() {
		return status;
	}

	/**
	 * @param status
	 *            the status to set
	 */
	public void setStatus(boolean status) {
		this.status = status;
	}

	/**
	 * @return the userName
	 */
	public String getUserName() {
		return username;
	}

	/**
	 * @param userName
	 *            the userName to set
	 */
	public void setUserName(String userName) {
		this.username = userName;
	}

	/**
	 * @return the password
	 */
	public String getPassword() {
		return password;
	}

	/**
	 * @param password
	 *            the password to set
	 */
	public void setPassword(String password) {
		this.password = password;
	}

	/**
	 * @return the email
	 */
	public String getEmail() {
		return email;
	}

	/**
	 * @param email
	 *            the email to set
	 */
	public void setEmail(String email) {
		this.email = email;
	}

	public Date getCreatedDate() {
		return createdDate;
	}

	public void setCreatedDate(Date createdDate) {
		this.createdDate = createdDate;
	}
	
	/**
	 * @return The modules, which this user has authored
	 */
	public List<BaseModule> getAuthoredModules() {
		return authoredModules;
	}

	/**
	 * @param authoredModules The modules, which this user has authored
	 */
	public void setAuthoredModules(List<BaseModule> authoredModules) {
		this.authoredModules = authoredModules;
	}
	
	public void addAuthoredModule(Module newModule) {
		if(authoredModules == null) {
			authoredModules = new ArrayList<BaseModule>();
		}
		authoredModules.add(newModule);
	}
	
	public List<BaseForm> getAuthoredForms() {
		return authoredForms;
	}

	/**
	 * @param authoredModules The modules, which this user has authored
	 */
	public void setAuthoredForms(List<BaseForm> authoredForms) {
		this.authoredForms = authoredForms;
	}
	
	public void addAuthoredForm(BaseForm newForm) {
		if(authoredForms == null) {
			authoredForms = new ArrayList<BaseForm>();
		}
		authoredForms.add(newForm);
	}

	public Set<Role> getRoles() {
		return roles;
	}

	public void setRoles(Set<Role> roles) {
		this.roles = roles;
	}

	public void addRole(Role role)
	{
		if (roles == null)
			roles = new HashSet<Role>();

		roles.add(role);
	}

	@Transient
	public String getListOfRoles() {
		if (roles == null || roles.isEmpty()) {
			return null;
		}
		StringBuilder sb = new StringBuilder();
		Iterator<Role> it = roles.iterator();
		while (it.hasNext()) {
			Role role = it.next();
			sb.append(role.getName());
			if (it.hasNext()) {
				sb.append(", ");
			}
		}
		return sb.toString();
	}

	@Override
	public boolean isNew() {
		return (id == null);

	}



}