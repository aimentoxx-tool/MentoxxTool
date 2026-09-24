#!/data/data/com.termux/files/usr/bin/bash
set -e

clear
printf '\033[38;5;208m'
cat <<'BANNER'
╔════════════════════════════════════╗
║          MENTOXXTOOL               ║
║          INSTALLER                 ║
╚════════════════════════════════════╝
BANNER
printf '\033[0m\n'

echo "[+] Installing packages..."
pkg update -y
pkg install -y python android-tools unzip

TOOL="$HOME/mentoxxtool"
mkdir -p "$TOOL"

cat > "$TOOL/mentoxx.py" <<'PY'
#!/data/data/com.termux/files/usr/bin/python3
import os
import time
import subprocess
import shutil

ORANGE="\033[38;5;208m"
CYAN="\033[96m"
GREEN="\033[92m"
RED="\033[91m"
YELLOW="\033[93m"
RESET="\033[0m"

def clear():
    os.system("clear")

def run(command):
    try:
        return subprocess.check_output(
            command, shell=True, stderr=subprocess.STDOUT, text=True
        ).strip()
    except Exception:
        return ""

def pause():
    input("\nPress ENTER to continue...")

def banner():
    for text in ["M", "ME", "MEN", "MENT", "MENTO", "MENTOX", "MENTOXX", "MENTOXXTOOL"]:
        clear()
        print(ORANGE + "╔════════════════════════════════════╗" + RESET)
        print(ORANGE + "║                                    ║" + RESET)
        print(ORANGE + "║       " + CYAN + text.center(16) + ORANGE + "       ║" + RESET)
        print(ORANGE + "║                                    ║" + RESET)
        print(ORANGE + "╚════════════════════════════════════╝" + RESET)
        time.sleep(0.08)

def device_info():
    clear()
    print(ORANGE + "=== DEVICE INFORMATION ===" + RESET)
    print()
    if not shutil.which("adb"):
        print(RED + "ADB is not installed." + RESET)
        pause()
        return

    if "\tdevice" not in run("adb devices"):
        print(RED + "No authorized ADB device found." + RESET)
        print("Enable USB debugging and authorize the computer.")
        pause()
        return

    props = {
        "Brand": "ro.product.brand",
        "Manufacturer": "ro.product.manufacturer",
        "Model": "ro.product.model",
        "Device": "ro.product.device",
        "Android": "ro.build.version.release",
        "SDK": "ro.build.version.sdk",
        "Build": "ro.build.display.id",
    }
    for name, prop in props.items():
        print(CYAN + f"{name:<15}" + RESET + ": " + run("adb shell getprop " + prop))
    pause()

def adb_tools():
    while True:
        clear()
        print(ORANGE + "=== ADB TOOLS ===" + RESET)
        print("\n1  Check Device\n2  Reboot Device\n3  Battery\n4  Storage\n5  ADB Shell\nb  Back\n")
        choice = input("Choice › ").lower().strip()

        if choice == "1":
            clear()
            print(run("adb devices"))
            pause()
        elif choice == "2":
            clear()
            if input("Reboot device? [y/N] › ").lower() == "y":
                os.system("adb reboot")
                print(GREEN + "Reboot command sent." + RESET)
            pause()
        elif choice == "3":
            clear()
            print(run("adb shell dumpsys battery"))
            pause()
        elif choice == "4":
            clear()
            print(run("adb shell df -h /data"))
            pause()
        elif choice == "5":
            clear()
            print("Type 'exit' to return.")
            os.system("adb shell")
        elif choice == "b":
            return

def mi_assistant():
    clear()
    print(ORANGE + "=== MI ASSISTANT ===" + RESET)
    print()
    props = {
        "Model": "ro.product.model",
        "MIUI": "ro.miui.ui.version.name",
        "HyperOS": "ro.mi.os.version.name",
        "Android": "ro.build.version.release",
        "Region": "ro.product.locale",
    }
    for name, prop in props.items():
        value = run("adb shell getprop " + prop) or "Not available"
        print(CYAN + f"{name:<12}" + RESET + ": " + value)
    print("\nADB State:", run("adb get-state"))
    pause()

def firmware_extractor():
    clear()
    print(ORANGE + "=== FIRMWARE ZIP EXTRACTOR ===" + RESET)
    print()
    path = os.path.expanduser(input("Firmware ZIP path › ").strip())
    if not os.path.isfile(path):
        print(RED + "File not found." + RESET)
        pause()
        return
    if not path.lower().endswith(".zip"):
        print(RED + "Only ZIP files are supported." + RESET)
        pause()
        return
    output = os.path.expanduser(input("Output folder [firmware_extracted] › ").strip() or "firmware_extracted")
    os.makedirs(output, exist_ok=True)
    print("\n[+] Extracting...")
    result = subprocess.run(["unzip", "-o", path, "-d", output])
    print(GREEN + "Extraction completed!" + RESET if result.returncode == 0 else RED + "Extraction failed." + RESET)
    print("Location:", output)
    pause()

def unlock_status():
    clear()
    print(ORANGE + "=== UNLOCK STATUS ===" + RESET)
    print()
    state = run("adb get-state")
    if state != "device":
        print(RED + "No authorized ADB device." + RESET)
        pause()
        return
    locked = run("adb shell getprop ro.boot.flash.locked")
    verified = run("adb shell getprop ro.boot.verifiedbootstate")
    print(CYAN + "ADB State" + RESET + ":", state)
    print(CYAN + "Flash Locked" + RESET + ":", locked or "Unknown")
    print(CYAN + "Verified Boot" + RESET + ":", verified or "Unknown")
    print("\n" + YELLOW + "Status checking only. Manufacturer authorization is not bypassed." + RESET)
    pause()

def menu():
    while True:
        clear()
        print(ORANGE + "╔════════════════════════════════════╗" + RESET)
        print(ORANGE + "║          MENTOXXTOOL               ║" + RESET)
        print(ORANGE + "╚════════════════════════════════════╝" + RESET)
        print("\n1  Device Information\n2  ADB Tools\n3  Mi Assistant\n4  Firmware Extractor\n5  Unlock Status\n\nq  Quit\n")
        choice = input("Choice › ").lower().strip()
        if choice == "1":
            device_info()
        elif choice == "2":
            adb_tools()
        elif choice == "3":
            mi_assistant()
        elif choice == "4":
            firmware_extractor()
        elif choice == "5":
            unlock_status()
        elif choice == "q":
            clear()
            print(CYAN + "MENTOXXTOOL closed." + RESET)
            return
        else:
            print(RED + "Invalid choice." + RESET)
            time.sleep(1)

banner()
menu()
PY

chmod +x "$TOOL/mentoxx.py"

cat > "$PREFIX/bin/mentoxxtool" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec python "$HOME/mentoxxtool/mentoxx.py"
EOF
chmod +x "$PREFIX/bin/mentoxxtool"

clear
echo "╔════════════════════════════════════╗"
echo "║     MENTOXXTOOL INSTALLED!        ║"
echo "╚════════════════════════════════════╝"
echo
echo "Run:"
echo "    mentoxxtool"
