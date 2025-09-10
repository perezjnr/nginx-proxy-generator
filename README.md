# Nginx Proxy Generator Script

A lightweight Bash script for generating Nginx reverse proxy configuration files without the overhead of full UI-based solutions.

This script was created to provide more **direct control over Nginx reverse proxy configuration**, especially for users who prefer or require CLI-driven workflows. While tools like **Nginx Proxy Manager** offer a great web interface, this script focuses on direct file manipulation and scripting flexibility. The long-term goal is to also offer a web interface that complements the CLI by writing and editing configuration files directly.

---

## 🚀 Features

- Interactive menu-based or CLI usage
- Create or remove Nginx proxy site configurations
- Displays current Nginx version and directories
- Performs syntax validation on config before enabling
- Automatically restarts Nginx if changes are applied
- Works well for self-hosted apps behind firewalls, DMZs, or internal networks

---
## ✅ Prerequisites
These neccessary application can be installed by the script if not installed already
- Tested on **Ubuntu 24.04 LTS**, but compatible with other Debian-based systems.
- **Nginx**.
- **CertBot**
- **Netcat**
## 📥 Downloading the latest release
   ```sh
    wget https://github.com/perezjnr/nginx-proxy-generator/releases/download/latest/nginx-proxy-generator.tar.gz
    tar -xzf nginx-proxy-generator.tar.gz && cd nginx-proxy-generator
    sudo chmod +x main.sh
   ```
To install Nginx Manually(script can auto install):

```bash
sudo apt update
sudo apt install nginx
```

---
## ⚙️ How It Works

1. Checks if Nginx is installed.
2. Confirms the existence of `/etc/nginx/sites-available` and `/etc/nginx/sites-enabled`.
3. Prompts the user for required values:
   - Port to listen on
   - Domain name
   - Internal IP address of web app
4. Creates a configuration file in `sites-available`.
5. Validates configuration using `nginx -t`.
6. Enables the site by linking it to `sites-enabled`.
7. Restarts Nginx and confirms success.

> **Note:** Existing files with the same name will be overwritten.

---

## 📘 Menu Interface

Run the script without arguments to access the interactive menu:

```bash
sudo ./main.sh
```

### Menu Options

| Option | Description                                  |
|--------|----------------------------------------------|
| 1      | Add a new website configuration              |
| 2      | Remove an existing website configuration     |
| 3      | Display usage information                    |
| 4      | Display script information                   |
| 5      | Display current Nginx version                |
| 6      | Show Nginx `sites-available` directory path  |
| 7      | Show Nginx `sites-enabled` directory path    |
| 8      | Request new SSL certificate                  |
| 9      | Exit                                          |

---

## 🖥️ CLI Options

You can run specific actions directly from the command line:

```bash
sudo ./main.sh [option]
```

### Supported Flags

| Short Flag | Long Flag           | Description                                      |
|------------|---------------------|--------------------------------------------------|
| `-a`       | `--add`             | Add a new website configuration                  |
| `-r`       | `--remove`          | Remove an existing website configuration         |
| `-h`       | `--help`            | Display help/usage information                   |
| `-i`       | `--info`            | Show detailed script information                 |
| `-v`       | `--version`         | Display current installed Nginx version          |
| `-s`       | `--sites-available` | Show `sites-available` directory path            |
| '-c'       | '--certbot'         | Request new SSL certificate                      |
| `-e`       | `--sites-enabled`   | Show `sites-enabled` directory path              |

> Example:
> ```bash
> sudo ./main.sh --add
> ```

---

## 📌 Example Use Case

You're running a self-hosted app on `192.168.1.100:5000` and want to serve it externally at `http://app.example.com`.

### What you want:

- External visitors reach `app.example.com`
- Internally it goes to `192.168.1.100:5000`
- Proxy should listen on default HTTP port (80)

### What to do:

```bash
sudo ./main.sh --add
```

Then when prompted, enter:

- **Listen Port**: `80`
- **Domain Name**: `app.example.com`
- **Internal IP**: `192.168.1.100`
- **Internal Port**: `5000`

This will:

- Generate a reverse proxy config
- Link it to `sites-enabled`
- Confirm if you want SSL cert and it will automatically request for **Lets Encrypt** certificate using certbot 
- Reload Nginx

You're now live with a fully functional reverse proxy.

---

## 🎯 Future Plans

Features that may be added soon:

```txt
- Web interface (optional) to accompany CLI tool
- Improve SSL support for existing http sites
- Backup/restore of existing configurations
- Access logging, better validation and conflict checks
- Modular plugin-like add-ons (e.g., rate limiting, headers, etc.)
```

---

## 🧑‍💻 Contributing

Pull requests and suggestions are welcome! Feel free to fork this repo and propose new features or improvements.

---

## 📄 License

MIT

---

## 🙏 Acknowledgements

Inspired by Nginx Proxy Manager and the need for low-footprint CLI-based tools in self-hosted environments.
