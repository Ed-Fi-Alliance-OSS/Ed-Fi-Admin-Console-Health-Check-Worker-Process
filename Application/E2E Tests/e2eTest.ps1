# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

Import-Module -Name "$PSScriptRoot/e2eTest-helpers.psm1" -Force

# Pre-Step
Read-EnvVariables

# Global Variables
$adminApiUrl = $env:ADMIN_API
$adminConsoleInstancesUrl = "$env:ADMIN_API/adminconsole/instances"
$AdminConsoleHealthCheckUrl = "$env:ADMIN_API/adminconsole/healthcheck"
$AdminConsoleHealthCheckWorkerProcessPath = $env:ADMIN_CONSOLE_HEALTHCHECK_WORKER_PROCESS_PATH

[System.Environment]::SetEnvironmentVariable("clientId", "client-$(New-Guid)")
[System.Environment]::SetEnvironmentVariable("clientSecret", $env:CLIENT_SECRET)

if ($env:MULTITENANCY -ne "true") {
  throw "Single tenant not yet supported."
}

# 1. Register client on Admin Api
Write-Host "Register client..."
$response = Register-AdminApiClient
if ($response.StatusCode -ne 200) {
    Write-Error "Not able to register user on Admin Api." -ErrorAction Stop
}

# 2. Get Token from Admin Api
Write-Host "Get token..."
$response = Get-Token -clientId $clientId -clientSecret $clientSecret
if ($response.StatusCode -ne 200) {
    Write-Error "Not able to get token on Admin Api." -ErrorAction Stop
}

$access_token = $response.Body.access_token

# 3.1 Create vendor and application on admin api
$response = Invoke-AdminApi -access_token $access_token -filePath "$PSScriptRoot/payloads/vendor.json" -endpoint "vendors"
if ($response.StatusCode -ne 201) {
    Write-Error "Not able to create vendor on Admin Api." -ErrorAction Stop
}

$vendorId = $response.ResponseHeaders.location -replace '\D'

Copy-Item -Path "$PSScriptRoot/payloads/application.json" -Destination "$PSScriptRoot/payloads/applicationCopy.json"
(Get-Content $PSScriptRoot/payloads/applicationCopy.json).Replace('123456789', $vendorId) | Set-Content $PSScriptRoot/payloads/applicationCopy.json

$response = Invoke-AdminApi -access_token $access_token -filePath "$PSScriptRoot/payloads/applicationCopy.json" -endpoint "applications"

if ($response.StatusCode -ne 201) {
    Write-Error "Not able to create application on Admin Api." -ErrorAction Stop
}
Remove-Item -Path "$PSScriptRoot/payloads/applicationCopy.json"

# 3.3 Replace key and secret on instance payload.
Copy-Item -Path "$PSScriptRoot/payloads/instance.json" -Destination "$PSScriptRoot/payloads/instanceCopy.json"
(Get-Content $PSScriptRoot/payloads/instanceCopy.json).Replace('%key%', $response.Body.key) | Set-Content $PSScriptRoot/payloads/instanceCopy.json
(Get-Content $PSScriptRoot/payloads/instanceCopy.json).Replace('%secret%', $response.Body.secret) | Set-Content $PSScriptRoot/payloads/instanceCopy.json

# 3.4 Create Instance
Write-Host "Create Instance..."
$response = Invoke-AdminApi -access_token $access_token -filePath "$PSScriptRoot/payloads/instanceCopy.json" -endpoint "instances" -adminConsoleApi $true
if ($response.StatusCode -ne 201) {
    Write-Error "Not able to create instance on Admin Api - Console" -ErrorAction Stop
}
Remove-Item -Path "$PSScriptRoot/payloads/instanceCopy.json"

########## KEEP THIS SECTION?
# # 4.local Call worker Local  
# Set-Location $AdminConsoleHealthCheckWorkerProcessPath

# $clientIdArg = "--ClientId=$clientId"
# $clientSecretArg = "--ClientSecret=$clientSecret"
# $multitenancyArg = "--IsMultiTenant=true"
# $tenantArg = "--Tenant=$env:DEFAULTTENANT"
# $dotnetApp = "EdFi.AdminConsole.HealthCheckService.dll"

# Write-Host "Call Ed-Fi-Admin-Console-Health-Check-Worker-Process..."
# dotnet $dotnetApp $clientIdArg $clientSecretArg $multitenancyArg $tenantArg

# Set-Location -Path $PSScriptRoot
########## KEEP THIS SECTION?

# 4. Call docker to run healthcheck-cli

Set-Location "$PSScriptRoot/../../"
Write-Host "Build Ed-Fi-Admin-Console-Health-Check-Worker-Process..."
docker build -f $PSScriptRoot/../../Docker/Dockerfile -t edfi.adminconsole.healthcheckservice .
Set-Location -Path $PSScriptRoot

Write-Host "Call Ed-Fi-Admin-Console-Health-Check-Worker-Process..."
docker run -it edfi.adminconsole.healthcheckservice --isMultiTenant=true --tenant="$env:DEFAULTTENANT" --ClientId="$clientId" --ClientSecret="$clientSecret"

# 5. Get HealthCheck
Write-Host "Get HealthCheck..."
$response = Invoke-AdminApi -access_token $access_token -endpoint "healthcheck" -adminConsoleApi $true -method "GET"
if ($response.StatusCode -ne 200) {
    Write-Error "Not able to get get healthcheck on Admin Api." -ErrorAction Stop
}

# Check if the response is an array
Write-Host "Check response..."
if ($response.Body -is [System.Collections.IEnumerable]) {

    Write-Host "*******************************************"
    Write-Host $response

    # Iterate through each item in the array
    foreach ($healthcheckItem in $response.Body) {
        if ($healthcheckItem.document.healthy -ne $True) {
            Write-Error "Instance: ${healthcheckItem.document.instanceId} is not healthy" -ErrorAction Stop
        }
        else {
            Write-Host "Instance: ${healthcheckItem.document.instanceId} is healthy"
        }

        # if ($healthcheckItem.document.studentSchoolAssociations -ne 3230) {
        #     Write-Error "Count value for: studentSchoolAssociations is not correct" -ErrorAction Stop
        # }
        # else {
        #     Write-Host "Total count for studentSchoolAssociations looks good."
        # }

        # if ($healthcheckItem.document.sections -ne 1376) {
        #     Write-Error "Count value for: sections is not correct" -ErrorAction Stop
        # }
        # else {
        #     Write-Host "Total count for sections looks good."
        # }

        # if ($healthcheckItem.document.studentSectionAssociations -ne 50242) {
        #     Write-Error "Count value for: studentSectionAssociations is not correct" -ErrorAction Stop
        # }
        # else {
        #     Write-Host "Total count for studentSectionAssociations looks good."
        # }
    }
} else {
    Write-Error "HealthCheck response is not an array." -ErrorAction Stop
}

Write-Host "HealthCheck Data returned. Process completed."
