# Server Management and Database Transfer Script

This script allows you to manage server details and transfer databases to specified servers. The script provides options to add, edit, delete, and list server details, as well as dump and transfer databases.

## Features

1. Add server details
2. Edit server details
3. Delete server details
4. List server details
5. Dump and transfer databases
6. Display help information

## Usage

Run the script and follow the prompts to manage server details and transfer databases.

### Main Menu

1. **Add server details**: Prompts you to enter a nickname, server username, and server DNS to save to the server details file.
2. **Edit server details**: Lists the saved servers and prompts you to select a server to edit. You can edit one or more parameters. If a parameter is left empty, it retains the current value.
3. **Delete server details**: Lists the saved servers and prompts you to select a server to delete.
4. **List server details**: Displays the saved servers in the format `nickname - username:dns`.
5. **Dump and transfer databases**: Prompts you to enter database credentials, selects databases to dump, and transfers them to the specified server(s).
6. **Exit**: Exits the script.

### Help

To display help information, run the script with the `-h` or `--help` flag:

```bash
./script.sh -h
```

Adding Server Details

    Choose option 1 from the main menu.
    Enter the server nickname.
    Enter the server username.
    Enter the server DNS.

Editing Server Details

    Choose option 2 from the main menu.
    Select the server number to edit.
    Update the desired fields (leave blank to retain current values).

Deleting Server Details

    Choose option 3 from the main menu.
    Select the server number to delete.

Listing Server Details

Choose option 4 from the main menu to list all saved servers in the format nickname - username:dns.
Dumping and Transferring Databases

    Choose option 5 from the main menu.
    Enter database user credentials.
    Select the databases to dump.
    Choose to upload to a single server (s) or multiple servers (m).
    Select the server(s) for database transfer.

Database Dump and Transfer Process

    Prompt for database credentials: Enter the database user and password.
    Select databases to backup: List the available databases and select the ones to backup.
    Choose upload option: Select whether to upload to a single server (s) or multiple servers (m).
    Transfer databases: The script will dump the selected databases and transfer the SQL files to the chosen server(s).

License
```
This script is released under the MIT License.
```
rust



```
This README file provides an overview of the script's features, usage instructions, and detailed steps for each functionality.```