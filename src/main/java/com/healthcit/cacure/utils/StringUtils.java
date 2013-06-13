/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.utils;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

public class StringUtils {
	public static List<?> getAsStrings( List<?> coll ) {
		List<String> list = new ArrayList<String>();
		for ( Iterator<?> iter = coll.iterator(); iter.hasNext(); ) {
			Object obj = iter.next();
			if ( obj != null ) list.add( obj.toString() );
		}
		return list;
	}
	
	public static String getAsCommaDelimitedString( List<?> coll ) {
		StringBuffer strBuffer = new StringBuffer();
		for ( Iterator<?> iter = coll.iterator(); iter.hasNext(); ) {
			Object obj = iter.next();
			if ( obj != null ) {
				strBuffer.append( obj.toString() );
				strBuffer.append(",");
			}
		}
		return strBuffer.toString();
	}
	
	/** 
	 * Replaces all occurrences of a substring within a StringBuffer with
	 * another string.
	 * 
	 * !!IMPORTANT!! Since StringBuilder is mutable and we are making 
	 * the modifications within a single instance, the text is going to be 
	 * replaced in the original as well. 
	 * 
	 * @param text the StringBuilder on which the operations to be performed
	 * @param toReplace the text, occurrences of which to be replaced
	 * @param replaceWith the text the replace them whit
	 * @return the mofified StringBuilder - since modifications are done within
	 * 			the original StringBuilder, this is just a courtesy return. 
	 */
	public static StringBuilder replace(StringBuilder text, String toReplace, String replaceWith){
		
		int index = text.indexOf(toReplace);
		
		while(index >= 0) {
			text.replace(index, toReplace.length() + index, replaceWith);
			index = text.indexOf(toReplace);
		}
		
		return text;
	}
	
	public static String truncateWithTrailingDots( String str, int length ) {
		if ( org.apache.commons.lang.StringUtils.trimToEmpty(str).length() > length)
			str   = org.apache.commons.lang.StringUtils.rightPad( org.apache.commons.lang.StringUtils.left( str, length ), length+3, "." );
		return str;		
	}
	
	private static Pattern REPLACE_DOUBLE_QUOTATION_MARKS_PATTERN = Pattern.compile("[\u201C\u201D]");
	private static Pattern REPLACE_SINGLE_QUOTATION_MARKS_PATTERN = Pattern.compile("[\u2018\u2019]");
	private static Pattern REPLACE_LONG_DASH_MARKS_PATTERN = Pattern.compile("[\u2212\u2013-\u2015]");
	private static Pattern REPLACE_SPACES_PATTERN = Pattern.compile("[ \u00A0]+");
	public static String normalizeString(String string) {
		if(string == null) return null;
		String result = string;
		result = REPLACE_DOUBLE_QUOTATION_MARKS_PATTERN.matcher(result).replaceAll("\"");
		result = REPLACE_SINGLE_QUOTATION_MARKS_PATTERN.matcher(result).replaceAll("'");
		result = REPLACE_LONG_DASH_MARKS_PATTERN.matcher(result).replaceAll("-");
		result = REPLACE_SPACES_PATTERN.matcher(result).replaceAll(" ");
		return result;
	}
	
	public static String prepareForShortName(String s){
		if(s == null) return null;
		return toCamelCase(s.replaceAll("[^\\p{Graph}]+", " "));
	}
	
	public static String toCamelCase(String s){
	   if(s == null) return null;
	   String[] parts = normalizeString(s).split("[\\p{Punct}\\s]+");
	   String camelCaseString = "";
	   for (String part : parts){
		  if(!"".equals(part)) {
			  camelCaseString = camelCaseString + part.substring(0, 1).toUpperCase() +
					  part.substring(1).toLowerCase();
		  }
	   }
	   return camelCaseString;
	}

}
