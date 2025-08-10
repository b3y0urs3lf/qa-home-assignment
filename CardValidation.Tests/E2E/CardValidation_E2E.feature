@e2e
Feature: Card Validation API (E2E)

  As a user of the API
  I want to validate credit card information against a running service
  So that I can ensure it works in a deployed environment

  @card-type-validation
  Scenario Outline: Successfully validate a card type
    Given the API is running at its endpoint
    When a POST request is sent to "/CardValidation/card/credit/validate" with owner "John Smith", number "<Number>", date "12/2025", and cvv "123"
    Then the response status code should be 200
    And the response content should be "<Result>"

    Examples:
      | Number           | Result          | Comment                              |
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

  @number-validation
  Scenario Outline: Attempt to validate with an invalid card number
    Given the API is running at its endpoint
    When a POST request is sent to "/CardValidation/card/credit/validate" with owner "John Smith", number "<Number>", date "12/2025", and cvv "123"
    Then the response status code should be 400
    And the response should contain the error "Wrong number"

    Examples:
      | Number              | Comment                         |
      | 1234567890123       | Invalid card number             |
      | 411111111111        | Invalid card number             |
       # Invalid number length cases (should fail) for VIsa
      | 41234567890123      | 14-digit (invalid length)       |
      | 412345678901234     | 15-digit (invalid length)       |
      | 412345678901        | Invalid (12 digits - too short) |
      | 41234567890123456   | Invalid (17 digits - too long)  |
      | 4a23456789012       | Invalid (contains letter)       |
      | 4123-4567-8901-2    | Invalid (contains hyphens)      |
      | ""                  | Invalid (empty string)          |
      | 4                   | Invalid (only prefix)           |
      | 412 345 678 9012    | Invalid (contains spaces)       |
      | 0000000000000000    | (All zeros)                     |
      #Invalid number length cases (should fail) for MasterCard
      | 2220000000000000    | (Invalid 2-series start)        |
      | 2721000000000000    | (Exceeds 2-series range)        |
      | 5699999999999999    | (Invalid 5-series)              |
      | 511111111111111     | (15 digits - too short)         |
      | 51111111111111111   | (17 digits - too long)          |
      | 5A11111111111111    | (Contains letters)              |
      | 5555 5555 5555 4444 | (Contains spaces)               |
      | 2                   | Invalid (only start of prefix)  |
      | 2720                | Invalid (only prefix)           |
      #Invalid number lenght cases (should fail) for AmericanExpress
      | 351111111111111     | (Wrong prefix 35)               |
      | 381111111111111     | (Wrong prefix 38)               |
      | 37111111111111      | (14 digits - too short)         |
      | 3711111111111111    | (16 digits - too long)          |
      | 37-111111-111111    | (Contains hyphens)              |
      | 37 111111 111111    | (Contains spaces)               |
      | 37A11111111111      | (Contains letters)              |
      | 34                  | Invalid (only prefix)           |
      | 3                   | Invalid (only start of prefix)  |

  @ownerNegativeCases
  Scenario Outline: Validate Card Owner
    Given the API is running at its endpoint
    When a POST request is sent to "/CardValidation/card/credit/validate" with owner "<Owner>", number "4111111111111111", date "12/2025", and cvv "123"
    Then the response status code should be 400
    And the response should contain the error "<Error>"

    Examples:
      | Owner                     | Error             | Comment                         |
      |                           | Owner is required | Missing owner                   |
      | John123                   | Wrong owner       | Invalid owner                   |
      | John@Smith                | Wrong owner       | Invalid owner                   |
      | "John   Doe"              | Wrong owner       | Double space (negative)         |
      | " John"                   | Wrong owner       | Leading space (negative)        |
      | "John "                   | Wrong owner       | Trailing space (negative)       |
      |                           | Owner is required | Empty string (edge case)        |
      | "null"                    | Wrong owner       | Null input (edge case)          |
      | John-Doe                  | Wrong owner       | Hyphen (special char)           |
      | John123                   | Wrong owner       | Numbers (negative)              |
      | Jöhn                      | Wrong owner       | Non-ASCII char (negative)       |
      | John Doe Smith Jr         | Wrong owner       | 4 words (exceeds limit)         |
      | A B C D                   | Wrong owner       | Too many words                  |
      | John\tDoe                 | Wrong owner       | Tab separator (negative)        |
      | John.Doe                  | Wrong owner       | Period (negative)               |
      | "John   Doe"              | Wrong owner       | Triple space (negative)         |
      | " John Doe "              | Wrong owner       | Leading & trailing spaces       |
      | J0hn                      | Wrong owner       | Number inside word              |
      | J@hn                      | Wrong owner       | Special char inside word        |
      | J + new string('o', 1000) | Wrong owner       | Extremely long name (DoS check) |
      | O’Connor                  | Wrong owner       | Apostrophe (negative)           |
      | John　Doe                 | Wrong owner       | Full-width space (Unicode)      |
      | John 〄 Doe               | Wrong owner       | Unicode symbol                  |
      | John D.                   | Wrong owner       | Abbreviation with period        |
      | John-Michael              | Wrong owner       | Hyphenated name                 |
      | John (Mike) Doe           | Wrong owner       | Parentheses                     |
      | John, Doe                 | Wrong owner       | Comma separator                 |
      | John\\nDoe                | Wrong owner       | Newline separator               |
      | "John Doe "               | Wrong owner       | Trailing space                  |
      | " JohnDoe"                | Wrong owner       | Leading space + no space        |
      | J o h n                   | Wrong owner       | Spaces inside word              |

  @ownerPositiveCases
  Scenario Outline: Successfully validate a card owner
    Given the API is running at its endpoint
    When a POST request is sent to "/CardValidation/card/credit/validate" with owner "<Owner>", number "4111111111111111", date "12/2025", and cvv "123"
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


  @cvvNegativeCases
  Scenario Outline: Attempt to validate with an invalid CVV
    Given the API is running at its endpoint
    When a POST request is sent to "/CardValidation/card/credit/validate" with owner "John Smith", number "4111111111111111", date "12/2025", and cvv "<Cvv>"
    Then the response status code should be 400
    And the response should contain the error "Wrong cvv"

    Examples:
      | Cvv   | Comment       |
      | 45    | Invalid CVV   |
      | 12345      | Invalid CVV          |
      | abc        | Invalid CVV          |
      | 12         | Too short            |
      | 12345      | Too long             |
      | abc        | Letters              |
      | 12a        | Alphanumeric         |
      | "123 "     | Trailing space       |
      | " 123"     | Leading space        |
      | "1 2 3"    | Spaces inside        |
      | null       | Null input           |
      | 123\\n     | Newline              |
      | 123\t     | Tab                  |
      | 123.       | Period               |
      | 123-       | Hyphen               |
      | 12.3       | Decimal              |
      | 1+2+3      | Plus signs           |
      | 一二三     | Non-ASCII digits     |
      | １２３     | Full-width digits    |
      | 1234567890 | Extremely long       |
      | 1          | Single digit         |
      | 12         | Two digits           |
      | 12345      | 5-digit              |
      | 123456     | 6-digit              |
      | 1234567    | 7-digit              |
      | 12345678   | 8-digit              |
      | 123456789  | 9-digit              |
      | 1234567890 | 10-digit             |
      | 1E3        | Scientific notation  |
      | 0x12       | Hex                  |
      | 1,23       | Comma separator      |
      | 1.23       | Decimal separator    |
      | 1 23       | Space separator      |
      | 1-23       | Hyphen separator     |
      | 1/23       | Slash separator      |
      | 1_23       | Underscore separator |
      | 1+23       | Plus separator       |

  Scenario Outline: Attempt to validate with an empty CVV
    Given the API is running at its endpoint
    When a POST request is sent to "/CardValidation/card/credit/validate" with owner "John Smith", number "4111111111111111", date "12/2025", and cvv ""
    Then the response status code should be 400
    And the response should contain the error "Cvv is required"



  @cvvPositiveCases
  Scenario Outline: Successfully validate a CVV
    Given the API is running at its endpoint
    When a POST request is sent to "/CardValidation/card/credit/validate" with owner "John Smith", number "4111111111111111", date "12/2025", and cvv "<Cvv>"
    Then the response status code should be 200

    Examples:
      | Cvv  | Comment        |
      | 123  |                |
      | 1234 |                |
      | 123  | 3-digit CVC    |
      | 1234 | 4-digit CVC    |
      | 000  | All zeros      |
      | 999  | All nines      |
      | 1234 | 4-digit (AmericanExpress) |

  @dateNegativeCases
  Scenario Outline: Attempt to validate with an invalid date
    Given the API is running at its endpoint
    When a POST request is sent to "/CardValidation/card/credit/validate" with owner "John Smith", number "4111111111111111", date "<Date>", and cvv "123"
    Then the response status code should be 400
    And the response should contain the error "Wrong date"

    Examples:
      | Date     | Comment              |
      | 01/2020  | Expired card         |
      | 13/2025  | Invalid month        |
      | 12-2025  | Invalid format       |
      | 00/23    | Month 00 (invalid)   |
      | 13/23    | Month 13 (invalid)   |
      | 1/23     | Missing leading 0    |
      | 01/2     | Year too short       |
      | 01/234   | Year too long        |
      | 01-23    | Hyphen separator     |
      | 01 23    | Space separator      |
      | 01//23   | Double /             |
      | 01/23/   | Trailing /           |
      | /01/23   | Leading /            |
      | 01/0023  | Year too long        |
      | 01/0000  | Year 0000 (invalid)  |
      | 01/10000 | Year too long        |
      | 122023   | Missing / (invalid)  |
      | 12/0023  | Extra zeros          |
      | 12/ 23   | Space in year        |
      | 12/23    | Leading space        |
      | 12/23    | Trailing space       |
      | 12/23a   | Non-numeric year     |
      | a1/23    | Non-numeric month    |
      | 12/23/   | Trailing /           |
      | 12//23   | Double /             |
      | 12/23/45 | Extra digits         |
      | 12/234   | 3-digit year         |
      | 12/2     | 1-digit year         |
      | 1/234    | 1-digit month        |
      | 12/23.   | Invalid separator    |
      | 12.23    | Dot separator        |
      | 12_23    | Underscore separator |
      | 12\23    | Backslash separator  |
      | 12/23\\n  | Newline in input     |

  Scenario Outline: Attempt to validate with an empty date
    Given the API is running at its endpoint
    When a POST request is sent to "/CardValidation/card/credit/validate" with owner "John Smith", number "4111111111111111", date "", and cvv "123"
    Then the response status code should be 400
    And the response should contain the error "Date is required"

  @datePositiveCases
  Scenario Outline: Successfully validate a date
    Given the API is running at its endpoint
    When a POST request is sent to "/CardValidation/card/credit/validate" with owner "John Smith", number "4111111111111111", date "<Date>", and cvv "123"
    Then the response status code should be 200

    Examples:
      | Date    | Comment             |
      | 12/2028 |                     |
      | 01/2029 |                     |
      | 01/26  | MM/YY format        |
      | 12/2026 | MM/YYYY format      |
      | 1226    | MMYY format         |
      | 01/2026 | Future date         |
      | 01/99   | 2-digit year (1999) |
      | 01/9999 | Far future year     |
      | 12/27   | Valid short year    |