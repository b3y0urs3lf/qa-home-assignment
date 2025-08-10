using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Json;
using CardValidation.Core.Enums;
using CardValidation.ViewModels;
using FluentAssertions;
using Reqnroll;

namespace CardValidation.Tests.E2E
{
    [Binding, Scope(Tag = "e2e")]
    public class E2EStepDefinitions
    {
        private HttpClient? _client;
        private HttpResponseMessage? _response;
        private static readonly string ApiBaseUrl = Environment.GetEnvironmentVariable("API_BASE_URL") ?? "http://localhost:8080";

        [Given(@"the API is running at its endpoint")]
        public void GivenTheApiIsRunningAtItsEndpoint()
        {
            _client = new HttpClient { BaseAddress = new Uri(ApiBaseUrl) };
        }

        [When(@"a POST request is sent to ""(.*)"" with owner ""(.*)"", number ""(.*)"", date ""(.*)"", and cvv ""(.*)""")]
        public async Task WhenAPostRequestIsSentToWithTheFollowingData(string url, string owner, string number, string date, string cvv)
        {
            var creditCard = new CreditCard
            {
                Owner = owner,
                Number = number,
                Date = date,
                Cvv = cvv
            };
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