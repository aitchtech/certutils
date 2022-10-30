# certutils

Small helper scripts to manage dev certificates

### Intended usage

1.  Generate root certificate once, using
    
    ```bash
    ./genca.sh
    ```

    It will output a root certificate root.crt in `%USERPROFILE%\certs`. Intall this certificate as Trusted Root Certificate Authority.

2.  Generate as many certificates for development using
    
    ```sh
    ./gencert.sh <commonname> [keyfilepassword]
    ```
    - .crt, .key, .pfx files will be exported in `%USERPROFILE%\certs\<commonname>`
    - .key and .pfx files default password will be `certpass` unless manually supplied
    - Following will be included as subjects name
        - hostname of computer
        - localhost
        - IP addresses of all interfaces including loopback addresses

### Requirements

bash (Git Bash)
powershell