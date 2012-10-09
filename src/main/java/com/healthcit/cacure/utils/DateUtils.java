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

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import org.apache.commons.lang.time.DateFormatUtils;

public class DateUtils {
	
	public static String DEFAULT_DATE_FORMAT = "MM/dd/yyyy";
	public static String DATE_FORMAT_A = "MMddyyyy";

	public static boolean isDate( String str )
	{
		boolean isDate = false; 
		
		if ( str == null ) return isDate;
		
		str = str.replaceAll("[/-]", "");
		
		DateFormat df = new SimpleDateFormat(DATE_FORMAT_A);
		
		try 
		{
			df.parse( str );
			
			isDate = true;
		}
		catch( ParseException ex )
		{
		}
		
		return isDate;
	}
	
	public static Date getDateValue( String str )
	{
		if ( str == null ) return null;
		
		Date dateValue = null;
		
		try
		{
			dateValue = new SimpleDateFormat( DEFAULT_DATE_FORMAT ).parse( str );
		}
		catch( ParseException ex )
		{
		}
		
		return dateValue;
	}
	
	public static String formatDate( Date date )
	{
		return formatDate( date, DEFAULT_DATE_FORMAT );
	}
	
	public static String formatDate( Date date, String format )
	{
		return new SimpleDateFormat( format ).format( date );
	}
	
	public static String formatDateUTC( Date date )
	{
		return DateFormatUtils.formatUTC( date, DateFormatUtils.ISO_DATETIME_FORMAT.getPattern() );
	}
	
	public static Date now()
	{
		return Calendar.getInstance().getTime();
	}
}
