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
package com.healthcit.cacure.model;

import junit.framework.TestCase;

import com.healthcit.cacure.utils.GetterAndSetterTester;

public class QuestionTest extends TestCase {

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
