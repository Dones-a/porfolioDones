# Servidor web simple en PowerShell para el puerto 5500
$port = 5500
$url = "http://localhost:$port"

Write-Host "Iniciando servidor web en $url" -ForegroundColor Green
Write-Host "Presiona Ctrl+C para detener el servidor" -ForegroundColor Yellow

# Crear un listener HTTP
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url + "/")

try {
    $listener.Start()
    Write-Host "Servidor iniciado correctamente en $url" -ForegroundColor Green
    
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        # Obtener la ruta solicitada
        $localPath = $request.Url.LocalPath.TrimStart('/')
        if ($localPath -eq "") {
            $localPath = "index.html"
        }
        
        # Construir la ruta completa del archivo
        $filePath = Join-Path $PWD $localPath
        
        Write-Host "Solicitud: $localPath" -ForegroundColor Cyan
        
        if (Test-Path $filePath -PathType Leaf) {
            # Leer el archivo
            $content = Get-Content $filePath -Raw -Encoding UTF8
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
            
            # Determinar el tipo de contenido
            $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
            switch ($extension) {
                ".html" { $contentType = "text/html; charset=utf-8" }
                ".css" { $contentType = "text/css" }
                ".js" { $contentType = "application/javascript" }
                ".png" { $contentType = "image/png" }
                ".jpg" { $contentType = "image/jpeg" }
                ".jpeg" { $contentType = "image/jpeg" }
                ".gif" { $contentType = "image/gif" }
                ".svg" { $contentType = "image/svg+xml" }
                default { $contentType = "text/plain" }
            }
            
            $response.ContentType = $contentType
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.StatusCode = 200
        } else {
            # Archivo no encontrado
            $notFoundHtml = @"
<!DOCTYPE html>
<html>
<head>
    <title>404 - No encontrado</title>
</head>
<body>
    <h1>404 - Archivo no encontrado</h1>
    <p>El archivo '$localPath' no existe.</p>
    <a href="/">Volver al inicio</a>
</body>
</html>
"@
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($notFoundHtml)
            $response.ContentType = "text/html; charset=utf-8"
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.StatusCode = 404
        }
        
        $response.Close()
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    $listener.Stop()
    Write-Host "Servidor detenido." -ForegroundColor Yellow
}



