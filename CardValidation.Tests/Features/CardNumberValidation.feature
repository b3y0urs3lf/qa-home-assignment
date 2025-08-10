@in-memory
Feature: Card Number Validation

  @numberNegativeCases
  Scenario Outline: Validate Card Number
    Given the API is running
    When a POST request is sent to "/cardvalidation/card/credit/validate" with the following data:
      | Owner      | Number   | Date    | Cvv |
      | John Smith | <Number> | 12/2025 | 123 |
    Then the response status code should be <StatusCode>
    And the response should contain the error "<ExpectedError>"

    Examples:
      | Number              | StatusCode | ExpectedError      | COmment                         |
      |                     | 400        | Number is required |                                 |
      | 1234567890          | 400        | Wrong number       |                                 |
      | abcdefghijklmno     | 400        | Wrong number       |                                 |
      # Invalid number length cases (should fail) for VIsa
      | 41234567890123      | 400        | Wrong number       | 14-digit (invalid length)       |
      | 412345678901234     | 400        | Wrong number       | 15-digit (invalid length)       |
      | 412345678901        | 400        | Wrong number       | Invalid (12 digits - too short) |
      | 41234567890123456   | 400        | Wrong number       | Invalid (17 digits - too long)  |
      | 4a23456789012       | 400        | Wrong number       | Invalid (contains letter)       |
      | 4123-4567-8901-2    | 400        | Wrong number       | Invalid (contains hyphens)      |
      | ""                  | 400        | Wrong number       | Invalid (empty string)          |
      | null                | 400        | Wrong number       | Invalid (null input)            |
      | 4                   | 400        | Wrong number       | Invalid (only prefix)           |
      | 412 345 678 9012    | 400        | Wrong number       | Invalid (contains spaces)       |
      | 0000000000000000    | 400        | Wrong number       | (All zeros)                     |
      #Invalid number length cases (should fail) for MasterCard
      | 2220000000000000    | 400        | Wrong number       | (Invalid 2-series start)        |
      | 2721000000000000    | 400        | Wrong number       | (Exceeds 2-series range)        |
      | 5699999999999999    | 400        | Wrong number       | (Invalid 5-series)              |
      | 511111111111111     | 400        | Wrong number       | (15 digits - too short)         |
      | 51111111111111111   | 400        | Wrong number       | (17 digits - too long)          |
      | 5A11111111111111    | 400        | Wrong number       | (Contains letters)              |
      | 5555 5555 5555 4444 | 400        | Wrong number       | (Contains spaces)               |
      | 2                   | 400        | Wrong number       | Invalid (only start of prefix)  |
      | 2720                | 400        | Wrong number       | Invalid (only prefix)           |
      | 0000000000000000    | 400        | Wrong number       | Invalid (all zeros)             |
      #Invalid number lenght cases (should fail) for AmericanExpress
      | 351111111111111     | 400        | Wrong number       | (Wrong prefix 35)               |
      | 381111111111111     | 400        | Wrong number       | (Wrong prefix 38)               |
      | 37111111111111      | 400        | Wrong number       | (14 digits - too short)         |
      | 3711111111111111    | 400        | Wrong number       | (16 digits - too long)          |
      | 37-111111-111111    | 400        | Wrong number       | (Contains hyphens)              |
      | 37 111111 111111    | 400        | Wrong number       | (Contains spaces)               |
      | 37A11111111111      | 400        | Wrong number       | (Contains letters)              |
      | 34                  | 400        | Wrong number       | Invalid (only prefix)           |
      | 3                   | 400        | Wrong number       | Invalid (only start of prefix)  |
      | 000000000000000     | 400        | Wrong number       | (All zeros)                     |

  @numberPositiveCases
  Scenario Outline: Successfully validate a card number
    Given the API is running
    When a POST request is sent to "/cardvalidation/card/credit/validate" with the following data:
      | Owner      | Number   | Date    | Cvv |
      | John Smith | <Number> | 12/2025 | 123 |
    Then the response status code should be 200
    And the response content should be "<ExpectedResult>"

    Examples:
      | Number           | ExpectedResult  | Comment                              |
      #Boundary Value Analysis (length limits) of card dumbers for Visa == Visa Test Cases (16 or 13 digits, starts with 4)
      | 4111111111111111 | Visa            | Valid Visa card                      |
      | 4111111111111    | Visa            | 13 digits, old format                |
      | 4123456789012345 | Visa            | Valid 16-digit Visa (upper boundary) |
      | 4123456789012    | Visa            | Valid 13-digit Visa (lower boundary) |
      | 4999999999999999 | Visa            | (16, upper bound)                    |
      | 4100000000000000 | Visa            | (16, lower bound)                    |
      | 4999999999999    | Visa            | (13, upper bound)                    |
      | 4000000000000    | Visa            | (13, lower bound)                    |
      | 4012888888881881 | Visa            | (16, Luhn-valid)                     |
      | 4222222222222    | Visa            | (13, Luhn-valid)                     |
      | 5111111111111111 | Mastercard      | Valid Mastercard card                |
      # MasterCard (^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$) == (16 digits, starts with 51-55 or 2221-2720)
      #Boundary Value Analysis (length limits) of card dumbers for MasterCard
      | 5112345678901234 | MasterCard      | Valid 16-digit (lower boundary)      |
      | 2720123456789012 | Mastercard      | Valid 16-digit (upper boundary)      |
      # Equivalence Partitioning (prefix ranges)
      | 5112345678901234 | Mastercard      | Valid (51-55 range)                  |
      | 2221123456789012 | Mastercard      | Valid (2221-2229 range)              |
      | 2720123456789012 | Mastercard      | Valid (2720 exact)                   |
      | 5555555555554444 | Mastercard      | (16, classic 5-series)               |
      | 5105105105105100 | Mastercard      | (16, Luhn-valid)                     |
      | 2221000000000009 | Mastercard      | (16, 2-series lower bound)           |
      | 2720999999999999 | Mastercard      | (16, 2-series upper bound)           |
      | 2345678901234567 | Mastercard      | (16, 2-series valid)                 |
      | 2620123456789012 | Mastercard      | (16, 2-series valid)                 |
      | 2720123456789012 | Mastercard      | (16, 2-series valid)                 |
      | 5432109876543210 | Mastercard      | (16, 5-series valid)                 |
      | 5599999999999999 | Mastercard      | (16, 5-series upper bound)           |
      | 5111111111111118 | Mastercard      | (16, Luhn-valid)                     |
      #American Express (^3[47][0-9]{13}$) ==  (15 digits, starts with 34 or 37)
      | 341111111111111  | AmericanExpress | Valid Amex card                      |
      | 371449635398431  | AmericanExpress | (15, standard)                       |
      | 341111111111111  | AmericanExpress | (15, starts with 34)                 |
      | 378282246310005  | AmericanExpress | (15, Luhn-valid)                     |
      | 370000000000000  | AmericanExpress | (15, lower bound)                    |
      | 379999999999999  | AmericanExpress | (15, upper bound)                    |
      | 345678901234567  | AmericanExpress | (15, random valid)                   |
      | 376543210987654  | AmericanExpress | (15, random valid)                   |
      | 341234567890123  | AmericanExpress | (15, random valid)                   |
      | 371234567890123  | AmericanExpress | (15, random valid)                   |
      | 378734493671000  | AmericanExpress | (15, Luhn-valid)                     |