/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


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
