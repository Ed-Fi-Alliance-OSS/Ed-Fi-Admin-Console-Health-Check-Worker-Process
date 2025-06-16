# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

Import-Module -Name "$PSScriptRoot/e2eTest-helpers.psm1" -Force

# Import Pester for testing (but don't auto-discover)
Import-Module Pester -Force

# Pre-Step
Read-EnvVariables

# Global Variables
$adminApiUrl = $env:ADMIN_API
$adminConsoleInstancesUrl = "$env:ADMIN_API/adminconsole/instances"
$AdminConsoleHealthCheckUrl = "$env:ADMIN_API/adminconsole/healthcheck"

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
$response = Get-Token -clientId $env:clientId -clientSecret $env:clientSecret
if ($response.StatusCode -ne 200) {
    Write-Error "Not able to get token on Admin Api." -ErrorAction Stop
}

$access_token = $response.Body.access_token

# 3.1 Create vendor, ods instance and application on admin api
$response = Invoke-AdminApi -access_token $access_token -filePath "$PSScriptRoot/payloads/vendor.json" -endpoint "vendors"
if ($response.StatusCode -ne 201) {
    Write-Error "Not able to create vendor on Admin Api." -ErrorAction Stop
}

$vendorId = $response.ResponseHeaders.location -replace '\D'

Copy-Item -Path "$PSScriptRoot/payloads/odsInstance.json" -Destination "$PSScriptRoot/payloads/odsInstanceCopy.json"
(Get-Content $PSScriptRoot/payloads/odsInstanceCopy.json).Replace('%Password%', $env:POSTGRES_PASSWORD) | Set-Content $PSScriptRoot/payloads/odsInstanceCopy.json
(Get-Content $PSScriptRoot/payloads/odsInstanceCopy.json).Replace('%Name%', "ods-$(New-Guid)") | Set-Content $PSScriptRoot/payloads/odsInstanceCopy.json

$response = Invoke-AdminApi -access_token $access_token -filePath "$PSScriptRoot/payloads/odsInstanceCopy.json" -endpoint "odsInstances"
if ($response.StatusCode -ne 201) {
    Write-Error "Not able to create ods instance on Admin Api." -ErrorAction Stop
}

$odsInstanceId = $response.ResponseHeaders.location -replace '\D'

Remove-Item -Path "$PSScriptRoot/payloads/odsInstanceCopy.json"

Copy-Item -Path "$PSScriptRoot/payloads/application.json" -Destination "$PSScriptRoot/payloads/applicationCopy.json"
(Get-Content $PSScriptRoot/payloads/applicationCopy.json).Replace('123456789', $vendorId) | Set-Content $PSScriptRoot/payloads/applicationCopy.json
(Get-Content $PSScriptRoot/payloads/applicationCopy.json).Replace('987654321', $odsInstanceId) | Set-Content $PSScriptRoot/payloads/applicationCopy.json

$response = Invoke-AdminApi -access_token $access_token -filePath "$PSScriptRoot/payloads/applicationCopy.json" -endpoint "applications"

if ($response.StatusCode -ne 201) {
    Write-Error "Not able to create application on Admin Api." -ErrorAction Stop
}
Remove-Item -Path "$PSScriptRoot/payloads/applicationCopy.json"

# 3.3 Replace instance name to make it unique
Copy-Item -Path "$PSScriptRoot/payloads/instance.json" -Destination "$PSScriptRoot/payloads/instanceCopy.json"
(Get-Content $PSScriptRoot/payloads/instanceCopy.json).Replace('%InstanceName%', "$(New-Guid)") | Set-Content $PSScriptRoot/payloads/instanceCopy.json

# 3.4 Create Instance
Write-Host "Create Instance..."
$response = Invoke-AdminApi -access_token $access_token -filePath "$PSScriptRoot/payloads/instanceCopy.json" -endpoint "odsInstances" -adminConsoleApi $true
if ($response.StatusCode -ne 201) {
    Write-Error "Not able to create instance on Admin Api - Console" -ErrorAction Stop
}
Remove-Item -Path "$PSScriptRoot/payloads/instanceCopy.json"

# 4. Call Ed-Fi Admin Console Health Check Worker Process
Write-Host "Call Ed-Fi-Admin-Console-Health-Check-Worker-Process..."
docker run --rm edfi.adminconsole.healthcheckservice dotnet EdFi.AdminConsole.HealthCheckService.dll --isMultiTenant=true --tenant="$env:DEFAULTTENANT" --ClientId="$env:clientId" --ClientSecret="$env:clientSecret"

# 5. Get HealthCheck
Write-Host "Get HealthCheck..."
$response = Invoke-AdminApi -access_token $access_token -endpoint "healthcheck" -adminConsoleApi $true -method "GET"
if ($response.StatusCode -ne 200) {
    Write-Error "Not able to get get healthcheck on Admin Api." -ErrorAction Stop
}

# Check if the response is an array
Write-Host "Check response..."
Write-Host "Response Status Code: $($response.StatusCode)"
Write-Host "Response Body Type: $($response.Body.GetType().Name)"
Write-Host "Response Body: $($response.Body | ConvertTo-Json -Depth 10)"

# Store response in a variable accessible to Pester
$global:HealthCheckResponse = $response

# Run Pester tests for HealthCheck response validation
$pesterConfig = New-PesterConfiguration
$pesterConfig.Run.ScriptBlock = {
    Describe "HealthCheck API Response Validation" {        It "Should return a successful status code" {
            $global:HealthCheckResponse.StatusCode | Should -Be 200
        }
        
        It "Should return an enumerable response body or null (for empty results)" {
            # Allow for null response when no health checks have been performed
            if ($global:HealthCheckResponse.Body -ne $null) {
                $global:HealthCheckResponse.Body | Should -BeOfType [System.Collections.IEnumerable]
            } else {
                Write-Warning "Response body is null - this may be expected if no health checks have been performed yet"
                $global:HealthCheckResponse.StatusCode | Should -Be 200
            }
        }        
        
        It "Should contain health check items and validate healthy status" {
            if ($global:HealthCheckResponse.Body -eq $null) {
                throw "Response body is null - health check items are required"
            } elseif ($global:HealthCheckResponse.Body -is [System.Collections.IEnumerable]) {
                Write-Host "Response is enumerable, validating health check items..."
                
                if ($global:HealthCheckResponse.Body.Count -eq 0) {
                    throw "No health check items found in response - at least one health check item is required"
                }
                
                foreach ($healthcheckItem in $global:HealthCheckResponse.Body) {
                    Write-Host "Processing healthcheck item: $($healthcheckItem | ConvertTo-Json -Depth 5)"
                    
                    # Validate that each item has required properties
                    $healthcheckItem | Should -Not -BeNullOrEmpty
                    $healthcheckItem.document | Should -Not -BeNullOrEmpty
                    $healthcheckItem.document.healthy | Should -Be $True -Because "Instance must be healthy - any other status is a failure"
                }
            } else {
                throw "HealthCheck response is not an enumerable type"
            }
        }
    }
}
$pesterConfig.Output.Verbosity = 'Detailed'

# Execute the Pester tests
Invoke-Pester -Configuration $pesterConfig

Write-Host "HealthCheck Data returned. Process completed."
