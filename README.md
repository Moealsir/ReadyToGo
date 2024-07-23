# Automated Software Installation and Configuration

Make your fresh servers ready to go.
## Table of Contents

- [Automated Software Installation and Configuration](#automated-software-installation-and-configuration)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Script Functions](#script-functions)
- [Important !](#important-)
  - [Troubleshooting](#troubleshooting)
  - [License](#license)
  - [Contact](#contact)

## Overview

This tool will make your fresh server Ready To Go by helping you install the necessary modules quickly. It automates the installation and configuration of various software tools and settings on a system, including updating the system, installing Node.js, npm, pm2, MySQL, nginx, and adding authorized keys and GitHub credentials. Additionally, it handles creating swap space, configuring firewalls, installing Docker, and more. A state file is maintained to track completed installations.

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

bash
```
./setup.sh
```
The script will guide you through the installation and configuration process. Follow the prompts to provide necessary inputs such as GitHub credentials and swap space size.

Check the log files:


## Script Functions

| Module                      | Description                                                      |
|-----------------------------|------------------------------------------------------------------|
| `update_and_upgrade`        | Updates the system packages and upgrades them to the latest version. |
| `install_pm2`               | Installs pm2, a process manager for Node.js applications.        |
| `install_mysql`             | Installs and configures MySQL server.                            |
| `copy_dir_navigator`        | Copies `dir_navigator.sh` to `/bin` for directory navigation.    |
| `add_authorized_keys`       | Adds authorized SSH keys.                                        |
| `add_to_bashrc`             | Appends GitHub credentials to `.bashrc`.                         |
| `install_nginx`             | Installs and configures nginx web server.                        |
| `add_swap`                  | Creates swap space on the system.                                |
| `configure_firewall`        | Configures the firewall for secure access.                       |
| `install_ssl_certificates`  | Installs SSL certificates for secure communication.              |
| `install_docker`            | Installs Docker and Docker Compose.                              |
| `install_fail2ban`          | Installs fail2ban for security.                                  |
| `manage_users`              | Manages users.                                                   |
| `configure_backups`         | Configures regular system backups.                               |
| `install_monitoring_tools`  | Installs tools for system monitoring.                            |
| `configure_log_rotation`    | Configures log rotation to manage log files.                     |
| `schedule_security_updates` | Schedules regular security updates.                              |

# Important !
Make sure to add the authorized keys inside file `authorized_keys` before you run the module.
## Troubleshooting 

If you encounter errors, check the setup_error.log file for detailed error messages.
## License

This project is licensed under the MIT License - see the LICENSE file for details.
## Contact

For any issues or questions, please contact mohamedwdalsir@gmail.com.

```
You can copy and paste this into your README file to provide a comprehensive and navigable overview of the automated software installation and configuration process.