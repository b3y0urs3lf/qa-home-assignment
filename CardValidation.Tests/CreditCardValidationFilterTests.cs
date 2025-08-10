using System.Collections.Generic;
using CardValidation.Core.Services.Interfaces;
using CardValidation.Infrustructure;
using CardValidation.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Abstractions;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Routing;
using Moq;
using Xunit;

namespace CardValidation.Tests
{
    public class CreditCardValidationFilterTests
    {
        private readonly Mock<ICardValidationService> _mockValidationService;
        private readonly CreditCardValidationFilter _filter;

        public CreditCardValidationFilterTests()
        {
            _mockValidationService = new Mock<ICardValidationService>();
            _filter = new CreditCardValidationFilter(_mockValidationService.Object);
        }

        private ActionExecutingContext CreateContext(object? creditCard)
        {
            var modelState = new ModelStateDictionary();
            var httpContext = new DefaultHttpContext();
            var actionContext = new ActionContext(httpContext, new RouteData(), new ActionDescriptor(), modelState);
            
            return new ActionExecutingContext(
                actionContext,
                new List<IFilterMetadata>(),
                new Dictionary<string, object?> { { "creditCard", creditCard } },
                new Mock<Controller>().Object
            );
        }

        [Fact]
        public void OnActionExecuting_AllFieldsValid_DoesNotAddModelStateError()
        {
            // Arrange
            var creditCard = new CreditCard { Owner = "Test Owner", Number = "1234567890123456", Date = "12/25", Cvv = "123" };
            var context = CreateContext(creditCard);
            _mockValidationService.Setup(s => s.ValidateOwner(It.IsAny<string>())).Returns(true);
            _mockValidationService.Setup(s => s.ValidateNumber(It.IsAny<string>())).Returns(true);
            _mockValidationService.Setup(s => s.ValidateIssueDate(It.IsAny<string>())).Returns(true);
            _mockValidationService.Setup(s => s.ValidateCvc(It.IsAny<string>())).Returns(true);

            // Act
            _filter.OnActionExecuting(context);

            // Assert
            Assert.True(context.ModelState.IsValid);
        }

        [Theory]
        [InlineData(null, "1234567890123456", "12/25", "123", "Owner", "Owner is required")]
        [InlineData("Test Owner", null, "12/25", "123", "Number", "Number is required")]
        [InlineData("Test Owner", "1234567890123456", null, "123", "Date", "Date is required")]
        [InlineData("Test Owner", "1234567890123456", "12/25", null, "Cvv", "Cvv is required")]
        public void OnActionExecuting_MissingFields_AddsRequiredErrorToModelState(string? owner, string? number, string? date, string? cvv, string expectedKey, string expectedError)
        {
            // Arrange
            var creditCard = new CreditCard { Owner = owner, Number = number, Date = date, Cvv = cvv };
            var context = CreateContext(creditCard);

            // Act
            _filter.OnActionExecuting(context);

            // Assert
            Assert.False(context.ModelState.IsValid);
            Assert.True(context.ModelState.ContainsKey(expectedKey));
            Assert.Equal(expectedError, context.ModelState[expectedKey]?.Errors[0].ErrorMessage);
        }

        [Fact]
        public void OnActionExecuting_InvalidFields_AddsWrongParameterErrorToModelState()
        {
            // Arrange
            var creditCard = new CreditCard { Owner = "Invalid", Number = "Invalid", Date = "Invalid", Cvv = "Invalid" };
            var context = CreateContext(creditCard);
            _mockValidationService.Setup(s => s.ValidateOwner(It.IsAny<string>())).Returns(false);
            _mockValidationService.Setup(s => s.ValidateNumber(It.IsAny<string>())).Returns(false);
            _mockValidationService.Setup(s => s.ValidateIssueDate(It.IsAny<string>())).Returns(false);
            _mockValidationService.Setup(s => s.ValidateCvc(It.IsAny<string>())).Returns(false);

            // Act
            _filter.OnActionExecuting(context);

            // Assert
            Assert.False(context.ModelState.IsValid);
            Assert.Contains("Owner", context.ModelState.Keys);
            Assert.Contains("Number", context.ModelState.Keys);
            Assert.Contains("Date", context.ModelState.Keys);
            Assert.Contains("Cvv", context.ModelState.Keys);
            Assert.Equal("Wrong owner", context.ModelState["Owner"]?.Errors[0].ErrorMessage);
        }

        [Fact]
        public void OnActionExecuting_NullCreditCard_ThrowsInvalidOperationException()
        {
            // Arrange
            var context = CreateContext(null);

            // Act & Assert
            Assert.Throws<InvalidOperationException>(() => _filter.OnActionExecuting(context));
        }
    }
}
