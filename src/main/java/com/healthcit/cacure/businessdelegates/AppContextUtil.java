/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.businessdelegates;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

public class AppContextUtil implements ApplicationContextAware 
{
    private static final AppContextUtil instance = new AppContextUtil();
    private ApplicationContext applicationContext;

    private AppContextUtil() {}

    public static AppContextUtil getInstance() 
    {
        return instance;
    }

    public <T> T getBean(Class<T> clazz) 
    {
        return applicationContext.getBean(clazz);
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException 
    {
        this.applicationContext = applicationContext;
    }
}
