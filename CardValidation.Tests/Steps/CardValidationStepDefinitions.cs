using CardValidation.Core.Enums;
using System.Net;
using System.Net.Http.Json;
using CardValidation.ViewModels;
using FluentAssertions;
using Reqnroll;
using Reqnroll.Assist;

namespace CardValidation.Tests.Steps
{
    [Binding, Scope(Tag = "in-memory")]
    internal class CardValidationStepDefinitions
    {
        private readonly CustomWebApplicationFactory _factory;
        private HttpClient? _client;
        private HttpResponseMessage? _response;

        public CardValidationStepDefinitions(CustomWebApplicationFactory factory)
        {
            _factory = factory;
        }

        [Given(@"the API is running")]
        public void GivenTheApiIsRunning()
        {
            _client = _factory.CreateClient();
        }

        [When(@"a POST request is sent to ""(.*)"" with the following valid data:")]
        public async Task WhenAPostRequestIsSentToWithTheFollowingValidData(string url, Table table)
        {
            var creditCard = table.CreateInstance<CreditCard>();
            _response = await _client!.PostAsJsonAsync(url, creditCard);
        }

        [When(@"a POST request is sent to ""(.*)"" with the following invalid data:")]
        public async Task WhenAPostRequestIsSentToWithTheFollowingInvalidData(string url, Table table)
        {
            var creditCard = table.CreateInstance<CreditCard>();
            _response = await _client!.PostAsJsonAsync(url, creditCard);
        }

        [When(@"a POST request is sent to ""(.*)"" with the following data:")]
        public async Task WhenAPostRequestIsSentToWithTheFollowingData(string url, Table table)
        {
            var creditCard = table.CreateInstance<CreditCard>();
            _response = await _client!.PostAsJsonAsync(url, creditCard);
        }

        [Then(@"the response status code should be (.*)")]
        public void ThenTheResponseStatusCodeShouldBe(int statusCode)
        {
            _response!.StatusCode.Should().Be((HttpStatusCode)statusCode);
        }

        [Then(@"the response content should be ""(.*)""")]
        public async Task ThenTheResponseContentShouldBe(string expectedContent)
        {
            var content = await _response!.Content.ReadAsStringAsync();
            var actualEnumValue = int.Parse(content);

            var expectedEnumValue = Enum.Parse<PaymentSystemType>(expectedContent, true);

            ((int)expectedEnumValue).Should().Be(actualEnumValue);
        }

        [Then(@"the response should contain the error ""(.*)""")]
        public async Task ThenTheResponseShouldContainTheError(string expectedError)
        {
            var content = await _response!.Content.ReadAsStringAsync();
            content.Should().Contain(expectedError);
        }
    }
}