
CREATE DATABASE IF NOT EXISTS network_logs;

CREATE USER IF NOT EXISTS 'trafficlogger'@'localhost' IDENTIFIED BY 'sinkhole_pass';
GRANT ALL PRIVILEGES ON network_logs.* TO 'trafficlogger'@'localhost';

USE network_logs;

CREATE TABLE IF NOT EXISTS packets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp DATETIME NOT NULL,
    protocol VARCHAR(10) NOT NULL,
    source_ip VARCHAR(45) NOT NULL,
    source_port INT NOT NULL,
    data_hex LONGTEXT NOT NULL,
    meta TEXT
);
