// SPDX-License-Identifier: Apache-2.0
// Licensed to the Ed-Fi Alliance under one or more agreements.
// The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
// See the LICENSE and NOTICES files in the project root for more information.

using EdFi.AdminConsole.HealthCheckService.Helpers;
using FakeItEasy;
using Microsoft.Extensions.Logging;
using NUnit.Framework;
using Shouldly;

namespace EdFi.AdminConsole.HealthCheckService.UnitTests.Helpers;

public class Given_AdminApiSettings_provided
{
    private readonly AdminApiSettings _adminApiSettings = new();
    private ILogger<Given_AdminApiSettings_provided> _logger;

    [SetUp]
    public void SetUp()
    {
        _logger = A.Fake<ILogger<Given_AdminApiSettings_provided>>();

        _adminApiSettings.AccessTokenUrl = "http://www.myserver.com/token";
        _adminApiSettings.AdminConsoleInstancesURL = "http://www.myserver.com/adminconsole/instances";
        _adminApiSettings.AdminConsoleHealthCheckURL = "http://www.myserver.com/adminconsole/healthcheck";
        _adminApiSettings.Username = "SomeUserName";
        _adminApiSettings.ClientId = "SomeClientId";
        _adminApiSettings.Password = "SomePassword";
    }

    [TestFixture]
    public class When_it_has_all_required_fields : Given_AdminApiSettings_provided
    {
        [Test]
        public void should_be_valid()
        {
            AdminApiConnectioDataValidator.IsValid(_logger, _adminApiSettings).ShouldBeTrue();
        }
    }

    [TestFixture]
    public class When_it_does_not_have_AccessTokenUrl : Given_AdminApiSettings_provided
    {
        [Test]
        public void should_be_invalid()
        {
            _adminApiSettings.AccessTokenUrl = string.Empty;
            AdminApiConnectioDataValidator.IsValid(_logger, _adminApiSettings).ShouldBeFalse();
        }
    }

    [TestFixture]
    public class When_it_does_not_have_InstancesURI : Given_AdminApiSettings_provided
    {
        [Test]
        public void should_be_invalid()
        {
            _adminApiSettings.AdminConsoleInstancesURL = string.Empty;
            AdminApiConnectioDataValidator.IsValid(_logger, _adminApiSettings).ShouldBeFalse();
        }
    }

    [TestFixture]
    public class When_it_does_not_have_HealthCheckURI : Given_AdminApiSettings_provided
    {
        [Test]
        public void should_be_invalid()
        {
            _adminApiSettings.AdminConsoleHealthCheckURL = string.Empty;
            AdminApiConnectioDataValidator.IsValid(_logger, _adminApiSettings).ShouldBeFalse();
        }
    }

    [TestFixture]
    public class When_it_does_not_have_Username : Given_AdminApiSettings_provided
    {
        [Test]
        public void should_be_invalid()
        {
            _adminApiSettings.Username = string.Empty;
            AdminApiConnectioDataValidator.IsValid(_logger, _adminApiSettings).ShouldBeFalse();
        }
    }

    [TestFixture]
    public class When_it_does_not_have_ClientId : Given_AdminApiSettings_provided
    {
        [Test]
        public void should_be_invalid()
        {
            _adminApiSettings.ClientId = string.Empty;
            AdminApiConnectioDataValidator.IsValid(_logger, _adminApiSettings).ShouldBeFalse();
        }
    }

    [TestFixture]
    public class When_it_does_not_have_Password : Given_AdminApiSettings_provided
    {
        [Test]
        public void should_be_invalid()
        {
            _adminApiSettings.Password = string.Empty;
            AdminApiConnectioDataValidator.IsValid(_logger, _adminApiSettings).ShouldBeFalse();
        }
    }
}
