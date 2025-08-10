@in-memory
Feature: Card Validation API

  As a user of the API
  I want to validate credit card information
  So that I can determine the card's payment system and ensure it is valid

  @positive
  Scenario Outline: Successfully validate a credit card
    Given the API is running
    When a POST request is sent to "/cardvalidation/card/credit/validate" with the following valid data:
      | Owner      | Number           | Date    | Cvv |
      | <Owner>    | <Number>         | <Date>  | <Cvv> |
    Then the response status code should be 200
    And the response content should be "<ExpectedResult>"

    Examples:
      | Owner      | Number           | Date    | Cvv | ExpectedResult |
      | John Smith | 4111111111111111 | 12/2025 | 123 | Visa           |
      | Jane Doe   | 5111111111111111 | 01/2026 | 456 | Mastercard     |
      | Foo Bar    | 341111111111111  | 01/2026 | 456 | AmericanExpress           |


  @negative
  Scenario Outline: Attempt to validate with an invalid card data
    Given the API is running
    When a POST request is sent to "/cardvalidation/card/credit/validate" with the following invalid data:
      | Owner    | Number        | Date    | Cvv |
      | <Owner>  | <Number>      | <Date>  | <Cvv> |
    Then the response status code should be 400
    And the response should contain the error "<ExpectedError>"

    Examples:
      | Owner    | Number        | Date    | Cvv | ExpectedError  |
      | Jane Doe | 1234567890123 | 01/2026 | 456 | Wrong number   |