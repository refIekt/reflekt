# Reflekt  

*Reflection powered automatic testing*.  

Test driven development is *fine* but it's not perfect. Tests often check for a golden path that works, when errors actually happen when the code or user does something unexpected. And with automated testing humans still have to write the tests.

**Reflekt** writes the tests for you, and tests in the negative for situations that you wouldn't have noticed. It works out of the box with no extra coding required. You can use it alongside test driven development too.

## Installation  

Install:  
```  
gem install reflekt  
```  

In your [config](https://github.com/rubyconfig/config) YAML add:  
```yaml  
reflekt:
  enabled: true
```  

Don't forget to set `reflekt: false` in your production config.  

## Usage  

Inside your class add:  
```ruby  
prepend Reflekt
```  

Use the application as usual and test results will start showing up in the `reflekt/results` folder.

## Configuration

You'll likely want to stop Reflekt testing methods that delete data or output directly to the UI. Only "no undo" actions like deletion, sending email and the final rendering of the UI need to be disabled.

In your class add:

```ruby
dont_reflekt :method_name
```

By default Reflekt is opt-out but you can configure it to be opt-in:

```yaml
reflekt:
  [...]
  opt_in: true
```

Then instead of `dont_reflekt` use `reflekt`:
```ruby
reflekt :method_name
```

## How it works  

When a method is called in the usual flow of an application, Reflekt  runs multiple simulations with different values on the same method to see if it can break things, before handing back control to the method to perform its task as usual.

Because Reflekt tests your objects as they are used in the normal flow of the application, you get real world test results. It's not some external tool that periodically queries your app's API under a particular set of circumstances.

## Why?  

Consider this logic:  
1. Tests often check that things work (in the positive)  
2. Errors happen when things break (in the negative)  
3. Tests should check more often for the negative  
4. This can be automated  

**Rambling / Poetry:**
Test driven development is a carrot and a stick approach where the tests tell you where to go while beating you with a stick. Let the code be your carrot and Reflekt be your stick :)  
