
function Invoke-GNS3RestMethod {
  <#
  .SYNOPSIS
  Forms and executes a REST API call to a GNS3 Main Server
  .DESCRIPTION
  Invoke-GNS3RestMethod uses either a specified connection object as returned
  by Connect-GNS3Server, or the $defaultGNS3Connection global variable if
  defined to construct a REST api call to the GNS3 API.
  Invoke-GNS3RestMethod constructs the appropriate request headers required by
  the GNS3 API, the content type, before making the rest call and returning the
  appropriate JSON object to the caller cmdlet.
  .EXAMPLE
  PS C:\> Invoke-GNS3RestMethod -Method GET -Uri "/v2/projects"
  Performs a 'GET' against the URI /v2/projects and returns
  the JSON object which contains the GNS3 response. This call requires the
  $defaultGNS3Connection variable to exist and be populated with server
  details as created by Connect-GNS3Server, or it fails with a message to
  first use Connect-GNS3Server
  .EXAMPLE
  PS C:\> $MyConnection = Connect-GNS3Server -Server gns3.lab.local
  PS C:\> Invoke-GNS3RestMethod -Method GET -Uri "/v2/projects" -Connection $MyConnection
  Connects to a GNS3 Main Server and stores the connection details in a
  variable, which in turn is used for the following cmdlet to retrieve
  all projects. The JSON object containing the vRNI response is returned.
  #>

  [CmdletBinding(DefaultParameterSetName = "ConnectionObj")]

  param (
    [Parameter (Mandatory = $true, ParameterSetName = "Parameter")]
    # GNS3 Main server
    [string]$Server,
    [Parameter (Mandatory = $true, ParameterSetName = "Parameter")]
    [Parameter (ParameterSetName = "ConnectionObj")]
    # REST Method (GET, POST, DELETE, UPDATE)
    [string]$Method,
    [Parameter (Mandatory = $true, ParameterSetName = "Parameter")]
    [Parameter (ParameterSetName = "ConnectionObj")]
    # URI of API endpoint (/v2/projects)
    [string]$URI,
    [Parameter (Mandatory = $false, ParameterSetName = "Parameter")]
    [Parameter (ParameterSetName = "ConnectionObj")]
    # Content to be sent to server when method is PUT/POST/PATCH
    [string]$Body = "",
    [Parameter (Mandatory = $false, ParameterSetName = "Parameter")]
    [Parameter (ParameterSetName = "ConnectionObj")]
    # Save content to file
    [string]$OutFile = "",
    [Parameter (Mandatory = $false, ParameterSetName = "Parameter")]
    [Parameter (ParameterSetName = "ConnectionObj")]
    # Extra headers to put into request
    [System.Collections.Hashtable]$extraHeaders,
    [Parameter (Mandatory = $false, ParameterSetName = "Parameter")]
    [Parameter (ParameterSetName = "ConnectionObj")]
    # Override Content-Type
    [string]$ContentType = "application/json",
    [Parameter (Mandatory = $false, ParameterSetName = "ConnectionObj")]
    # Pre-populated connection object as returned by Connect-GNS3Server
    [psObject]$Connection
  )

  if ($pscmdlet.ParameterSetName -eq "ConnectionObj") {
    # Ensure we were either called with a connection or there is a defaultConnection (user has called Connect-GNS3Server)
    if ($null -eq $connection) {
      # Now we need to assume that defaultGNS3Connection does not exist...
      if ( -not (test-path variable:global:defaultGNS3Connection) ) {
        throw "Not connected. Connect to GNS3 Main Server with Connect-GNS3Server first."
      }
      else {
        Write-Host "$($MyInvocation.MyCommand.Name) : Using default connection"
        $connection = $defaultGNS3Connection
      }
    }

    $server = $connection.Server
    $cred = $connection.credential
  }

  # Create a header option dictionary, to be used for authentication (if we have an existing session) and other RESTy stuff
  $headerDict = @{ }
  $headerDict.add("Content-Type", $ContentType)

  if ($extraHeaders) {
    foreach ($header in $extraHeaders.GetEnumerator()) {
      Write-Debug "$($MyInvocation.MyCommand.Name) : Adding extra header $($header.Key ) : $($header.Value)"
      $headerDict.add($header.Key, $header.Value)
    }
  }

  if ($cred) {
    $base64cred = [system.convert]::ToBase64String(
      [system.text.encoding]::ASCII.Getbytes(
        #"admin:VMware1!"
        "$($cred.GetNetworkCredential().username):$($cred.GetNetworkCredential().password)"
      )
    )
    $headerDict.add("Authorization", "Basic $Base64cred")
  }

  # Form the URL to call and write in our journal about this call
  $URL = "http://$($Server)/$($URI)"
  Write-Debug "$(Get-Date -format s)  REST Call via Invoke-RestMethod: $Method $URL "
  Write-Debug "Headers: $headerDict"
  Write-Debug "Body: $Body"

  # Build up Invoke-RestMethod parameters, can differ per platform
  $invokeRestMethodParams = @{
    "Method"      = $Method;
    "Headers"     = $headerDict;
    "ContentType" = $ContentType;
    "Uri"         = $URL;
  }

  # If a body for a POST request has been specified, add it to the parameters for Invoke-RestMethod
  if ($Body -ne "") {
    $invokeRestMethodParams.Add("Body", $body)
  }

  # If we want to save the output to a file, specify -OutFile
  if ($OutFile -ne "") {
    $invokeRestMethodParams.Add("OutFile", $OutFile)
  }

  # Ignore SSL certificate checks
  if (($script:PowerGNS3_PlatformType -eq "Desktop")) {
    # Allow untrusted certificate presented by the remote system to be accepted
    if ([System.Net.ServicePointManager]::CertificatePolicy.tostring() -ne 'TrustAllCertsPolicy') {
      [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    }
  }
  # Core (for now) uses a different mechanism to manipulating [System.Net.ServicePointManager]::CertificatePolicy
  if (($script:PowerGNS3_PlatformType -eq "Core")) {
    $invokeRestMethodParams.Add("SkipCertificateCheck", $true)
  }

  # Energize!
  try {
    $response = Invoke-RestMethod @invokeRestMethodParams
  }

  # If its a webexception, we may have got a response from the server with more information...
  # Even if this happens on PoSH Core though, the ex is not a webexception and we cant get this info :(
  catch [System.Net.WebException] {
    #Check if there is a response populated in the response prop as we can return better detail.
    $response = $_.exception.response
    if ( $response ) {
      $responseStream = $response.GetResponseStream()
      $reader = New-Object system.io.streamreader($responseStream)
      $responseBody = $reader.readtoend()
      ## include ErrorDetails content in case therein lies juicy info
      $ErrorString = "$($MyInvocation.MyCommand.Name) : The API response received indicates a failure. $($response.StatusCode.value__) : $($response.StatusDescription) : Response Body: $($responseBody)`nErrorDetails: '$($_.ErrorDetails)'"

      # Log the error with response detail.
      Write-Warning -Message $ErrorString
      ## throw the actual error, so that the consumer can debug via the actuall ErrorRecord
      Throw $_
    }
    else {
      # No response, log and throw the underlying ex
      $ErrorString = "$($MyInvocation.MyCommand.Name) : Exception occured calling invoke-restmethod. $($_.exception.tostring())"
      Write-Warning -Message $_.exception.tostring()
      ## throw the actual error, so that the consumer can debug via the actuall ErrorRecord
      Throw $_
    }
  }

  catch {
    # Not a webexception (may be on PoSH core), log and throw the underlying ex string
    $ErrorString = "$($MyInvocation.MyCommand.Name) : Exception occured calling invoke-restmethod. $($_.exception.tostring())"
    Write-Warning -Message $ErrorString
    ## throw the actual error, so that the consumer can debug via the actuall ErrorRecord
    Throw $_
  }


  Write-Debug "$(Get-Date -format s) Invoke-RestMethod Result: $response"
  Write-Debug "$(Get-Date -format s) Invoke-RestMethod Results: $($response.results)"

  # Workaround for bug in invoke-restmethod where it doesnt complete the tcp session close to our server after certain calls.
  # We end up with connectionlimit number of tcp sessions in close_wait and future calls die with a timeout failure.
  # So, we are getting and killing active sessions after each call.  Not sure of performance impact as yet - to test
  # and probably rewrite over time to use invoke-webrequest for all calls... PiTA!!!! :|

  #$ServicePoint = [System.Net.ServicePointManager]::FindServicePoint($FullURI)
  #$ServicePoint.CloseConnectionGroup("") | out-null

  # Return result
  if ($response) { $response }
}

function Connect-GNS3Server {
  <#
  .SYNOPSIS

  .DESCRIPTION

  .EXAMPLE
  #>
  param (
    [Parameter (Mandatory = $true)]
    # GNS3 Main server hostname or IP address
    [ValidateNotNullOrEmpty()]
    [string]$Server,
    [Parameter (Mandatory = $true)]
    # GNS3 Main server port
    [ValidateNotNullOrEmpty()]
    [string]$Port,
    [Parameter (Mandatory = $false)]
    # Username to use to login
    [ValidateNotNullOrEmpty()]
    [securestring]$Username,
    [Parameter (Mandatory = $false)]
    # Password to use to login
    [ValidateNotNullOrEmpty()]
    [securestring]$Password
  )

  # No credentials given
  $connection_credentials = $false
  if (!($PsBoundParameters.ContainsKey("Password")) -And !($PsBoundParameters.ContainsKey("Username"))) {
    $connection_credentials = Get-Credential -Message "GNS3 Authentication"
  }
  elseif (!($PsBoundParameters.ContainsKey("Password"))) {
    $connection_credentials = Get-Credential -UserName $Username -Message "GNS3 Authentication"
  }
  # If the password has been given
  else {
    $connection_credentials = New-Object System.Management.Automation.PSCredential($Username, $Password)
  }

  $headerDictionary = @{}
  $base64cred = [system.convert]::ToBase64String(
    [system.text.encoding]::ASCII.Getbytes(
      "$($connection_credentials.GetNetworkCredential().username):$($connection_credentials.GetNetworkCredential().password)"
    )
  )
  $headerDictionary.add("Authorization", "Basic $Base64cred")

  $Server = "$($Server):$($Port)"
  $response = Invoke-GNS3RestMethod -Server $Server -Method GET -URI "v2/version"
  Write-Debug "Response: $($response)"

  if ($response) {
    # Setup a custom object to contain the parameters of the connection
    $connection = [pscustomObject] @{
      "Server"      = $Server
      "GNS3Version" = $response.version
      "Credentials" = $connection_credentials
    }

    # Remember this as the default connection
    Set-Variable -name defaultGNS3Connection -value $connection -scope Global

    # Return the connection
    $connection
  }
}

function Get-GNS3Project {
  <#
  .SYNOPSIS

  .DESCRIPTION

  .EXAMPLE
  #>
  param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [PSCustomObject]$Connection = $defaultGNS3Connection
  )

  $response = Invoke-GNS3RestMethod -Connection $Connection -Method GET -URI "v2/projects"
  Write-Debug "Response: $($response)"

  $response
}

