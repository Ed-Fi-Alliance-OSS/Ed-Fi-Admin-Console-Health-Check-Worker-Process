﻿// SPDX-License-Identifier: Apache-2.0
// Licensed to the Ed-Fi Alliance under one or more agreements.
// The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
// See the LICENSE and NOTICES files in the project root for more information.

using EdFi.AdminConsole.HealthCheckService.Features.AdminApi;
using Microsoft.Extensions.Logging;

namespace EdFi.AdminConsole.HealthCheckService.Helpers;

public static class InstanceValidator
{
    public static bool IsInstanceValid(ILogger logger, AdminApiInstanceDocument instance)
    {
        var messages = new List<string>();

        if (instance == null)
            messages.Add("instance cannot be empty.");
        else
        {
            if (string.IsNullOrEmpty(instance.AuthenticationUrl))
                messages.Add("AuthenticationUrl is required.");
            
            if (string.IsNullOrEmpty(instance.ResourcesUrl))
                messages.Add("ResourcesUrl is required.");
            
            if (string.IsNullOrEmpty(instance.ClientId))
                messages.Add("ClientId is required.");
            
            if (string.IsNullOrEmpty(instance.ClientSecret))
                messages.Add("ClientSecret is required.");
        }

        if (messages != null && messages.Count > 0)
        {
            string concatenatedMessages = String.Concat(messages);
            logger.LogWarning($"The instance obtained from Admin API is not properly formed. {concatenatedMessages}");
            return false;
        }

        return true;
    }
}
