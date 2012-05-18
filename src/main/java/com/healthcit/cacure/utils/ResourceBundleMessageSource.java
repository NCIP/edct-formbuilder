package com.healthcit.cacure.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;

public class ResourceBundleMessageSource extends Properties
{

	/**
	 * This class encapsulates the properties loaded from *.properties files.  Property
	 * values can be obtained by calling AppConfig.getXXX(propName) where XXX can be String,
	 * Boolean, Int, Long, Double, and Float currently.  We could add Date as well but then we'd
	 * require a format as well.
	 *
	 * If a default value is supplied to getXXX methods, then the defaultValue is returned if the
	 * property name is not found in property file.  The getXXX methods that don't take a default
	 * value will throw an exception if the property does not exist.  These overloaded methods would
	 * be called normally as one wouldn't ask for a property that doesn't exist.
	 *
	 * @author ybrown
	 */
		private static final long serialVersionUID = -2775389877366109345L;

		private static Set<String> fileNames = new HashSet<String>();

		private  String filename;

		@Autowired
		private  org.springframework.context.support.ResourceBundleMessageSource msgSource;
		
		private static Map<Locale, Map<String, String>> messages = new HashMap<Locale, Map<String, String>>();
	    private ResourceBundleMessageSource() {}

	    private static ResourceBundleMessageSource me;

	    private static ResourceBundleMessageSource load(boolean reload) {
	        if (me == null || reload) {
	            me = new ResourceBundleMessageSource();
	            // Needed to prevent getters in other threads from accessing properties while
	            // properties are being loaded.  This is especially an issue during
	            // property file reloads
	            synchronized (me) {
	                for (String fileName : fileNames) {
	                    load(fileName, me);
	                }
	            }
	        }
	        return me;
	    }

	    /**
	     * Used by Spring to inject the property file name at startup
	     * @param filename - property file name to inject into Spring
	     */
	    public void setFileName(String filename) {
	        fileNames.clear();
	        fileNames.add(filename);
	        load(false);
	    }
	    
	    /**
	     * Used by Spring to inject the property file name at startup
	     * @param msgSource - property ResourceBundleMessageSource to inject into Spring
	     */
	    public void setResourceBundleMessageSource(org.springframework.context.support.ResourceBundleMessageSource msgSource) {
	    	this.msgSource = msgSource;
	    }

	    
	    public  Map<String, String> getMessages(Locale locale)
	    {
	    	Map<String, String> localizedMessages;
	    	if (messages.containsKey(locale))
	    	{
	    		localizedMessages = messages.get(locale);
	    	}
	    	else
	    	{
	    		synchronized(me)
	    		{
	    			localizedMessages = new HashMap<String, String>();
			    	Set<Object> keys = me.keySet();
			    	
			    	for (Object key: keys)
			    	{
			    		if (key instanceof String)
			    		{
			    		    String message = msgSource.getMessage((String)key, null, locale);
			    		    localizedMessages.put((String)key, message);
			    		    
			    		}
			    	}
		    		messages.put(locale, localizedMessages);
	    		}
		    	
	    	}
            return localizedMessages;
	    }
	    /**
	     * Can be used to reload a property file at runtime
	     */
	    public static void reload() {
	        load(true);
	    }

	    /**
	     * Loads properties if they've haven't been loaded already
	     */
	    public static void load() {
	        load(false);
	    }


	    /**
	     * This method is responsible for loading the property file represented by propertiesFileName
	     * into properties passed in.
	     *
	     * @param propertiesFileName - property file to load
	     * @param properties - ResourceBundleMessageSource object to load props into
	     * @return the ResourceBundleMessageSource instance loaded with properties
	     */
	    protected static ResourceBundleMessageSource load(String propertiesFileName, ResourceBundleMessageSource properties) {
	        InputStream in;
	        ClassLoader cl= ResourceBundleMessageSource.class.getClassLoader();
	        if (cl==null) {
	            FileInputStream fis;
	            try {
	                fis=new FileInputStream(new File(propertiesFileName));
	            } catch (Exception ex) {
	                throw new RuntimeException("ClassLoader returned null and could not find file="+propertiesFileName);
	            }
	            in=fis;
	        } else {
	            in = cl.getResourceAsStream(propertiesFileName);
	        }
	        if (in == null) {
	            Logger.getLogger(ResourceBundleMessageSource.class).warn("Could not read properties file: "+ propertiesFileName);
	        }
	        try {
	            properties.load(in);
	            if (null!=in) {
	                in.close();
	            }
	        } catch (Exception e) {
	            Logger.getLogger(ResourceBundleMessageSource.class).warn("Could not read properties file: "+ propertiesFileName);
	        }
	        return properties;
	    }

	    
}
