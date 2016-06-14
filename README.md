## Script to configure WinRM on fresh windows instance

Script structure:  
- Configure firewall to allow WinRM HTTP connections.  
- Configure firewall to allow WinRM HTTPS connections.  
- Find and start the WinRM service.  
- WinRM should be running; check that we have a PS session config.  
- Check for service basic authentication.  
- Check for client basic authentication.  
- Check for service Unencrypted.  

