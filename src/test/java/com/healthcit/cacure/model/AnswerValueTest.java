/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model;

import junit.framework.TestCase;

import com.healthcit.cacure.utils.GetterAndSetterTester;

public class AnswerValueTest extends TestCase {

    private GetterAndSetterTester tester;

    public void setUp(){
        tester = new GetterAndSetterTester();
    }

    /**
     * Test the getters and setters of a the given class.
     * Instantiation is left top the tester.
     *
     */
    public void testAllSettersAndGettersClass(){
        tester.testClass(Answer.class);
    }
}
