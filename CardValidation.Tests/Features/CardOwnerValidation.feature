@in-memory
Feature: Card Owner Validation

  @ownerNegativeCases
  Scenario Outline: Validate Card Owner
    Given the API is running
    When a POST request is sent to "/cardvalidation/card/credit/validate" with the following data:
      | Owner   | Number           | Date    | Cvv |
      | <Owner> | 4111111111111111 | 12/2025 | 123 |
    Then the response status code should be <StatusCode>
    And the response should contain the error "<ExpectedError>"

    Examples:
      | Owner                     | StatusCode | ExpectedError     | Comment                         |
      |                           | 400        | Owner is required | Missing owner                   |
      | John123                   | 400        | Wrong owner       | Invalid owner                   |
      | John@Smith                | 400        | Wrong owner       | Invalid owner                   |
      | "John   Doe"              | 400        | Wrong owner       | Double space (negative)         |
      | " John"                   | 400        | Wrong owner       | Leading space (negative)        |
      | "John "                   | 400        | Wrong owner       | Trailing space (negative)       |
      |                           | 400        | Owner is required | Empty string (edge case)        |
      | "null"                    | 400        | Wrong owner       | Null input (edge case)          |
      | John-Doe                  | 400        | Wrong owner       | Hyphen (special char)           |
      | John123                   | 400        | Wrong owner       | Numbers (negative)              |
      | Jöhn                      | 400        | Wrong owner       | Non-ASCII char (negative)       |
      | John Doe Smith Jr         | 400        | Wrong owner       | 4 words (exceeds limit)         |
      | A B C D                   | 400        | Wrong owner       | Too many words                  |
      | John\tDoe                 | 400        | Wrong owner       | Tab separator (negative)        |
      | John.Doe                  | 400        | Wrong owner       | Period (negative)               |
      | "John   Doe"              | 400        | Wrong owner       | Triple space (negative)         |
      | " John Doe "              | 400        | Wrong owner       | Leading & trailing spaces       |
      | J0hn                      | 400        | Wrong owner       | Number inside word              |
      | J@hn                      | 400        | Wrong owner       | Special char inside word        |
      | J + new string('o', 1000) | 400        | Wrong owner       | Extremely long name (DoS check) |
      | O’Connor                  | 400        | Wrong owner       | Apostrophe (negative)           |
      | John　Doe                 | 400        | Wrong owner       | Full-width space (Unicode)      |
      | John 〄 Doe               | 400        | Wrong owner       | Unicode symbol                  |
      | John D.                   | 400        | Wrong owner       | Abbreviation with period        |
      | John-Michael              | 400        | Wrong owner       | Hyphenated name                 |
      | John (Mike) Doe           | 400        | Wrong owner       | Parentheses                     |
      | John, Doe                 | 400        | Wrong owner       | Comma separator                 |
      | John\\nDoe                | 400        | Wrong owner       | Newline separator               |
      | "John Doe "               | 400        | Wrong owner       | Trailing space                  |
      | " JohnDoe"                | 400        | Wrong owner       | Leading space + no space        |
      | J o h n                   | 400        | Wrong owner       | Spaces inside word              |

  @ownerPositiveCases
  Scenario Outline: Successfully validate a card owner
    Given the API is running
    When a POST request is sent to "/cardvalidation/card/credit/validate" with the following data:
      | Owner      | Number           | Date    | Cvv |
      | <Owner>    | 4111111111111111 | 12/2025 | 123 |
    Then the response status code should be 200

    Examples:
      | Owner                                                                                                                                   | Comment                   |
      | John                                                                                                                                    | Single word (min length)  |
      | John Doe                                                                                                                                | Two words                 |
      | John Michael Doe                                                                                                                        | Three words (max allowed) |
      | J                                                                                                                                       | Single character (valid)  |
      | A B                                                                                                                                     | Two single-char words     |
      | A B C                                                                                                                                   | Three single-char words   |
      | JOHN DOE                                                                                                                                | Uppercase allowed         |
      | john doe                                                                                                                                | Lowercase allowed         |
      | John D                                                                                                                                  | Initial allowed           |
      | JohnDoe                                                                                                                                 | No space (single word)    |
      | Joooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooe | Long but valid name       |