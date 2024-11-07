<#
.SYNOPSIS
    Synchronizes the autounattend.xml file with PowerShell scripts (or else) based on a mapping file.

.DESCRIPTION
    This script updates an XML template file (`autounattend_template.xml`) to ensure it contains `<File>`
    nodes for each file defined in a mapping file (`script_mapping.csv`).
    - Adds or updates `<File>` nodes with the content of each script wrapped in CDATA.
    - Removes `<File>` nodes for scripts (with Path starting with `C:\Windows\Setup\Scripts\`)
      that are not listed in the mapping file.

.PARAMETER templateFilePath
    Path to the XML template file to be used as a base (default: `autounattend_template.xml`).

.PARAMETER outputFilePath
    Path to the resulting XML file (default: `autounattend.xml`).

.PARAMETER mappingFilePath
    Path to the CSV mapping file (default: `script_mapping.csv`).
    This file should contain two columns: `FileOrigin` and `FileDestination` separated by comma.

    Example  of csv content:
        FileOrigin,FileDestination
        .\files\DotNet.ps1,C:\Windows\Temp\DotNet.ps1

.OUTPUTS
    Updates and saves the specified XML file on disk.

#>

# Define paths
$templateFilePath = "autounattend_template.xml" # Path to the template XML file
$outputFilePath = "autounattend.xml"            # Path to the final output XML file
$mappingFilePath = "file_mapping.csv"         # Path to the CSV mapping file

# Load the XML template file or exit with error if it doesn't exist
if (Test-Path $templateFilePath) {
    [xml]$xmlDocument = Get-Content -Path $templateFilePath
} else {
    Write-Host "Error: Template XML file '$templateFilePath' not found. Exiting." -ForegroundColor Red
    exit 1
}

# Load the mapping file or exit with error if it doesn't exist
if (Test-Path $mappingFilePath) {
    $scriptMappings = Import-Csv -Path $mappingFilePath
} else {
    Write-Host "Error: Mapping file '$mappingFilePath' not found. Exiting." -ForegroundColor Red
    exit 1
}

# Create namespace manager for default namespace
$namespaceManager = New-Object System.Xml.XmlNamespaceManager($xmlDocument.NameTable)
$namespaceManager.AddNamespace("x", "urn:schemas-microsoft-com:unattend")

# Ensure the unattend node exists
$unattendNode = $xmlDocument.SelectSingleNode("//x:unattend", $namespaceManager)
if (-not $unattendNode) {
    Write-Host "Error: <unattend> node not found in the XML template file. Exiting." -ForegroundColor Red
    exit 1
}

# Ensure the Extensions node exists
$extensionsNode = $xmlDocument.SelectSingleNode("//x:Extensions", $namespaceManager)
if (-not $extensionsNode) {
    Write-Host "Error: <Extensions> node not found in the XML template file. Exiting." -ForegroundColor Red
    exit 1
}

# Remove File nodes
$extensionsNode.SelectNodes("x:File", $namespaceManager) | ForEach-Object {
    $fileNode = $_
    # Remove the <File> node
    $extensionsNode.RemoveChild($fileNode) | Out-Null
}

# Process files from the mapping file
$scriptMappings | ForEach-Object {
    $fileOrigin = $_.FileOrigin
    $fileDestination = $_.FileDestination

    if (-not (Test-Path $fileOrigin)) {
        Write-Host "Warning: Script file '$fileOrigin' not found. Skipping." -ForegroundColor Yellow
        return
    }

    # Load the script content and wrap it in CDATA
    $scriptContent = Get-Content -Path $fileOrigin -Raw
    $cdataContent = "`n      <![CDATA[`n$scriptContent`n    ]]>`n    "

    # Create a new <File> node
    $fileNode = $xmlDocument.CreateElement("File", "urn:schemas-microsoft-com:unattend")
    $fileNode.SetAttribute("path", $fileDestination)
    $fileNode.InnerXml = $cdataContent

    # Append the new <File> node to the <Extensions> node
    $extensionsNode.AppendChild($fileNode) | Out-Null
}

# Add comment at the beginning of the XML
$comment = $xmlDocument.CreateComment("This file was generated by the insert_files_to_xml.ps1 script.")
$xmlDocument.InsertBefore($comment, $xmlDocument.DocumentElement)

# Save the updated XML file
$xmlDocument.Save($outputFilePath)
Write-Host "Updated XML file saved: $outputFilePath"
