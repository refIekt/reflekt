# Reflekt

*The step before the tests*.

Test driven development is fine but it's not perfect. Tests often check that a "golden path" still works. When actually errors happen when the user or code does something unexpected. And automated testing isn't actually that automated, humans still have to write the tests.

Reflekt writes the tests for you, and tests for the negative situations that you wouldn't have noticed. It works out of the box with no extra coding required.

## Installation

Install:
```
gem install reflekt
```

## Usage

In your class add:
```ruby
prepend Reflekt # Add inside "class" block
```

Use the application as usual and test results will start showing up in the `reflekt/results` folder.

## Reasoning

Consider this logic:
1. Tests are often written in the positive
2. Users are going to break the system by walking off the golden path
3. Tests need to check for all of the possible broken paths
4. This can be automated

Test driven development is a carrot and a stick approach where the tests tell you where to go while simultaneously beating you with a stick. Let the code be your carrot and Reflect be your stick :)
