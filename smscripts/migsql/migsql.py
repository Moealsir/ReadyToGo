import json
import os
import getpass
import subprocess
import paramiko

# File paths for storing server and user details
SERVERS_FILE = 'servers.json'
USERS_FILE = 'users.json'

def load_data(file_path):
    if os.path.exists(file_path):
        with open(file_path, 'r') as file:
            return json.load(file)
    return {}

def save_data(file_path, data):
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=4)

def display_menu(options):
    print("\nMenu:")
    for i, option in enumerate(options, 1):
        print(f"{i}. {option}")
    choice = input("Select an option: ")
    return int(choice) if choice.isdigit() and 1 <= int(choice) <= len(options) else None

def list_saved_servers(servers):
    if not servers:
        print("No servers found.")
        return
    for nickname in servers:
        print(nickname)

def list_saved_users(users):
    if not users:
        print("No users found.")
        return
    for username in users:
        print(username)

def list_user_databases(users):
    if not users:
        print("No users found.")
        return None
    for i, username in enumerate(users, 1):
        print(f"{i}. {username}")
    
    choice = input("Select a user to list databases: ")
    if choice.isdigit() and 1 <= int(choice) <= len(users):
        username = list(users.keys())[int(choice) - 1]
        # Placeholder to list databases for the selected user
        print(f"Databases for {username}:")
        # Assume databases are listed here
        databases = ['db1', 'db2', 'db3']  # Replace with actual list of databases
        for i, db in enumerate(databases, 1):
            print(f"{i}. {db}")
        return databases
    else:
        print("Invalid choice.")
        return None

def add_server(servers):
    nickname = input("Enter server nickname: ")
    if nickname in servers:
        print("Nickname already exists.")
        return
    username = input("Enter server username: ")
    dns = input("Enter server DNS: ")
    servers[nickname] = {'username': username, 'dns': dns}
    save_data(SERVERS_FILE, servers)
    print("Server added successfully.")

def edit_server(servers):
    if not servers:
        print("No servers to edit.")
        return
    for i, nickname in enumerate(servers, 1):
        print(f"{i}. {nickname} - {servers[nickname]['username']}:{servers[nickname]['dns']}")
    choice = input("Select a server to edit: ")
    if choice.isdigit() and 1 <= int(choice) <= len(servers):
        nickname = list(servers.keys())[int(choice) - 1]
        username = input(f"Enter new username ({servers[nickname]['username']}): ") or servers[nickname]['username']
        dns = input(f"Enter new DNS ({servers[nickname]['dns']}): ") or servers[nickname]['dns']
        servers[nickname] = {'username': username, 'dns': dns}
        save_data(SERVERS_FILE, servers)
        print("Server edited successfully.")
    else:
        print("Invalid choice.")

def delete_server(servers):
    if not servers:
        print("No servers to delete.")
        return
    for i, nickname in enumerate(servers, 1):
        print(f"{i}. {nickname} - {servers[nickname]['username']}:{servers[nickname]['dns']}")
    choice = input("Select a server to delete: ")
    if choice.isdigit() and 1 <= int(choice) <= len(servers):
        nickname = list(servers.keys())[int(choice) - 1]
        confirm = input(f"Are you sure you want to delete {nickname}? (y/n): ")
        if confirm.lower() == 'y':
            del servers[nickname]
            save_data(SERVERS_FILE, servers)
            print("Server deleted successfully.")
    else:
        print("Invalid choice.")

def add_user(users):
    username = input("Enter username: ")
    if username in users:
        print("Username already exists.")
        return
    password = getpass.getpass("Enter password: ")
    users[username] = password
    save_data(USERS_FILE, users)
    print("User added successfully.")

def edit_user(users):
    if not users:
        print("No users to edit.")
        return
    for i, username in enumerate(users, 1):
        print(f"{i}. {username}")
    choice = input("Select a user to edit: ")
    if choice.isdigit() and 1 <= int(choice) <= len(users):
        username = list(users.keys())[int(choice) - 1]
        password = getpass.getpass(f"Enter new password (leave blank to keep current password): ") or users[username]
        users[username] = password
        save_data(USERS_FILE, users)
        print("User edited successfully.")
    else:
        print("Invalid choice.")

def delete_user(users):
    if not users:
        print("No users to delete.")
        return
    for i, username in enumerate(users, 1):
        print(f"{i}. {username}")
    choice = input("Select a user to delete: ")
    if choice.isdigit() and 1 <= int(choice) <= len(users):
        username = list(users.keys())[int(choice) - 1]
        confirm = input(f"Are you sure you want to delete {username}? (y/n): ")
        if confirm.lower() == 'y':
            del users[username]
            save_data(USERS_FILE, users)
            print("User deleted successfully.")
    else:
        print("Invalid choice.")

