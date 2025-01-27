// SPDX-License-Identifier: Apache-2.0
// Licensed to the Ed-Fi Alliance under one or more agreements.
// The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
// See the LICENSE and NOTICES files in the project root for more information.

using EdFi.AdminConsole.HealthCheckService;
using EdFi.AdminConsole.HealthCheckService.Features.AdminApi;
using EdFi.AdminConsole.HealthCheckService.Features.OdsApi;
using Microsoft.Extensions.Options;

namespace EdFi.Ods.AdminApi.HealthCheckService.UnitTests;

public class Testing
{
    public static IOptions<AppSettings> GetAppSettings()
    {
        AppSettings appSettings = new AppSettings();
        IOptions<AppSettings> options = Options.Create(appSettings);
        return options;
    }

    public static IOptions<AdminApiSettings> GetAdminApiSettings()
    {
        AdminApiSettings adminApiSettings = new AdminApiSettings();
        adminApiSettings.AccessTokenUrl = "http://www.myserver.com/token";
        adminApiSettings.ApiUrl = "http://www.myserver.com";
        adminApiSettings.AdminConsoleInstancesURI = "/adminconsole/instances";
        adminApiSettings.AdminConsoleHealthCheckURI = "/adminconsole/healthcheck";
        IOptions<AdminApiSettings> options = Options.Create(adminApiSettings);
        return options;
    }

    public static IOptions<OdsApiSettings> GetOdsApiSettings()
    {
        OdsApiSettings odsApiSettings = new OdsApiSettings();
        odsApiSettings.Endpoints = Endpoints;
        IOptions<OdsApiSettings> options = Options.Create(odsApiSettings);
        return options;
    }

    public static List<string> Endpoints { get { return new List<string> { "ed-fi/firstEndPoint", "ed-fi/secondEndpoint", "ed-fi/thirdEndPoint" }; } }

    public static List<OdsApiEndpointNameCount> HealthCheckData
    {
        get
        {
            return new List<OdsApiEndpointNameCount>
            {
                new OdsApiEndpointNameCount()
                {
                    OdsApiEndpointName = "ed-fi/firstEndPoint",
                    OdsApiEndpointCount = 3,
                    AnyErrros = false
                },
                new OdsApiEndpointNameCount()
                {
                    OdsApiEndpointName = "ed-fi/secondEndpoint",
                    OdsApiEndpointCount = 8,
                    AnyErrros = false
                },
                new OdsApiEndpointNameCount()
                {
                    OdsApiEndpointName = "ed-fi/thirdEndPoint",
                    OdsApiEndpointCount = 5,
                    AnyErrros = false
                }
            };
        }
    }

    public static List<AdminApiInstance> AdminApiInstances
    {
        get
        {
            return new List<AdminApiInstance>
            {
                new AdminApiInstance()
                {
                    InstanceId = 1,
                    OdsInstanceId = 1,
                    TenantId = 1,
                    InstanceName = "instance 1",
                    ClientId = "one client",
                    ClientSecret = "one secret",
                    OauthUrl = "http://www.myserver.com/connect/token",
                    ResourceUrl = "http://www.myserver.com/data/v3",
                    Status = "Completed",
                },
                new AdminApiInstance()
                {
                    InstanceId = 2,
                    OdsInstanceId = 2,
                    TenantId = 2,
                    InstanceName = "instance 2",
                    ClientId = "another client",
                    ClientSecret = "another secret",
                    OauthUrl = "http://www.myserver.com/connect/token",
                    ResourceUrl = "http://www.myserver.com/data/v3",
                    Status = "Completed",
                }
            };
        }
    }

    public const string Instances =
    @"[{
        ""instanceId"": 1,
        ""odsInstanceId"": 1,
        ""tenantId"": 1,
        ""instanceName"": ""instance 1"",
        ""clientId"": ""one client"",
        ""clientSecret"": ""one secret"",
        ""resourceUrl"": ""http://www.myserver.com/data/v3"",
        ""oauthUrl"": ""http://www.myserver.com/connect/token"",
        ""status"": ""Completed""
      },{
        ""instanceId"": 2,
        ""odsInstanceId"": 2,
        ""tenantId"": 2,
        ""instanceName"": ""instance 2"",
        ""clientId"": ""another client"",
        ""clientSecret"": ""another secret"",
        ""resourceUrl"": ""http://www.myserver.com/data/v3"",
        ""oauthUrl"": ""http://www.myserver.com/connect/token"",
        ""status"": ""Completed""
    }]";


    public static Dictionary<string, string?> CommandArgsDicWithMultitenant = new Dictionary<string, string?>
        {
            {"isMultiTenant", "true"},
            {"tenant", "Tenant1"},
            {"clientid", "SomeClientId"},
            {"clientsecret", "SomeClientSecret"}
        };

    public static Dictionary<string, string?> CommandArgsDicWithSingletenant = new Dictionary<string, string?>
        {
            {"isMultiTenant", "false"},
            {"clientid", "SomeClientId"},
            {"clientsecret", "SomeClientSecret"}
        };

    public static Dictionary<string, string?> CommandArgsDicNoClientId = new Dictionary<string, string?>
        {
            {"isMultiTenant", "false"},
            {"clientid", ""},
            {"clientsecret", "SomeClientSecret"}
        };

    public static Dictionary<string, string?> CommandArgsDicNoClientSecret = new Dictionary<string, string?>
        {
            {"isMultiTenant", "false"},
            {"clientid", "SomeClientId"},
            {"clientsecret", ""}
        };

    public static Dictionary<string, string?> CommandArgsDicWithMultitenantNoTenant = new Dictionary<string, string?>
        {
            {"isMultiTenant", "true"},
            {"tenant", ""},
            {"clientid", "SomeClientId"},
            {"clientsecret", "SomeClientSecret"}
        };
}
