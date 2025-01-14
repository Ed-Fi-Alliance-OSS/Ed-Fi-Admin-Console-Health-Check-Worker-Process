# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

[CmdLetBinding()]
<#
    .SYNOPSIS
        Automation script for running build operations from the command line.

    .DESCRIPTION
        Provides automation of the following tasks:

        * Clean: runs `dotnet clean`
        * Build: runs `dotnet build` with several implicit steps
          (clean, restore, inject version information).
        * UnitTest: executes NUnit tests in projects named `*.UnitTests`, which
          do not connect to a database.
    .EXAMPLE
        .\build-dms.ps1 build -Configuration Release -Version "2.0" -BuildCounter 45

        Overrides the default build configuration (Debug) to build in release
        mode with assembly version 2.0.45.

    .EXAMPLE
        .\build-dms.ps1 unittest

        Output: test results displayed in the console and saved to XML files.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'False positive')]
param(
    # Command to execute, defaults to "Build".
    [string]
    [ValidateSet("Clean", "Build", "UnitTest","PackageHealthWorker", "BuildAndPublish", "BuildPackage")]
    $Command = "Build",

    # Assembly and package version number for the Data Management Service. The
    # current package number is configured in the build automation tool and
    # passed to this script.
    [string]
    $HealthWorkerVersion = "0.1",

    # .NET project build configuration, defaults to "Debug". Options are: Debug, Release.
    [string]
    [ValidateSet("Debug", "Release")]
    $Configuration = "Debug",

    # Ed-Fi's official NuGet package feed for package download and distribution.
    [string]
    $EdFiNuGetFeed = "https://pkgs.dev.azure.com/ed-fi-alliance/Ed-Fi-Alliance-OSS/_packaging/EdFi/nuget/v3/index.json",

    # Only required with local builds and testing.
    [switch]
    $IsLocalBuild
)

$solutionRoot = "$PSScriptRoot/Application"
$defaultSolution = "$solutionRoot/EdFi.AdminConsole.HealthCheckService.sln"
$projectName = "EdFi.AdminConsole.HealthCheckService"
$packageName = "Ed-Fi-Admin-Console-Health-Check-Worker-Process"


$maintainers = "Ed-Fi Alliance, LLC and contributors"

Import-Module -Name "$PSScriptRoot/eng/build-helpers.psm1" -Force

function RunNuGetPack {
    param (
        [string]
        $ProjectPath,

        [string]
        $PackageVersion,

        [string]
        $nuspecPath
    )

    # NU5100 is the warning about DLLs outside of a "lib" folder. We're
    # deliberately using that pattern, therefore we don't care about the
    # warning.
    # NU5110 is the warning about ps1 files outside the "tools" folder
    # NU5111 is a warning about an unrecognized ps1 filename
    dotnet pack $ProjectPath --output $PSScriptRoot -p:NuspecFile=$nuspecPath -p:NuspecProperties="version=$PackageVersion" /p:NoWarn='"NU5100;NU5110;NU5111"'
}

function DotNetClean {
    Invoke-Execute { dotnet clean $defaultSolution -c $Configuration --nologo -v minimal }
}

function Restore {
    Invoke-Execute { dotnet restore $defaultSolution }
}

function SetHealthWorkerAssemblyInfo {
    Invoke-Execute {
        $assembly_version = $HealthWorkerVersion

        Invoke-RegenerateFile "$solutionRoot/Directory.Build.props" @"
<Project>
    <!-- This file is generated by the build script. -->
    <PropertyGroup>
        <TreatWarningsAsErrors>True</TreatWarningsAsErrors>
        <ErrorLog>results.sarif,version=2.1</ErrorLog>
        <Product>Ed-Fi Data Management Service</Product>
        <Authors>$maintainers</Authors>
        <Company>$maintainers</Company>
        <Copyright>Copyright © ${(Get-Date).year)} Ed-Fi Alliance</Copyright>
        <VersionPrefix>$assembly_version</VersionPrefix>
        <VersionSuffix></VersionSuffix>
    </PropertyGroup>
</Project>
"@
    }
}

