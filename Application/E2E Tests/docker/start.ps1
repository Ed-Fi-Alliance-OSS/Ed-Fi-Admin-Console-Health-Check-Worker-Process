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
    $pull = "never"
    if ($p) {
        $pull = "always"
    }

    Write-Output "Starting services"
    docker compose up -d
}