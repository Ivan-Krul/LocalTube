Clear-Host

function Write-List
{
    param
    (
        [Array]$list
    )
    for($i = 0; $i -lt $list.Count; $i += 1)
    {
        Write-Host "$($i)`t: $($list[$i])"
    }
}

function Check-AdditionalDirectories
{
    param
    (
        [System.IO.FileInfo]$currentPath,
        [System.IO.FileInfo]$filePath
    )

    $checkItOut = Get-Content $filePath -Encoding UTF8
    $filePathlist = $checkItOut.Split("`n")
    $allFiles = @()

    Write-List $filePathlist

    foreach($path in $filePathlist)
    {
        Set-Location -Path $path
        Write-Host "Import from`t: $($path)"
        $allFilesLocal = Get-ChildItem -Path $Directory -File -Name -Recurse
        for($i = 0; $i -lt $allFilesLocal.Count; $i++)
		{
			$allFilesLocal[$i] = "$($path)$($allFilesLocal[$i])"
		}
        Write-Host "Fetched     : $($allFilesLocal.Count)"
        $allFiles += $allFilesLocal
        Set-Location $currentPath
    }
    Set-Location $currentPath
    return $allFiles
}

function Parse-Ignore
{
    param
    (
        [System.IO.FileInfo]$IgnoreFilePath,
        [string[]]$allFiles
    )

    $ignorePatterns = Get-Content -Path $IgnoreFilePath -Encoding UTF8
    $ignorePatternList = $ignorePatterns.Split("`n")
    Write-List $ignorePatternList

    $filteredFiles = @()

    $pattern = ""
    $filter = {$_ -cmatch $pattern}

    foreach ($file in $allFiles)
    {
        $notmathc = 0
        foreach($ignoreEl in $ignorePatternList)
        {
            $pattern = $ignoreEl
            if ($file | Where-Object $filter)
            {
                $notmathc = 1
                break
            }
        }
        if($notmathc -eq 0)
        {
            $filteredFiles += $file
        }
        else
        {
            Write-Host "Not mathced: $($file)"
        }
    }

    return $filteredFiles
}

$location = Get-Location
$allFiles = Check-AdditionalDirectories $location.Path "pathToCheckItOut.txt"
$files = Parse-Ignore "videoIgnore.txt" $allFiles

New-Item "videos.txt" -Force
foreach($file in $files)
{
    $file >> "videos.txt"
}
