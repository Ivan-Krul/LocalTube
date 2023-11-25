$paths = Get-Content -Path "content.txt"
$listPaths = $paths.Split("`n")

New-Item "previews" -ItemType directory

$index = 0

foreach($itemPath in $listPaths) {
    $item = Get-Item -Path $itemPath
	Write-Host $itemPath
    ffmpeg -i $itemPath -ss 00:00:02 -vframes 1 -loglevel quiet "previews/$($index).jpg"
    $index+= 1
}
