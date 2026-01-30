$ftpHost = "ftpupload.net"
$ftpUser = "if0_40917433"
$ftpPass = "cjdtlqkf"

function Upload-File {
    param($localPath, $remotePath)
    $uri = New-Object System.Uri("ftp://$ftpHost/$remotePath")
    $ftpRequest = [System.Net.FtpWebRequest]::Create($uri)
    $ftpRequest.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftpRequest.UseBinary = $true
    $ftpRequest.KeepAlive = $false

    $fileContent = [System.IO.File]::ReadAllBytes($localPath)
    $ftpRequest.ContentLength = $fileContent.Length

    $requestStream = $ftpRequest.GetRequestStream()
    $requestStream.Write($fileContent, 0, $fileContent.Length)
    $requestStream.Close()
    $response = $ftpRequest.GetResponse()
    Write-Host "Uploaded $localPath to $remotePath - Status: $($response.StatusDescription)"
    $response.Close()
}

function Create-Folder {
    param($remotePath)
    try {
        $uri = New-Object System.Uri("ftp://$ftpHost/$remotePath")
        $ftpRequest = [System.Net.FtpWebRequest]::Create($uri)
        $ftpRequest.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
        $ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
        $response = $ftpRequest.GetResponse()
        $response.Close()
    }
    catch {
        # Directory likely exists
    }
}

try {
    Write-Host "Starting deployment to $ftpHost..."
    
    # Use Join-Path and Get-Location to handle paths correctly
    $currentDir = Get-Location
    
    Upload-File (Join-Path $currentDir "index.html") "htdocs/index.html"
    Upload-File (Join-Path $currentDir "style.css") "htdocs/style.css"

    Create-Folder "htdocs/assets"

    $assetsLocal = Join-Path $currentDir "assets"
    $assetsFiles = Get-ChildItem -Path $assetsLocal -File
    foreach ($file in $assetsFiles) {
        $remotePath = "htdocs/assets/$($file.Name)"
        Upload-File $file.FullName $remotePath
    }

    Write-Host "Deployment completed successfully!"
}
catch {
    Write-Error $_
}
