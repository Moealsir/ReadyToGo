Automated Software Installation and Configuration

# Overview

This project provides a Bash script to automate the installation and configuration of various software tools and settings on a system. The script includes functionalities for updating the system, installing Node.js, npm, pm2, MySQL, nginx, and adding authorized keys and GitHub credentials. It also handles creating swap space and maintains a state file to track completed installations.

## Features

- System update and upgrade
- Installation of Node.js (v20.15.1) and npm (v10.7.0)
- Installation of pm2
- MySQL installation and setup
- Nginx installation and configuration
- Addition of authorized keys
- GitHub credentials management
- Creation of swap space
- Logging and error handling

## Requirements

- Bash (version 4.0 or higher)
- curl (for adding Node.js repository)
- apt-get (for package management)

## Installation

Clone the repository:

```bash
git clone https://github.com/Moealsir/ReadyToGo.git
cd ReadyToGo
```


## Usage

Run the script:

```bash
./setup.sh
```

The script will guide you through the installation and configuration process. Follow the prompts to provide necessary inputs such as GitHub credentials and swap space size.

Check the log files:

- `setup.log` - Contains log messages for successful operations.
- `setup_error.log` - Contains error messages for failed operations.

## Script Functions

- `update_and_upgrade`: Updates and upgrades the system.
- `install_nodejs_npm`: Installs Node.js and npm.
- `install_pm2`: Installs pm2.
- `install_mysql`: Installs and configures MySQL.
- `copy_dir_navigator`: Copies `dir_navigator.sh` to `/bin`.
- `add_authorized_keys`: Adds authorized keys for SSH.
- `add_to_bashrc`: Appends GitHub credentials to `.bashrc`.
- `install_nginx`: Installs and configures nginx.
- `add_swap`: Creates swap space.

## ! Important

#### ! Make sure to add you public keys in file `authorized_keys` before running option `add_authorized_keys`

## Troubleshooting

If you encounter errors, check the `setup_error.log` file for detailed error messages.
Ensure you have the necessary permissions to run the script and install software.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## Contact

For any issues or questions, please contact mohamedwdalsir@gmail.com.