function BuildPackage {
    $projectRoot = "$solutionRoot/$projectName"
    $projectPath = "$projectRoot/$projectName.csproj"
    $nugetSpecPath = "$projectRoot/$projectName.nuspec"

    RunNuGetPack -ProjectPath $projectPath -PackageVersion $HealthWorkerVersion $nugetSpecPath
}

function Compile {
    Invoke-Execute {
        dotnet build $defaultSolution -c $Configuration --nologo --no-restore
    }
}

function PushPackage {
    Invoke-Execute {
        if (-not $NuGetApiKey) {
            throw "Cannot push a NuGet package without providing an API key in the `NuGetApiKey` argument."
        }

        if (-not $EdFiNuGetFeed) {
            throw "Cannot push a NuGet package without providing a feed in the `EdFiNuGetFeed` argument."
        }

        if (-not $PackageFile) {
            $PackageFile = "$PSScriptRoot/$packageName.$DMSVersion.nupkg"
        }

        if ($DryRun) {
            Write-Info "Dry run enabled, not pushing package."
        }
        else {
            Write-Info ("Pushing $PackageFile to $EdFiNuGetFeed")

            dotnet nuget push $PackageFile --api-key $NuGetApiKey --source $EdFiNuGetFeed
        }
    }
}

function RunTests {
    param (
        # File search filter
        [string]
        $Filter
    )

    $testAssemblyPath = "$solutionRoot/$Filter/bin/$Configuration/"
    $testAssemblies = Get-ChildItem -Path $testAssemblyPath -Filter "$Filter.dll" -Recurse

    if ($testAssemblies.Length -eq 0) {
        Write-Output "no test assemblies found in $testAssemblyPath"
    }

    $testAssemblies | ForEach-Object {
        Write-Output "Executing: dotnet test $($_)"
        Invoke-Execute {
            dotnet test $_ `
                --logger "trx;LogFileName=$($_).trx" `
                --nologo
        }
    }
}

function UnitTests {
    Invoke-Execute { RunTests -Filter "*.UnitTests" }
}

function PublishHealthWorker {
    Write-Output "Publishing Health Worker to ($solutionRoot/$projectName/)"
    Invoke-Execute {
        $projectRoot = "$solutionRoot/$projectName"
        $outputPath = "$projectRoot/publish"
        dotnet publish $projectRoot -c $Configuration -o $outputPath --nologo
    }
}

function Invoke-Build {
    Write-Output "Building HealthCheck worker binaries ($HealthWorkerVersion)"
    Invoke-Step { DotNetClean }
    Invoke-Step { Restore }
    Invoke-Step { Compile }
}

function Invoke-BuildPackage {
    Invoke-Step { BuildPackage }
}

function Invoke-Publish {
    Write-Output "Publishing Health Worker ($HealthWorkerVersion)"
    Invoke-Step { PublishHealthWorker }
}

function Invoke-PushPackage {
    Invoke-Step { PushPackage }
}

function Invoke-Clean {
    Invoke-Step { DotNetClean }
}

function Invoke-TestExecution {
    param (
        [ValidateSet("UnitTests",
            ErrorMessage = "Please specify a valid Test Type name from the list.",
            IgnoreCase = $true)]
        # File search filter
        [string]
        $Filter
    )
    switch ($Filter) {
        UnitTests { Invoke-Step { UnitTests } }
        Default { "Unknown Test Type" }
    }
}

function Invoke-SetAssemblyInfo {
    Write-Output "Setting Assembly Information"

    Invoke-Step { SetHealthWorkerAssemblyInfo }
}

Invoke-Main {
    if ($IsLocalBuild) {
        $nugetExePath = Install-NugetCli
        Set-Alias nuget $nugetExePath -Scope Global -Verbose
    }
    switch ($Command) {
        Clean { Invoke-Clean }
        Build { Invoke-Build }
        BuildAndPublish {
            Invoke-Build
            Invoke-Publish
         }
        BuildPackage { Invoke-BuildPackage }
        Push { Invoke-PushPackage }
        UnitTest { Invoke-TestExecution UnitTests }
        default { throw "Command '$Command' is not recognized" }
    }
}
