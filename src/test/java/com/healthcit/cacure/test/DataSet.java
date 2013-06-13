/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.test;

import java.lang.annotation.*;

/**
 * Annotation which indicates that a test class or test method should load a
 * data set, using dbunit behind the scenes, before executing the test.
 */
@Target( { ElementType.METHOD, ElementType.TYPE })
@Retention(RetentionPolicy.RUNTIME)
@Inherited
@Documented
public @interface DataSet {

  String value() default "";

  String setupOperation() default "CLEAN_INSERT";

  String teardownOperation() default "NONE";
}
