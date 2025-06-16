# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

[CmdletBinding()]
param (
    # Stop services instead of starting them
    [Switch]
    $d,

    # Delete volumes after stopping services
    [Switch]
    $v
)

if ($d) {
    if ($v) {
        Write-Output "Shutting down services and deleting volumes"
        docker compose down -v
    }
    else {
        Write-Output "Shutting down services"
        docker compose down
    }
}
else {
    # Always build Health Check Service Docker image when starting services
    Write-Output "Building Ed-Fi Admin Console Health Check Service Docker image..."
    
    # Navigate to the project root (3 levels up from docker folder)
    $originalLocation = Get-Location
    Set-Location "$PSScriptRoot/../../../"
    
    try {
        $dockerBuildArgs = @(
            "build",
            "-f", "Docker/Dockerfile",
            "-t", "edfi.adminconsole.healthcheckservice"
        )
        
        if ($rebuild) {
            Write-Output "Force rebuilding (no cache)..."
            $dockerBuildArgs += "--no-cache"
        }
        
        $dockerBuildArgs += "."
        
        $buildResult = & docker @dockerBuildArgs
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Docker build failed with exit code $LASTEXITCODE"
            return
        }
        
        Write-Output "Health Check Service Docker image built successfully!"
    }
    finally {
        # Always return to original location
        Set-Location $originalLocation
    }

    $pull = "never"
    if ($p) {
        $pull = "always"
    }

    Write-Output "Starting services"
    docker compose up -d
}