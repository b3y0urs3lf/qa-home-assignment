@in-memory
Feature: Expiration Date Validation

  @dateNegativeCases
  Scenario Outline: Validate Expiration Date
    Given the API is running
    When a POST request is sent to "/cardvalidation/card/credit/validate" with the following data:
      | Owner      | Number           | Date    | Cvv |
      | John Smith | 4111111111111111 | <Date>  | 123 |
    Then the response status code should be <StatusCode>
    And the response should contain the error "<ExpectedError>"

    Examples:
      | Date     | StatusCode | ExpectedError    | comment              |
      |          | 400        | Date is required |                      |
      | 13/2025  | 400        | Wrong date       |                      |
      | 12/2020  | 400        | Wrong date       |                      |
      | 12-2025  | 400        | Wrong date       |                      |
      | 00/23    | 400        | Wrong date       | Month 00 (invalid)   |
      | 13/23    | 400        | Wrong date       | Month 13 (invalid)   |
      | 1/23     | 400        | Wrong date       | Missing leading 0    |
      | 01/2     | 400        | Wrong date       | Year too short       |
      | 01/234   | 400        | Wrong date       | Year too long        |
      | 01-23    | 400        | Wrong date       | Hyphen separator     |
      | 01 23    | 400        | Wrong date       | Space separator      |
      | 01//23   | 400        | Wrong date       | Double /             |
      | 01/23/   | 400        | Wrong date       | Trailing /           |
      | /01/23   | 400        | Wrong date       | Leading /            |
      | 01/0023  | 400        | Wrong date       | Year too long        |
      | 01/0000  | 400        | Wrong date       | Year 0000 (invalid)  |
      | 01/10000 | 400        | Wrong date       | Year too long        |
      | 122023   | 400        | Wrong date       | Missing / (invalid)  |
      | 12/0023  | 400        | Wrong date       | Extra zeros          |
      | 12/ 23   | 400        | Wrong date       | Space in year        |
      | 12/23    | 400        | Wrong date       | Leading space        |
      | 12/23    | 400        | Wrong date       | Trailing space       |
      | 12/23a   | 400        | Wrong date       | Non-numeric year     |
      | a1/23    | 400        | Wrong date       | Non-numeric month    |
      | 12/23/   | 400        | Wrong date       | Trailing /           |
      | 12//23   | 400        | Wrong date       | Double /             |
      | 12/23/45 | 400        | Wrong date       | Extra digits         |
      | 12/234   | 400        | Wrong date       | 3-digit year         |
      | 12/2     | 400        | Wrong date       | 1-digit year         |
      | 1/234    | 400        | Wrong date       | 1-digit month        |
      | 12/23.   | 400        | Wrong date       | Invalid separator    |
      | 12.23    | 400        | Wrong date       | Dot separator        |
      | 12_23    | 400        | Wrong date       | Underscore separator |
      | 12\23    | 400        | Wrong date       | Backslash separator  |
      | 12/23\n  | 400        | Wrong date       | Newline in input     |



  @datePositiveCases
  Scenario Outline: Successfully validate a date
    Given the API is running
    When a POST request is sent to "/cardvalidation/card/credit/validate" with the following data:
      | Owner      | Number           | Date    | Cvv |
      | John Smith | 4111111111111111 | <Date>  | 123 |
    Then the response status code should be 200

    Examples:
      | Date    | comment             |
      | 12/2028 |                     |
      | 01/2029 |                     |
      | 01/26   | MM/YY format        |
      | 12/2026 | MM/YYYY format      |
      | 1227    | MMYY format         |
      | 01/2026 | Future date         |
      | 01/99   | 2-digit year (1999) |
      | 01/9999 | Far future year     |
      | 12/27   | Valid short year    |