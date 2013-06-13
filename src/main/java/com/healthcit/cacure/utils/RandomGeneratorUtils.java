/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.utils;

import java.text.DecimalFormat;
import java.util.Calendar;
import java.util.Date;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.RandomStringUtils;
import org.apache.commons.lang.math.RandomUtils;

/**
 * 
 * @author Oawofolu
 *
 */
public class RandomGeneratorUtils {
	
	// Random Generator algorithms
	// TODO: Other algorithm should be added as an enhancement
	public enum Algorithm { PSEUDORANDOM, EVEN }
		
	public static String generateRandomString()
	{		
		String randomStringPrefix = "Random String ";
		
		return randomStringPrefix + RandomStringUtils.randomNumeric( 10 );
	}
	
	public static Object selectRandomElement( Object[] elements, Object lastElement, Algorithm algorithm ) {
		if ( elements == null ) return null;
		
		int randomIndex = -1;
		
		switch( algorithm )
		{
			case PSEUDORANDOM:
				randomIndex = RandomUtils.nextInt( elements.length );
			
				return elements[ randomIndex ];
			case EVEN:
				int currentIndex = ArrayUtils.indexOf( elements, lastElement );
				
				randomIndex = ( currentIndex + 1 ) % elements.length;
				
				return elements[ randomIndex ];
			default:
				return null;
		}
	}
	
	public static Number selectRandomElementFromRange( Number lowerBound, Number upperBound, Number lastElement, Algorithm algorithm ) {
		
		if ( lowerBound == null ) lowerBound = 0;
		
		if ( upperBound == null ) upperBound = Integer.MAX_VALUE;
		
		boolean wholeNumbers = ( NumberUtils.isWholeNumber( lowerBound ) && NumberUtils.isWholeNumber( upperBound ) ) ;
		
		Number random = null;
		
		if ( lastElement == null ) lastElement = lowerBound;
		
		switch( algorithm )
		{
			case PSEUDORANDOM:
				double range = upperBound.doubleValue() - lowerBound.doubleValue();
				
				int rangePrecision = (int)Math.ceil( Math.log10( range ) );
				
				String decimalFormatPrecisionStr = org.apache.commons.lang.StringUtils.repeat( "#", rangePrecision );
				
				double seed = Double.parseDouble( new DecimalFormat( "#." + decimalFormatPrecisionStr ).format( Math.random() ) );
												
				random = lowerBound.doubleValue() + ( range * seed );		
				
				if ( wholeNumbers ) 
				{
					random = random.intValue();
				}
				
				else
				{
					double lowerBoundPrecision = NumberUtils.getPrecision( lowerBound ).doubleValue();
					
					double upperBoundPrecision = NumberUtils.getPrecision( upperBound ).doubleValue();
					
					double requiredPrecision = Math.max( lowerBoundPrecision, upperBoundPrecision );
					
					double numberWithRequiredPrecision = NumberUtils.roundDown( Math.random(), (int)requiredPrecision).doubleValue();
					
					random = random.intValue() + numberWithRequiredPrecision;
					
				}
				
				return random;
			case EVEN:
				
				random = lastElement.doubleValue() + 1;
				
				if ( upperBound != null && random.doubleValue() > upperBound.doubleValue() ) 
					random = upperBound; 
				
				return random;
				
			default:
				return null;
		}
	}
	
	
	public static String selectRandomElementFromRange( Date lowerBound, Date upperBound, Date lastElement, Algorithm algorithm ) {
		
		Calendar randomDate = null;
		
		if ( lowerBound == null ) lowerBound = DateUtils.getDateValue("1/1/1970");
		
		if ( upperBound == null ) upperBound = new Date();
		
		if ( lastElement == null ) lastElement = lowerBound;
		
		switch( algorithm )
		{
			case PSEUDORANDOM:
				long lowerBoundDays = Math.round(lowerBound.getTime()/( 1000 * 60 * 60 * 24 ) ); 
				
				long upperBoundDays = Math.round(upperBound.getTime()/( 1000 * 60 * 60 * 24 ) );
						
				Number randomNumDays = selectRandomElementFromRange( new Long(lowerBoundDays), new Long(upperBoundDays), lastElement.getTime(), algorithm );
				
				randomDate = Calendar.getInstance();
				
				randomDate.setTimeInMillis(randomNumDays.longValue() * 1000 * 60 * 60 * 24 );
				
				return DateUtils.formatDate(randomDate.getTime());
				
			case EVEN:
				
				randomDate = Calendar.getInstance();
				
				randomDate.setTimeInMillis( lastElement.getTime() + ( 1000 * 60 * 60 * 24 ) );
				
				if ( upperBound != null )
				{				
					Calendar upperBoundCalendar = Calendar.getInstance();
					
					upperBoundCalendar.setTime( upperBound );
					
					if ( randomDate.after( upperBoundCalendar ) ) randomDate.setTime( upperBound );
				}
				
				return DateUtils.formatDate(randomDate.getTime());
				
			default:
				return null;
		}
	}
	
