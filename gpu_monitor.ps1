# Get GPU info from nvidia-smi
$gpuInfo = & nvidia-smi --query-gpu=utilization.gpu,memory.used,temperature.gpu --format=csv,noheader,nounits

if (-not $gpuInfo) {
    Write-Error "No data returned from nvidia-smi"
    exit 1
}

# If multiple GPUs exist, take the first line
$line = ($gpuInfo | Select-Object -First 1).Trim()
$fields = $line -split '\s*,\s*'

if ($fields.Count -lt 3) {
    Write-Error "Unexpected nvidia-smi output: $line"
    exit 1
}

$gpuUtil = [int]$fields[0]
$memUsed = [int]$fields[1]
$tempGpu = [int]$fields[2]

# Build XML for PRTG HTTP Push Data Advanced sensor
$xml = @"
<prtg>
<result>
<channel>GPU Utilization</channel>
<value>$gpuUtil</value>
<unit>Percent</unit>
</result>
<result>
<channel>Memory Used</channel>
<value>$memUsed</value>
<unit>Custom</unit>
<customunit>MB</customunit>
</result>
<result>
<channel>GPU Temperature</channel>
<value>$tempGpu</value>
<unit>Temperature</unit>
</result>
<text>GPU OK - Utilization $gpuUtil%, Memory $memUsed MB, Temp $tempGpu C</text>
</prtg>
"@

# Advanced sensor endpoint
$url = "http://PRTG_IP:5050/TOKEN?content="

Invoke-WebRequest -UseBasicParsing `
    -Uri $url `
    -Method POST `
    -Body $xml `
    -ContentType "application/xml"