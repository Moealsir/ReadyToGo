import json

# Load data from details.json
with open('details.json', 'r') as file:
    details = json.load(file)

def list_servers():
    for i, server in enumerate(details['servers']):
        print(f"{i + 1}. Nickname: {server['nickname']}, Username: {server['username']}, DNS: {server['dns']}")

def list_users():
    for i, user in enumerate(details['users']):
        print(f"{i + 1}. Username: {user['username']}, Password: {user['password']}")

def list_user_databases():
    for i, user_db in enumerate(details['users_dbs']):
        print(f"{i + 1}. Username: {user_db['username']}, Databases: {', '.join(user_db['databases'])}")

def add_server():
    nickname = input("Enter server nickname: ")
    username = input("Enter server username: ")
    dns = input("Enter server DNS: ")
    details['servers'].append({"nickname": nickname, "username": username, "dns": dns})

def edit_server():
    list_servers()
    server_index = int(input("Select server number to edit: ")) - 1
    if 0 <= server_index < len(details['servers']):
        nickname = input("Enter new nickname: ")
        username = input("Enter new username: ")
        dns = input("Enter new DNS: ")
        details['servers'][server_index] = {"nickname": nickname, "username": username, "dns": dns}
    else:
        print("Invalid selection.")

def delete_server():
    list_servers()
    server_index = int(input("Select server number to delete: ")) - 1
    if 0 <= server_index < len(details['servers']):
        details['servers'].pop(server_index)
    else:
        print("Invalid selection.")

def add_user():
    username = input("Enter new user username: ")
    password = input("Enter new user password: ")
    databases = input("Enter databases (comma separated): ").split(',')
    details['users'].append({"username": username, "password": password})
    details['users_dbs'].append({"username": username, "databases": [db.strip() for db in databases]})

def edit_user_db():
    list_user_databases()
    user_db_index = int(input("Select user number to edit: ")) - 1
    if 0 <= user_db_index < len(details['users_dbs']):
        username = input("Enter new username: ")
        databases = input("Enter new databases (comma separated): ").split(',')
        details['users_dbs'][user_db_index] = {"username": username, "databases": [db.strip() for db in databases]}
    else:
        print("Invalid selection.")

def delete_user_db():
    list_user_databases()
    user_db_index = int(input("Select user number to delete: ")) - 1
    if 0 <= user_db_index < len(details['users_dbs']):
        details['users_dbs'].pop(user_db_index)
    else:
        print("Invalid selection.")

def save_data():
    with open('details.json', 'w') as file:
        json.dump(details, file, indent=4)

def menu():
    while True:
        print("\nMenu:")
        print("1. List servers")
        print("2. List users")
        print("3. List user databases")
        print("4. Add server")
        print("5. Edit server")
        print("6. Delete server")
        print("7. Add user")
        print("8. Edit user database")
        print("9. Delete user database")
        print("10. Exit")
        
        choice = int(input("Enter your choice: "))
        
        if choice == 1:
            list_servers()
        elif choice == 2:
            list_users()
        elif choice == 3:
            list_user_databases()
        elif choice == 4:
            add_server()
        elif choice == 5:
            edit_server()
        elif choice == 6:
            delete_server()
        elif choice == 7:
            add_user()
        elif choice == 8:
            edit_user_db()
        elif choice == 9:
            delete_user_db()
        elif choice == 10:
            save_data()
            break
        else:
            print("Invalid choice. Please try again.")

# Call the menu function to start the script
menu()
