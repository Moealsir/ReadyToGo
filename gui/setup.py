import subprocess
import sys
import tkinter as tk
from tkinter import messagebox

# Function to check if Tkinter is installed
def check_tkinter():
    try:
        import tkinter
    except ImportError:
        print("Tkinter is not installed. Installing Tkinter...")
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'tk'])
        try:
            import tkinter
        except ImportError:
            print("Failed to install Tkinter. Please install it manually.")
            sys.exit(1)

# Define available functions
functions = {
    'update_and_upgrade': 'Update and Upgrade System',
    'install_nodejs_npm': 'Install Node.js and npm',
    'install_pm2': 'Install PM2',
    'add_swap': 'Add Swap Space',
    'install_mysql': 'Install MySQL',
    'copy_dir_navigator': 'Copy dir_navigator.sh',
    'add_authorized_keys': 'Add Authorized Keys',
    'add_to_bashrc': 'Add to ~/.bashrc',
    'add_github_credentials': 'Add GitHub Credentials',
    'install_nginx': 'Install Nginx'
}

def run_function(func_name):
    try:
        result = subprocess.run(["bash", f"{func_name}.sh"], capture_output=True, text=True)
        print(result.stdout)
        if result.stderr:
            print(result.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Error running {func_name}: {e}")

def run_selected_functions():
    selected_funcs = [func for func, var in checkboxes.items() if var.get()]
    for func in selected_funcs:
        run_function(func)

def on_apply():
    run_selected_functions()
    messagebox.showinfo("Info", "Selected functions have been executed.")

# Check and install Tkinter if not available
check_tkinter()

# Create GUI window
root = tk.Tk()
root.title("Tool Selection")

# Create checkboxes for each function
checkboxes = {}
for func_name, func_desc in functions.items():
    var = tk.BooleanVar()
    chk = tk.Checkbutton(root, text=func_desc, variable=var)
    chk.pack(anchor='w')
    checkboxes[func_name] = var

# Apply button
apply_button = tk.Button(root, text="Apply", command=on_apply)
apply_button.pack(pady=10)

# Start the GUI event loop
root.mainloop()
