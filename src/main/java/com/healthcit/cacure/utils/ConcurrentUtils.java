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
package com.healthcit.cacure.utils;

import java.util.Collection;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class ConcurrentUtils {
	
	public static void invokeBulkActions( Collection<Callable<Object>> tasks )
	{
		invokeBulkActions(tasks, 20 );
	}
	
	public static void invokeBulkActions( Collection<Callable<Object>> tasks, int numFixedThreads )
	{
		ExecutorService executor = Executors.newFixedThreadPool( numFixedThreads );
		try
		{
			executor.invokeAll( tasks );
		}
		catch ( InterruptedException iex )
		{
		}
		finally
		{
			executor.shutdown();
		}
	}
}
