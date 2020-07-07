# Reflekt

## The step before the tests

Automated testing is fine but it's not perfect. Tests often check that a "golden path" still works. When actually most errors happen when the user or code does something unexpected. And automated testing isn't actually automated, humans still have to write the tests.

Reflekt writes the tests for you, and tests for the negative situations that you wouldn't have noticed.

Consider this logic:
1. Tests are often written in the positive
2. Users are going to break the system by walking off the golden path
3. Tests need to check for all of the possible broken paths
4. This can be automated
