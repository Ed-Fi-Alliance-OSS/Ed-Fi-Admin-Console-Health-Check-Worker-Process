// SPDX-License-Identifier: Apache-2.0
// Licensed to the Ed-Fi Alliance under one or more agreements.
// The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
// See the LICENSE and NOTICES files in the project root for more information.

using System.Net;
using System.Net.Http.Headers;
using System.Text;
using EdFi.AdminConsole.HealthCheckService.Features.AdminApi;
using EdFi.AdminConsole.HealthCheckService.Helpers;
using EdFi.AdminConsole.HealthCheckService.Infrastructure;
using FakeItEasy;
using Microsoft.Extensions.Logging;
using NUnit.Framework;
using Shouldly;

namespace EdFi.AdminConsole.HealthCheckService.UnitTests.Features.AdminApi;

public partial class Given_an_admin_api
{
    private ILogger<Given_an_admin_api> _logger;

    [SetUp]
    public void SetUp()
    {
        _logger = A.Fake<ILogger<Given_an_admin_api>>();
    }

    [TestFixture]
    public class When_instances_are_requested : Given_an_admin_api
    {
        [Test]
        public async Task should_return_successfully()
        {
            StringContent? content = null;
            if (!string.IsNullOrEmpty(Testing.AdminApiInstances.First().TenantName))
            {
                content = new StringContent(string.Empty, Encoding.UTF8, "application/json");
                content.Headers.Add("tenant", Testing.AdminApiInstances.First().TenantName);
            }

            var httpClient = A.Fake<IAppHttpClient>();
            var instancesUrl = Testing.GetAdminApiSettings().Value.AdminConsoleInstancesURL + Constants.CompletedInstances;

            A.CallTo(() => httpClient.SendAsync(Testing.GetAdminApiSettings().Value.AccessTokenUrl, HttpMethod.Post, A<FormUrlEncodedContent>.Ignored, null))
                .Returns(new ApiResponse(HttpStatusCode.OK, "{ \"access_token\": \"123\"}"));

            A.CallTo(() => httpClient.SendAsync(instancesUrl, HttpMethod.Get, A<StringContent>.Ignored, new AuthenticationHeaderValue("bearer", "123")))
                .Returns(new ApiResponse(HttpStatusCode.OK, Testing.Instances));

            var adminApiClient = new AdminApiClient(httpClient, _logger, Testing.GetAdminApiSettings());

            var InstancesReponse = await adminApiClient.AdminApiGet(instancesUrl, Testing.AdminApiInstances.First().TenantName);

            InstancesReponse.Content.ShouldBeEquivalentTo(Testing.Instances);
        }
    }

    public class When_instances_are_requested_without_token : Given_an_admin_api
    {
        [Test]
        public async Task InternalServerError_is_returned()
        {
            var httpClient = A.Fake<IAppHttpClient>();
            var instancesUrl = Testing.GetAdminApiSettings().Value.AdminConsoleInstancesURL + Constants.CompletedInstances;

            A.CallTo(() => httpClient.SendAsync(Testing.GetAdminApiSettings().Value.AccessTokenUrl, HttpMethod.Post, A<FormUrlEncodedContent>.Ignored, null))
                .Returns(new ApiResponse(HttpStatusCode.InternalServerError, string.Empty));

            A.CallTo(() => httpClient.SendAsync(Testing.GetAdminApiSettings().Value.AdminConsoleInstancesURL, HttpMethod.Get, null as StringContent, new AuthenticationHeaderValue("bearer", "123")))
                .Returns(new ApiResponse(HttpStatusCode.OK, Testing.Instances));

            var adminApiClient = new AdminApiClient(httpClient, _logger, Testing.GetAdminApiSettings());

            var getOnAdminApi = await adminApiClient.AdminApiGet(instancesUrl, Testing.AdminApiTenants.First().Document.Name);

            getOnAdminApi.StatusCode.ShouldBe(HttpStatusCode.InternalServerError);
        }
    }
}
