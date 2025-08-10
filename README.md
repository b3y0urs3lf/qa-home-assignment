# Home Assignment

You will be required to write unit tests and automated tests for a payment application to demonstrate your skills. 

# Application information 

It’s an small microservice that validates provided Credit Card data and returns either an error or type of credit card application. 

# API Requirements 

API that validates credit card data. 

Input parameters: Card owner, Credit Card number, issue date and CVC. 

Logic should verify that all fields are provided, card owner does not have credit card information, credit card is not expired, number is valid for specified credit card type, CVC is valid for specified credit card type. 

API should return credit card type in case of success: Master Card, Visa or American Express. 

API should return all validation errors in case of failure. 


# Technical Requirements 

 - Write unit tests that covers 80% of application 
 - Write integration tests (preferably using Reqnroll framework) 
 - As a bonus: 
    - Create a pipeline where unit tests and integration tests are running with help of Docker. 
    - Produce tests execution results. 

# Running the  application 

1. Fork the repository
2. Clone the repository on your local machine 
3. Compile and Run application Visual Studio 2022.


# What was done:
1. Added unit tests 
2. Added integration tests using BDD framework Reqnroll
3. Created pipeline where tests executed and coverage report created in the end:
```
test-runner-1         | To view the report, open the following URL in your browser:
test-runner-1         | Coverage Report:      http://localhost:8080/reports/coverage/index.html
```

# How to run
- To run execute ```docker compose -up build```
- To close everything Ctrl+C ```docker compose down -v```
- To execute tests go to from your terminal to  ```cd CardValidation.Tests``` , and then using tags i.e:
 ```
 dotnet test --filter "Category=e2e"
 dotnet test --filter "Category=e2e&Category=ownerNegativeCases
 dotnet test --filter "Category=e2e&Category=ownerPositiveCases"
dotnet test --filter "Category=in-memory&Category=ownerPositiveCases"
dotnet test --filter "Category=in-memory&Category=ownerNegativeCases"
dotnet test --filter "Category=in-memory&Category=ccvPositiveeCases"
 dotnet test --filter "Category=in-memory&Category=ccvPositiveCases"
 ```
- If you want to generate coverage report then:
 ```
dotnet test --settings ../coverlet.runsettings and then from main directory reportgenerator -reports:CardValidation.Tests/TestResults/**/coverage.opencover.xml -targetdir:coveragereport -reporttypes:Html
 ```
