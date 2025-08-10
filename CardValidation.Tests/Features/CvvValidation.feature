@in-memory
Feature: CVV Validation

  @cvvNegativeCases
  Scenario Outline: Validate CVV
    Given the API is running
    When a POST request is sent to "/cardvalidation/card/credit/validate" with the following data:
      | Owner      | Number           | Date    | Cvv   |
      | John Smith | 4111111111111111 | 12/2025 | <Cvv> |
    Then the response status code should be <StatusCode>
    And the response should contain the error "<ExpectedError>"

    Examples:
      | Cvv        | StatusCode | ExpectedError   | Comment              |
      |            | 400        | Cvv is required |                      |
      | 12         | 400        | Wrong cvv       |                      |
      | 12345      | 400        | Wrong cvv       |                      |
      | abc        | 400        | Wrong cvv       |                      |
      | 12         | 400        | Wrong cvv       | Too short            |
      | 12345      | 400        | Wrong cvv       | Too long             |
      | abc        | 400        | Wrong cvv       | Letters              |
      | 12a        | 400        | Wrong cvv       | Alphanumeric         |
      | "123 "     | 400        | Wrong cvv       | Trailing space       |
      | " 123"     | 400        | Wrong cvv       | Leading space        |
      | "1 2 3"    | 400        | Wrong cvv       | Spaces inside        |
      | null       | 400        | Wrong cvv       | Null input           |
      | 123\\n"    | 400        | Wrong cvv       | Newline              |
      | 123\t"     | 400        | Wrong cvv       | Tab                  |
      | 123.       | 400        | Wrong cvv       | Period               |
      | 123-       | 400        | Wrong cvv       | Hyphen               |
      | 12.3       | 400        | Wrong cvv       | Decimal              |
      | 1+2+3      | 400        | Wrong cvv       | Plus signs           |
      | 一二三     | 400        | Wrong cvv       | Non-ASCII digits     |
      | １２３     | 400        | Wrong cvv       | Full-width digits    |
      | 1234567890 | 400        | Wrong cvv       | Extremely long       |
      | 1          | 400        | Wrong cvv       | Single digit         |
      | 12         | 400        | Wrong cvv       | Two digits           |
      | 12345      | 400        | Wrong cvv       | 5-digit              |
      | 123456     | 400        | Wrong cvv       | 6-digit              |
      | 1234567    | 400        | Wrong cvv       | 7-digit              |
      | 12345678   | 400        | Wrong cvv       | 8-digit              |
      | 123456789  | 400        | Wrong cvv       | 9-digit              |
      | 1234567890 | 400        | Wrong cvv       | 10-digit             |
      | 1E3        | 400        | Wrong cvv       | Scientific notation  |
      | 0x12       | 400        | Wrong cvv       | Hex                  |
      | 1,23       | 400        | Wrong cvv       | Comma separator      |
      | 1.23       | 400        | Wrong cvv       | Decimal separator    |
      | 1 23       | 400        | Wrong cvv       | Space separator      |
      | 1-23       | 400        | Wrong cvv       | Hyphen separator     |
      | 1/23       | 400        | Wrong cvv       | Slash separator      |
      | 1_23       | 400        | Wrong cvv       | Underscore separator |
      | 1+23       | 400        | Wrong cvv       | Plus separator       |

  @cvvPositiveCases
  Scenario Outline: Successfully validate a CVV
    Given the API is running
    When a POST request is sent to "/cardvalidation/card/credit/validate" with the following data:
      | Owner      | Number           | Date    | Cvv   |
      | John Smith | 4111111111111111 | 12/2025 | <Cvv> |
    Then the response status code should be 200

    Examples:
      | Cvv  | Comment        |
      | 123  |                |
      | 1234 |                |
      | 123  | 3-digit CVC    |
      | 1234 | 4-digit CVC    |
      | 000  | All zeros      |
      | 999  | All nines      |
      | 1234 | 4-digit (AmEx) |