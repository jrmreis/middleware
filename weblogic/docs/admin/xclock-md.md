# xclock / X11 — Display Configuration for WebLogic GUI Tools

Guide to setting up X11 forwarding and graphical display for running WebLogic GUI tools (Configuration Wizard, Admin Console) on headless Linux servers.

---

## 📋 Prerequisites

- SSH client with X11 forwarding support (e.g., MobaXterm, PuTTY + Xming, or native Linux/macOS)
- `xorg-x11-apps` or `x11-apps` package installed on the server
- `xclock` available to test the display

---

## 🔧 Install xclock (if missing)

```bash
# Oracle Linux / RHEL / CentOS
sudo yum install xorg-x11-apps -y

# Ubuntu / Debian
sudo apt-get install x11-apps -y
```

---

## 🖥️ Enable X11 Forwarding via SSH

### On the server — edit `/etc/ssh/sshd_config`:
```bash
X11Forwarding yes
X11DisplayOffset 10
X11UseLocalhost yes
```

Restart SSH:
```bash
sudo systemctl restart sshd
```

### Connect from client with X11 forwarding:
```bash
ssh -X user@<server_host>
# or trusted forwarding:
ssh -Y user@<server_host>
```

---

## ✅ Test the Display

After connecting via SSH with X11:

```bash
echo $DISPLAY        # Should return something like: localhost:10.0
xclock               # A clock window should appear on your local screen
```

If `xclock` opens, your X11 display is working correctly.

---

## 🚀 Run WebLogic GUI Tools

### Configuration Wizard
```bash
export DISPLAY=localhost:10.0   # adjust if needed
cd $ORACLE_HOME/oracle_common/common/bin
./config.sh
```

### Fusion Middleware Control (if applicable)
```bash
export DISPLAY=localhost:10.0
cd $DOMAIN_HOME/bin
./startEMServer.sh
```

---

## 🛠️ Troubleshooting

| Problem | Solution |
|---|---|
| `cannot connect to X server` | Check `$DISPLAY` is set; reconnect with `ssh -X` |
| `xclock` doesn't open | Verify `X11Forwarding yes` in `sshd_config` |
| Slow rendering | Use `ssh -Y` (trusted) instead of `ssh -X` |
| No `$DISPLAY` after su | Run `xauth merge ~/.Xauthority` as target user |

### Manual DISPLAY export
```bash
export DISPLAY=:0.0
# or for remote forwarding:
export DISPLAY=<client_ip>:0.0
```

---

## 📌 Notes

- Prefer `-Y` (trusted forwarding) in controlled environments for better performance
- On Oracle Linux 8+, you may need to install `xorg-x11-xauth` separately
- X11 is only needed for GUI-based setup; all runtime admin can be done via console or WLST
