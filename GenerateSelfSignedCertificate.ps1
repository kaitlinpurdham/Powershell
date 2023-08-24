# Create certificate
$mycert = New-SelfSignedCertificate -DnsName "domain name" -CertStoreLocation "cert:\CurrentUser\My" -NotAfter (Get-Date).AddYears(1) -KeySpec KeyExchange -KeyExportPolicy Exportable

# Export certificate to .pfx file
$mycert | Export-PfxCertificate -FilePath cert-name.pfx -Password $(ConvertTo-SecureString -String "password" -AsPlainText -Force)

# Export certificate to .cer file
$mycert | Export-Certificate -FilePath cert-name.cer