package com.healthcit.cacure.dao;

import javax.persistence.Query;

import com.healthcit.cacure.model.Role;
import com.healthcit.cacure.model.Role.RoleCode;


public class RoleDao extends BaseJpaDao<Role, Long>  
{

	public RoleDao() 
	{
		super(Role.class);
	}

	public Role getByRoleCode(RoleCode roleCode) {
		String jpql = "from Role r where r.roleCode = :roleCode";
		Query query = em.createQuery(jpql);
		query.setParameter("roleCode", roleCode);
		return (Role)query.getSingleResult();
	}

}
