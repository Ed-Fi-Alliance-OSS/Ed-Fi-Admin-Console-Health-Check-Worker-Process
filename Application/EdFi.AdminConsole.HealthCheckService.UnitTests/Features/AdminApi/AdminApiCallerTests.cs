// SPDX-License-Identifier: Apache-2.0
// Licensed to the Ed-Fi Alliance under one or more agreements.
// The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
// See the LICENSE and NOTICES files in the project root for more information.

using System.Linq;
using System.Net;
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
    [TestFixture]
    public class When_tenants_are_returned_from_api : Given_an_admin_api
    {
        private new ILogger<When_instances_are_returned_from_api> _logger;
        private AdminApiCaller _adminApiCaller;
        private IAdminApiClient _adminApiClient;

        [SetUp]
        public new void SetUp()
        {
            _logger = A.Fake<ILogger<When_instances_are_returned_from_api>>();

            _adminApiClient = A.Fake<IAdminApiClient>();

            A.CallTo(() => _adminApiClient.AdminApiGet(Testing.GetAdminApiSettings().Value.AdminConsoleTenantsURL, null))
                .Returns(new ApiResponse(HttpStatusCode.OK, Testing.Tenants));

            _adminApiCaller = new AdminApiCaller(_logger, _adminApiClient, Testing.GetAdminApiSettings());
        }

        [Test]
        public async Task should_return_stronglytyped_tenants()
        {
            var tenants = await _adminApiCaller.GetTenantsAsync();
            tenants.Count().ShouldBe(2);

            tenants.First().TenantId.ShouldBe(1);
            tenants.First().Document.EdfiApiDiscoveryUrl.ShouldBe(Testing.AdminApiTenants.First().Document.EdfiApiDiscoveryUrl);
            tenants.First().Document.Name.ShouldBe(Testing.AdminApiTenants.First().Document.Name);

            tenants.ElementAt(1).TenantId.ShouldBe(2);
            tenants.ElementAt(1).Document.EdfiApiDiscoveryUrl.ShouldBe(Testing.AdminApiTenants.ElementAt(1).Document.EdfiApiDiscoveryUrl);
            tenants.ElementAt(1).Document.Name.ShouldBe(Testing.AdminApiTenants.ElementAt(1).Document.Name);
        }
    }
    [TestFixture]
    public class When_instances_are_returned_from_api : Given_an_admin_api
    {
        private new ILogger<When_instances_are_returned_from_api> _logger;
        private AdminApiCaller _adminApiCaller;
        private IAdminApiClient _adminApiClient;

        [SetUp]
        public new void SetUp()
        {
            _logger = A.Fake<ILogger<When_instances_are_returned_from_api>>();
            var instancesUrl = Testing.GetAdminApiSettings().Value.AdminConsoleInstancesURL + Constants.CompletedInstances;

            _adminApiClient = A.Fake<IAdminApiClient>();

            A.CallTo(() => _adminApiClient.AdminApiGet(instancesUrl, Testing.AdminApiInstances.First().TenantName))
                .Returns(new ApiResponse(HttpStatusCode.OK, Testing.Instances));

            _adminApiCaller = new AdminApiCaller(_logger, _adminApiClient, Testing.GetAdminApiSettings());
        }

        [Test]
        public async Task should_return_stronglytyped_instances()
        {
            var instances = await _adminApiCaller.GetInstancesAsync(Testing.AdminApiInstances.First().TenantName);
            instances.Count().ShouldBe(2);

            instances.First().Id.ShouldBe(1);
            instances.First().OdsInstanceId.ShouldBe(1);
            instances.First().TenantId.ShouldBe(1);
            instances.First().TenantName.ShouldBe("tenant1");
            instances.First().InstanceName.ShouldBe("instance 1");
            instances.First().ClientId.ShouldBe("one client");
            instances.First().ClientSecret.ShouldBe("one secret");
            instances.First().ResourceUrl.ShouldBe("http://www.myserver.com/data/v3");
            instances.First().OauthUrl.ShouldBe("http://www.myserver.com/connect/token");
            instances.First().Status.ShouldBe("Completed");

            instances.ElementAt(1).Id.ShouldBe(2);
            instances.ElementAt(1).OdsInstanceId.ShouldBe(2);
            instances.ElementAt(1).TenantId.ShouldBe(1);
            instances.ElementAt(1).TenantName.ShouldBe("tenant1");
            instances.ElementAt(1).InstanceName.ShouldBe("instance 2");
            instances.ElementAt(1).ClientId.ShouldBe("another client");
            instances.ElementAt(1).ClientSecret.ShouldBe("another secret");
            instances.ElementAt(1).ResourceUrl.ShouldBe("http://www.myserver.com/data/v3");
            instances.ElementAt(1).OauthUrl.ShouldBe("http://www.myserver.com/connect/token");
            instances.ElementAt(1).Status.ShouldBe("Completed");
        }
    }
}
