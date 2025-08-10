using CardValidation.Core.Enums;
using CardValidation.Core.Services;
using Xunit;

namespace CardValidation.Tests
{
    public class CardValidationServiceTests
    {
        private readonly CardValidationService _cardValidationService = new CardValidationService();

        [Theory]
        [InlineData("John Smith")]
        [InlineData("John")]
        [InlineData("John Smith ")]
        public void ValidateOwner_ValidOwner_ReturnsTrue(string owner)
        {
            var result = _cardValidationService.ValidateOwner(owner);
            Assert.True(result);
        }

        [Theory]
        [InlineData("John123")]
        [InlineData(" John Smith")]
        [InlineData("John Jacob Jingleheimer Schmidt")]
        [InlineData("")]
        // [InlineData(null)]
        public void ValidateOwner_InvalidOwner_ReturnsFalse(string owner)
        {
            var result = _cardValidationService.ValidateOwner(owner);
            Assert.False(result);
        }

        [Theory]
        [InlineData("12/2025")]
        [InlineData("01/26")]
        public void ValidateIssueDate_ValidDate_ReturnsTrue(string issueDate)
        {
            var result = _cardValidationService.ValidateIssueDate(issueDate);
            Assert.True(result);
        }

        [Theory]
        [InlineData("13/2025")]
        [InlineData("01/2022")]
        [InlineData("1/25")]
        [InlineData("12/2023")]
        [InlineData("")]
        // [InlineData(null)]
        public void ValidateIssueDate_InvalidDate_ReturnsFalse(string issueDate)
        {
            var result = _cardValidationService.ValidateIssueDate(issueDate);
            Assert.False(result);
        }

        [Theory]
        [InlineData("123")]
        [InlineData("1234")]
        public void ValidateCvc_ValidCvc_ReturnsTrue(string cvc)
        {
            var result = _cardValidationService.ValidateCvc(cvc);
            Assert.True(result);
        }

        [Theory]
        [InlineData("12")]
        [InlineData("12345")]
        [InlineData("abc")]
        [InlineData("")]
        // [InlineData(null)]
        public void ValidateCvc_InvalidCvc_ReturnsFalse(string cvc)
        {
            var result = _cardValidationService.ValidateCvc(cvc);
            Assert.False(result);
        }

        [Theory]
        [InlineData("4111111111111111")] // Visa
        [InlineData("5111111111111111")] // MasterCard
        [InlineData("341111111111111")]  // American Express
        public void ValidateNumber_ValidNumber_ReturnsTrue(string cardNumber)
        {
            var result = _cardValidationService.ValidateNumber(cardNumber);
            Assert.True(result);
        }

        [Theory]
        [InlineData("1234567890123456")]
        [InlineData("411111111111111")]
        [InlineData("511111111111111")]
        [InlineData("34111111111111")]
        [InlineData("")]
        // [InlineData(null)]
        public void ValidateNumber_InvalidNumber_ReturnsFalse(string cardNumber)
        {
            var result = _cardValidationService.ValidateNumber(cardNumber);
            Assert.False(result);
        }

        [Fact]
        public void GetPaymentSystemType_Visa_ReturnsVisa()
        {
            var result = _cardValidationService.GetPaymentSystemType("4111111111111111");
            Assert.Equal(PaymentSystemType.Visa, result);
        }

        [Fact]
        public void GetPaymentSystemType_MasterCard_ReturnsMasterCard()
        {
            var result = _cardValidationService.GetPaymentSystemType("5111111111111111");
            Assert.Equal(PaymentSystemType.MasterCard, result);
        }

        [Fact]
        public void GetPaymentSystemType_AmericanExpress_ReturnsAmericanExpress()
        {
            var result = _cardValidationService.GetPaymentSystemType("341111111111111");
            Assert.Equal(PaymentSystemType.AmericanExpress, result);
        }

        [Fact]
        public void GetPaymentSystemType_InvalidCard_ThrowsNotImplementedException()
        {
            Assert.Throws<NotImplementedException>(() => _cardValidationService.GetPaymentSystemType("1234567890123456"));
        }
        
        
        [Theory]
        [InlineData(null)]
        public void ValidateOwner_NullOwner_ThrowsArgumentNullException(string owner)
        {
            Assert.Throws<ArgumentNullException>(() => _cardValidationService.ValidateOwner(owner));
        }

        [Theory]
        [InlineData(null)]
        public void ValidateIssueDate_NullDate_ThrowsArgumentNullException(string issueDate)
        {
            Assert.Throws<ArgumentNullException>(() => _cardValidationService.ValidateIssueDate(issueDate));
        }

        [Theory]
        [InlineData(null)]
        public void ValidateCvc_NullCvc_ThrowsArgumentNullException(string cvc)
        {
            Assert.Throws<ArgumentNullException>(() => _cardValidationService.ValidateCvc(cvc));
        }

        [Theory]
        [InlineData(null)]
        public void ValidateNumber_NullNumber_ThrowsArgumentNullException(string cardNumber)
        {
            Assert.Throws<ArgumentNullException>(() => _cardValidationService.ValidateNumber(cardNumber));
        }
    }
}
