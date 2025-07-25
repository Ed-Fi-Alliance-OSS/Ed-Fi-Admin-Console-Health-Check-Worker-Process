// SPDX-License-Identifier: Apache-2.0
// Licensed to the Ed-Fi Alliance under one or more agreements.
// The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
// See the LICENSE and NOTICES files in the project root for more information.

using System.Net;

namespace EdFi.AdminConsole.HealthCheckService.Extensions;

public static class HttpStatusCodeExtensions
{
    public static bool IsPotentiallyTransientFailure(this HttpStatusCode httpStatusCode)
    {
        switch (httpStatusCode)
        {
            case HttpStatusCode.InternalServerError:
            case HttpStatusCode.GatewayTimeout:
            case HttpStatusCode.ServiceUnavailable:
            case HttpStatusCode.RequestTimeout:
                return true;
            default:
                return false;
        }
    }
}
