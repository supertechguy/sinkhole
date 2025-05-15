
# Sinkhole

**Sinkhole** is a passive network traffic logger that captures **all external TCP and UDP traffic**, detects **TLS handshakes**, decrypts initial payloads if applicable, and logs all data in **hexadecimal format** to a **MySQL database**. Sinkhole runs silently, with zero application-layer response to clients, and is ideal for research, monitoring, and honeypot deployment.

---

## 🔒 Features

- ✅ Captures all incoming TCP and UDP traffic using `iptables`
- ✅ Performs TLS handshakes when initiated by client
- ✅ Logs decrypted and plaintext payloads to MySQL in **hex**
- ✅ Records connection metadata such as IP, port, and connection duration
- ✅ Runs as a hardened `systemd` service
- ✅ Includes one-click installer with TLS certificate prompt
- ✅ Excludes SSH (22), MySQL (3306), and localhost traffic by default

---

## 📦 Requirements

- Python 3.7+
- MySQL Server
- Python packages:
  - `pymysql`
  - `pyOpenSSL`
- Linux OS with `iptables` and `systemd`

---

## 📁 Repository Structure

This repository contains:

- `traffic_logger.py` — Main Python listener
- `iptables_setup.sh` — Applies iptables redirection rules
- `mysql_setup.sql` — Initializes MySQL database and table
- `cert.pem`, `key.pem` — Optional self-signed TLS cert (can be regenerated)
- `sinkhole.service` — systemd unit file
- `install_sinkhole.sh` — One-click setup script
- `README.md` — This file

---

## ⚙️ Installation

### 1. Clone the Repository

```bash
git clone https://github.com/supertechguy/sinkhole.git
cd sinkhole
```

### 2. Run the Installer

```bash
chmod +x install_sinkhole.sh
sudo ./install_sinkhole.sh
```

---

## 🛠️ What the Installer Does

The `install_sinkhole.sh` script performs the following:

1. Prompts you to **generate a new self-signed TLS certificate**
2. **Copies all files** to `/opt/sinkhole/`
3. **Creates and configures the MySQL database**
4. **Applies `iptables` rules** to redirect all non-local, non-SSH/MySQL traffic to Sinkhole
5. **Installs and enables** the `sinkhole.service` to run on boot

---

## 🧪 Example Use Cases

- 🕵️ **Honeypot Detection**: Monitor attackers scanning your network or probing services.
- 🧪 **Threat Research**: Observe real-world exploit attempts and malware behavior.
- 🔍 **Network Audit**: Capture unauthorized or unexpected traffic in segmented environments.
- 📉 **Silent Failover**: Track service traffic when primary services are unavailable.

---

## 🗃️ MySQL Schema

```sql
CREATE DATABASE network_logs;

CREATE USER 'trafficlogger'@'localhost' IDENTIFIED BY 'sinkhole_pass';
GRANT ALL PRIVILEGES ON network_logs.* TO 'trafficlogger'@'localhost';

USE network_logs;

CREATE TABLE packets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp DATETIME NOT NULL,
    protocol VARCHAR(10) NOT NULL,
    source_ip VARCHAR(45) NOT NULL,
    source_port INT NOT NULL,
    data_hex LONGTEXT NOT NULL,
    meta TEXT
);
```

---

## 📋 Log Entry Example

| timestamp           | protocol  | source_ip     | source_port | meta              |
|---------------------|-----------|----------------|-------------|-------------------|
| 2025-05-14 15:30:11 | TCP-TLS   | 192.168.1.45   | 59733       | duration=0.22     |

Payloads are stored in `data_hex` as a full hexadecimal dump of the incoming packet data.

---

## 📜 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.  
See `LICENSE` for full terms.

---

## 💬 Questions or Feedback?

Please open an issue or discussion at:  
👉 [github.com/supertechguy/sinkhole/issues](https://github.com/supertechguy/sinkhole/issues)

Pull requests are welcome!

---