function Get-GNS3ProjectNodes {
  param (
    [Parameter (Mandatory = $true, ValueFromPipeline = $true)]
    # Application object, gotten from Get-GNS3Project
    [ValidateNotNullOrEmpty()]
    [PSObject]$Project,
    [Parameter (Mandatory = $False)]
    # GNS3 Connection object
    [ValidateNotNullOrEmpty()]
    [PSCustomObject]$Connection = $defaultGNS3Connection
  )

  process {
    ## do Foreach-Object, so as to enable user to pass multiple project objects for value of -Project parameter
    $Project | Foreach-Object {
      $oThisProject = $_
      # Get a list of all nodes for this project
      $node_list = Invoke-GNS3RestMethod -Connection $Connection -Method GET -URI "v2/projects/$($oThisProject.project_id)/nodes"
      $node_list
    } ## end Foreach-Object
  } ## end process
}

function Start-GNS3ProjectNode {
  param (
    [Parameter (Mandatory = $true, ValueFromPipeline = $true)]
    # Application object, gotten from Get-GNS3Project
    [ValidateNotNullOrEmpty()]
    [PSObject]$Node,
    [Parameter (Mandatory = $False)]
    # GNS3 Connection object
    [ValidateNotNullOrEmpty()]
    [PSCustomObject]$Connection = $defaultGNS3Connection
  )

  process {
    ## do Foreach-Object, so as to enable user to pass multiple project objects for value of -Project parameter
    $Node | Foreach-Object {
      $oThisNode = $_
      # Start this node
      $result = Invoke-GNS3RestMethod -Connection $Connection -Method POST -URI "v2/projects/$($oThisNode.project_id)/nodes/$($oThisNode.node_id)/start" -Body {}
      $result
    } ## end Foreach-Object
  } ## end process
}

