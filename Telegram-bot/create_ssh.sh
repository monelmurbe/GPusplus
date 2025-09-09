#!/bin/bash

# =================================================================
#           Skrip Pembuatan Akun SSH untuk Hokage-BOT
#           Disesuaikan dengan Format VPS
# =================================================================

# --- Validasi Input ---
if [ "$#" -ne 4 ]; then
    echo "Error: Input tidak lengkap."
    echo "Penggunaan: $0 <username> <password> <durasi_hari> <limit_ip>"
    exit 1
fi

# --- Inisialisasi Variabel ---
USERNAME=$1
PASSWORD=$2
DURATION=$3
IP_LIMIT=$4

# Validasi durasi adalah angka
if ! [[ "$DURATION" =~ ^[0-9]+$ ]]; then
    echo "Error: Durasi harus berupa angka."
    exit 1
fi

# Hitung tanggal expired dengan format yang konsisten
EXPIRED_DATE=$(date -d "+$DURATION days" +"%Y-%m-%d")
EXPIRED_DISPLAY=$(date -d "+$DURATION days" +"%b %d, %Y")

# --- Cek apakah user sudah ada ---
if id "$USERNAME" &>/dev/null; then
    echo "Error: User '$USERNAME' sudah ada."
    exit 1
fi

# Cek apakah username sudah ada di file /etc/xray/ssh
if grep -q "^### $USERNAME " /etc/xray/ssh; then
    echo "Error: User '$USERNAME' sudah ada di database."
    exit 1
fi

# --- Membuat User di Sistem ---
useradd -e "$EXPIRED_DATE" -s /bin/false -M "$USERNAME"
if [ $? -ne 0 ]; then
    echo "Error: Gagal membuat user '$USERNAME'."
    exit 1
fi
echo -e "$PASSWORD\n$PASSWORD\n" | passwd "$USERNAME" &> /dev/null

# --- Mengambil Informasi Server ---
domain=$(cat /etc/xray/domain 2>/dev/null || echo "not_set")
sldomain=$(cat /etc/xray/dns 2>/dev/null || echo "not_set")
slkey=$(cat /etc/slowdns/server.pub 2>/dev/null || echo "not_set")
ISP=$(cat /etc/xray/isp 2>/dev/null || echo "Unknown")
CITY=$(cat /etc/xray/city 2>/dev/null || echo "Unknown")

# --- Membuat direktori jika belum ada ---
mkdir -p /etc/xray/sshx
mkdir -p /etc/xray/sshx/akun
mkdir -p /home/vps/public_html/

# --- Simpan limit IP ---
echo "$IP_LIMIT" > /etc/xray/sshx/${USERNAME}IP

# --- Membuat File .txt di Web Server ---
cat > /home/vps/public_html/ssh-${USERNAME}.txt <<-END
SSH & OpenVPN Account Details
===============================
Username        : $USERNAME
Password        : $PASSWORD
Expired On      : $EXPIRED_DISPLAY
-------------------------------
Host / Server   : $domain
ISP             : $ISP
City            : $CITY
Login Limit     : $IP_LIMIT IP
-------------------------------
Port Details:
- OpenSSH       : 22
- Dropbear      : 143, 109
- SSH WS        : 80, 8080
- SSH SSL WS    : 443
- SSL/TLS       : 8443, 8880
- OVPN WS SSL   : 2086
- OVPN SSL      : 990
- OVPN TCP      : 1194
- OVPN UDP      : 2200
- BadVPN UDP    : 7100, 7200, 7300
-------------------------------
SlowDNS Details:
- Host SlowDNS  : $sldomain
- Public Key    : $slkey
-------------------------------
OpenVPN Configs:
- OVPN SSL      : http://$domain:89/ssl.ovpn
- OVPN TCP      : http://$domain:89/tcp.ovpn
- OVPN UDP      : http://$domain:89/udp.ovpn
===============================
END

# --- Simpan data user ke /etc/xray/ssh dengan format yang sesuai ---
# Format: ### username expired_date password
echo "### $USERNAME $EXPIRED_DATE $PASSWORD" >> /etc/xray/ssh

# --- Buat direktori kuota jika belum ada ---
KUOTA_DIR="/etc/kuota-ssh"
if [ ! -d "$KUOTA_DIR" ]; then
    mkdir -p "$KUOTA_DIR"