	public static Object selectRandomElementFromRange( String lowerBound, String upperBound, String lastElement, Algorithm algorithm ) {
		
		Object randomElement = null;
		
		if ( org.apache.commons.lang.math.NumberUtils.isNumber( lowerBound ) &&
		     org.apache.commons.lang.math.NumberUtils.isNumber( upperBound ) )
		{ // the lowerbound/upperbound are numbers
			
			randomElement =
				selectRandomElementFromRange( 
					org.apache.commons.lang.math.NumberUtils.createNumber(lowerBound),
					org.apache.commons.lang.math.NumberUtils.createNumber(upperBound),
					org.apache.commons.lang.math.NumberUtils.createNumber(lastElement),
					algorithm);
		}
		
		else if ( DateUtils.isDate( lowerBound ) 
				 && DateUtils.isDate( upperBound ))
		{// the lowerbound/upperbound are dates
			randomElement =
				selectRandomElementFromRange( 
					DateUtils.getDateValue( lowerBound ), 
					DateUtils.getDateValue( upperBound ),
					DateUtils.getDateValue( lastElement ),
					algorithm);			
		}
		
		return randomElement;
	}
	
	public static int getNumberOfElementsInRange( String lowerBound, String upperBound )
	{
		int rangeSize = Integer.MAX_VALUE;
		
		if ( org.apache.commons.lang.math.NumberUtils.isNumber( lowerBound ) &&
			 org.apache.commons.lang.math.NumberUtils.isNumber( upperBound ) )
		{// the lowerbound/upperbound are numbers
			
			// Calculate the number of whole numbers in between both numbers
			double upperBoundDouble = org.apache.commons.lang.math.NumberUtils.toDouble( upperBound );
			
			double lowerBoundDouble = org.apache.commons.lang.math.NumberUtils.toDouble( lowerBound );
						
			double numWholeNumbers = Math.floor( upperBoundDouble - lowerBoundDouble );
			
			System.out.println( numWholeNumbers );

			// Get the maximum precision of the two numbers
			double maxPrecision = Math.max( NumberUtils.getPrecision(upperBoundDouble).doubleValue(), (double)NumberUtils.getPrecision(lowerBoundDouble).doubleValue() );
			
			// Then, multiply the number of whole numbers above by 10^precision.
			rangeSize = (int)(numWholeNumbers * Math.pow(10, maxPrecision));
			
		}
		
		else if ( DateUtils.isDate( lowerBound ) && DateUtils.isDate( upperBound ) )
		{// the lowerbound/upperbound are dates
			// Calculate the number of days between the two dates
			long diffInMilliseconds = DateUtils.getDateValue( upperBound ).getTime() - DateUtils.getDateValue( lowerBound ).getTime();
			
			rangeSize = (int)Math.floor( diffInMilliseconds / ( 1000 * 60 * 60 * 24 ) );
		}
		
		return rangeSize;
	}
}