function Stop-GNS3ProjectNode {
  param (
    [Parameter (Mandatory = $true, ValueFromPipeline = $true)]
    # Application object, gotten from Get-GNS3Project
    [ValidateNotNullOrEmpty()]
    [PSObject]$Node,
    [Parameter (Mandatory = $False)]
    # GNS3 Connection object
    [ValidateNotNullOrEmpty()]
    [PSCustomObject]$Connection = $defaultGNS3Connection
  )

  process {
    ## do Foreach-Object, so as to enable user to pass multiple project objects for value of -Project parameter
    $Node | Foreach-Object {
      $oThisNode = $_
      # Start this node
      $result = Invoke-GNS3RestMethod -Connection $Connection -Method POST -URI "v2/projects/$($oThisNode.project_id)/nodes/$($oThisNode.node_id)/stop" -Body {}
      $result
    } ## end Foreach-Object
  } ## end process
}

# curl -X POST "http://localhost:3080/v2/projects/b8c070f7-f34c-4b7b-ba6f-be3d26ed073f/nodes/f124dec0-830a-451e-a314-be50bbd58a00/start" -d "{}"



# Run at module load time to determine a few things about the platform this module is running on.
function _PowerGNS3_init {
  # $PSVersionTable.PSEdition property does not exist pre v5.  We need to do a few things in
  # exported functions to workaround some limitations of core edition, so we export
  # the global PNSXPSTarget var to reference if required.
  if (($PSVersionTable.PSVersion.Major -ge 6) -or (($PSVersionTable.PSVersion.Major -eq 5) -And ($PSVersionTable.PSVersion.Minor -ge 1))) {
    $script:PowerGNS3_PlatformType = $PSVersionTable.PSEdition
  }
  else {
    $script:PowerGNS3_PlatformType = "Desktop"
  }

  # Define class required for certificate validation override.  Version dependant.
  # For whatever reason, this does not work when contained within a function?
  $TrustAllCertsPolicy = @"
      using System.Net;
      using System.Security.Cryptography.X509Certificates;
      public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
          ServicePoint srvPoint, X509Certificate certificate,
          WebRequest request, int certificateProblem)
        {
          return true;
        }
      }
"@

  if ($script:PowerGNS3_PlatformType -eq "Desktop") {
    if (-not ("TrustAllCertsPolicy" -as [type])) {
      Add-Type $TrustAllCertsPolicy
    }
  }
}

# Call Init function
_PowerGNS3_init