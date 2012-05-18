package com.healthcit.cacure.model;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.DiscriminatorColumn;
import javax.persistence.DiscriminatorType;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;
import javax.persistence.OneToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.Proxy;



@Entity
@Table(name="skip_rule")
@Inheritance(strategy=InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name="parent_type", discriminatorType=DiscriminatorType.STRING)
//@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
@Proxy(lazy=false)
public abstract class BaseSkipRule implements StateTracker, Cloneable, Serializable
{
	@Id
	@SequenceGenerator(name="genericSequence", sequenceName="\"GENERIC_ID_SEQ\"", allocationSize=1)
	@GeneratedValue(strategy=GenerationType.SEQUENCE, generator="genericSequence")
	protected Long id;
	
	@OneToMany(orphanRemoval = true, mappedBy="skipRule", cascade={CascadeType.ALL}, fetch=FetchType.EAGER )
	List<QuestionSkipRule>questionSkipRules = new ArrayList<QuestionSkipRule>();

	@Column(name="logical_op")
	String logicalOp = "AND";
	
	
	public List<QuestionSkipRule> getQuestionSkipRules()
	{
		return questionSkipRules;
	}
	
	public Long getId()
	{
		return id;
	}
	
	public void setId(Long id)
	{
		this.id = id;
	}
	public String getLogicalOp()
	{
		return logicalOp;
	}
	
	public void setLogicalOp(String logicalOp)
	{
		this.logicalOp = logicalOp;
	}
	public String getRule()
	{
		StringBuilder rule = new StringBuilder(500);
		int i=0;
		for (QuestionSkipRule questionSkipRule: questionSkipRules)
		{
			rule.append(questionSkipRule.getDescription());
			if (i != (questionSkipRules.size() -1))
			{
				rule.append(" " + logicalOp +" ");
			}
			
			i++;
		}
		return rule.toString();
	}
	
	public void addQuestionSkipRule(QuestionSkipRule rule)
	{
		rule.setSkipRule(this);
		questionSkipRules.add(rule);
	
	}
	
	public void setQuestionSkipRule(List<QuestionSkipRule> skips)
	{
		this.questionSkipRules = skips;
	}
	
	public void removeSkips()
	{
		questionSkipRules = new ArrayList<QuestionSkipRule>();
	}
	@Override
	public boolean isNew() {
		return (id == null);

	}
}