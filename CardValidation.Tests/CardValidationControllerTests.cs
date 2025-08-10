using CardValidation.Controllers;
using CardValidation.Core.Enums;
using CardValidation.Core.Services.Interfaces;
using CardValidation.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Xunit;

namespace CardValidation.Tests
{
    public class CardValidationControllerTests
    {
        private readonly Mock<ICardValidationService> _mockCardValidationService;
        private readonly CardValidationController _controller;

        public CardValidationControllerTests()
        {
            _mockCardValidationService = new Mock<ICardValidationService>();
            _controller = new CardValidationController(_mockCardValidationService.Object);
        }

        [Fact]
        public void ValidateCreditCard_ValidCard_ReturnsOkResultWithPaymentSystemType()
        {
            // Arrange
            var creditCard = new CreditCard { Number = "4111111111111111" };
            _mockCardValidationService.Setup(s => s.GetPaymentSystemType(creditCard.Number)).Returns(PaymentSystemType.Visa);

            // Act
            var result = _controller.ValidateCreditCard(creditCard);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var paymentSystemType = Assert.IsType<PaymentSystemType>(okResult.Value);
            Assert.Equal(PaymentSystemType.Visa, paymentSystemType);
        }

        [Fact]
        public void ValidateCreditCard_InvalidModelState_ReturnsBadRequest()
        {
            // Arrange
            _controller.ModelState.AddModelError("Error", "Model state is invalid");
            var creditCard = new CreditCard();

            // Act
            var result = _controller.ValidateCreditCard(creditCard);

            // Assert
            Assert.IsType<BadRequestObjectResult>(result);
        }
    }
}
