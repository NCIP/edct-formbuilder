/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.model;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Transient;

/**
 * @author vetali
 *
 */
@Entity
@Table(name="ROLES")
public class Role implements StateTracker {

	public enum RoleCode {
		ROLE_AUTHOR,
		ROLE_APPROVER,
		ROLE_DEPLOYER,
		ROLE_LIBRARIAN,
		ROLE_ADMIN;
	}

	private static final List<ValueLabelPair<String, String>> listOfRoles;

	static
	{
		listOfRoles = new ArrayList<ValueLabelPair<String, String>>();
		for(RoleCode roleCode:  RoleCode.values())
		{
			listOfRoles.add(new ValueLabelPair<String, String>(roleCode.name(), roleCode.name()));
		}
	}

	@Id
	@SequenceGenerator(name="genericSequence", sequenceName="\"GENERIC_ID_SEQ\"", allocationSize=1)
	@GeneratedValue(strategy=GenerationType.SEQUENCE, generator="genericSequence")
	private Long id;

	@Column(name="name")
	@Enumerated (EnumType.STRING)
	private RoleCode roleCode;
	
	@ManyToMany(fetch = FetchType.LAZY)
	@JoinTable(name = "user_roles", joinColumns = @JoinColumn(name = "role_id"), inverseJoinColumns = @JoinColumn(name = "user_id"))
	private Set<UserCredentials> users;

	public Set<UserCredentials> getUsers() {
		return users;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public RoleCode getRoleCode() {
		return roleCode;
	}

	public void setRoleCode(RoleCode roleCode) {
		this.roleCode = roleCode;
	}

	@Transient
	public String getName() {
		return getRoleCode().name();
	}


	public List<ValueLabelPair<String, String>> getAvailableRoles()
	{
		return listOfRoles;
	}

	@Override
	@Transient
	public boolean isNew() {
		return (id == null);

	}
	
	@Override
	public boolean equals(Object obj) {
		if(obj instanceof Role) {
			Role otherRole = (Role)obj;
			return this.roleCode == otherRole.roleCode;
		} else {
			return false;
		}
	}
}