def list_users(users):
    if not users:
        print("No users found.")
        return
    for username in users:
        print(username)

def list_server_details(servers):
    if not servers:
        print("No servers found.")
        return
    for nickname, details in servers.items():
        print(f"{nickname} - {details['username']}:{details['dns']}")

def dump_and_transfer_databases(servers, users):
    print("1. Use saved server details")
    print("2. Enter new server details")
    choice = input("Select an option: ")
    
    if choice == '1':
        list_saved_servers(servers)
        server_choice = input("Select a server: ")
        if server_choice.isdigit() and 1 <= int(server_choice) <= len(servers):
            server = servers[list(servers.keys())[int(server_choice) - 1]]
        else:
            print("Invalid choice.")
            return
    elif choice == '2':
        username = input("Enter server username: ")
        dns = input("Enter server DNS: ")
        server = {'username': username, 'dns': dns}
    else:
        print("Invalid choice.")
        return

    list_saved_users(users)
    user_choice = input("Select a user to dump databases: ")
    if user_choice.isdigit() and 1 <= int(user_choice) <= len(users):
        username = list(users.keys())[int(user_choice) - 1]
        databases = list_user_databases(users)
        if databases:
            db_choice = input("Select databases to dump (comma separated or 'all'): ")
            if db_choice.lower() == 'all':
                selected_databases = databases
            else:
                selected_indices = [int(idx.strip()) - 1 for idx in db_choice.split(',') if idx.strip().isdigit()]
                selected_databases = [databases[idx] for idx in selected_indices if 0 <= idx < len(databases)]
            
            destination_path = f"{server['username']}/home/db_backup"
            print(f"Dumping databases {', '.join(selected_databases)} and transferring to {server['dns']} at {destination_path}")
            
            # SSH connection details
            server_password = getpass.getpass(f"Enter SSH password for {server['username']}@{server['dns']}: ")
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            
            try:
                # Connect to the server
                ssh.connect(server['dns'], username=server['username'], password=server_password)
                
                # Loop through selected databases and dump
                for db_name in selected_databases:
                    dump_command = f"mysqldump -u {db_username} -p{db_password} {db_name} > {db_name}.sql"
                    stdin, stdout, stderr = ssh.exec_command(dump_command)
                    stdout_str = stdout.read().decode('utf-8')
                    stderr_str = stderr.read().decode('utf-8')
                    
                    if stderr_str:
                        print(f"Error dumping database {db_name}: {stderr_str}")
                        continue
                    
                    # Transfer the dump file using SCP
                    local_file = f"{db_name}.sql"
                    remote_path = f"{destination_path}/{db_name}.sql"
                    scp_command = f"scp {local_file} {server['username']}@{server['dns']}:{remote_path}"
                    subprocess.run(scp_command, shell=True, check=True)
                    
                    print(f"Database {db_name} dumped and transferred successfully to {server['dns']} at {destination_path}")
                
            except Exception as e:
                print(f"Error: {str(e)}")
            
            finally:
                ssh.close()
        
        else:
            print("No databases found for selected user.")
    else:
        print("Invalid choice.")

def main():
    servers = load_data(SERVERS_FILE)
    users = load_data(USERS_FILE)
    
    while True:
        choice = display_menu(["Servers", "Database Users", "List Databases for User or Users", "List Server Details", "Dump and Transfer Databases", "Exit"])
        
        if choice == 1:
            while True:
                server_choice = display_menu(["Add Server Details", "Edit Server Details", "Delete Server Details", "List Saved Servers", "Back"])
                if server_choice == 1:
                    add_server(servers)
                elif server_choice == 2:
                    edit_server(servers)
                elif server_choice == 3:
                    delete_server(servers)
                elif server_choice == 4:
                    list_saved_servers(servers)
                elif server_choice == 5:
                    break
                else:
                    print("Invalid choice.")
                    
        elif choice == 2:
            while True:
                user_choice = display_menu(["Add User Details", "Edit User Details", "Delete User Details", "List Saved Users", "Back"])
                if user_choice == 1:
                    add_user(users)
                elif user_choice == 2:
                    edit_user(users)
                elif user_choice == 3:
                    delete_user(users)
                elif user_choice == 4:
                    list_saved_users(users)
                elif user_choice == 5:
                    break
                else:
                    print("Invalid choice.")
                    
        elif choice == 3:
            list_users(users)
            
        elif choice == 4:
            list_server_details(servers)
            
        elif choice == 5:
            dump_and_transfer_databases(servers, users)
            
        elif choice == 6:
            print("Exiting script.")
            break
        
        else:
            print("Invalid choice.")

if __name__ == "__main__":
    main()
