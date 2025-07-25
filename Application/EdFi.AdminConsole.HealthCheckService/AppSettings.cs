// SPDX-License-Identifier: Apache-2.0
// Licensed to the Ed-Fi Alliance under one or more agreements.
// The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
// See the LICENSE and NOTICES files in the project root for more information.

namespace EdFi.AdminConsole.HealthCheckService;

public interface IAppSettings
{
    bool IgnoresCertificateErrors { get; set; }
}

public sealed class AppSettings : IAppSettings
{
    public bool IgnoresCertificateErrors { get; set; } = false;
    public int MaxRetryAttempts { get; set; }
}
