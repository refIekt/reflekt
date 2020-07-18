# Reflekt  

<img src="./Assets/Logo.svg" width="200" raw=true style="margin-left: 10px;" align="right" />

*Reflection-driven development.*  

Test-driven development is fine but it's not perfect. Tests often check for a golden path that works, when errors actually happen when the code or user does something unexpected. And with automated testing humans still have to write the tests.

**Reflekt** writes the tests for you, and tests in the negative for situations that you wouldn't have noticed. It works out of the box with no extra coding required. Because Reflekt tests your objects as they are used in the normal flow of the application, you get real world test results.

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

Don't forget to set `enabled: false` in your production config.

## Usage  

Inside a class that you want to test add:  
```ruby  
prepend Reflekt
```  

Use the application as usual and test results will start showing up in the `reflekt/results` folder.

## Configuration

You can configure Reflekt to not call "no undo" methods like deletion and sending email:

In your class add:

```ruby
deflekt :method_name
```

Also consider disabling Reflekt on methods that do the final rendering to the UI, to avoid a visual mess of duplicated elements.

## How it works

When a method is called in the usual flow of an application, Reflekt runs multiple simulations with different values on that method to see if it can break things, before handing back control to the method to perform its usual task.

<p align="center">
  <img src="./Assets/Flow.svg" raw=true width="500" style="margin-left: auto; margin-right: auto;"/>
</p>

## Comparison

Conceptual differences between TDD and RDD:

|                   | Test-driven development                  | Reflection-driven development                     |
--------------------|------------------------------------------|---------------------------------------------------|
| **Automation**    | Tests are defined manually.              | Tests are defined automatically.                  |
| **Granularity**   | Tests either PASS or FAIL.               | Tests are averaged into a PASS RATE.              |
| **Replication**   | Tests run externally on a new structure. | Tests run internally on the real world structure. |
| **Feedback loop** | Tests run periodically.                  | Tests run in real time.                           |

Consider this logic:  
1. Tests often check that things work (in the positive)  
2. Errors happen when things break (in the negative)  
3. Tests should check more often for the negative  
4. This can be automated

## QA

**Q.** Can I use it alongside test driven development too?  
**A.** Yes!
