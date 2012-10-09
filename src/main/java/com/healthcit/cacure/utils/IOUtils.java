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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.X509TrustManager;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.directwebremoting.WebContext;
import org.directwebremoting.WebContextFactory;


public class IOUtils {

  private static Logger log = Logger.getLogger(IOUtils.class);
  private static AppConfig appConfig = AppConfig.getInstance();
  private static SSLSocketFactory socketFactory;
  private static String QUESTIONMARK = "?";
  private static String AMPERSAND = "&";
  private static String EQUALSIGN = "=";

  private static HostnameVerifier hostnameVerifier = new HostnameVerifier() {
    @Override
	public boolean verify(String hostname, SSLSession session) {
      return true;
    }
  };

  static {
    try {
      SSLContext ctx = SSLContext.getInstance("SSL");
      ctx.init(null, new X509TrustManager[] {new TrustAllManager()}, null);
      socketFactory = ctx.getSocketFactory();
    } catch (Exception e) {
      log.error("Can't initialize SSL Socket Factory: " + e.getMessage(), e);
    }
  }

	public static String read (InputStream is) throws IOException
	{
		String data = null;

		if (is != null)
		{
			// read into a buffer
			BufferedReader reader = new BufferedReader(new InputStreamReader(is));
			StringBuilder sb = new StringBuilder();
			String line = null;
			while ((line = reader.readLine()) != null)
			{
				sb.append(line + "\n");
			}
			data = sb.toString();
		}

		return data;
	}

	private static InputStream getInputStream( HttpServletRequest request ) {
		InputStream ins = null;
		try {
			ins = request.getInputStream();
		} catch( IOException ioe ){ log.error( "Could not get inputstream from request" );}
		return ins;
	}

	public static String read(HttpServletRequest request)
	{
		String content = null;
		
		try {
			InputStream ins = getInputStream( request );
			if ( ins != null ) content = read( ins );
		}catch( Exception e){ 
			log.debug( e.getMessage() );
		}
		
		return content;
	}
	
	public static String getURLContent( String contextURL ) throws IOException {
		return getURLContent( contextURL, false );
	}

	/**
	 * This method works only in the context of a DWR call
   * @param contextURL
   * @return
   * @throws IOException
   */
  public static String getURLContent(String contextURL, boolean isFullUrl) throws IOException {
    String fullUrl = isFullUrl ? contextURL : getFullURL(contextURL);
    URL url = new URL(fullUrl);
    
    URLConnection connection = url.openConnection();
    if (connection instanceof HttpsURLConnection) {
      ((HttpsURLConnection) connection).setSSLSocketFactory(socketFactory);
      ((HttpsURLConnection) connection).setHostnameVerifier(hostnameVerifier);
    }
    InputStreamReader br = new InputStreamReader(connection.getInputStream());
    
    StringWriter sw = new StringWriter(1024*1024);
    char[] c = new char[10000];
    int len;
    while ((len=br.read(c)) > 0){
    	sw.write(c, 0, len);
    }
    return sw.toString();
  }

	/**
   * @param pageName
   * @return
   */
	public static String getFullURL(String pageName) {
		String serverName = appConfig.getProperty("application-server.name", "localhost");
		log.debug("Server name is " + serverName);
		WebContext wctx = WebContextFactory.get();
		HttpServletRequest rq = wctx.getHttpServletRequest();
		StringBuilder url = new StringBuilder();
		url.append(rq.getScheme()).append("://").append(serverName).append(":").append(rq.getServerPort())
			.append(rq.getContextPath()).append(pageName);
		return url.toString();
	}

	/**
	 * This method works only in the context of a DWR call
   * @param pageName
   * @return
   */
   
	public static String getAppContextURL(HttpServletRequest request, String serverName) {
		if (serverName == null || serverName.length() == 0)
			serverName=request.getServerName();

		StringBuilder url = new StringBuilder();
		url.append(request.getScheme()).append("://")
			.append(serverName)
			.append(":").append(request.getServerPort())
			.append(request.getContextPath());
		return url.toString();
	}
	/**
	 * @param str String
	 * @return queryString with "+" instead of white spaces
	 */
	public static String convertStringToStringQuery(String str) {
		String regex = "[\\s]+";
		String[] spl = str.trim().split(regex);
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < spl.length; i++) {
			sb.append(spl[i]);
			if (i < spl.length - 1) {
				sb.append("+");
			}
		}
		return sb.toString();
	}
	
	public static String constructLocalUrl( String fullUrl, String[] parameterNames, String[] parameterValues ) {

		StringBuffer url = null;
		try {
			if ( parameterNames == null ) {
				throw new Exception( "Parameter names must not be null" );
			}
			if ( parameterValues == null ) {
				throw new Exception( "Parameter values must not be null" );
			}
			if ( parameterNames.length != parameterValues.length ) {
				throw new Exception( "Parameter names and parameter values must be the same length" ) ;
			}
			
			// WebContext wctx = WebContextFactory.get();
			// HttpServletRequest rq = wctx.getHttpServletRequest();
			url = new StringBuffer( fullUrl );
			
			for ( int i = 0; i < parameterNames.length; ++i ) {
				if ( i == 0 ) url.append( QUESTIONMARK );
				else          url.append( AMPERSAND );
				url.append( parameterNames[i] )
				   .append( EQUALSIGN )
				   .append( URLEncoder.encode( parameterValues[i], "UTF-8" ) );
			}
			
		} catch ( Exception ex ) {
			ex.printStackTrace();
		}
		return StringUtils.defaultIfEmpty( url.toString(), null );
	}

}
