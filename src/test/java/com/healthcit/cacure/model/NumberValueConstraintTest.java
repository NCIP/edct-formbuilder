package com.healthcit.cacure.model;

import org.junit.Test;
import static org.junit.Assert.*;


public class NumberValueConstraintTest {
	
	@Test
	public void testParseString()
	{
		/* setting both min and max values */
		NumberValueConstraint constraint1 = new NumberValueConstraint(4,7);
		String stringConstraint1 = constraint1.getValueAsString();
		String expectedConstraint1 = NumberValueConstraint.MIN_VALUE_PREFIX + 4 + NumberValueConstraint.VALUES_SEPARATOR + NumberValueConstraint.MAX_VALUE_PREFIX + 7;
		assertEquals("String representation of the class is incorrect",expectedConstraint1, stringConstraint1);
		
		NumberValueConstraint newConstraint1 = new NumberValueConstraint(stringConstraint1);
		
		assertEquals("Objects should be equal", constraint1, newConstraint1);
		
		/* setting only min value */
		NumberValueConstraint constraint2 = new NumberValueConstraint(null,7);
		String stringConstraint2 = constraint2.getValueAsString();
		String expectedConstraint2 = NumberValueConstraint.MAX_VALUE_PREFIX + 7;
		assertEquals("String representation of the class is incorrect",expectedConstraint2, stringConstraint2);

		NumberValueConstraint newConstraint2 = new NumberValueConstraint(stringConstraint2);
		assertEquals("Objects should be equal", constraint2, newConstraint2);

		/* setting only max value */
		NumberValueConstraint constraint3 = new NumberValueConstraint(4,null);
		String stringConstraint3 = constraint3.getValueAsString();
		String expectedConstraint3 = NumberValueConstraint.MIN_VALUE_PREFIX + 4;

		NumberValueConstraint newConstraint3 = new NumberValueConstraint(stringConstraint3);
		assertEquals("Objects should be equal", constraint3, newConstraint3);

	}

}
