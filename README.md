# 🚀 GENOM SCRIPT VPS INSTALL

Panduan lengkap untuk instalasi **GENOM Script VPS** dengan mudah dan cepat.  
Ikuti langkah-langkah berikut agar instalasi berjalan lancar.

---

## 📌 1. Daftarkan IP VPS
Pastikan **IP VPS yang sudah di-pointing di Cloudflare** didaftarkan terlebih dahulu pada link ijin berikut:  

👉 [Daftar IP di sini](https://github.com/kope12/ijin/blob/main/akses)

---

## ⚡ 2. Install Script GPlus
> **Catatan:** Nama VPS harus sesuai dengan yang sudah didaftarkan di ijin.  

Jalankan perintah berikut di VPS:

```bash
wget -q https://raw.githubusercontent.com/kope12/GPus/refs/heads/main/install \
 && chmod +x install \
 && ./install
```

🔄 3. Update Script

Untuk memperbarui script, jalankan perintah berikut:

```
cd /root
rm update.sh
wget https://raw.githubusercontent.com/kope12/GPus/refs/heads/main/menu/update.sh \
 && chmod +x update.sh \
 && ./update.sh
```

🔐 4. Konfigurasi Port SSH

Setelah instalasi, gunakan port 200 untuk menghindari serangan DDoS yang biasanya menyasar port 22.

Jika ingin tetap menggunakan port 22, edit konfigurasi dengan:

```
nano /etc/ssh/sshd_config
```

## 🤖 5. Install Bot Telegram (Opsional)

Untuk pembuatan akun SSH dan XRAY melalui bot Telegram, silakan ikuti tutorial video berikut:

[![Tonton di YouTube](https://img.youtube.com/vi/EILzYC5Gcz4/0.jpg)](https://youtu.be/EILzYC5Gcz4)
