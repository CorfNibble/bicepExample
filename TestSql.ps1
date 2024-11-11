param(
    $sqlUsername,
    $sqlPassword,
    $SqlServerIp    
)

# Define the connection string
$connectionString = "Server=tcp:$SqlServerIp,1433;Initial Catalog=dev-db;Persist Security Info=False;User ID=$sqlUsername;Password='$sqlPassword';MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"

# Load the .NET SQL client library
Add-Type -AssemblyName "System.Data"

# Create a new SQL connection
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

try {
    # Open the SQL connection
    $connection.Open()
    Write-Host "Connection successful!"

    # Define a SQL command to execute (e.g., get server version)
    $sqlCommand = $connection.CreateCommand()
    $sqlCommand.CommandText = "SELECT @@VERSION as ServerVersion;"

    # Execute the SQL command
    $reader = $sqlCommand.ExecuteReader()

    # Display the results
    while ($reader.Read()) {
        Write-Host "SQL Server Version:" $reader["ServerVersion"]
    }

    # Close the data reader
    $reader.Close()
} catch {
    Write-Output "An error occurred: $($_.Exception.Message)"
} finally {
    # Close the SQL connection
    $connection.Close()
    Write-Output "Connection closed."
}

# removing script - Doesn't work du to rights issue
# $path = $MyInvocation.MyCommand.Path
# Start-Sleep -Seconds 2  # Give the script time to exit
# Remove-Item $path # Script removes itself
