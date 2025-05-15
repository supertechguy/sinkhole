
import asyncio
import ssl
import binascii
import pymysql
from datetime import datetime

DB_CONFIG = {
    'host': 'localhost',
    'user': 'trafficlogger',
    'password': 'sinkhole_pass',
    'database': 'network_logs',
}

TCP_PORT = 4433
UDP_PORT = 4433
CERT_FILE = 'cert.pem'
KEY_FILE = 'key.pem'

def log_to_db(protocol, source_ip, source_port, data, metadata=""):
    try:
        hex_data = binascii.hexlify(data).decode()
        conn = pymysql.connect(**DB_CONFIG)
        with conn.cursor() as cursor:
            cursor.execute(
                "INSERT INTO packets (timestamp, protocol, source_ip, source_port, data_hex, meta) VALUES (NOW(), %s, %s, %s, %s, %s)",
                (protocol, source_ip, source_port, hex_data, metadata)
            )
            conn.commit()
        conn.close()
    except Exception as e:
        print(f"[DB ERROR] {e}")

async def handle_tcp(reader, writer):
    peer = writer.get_extra_info('peername')
    start_time = datetime.utcnow()
    try:
        peek = await reader.read(4)
        if peek.startswith(b'\x16\x03'):
            ssl_ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
            ssl_ctx.load_cert_chain(certfile=CERT_FILE, keyfile=KEY_FILE)
            ssl_reader, ssl_writer = await asyncio.open_connection(
                ssl=ssl_ctx, sock=writer.get_extra_info('socket'), server_side=True
            )
            data = await ssl_reader.read(4096)
            duration = (datetime.utcnow() - start_time).total_seconds()
            log_to_db('TCP-TLS', peer[0], peer[1], data, f"duration={duration}")
            ssl_writer.close()
            await ssl_writer.wait_closed()
        else:
            data = peek + await reader.read(4096)
            duration = (datetime.utcnow() - start_time).total_seconds()
            log_to_db('TCP-PLAIN', peer[0], peer[1], data, f"duration={duration}")
    except Exception as e:
        print(f"[TCP ERROR] {e}")
    finally:
        writer.close()
        await writer.wait_closed()

class UDPServer(asyncio.DatagramProtocol):
    def datagram_received(self, data, addr):
        log_to_db('UDP', addr[0], addr[1], data)

async def main():
    loop = asyncio.get_running_loop()
    tcp_server = await asyncio.start_server(handle_tcp, '0.0.0.0', TCP_PORT)
    udp_transport, _ = await loop.create_datagram_endpoint(
        lambda: UDPServer(), local_addr=('0.0.0.0', UDP_PORT)
    )
    print(f"Listening on TCP/UDP {TCP_PORT}")
    async with tcp_server:
        await tcp_server.serve_forever()

if __name__ == '__main__':
    asyncio.run(main())
