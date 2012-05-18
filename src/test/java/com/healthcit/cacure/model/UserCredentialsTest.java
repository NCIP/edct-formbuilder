package com.healthcit.cacure.model;

import junit.framework.TestCase;

import com.healthcit.cacure.utils.GetterAndSetterTester;

public class UserCredentialsTest extends TestCase {

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
        tester.testClass(Question.class);
    }
}