fi

# --- Atur limit kuota ---
DEFAULT_LIMIT_BYTES="5368709120" # 5GB
cat > ${KUOTA_DIR}/${USERNAME} <<-END
USERNAME="${USERNAME}"
STATUS="AKTIF"
LIMIT_BYTES="${DEFAULT_LIMIT_BYTES}"
USAGE_BYTES="0"
END

# --- Membuat log file ---
cat > /etc/xray/sshx/akun/log-create-${USERNAME}.log <<-END
◇━━━━━━━━━━━━━━━━━◇
SSH Premium Account
◇━━━━━━━━━━━━━━━━━◇
Username        :  $USERNAME
Password        :  $PASSWORD
Expired On      :  $EXPIRED_DISPLAY
◇━━━━━━━━━━━━━━━━━◇
ISP             :  $ISP
CITY            :  $CITY
Host            :  $domain
Login Limit     :  ${IP_LIMIT} IP
Port OpenSSH    :  22
Port Dropbear   :  109, 143
Port SSH WS     :  80, 8080
Port SSH SSL WS :  443
Port SSL/TLS    :  8443,8880
Port OVPN WS SSL:  2086
Port OVPN SSL   :  990
Port OVPN TCP   :  1194
Port OVPN UDP   :  2200
Proxy Squid     :  3128
BadVPN UDP      :  7100, 7300, 7300
◇━━━━━━━━━━━━━━━━━◇
SSH UDP VIRAL   : $domain:1-65535@$USERNAME:$PASSWORD
◇━━━━━━━━━━━━━━━━━◇
HTTP COSTUM WS  : $domain:80@$USERNAME:$PASSWORD
◇━━━━━━━━━━━━━━━━━◇
Host Slowdns    :  $sldomain
Port Slowdns    :  80, 443, 53
Pub Key         :  $slkey
◇━━━━━━━━━━━━━━━━━◇
Payload WS/WSS  :
GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]
◇━━━━━━━━━━━━━━━━━◇
OpenVPN SSL     :  http://$domain:89/ssl.ovpn
OpenVPN TCP     :  http://$domain:89/tcp.ovpn
OpenVPN UDP     :  http://$domain:89/udp.ovpn
◇━━━━━━━━━━━━━━━━━◇
Save Link Account: http://$domain:89/ssh-$USERNAME.txt
◇━━━━━━━━━━━━━━━━━◇
END

# --- Menampilkan Output Lengkap untuk Bot Telegram ---
cat << EOF
🎊 SSH Premium Account Created 🎊
━━━━━━━━━━━━━━━━━━━━━━━━━━
📄 Account Info
  ┣ Username   : ${USERNAME}
  ┣ Password   : ${PASSWORD}
  ┣ Host       : ${domain}
  ┗ Expired On : ${EXPIRED_DISPLAY}
━━━━━━━━━━━━━━━━━━━━━━━━━━
🔌 Connection Info
  ┣ ISP        : ${ISP}
  ┣ City       : ${CITY}
  ┣ Limit      : ${IP_LIMIT} Device(s)
  ┣ OpenSSH    : 22
  ┣ Dropbear   : 109, 143
  ┣ SSL/TLS    : 8443, 8880
  ┣ SSH WS     : 80, 8080
  ┣ SSH SSL WS : 443
  ┗ UDPGW      : 7100-7300
━━━━━━━━━━━━━━━━━━━━━━━━━━
🔗 Links & Payloads
  ┣ OVPN TCP : http://${domain}:89/tcp.ovpn
  ┣ OVPN UDP : http://${domain}:89/udp.ovpn
  ┗ OVPN SSL : http://${domain}:89/ssl.ovpn
  
  📋 Payload WS/WSS:
  GET / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf]Connection: upgrade[crlf][crlf]
━━━━━━━━━━━━━━━━━━━━━━━━━━
SlowDNS Nameserver & Key
  ┣ NS    : ${sldomain}
  ┗ Key   : ${slkey}
━━━━━━━━━━━━━━━━━━━━━━━━━━
💾 Save Full Config:
http://${domain}:89/ssh-${USERNAME}.txt
━━━━━━━━━━━━━━━━━━━━━━━━━━
🙏 Terima kasih telah order di Hokage Legend
EOF

# Mengakhiri skrip dengan status sukses
exit 0
