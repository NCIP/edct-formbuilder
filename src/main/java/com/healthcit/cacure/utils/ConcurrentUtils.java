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
