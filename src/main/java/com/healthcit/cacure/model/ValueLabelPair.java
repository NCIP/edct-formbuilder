package com.healthcit.cacure.model;

public class ValueLabelPair <V, L>{

	private V value;
	private L label;
	public ValueLabelPair(V val, L lab)
	{
		this.value = val;
		this.label = lab;
	}
	
	public V getValue()
	{
		return value;
	}

	public L getLabel()
	{
		return label;
	}
}
