import serial
import time
import sys
import requests
import base64
import io
import struct
from PIL import Image

# --- CONFIGURATION ---
COM_PORT = 'COM15'       # <--- CHECK YOUR PORT
BAUD_RATE = 115200       # <--- MATCHES C CODE
POLL_URL = "https://letsdothis3.app.n8n.cloud/webhook/poll-mail"
CHUNK_SIZE = 2048        # Send 2KB at a time (Safe size)

def process_and_send_image(ser, b64_string):
    print("[Image]: Processing...")
    
    # Strip headers if present
    if "," in b64_string[:50]:
        b64_string = b64_string.split(",", 1)[1]

    try:
        # Decode and Process
        image_data = base64.b64decode(b64_string)
        img = Image.open(io.BytesIO(image_data))
        img = img.resize((128, 160))
        img = img.convert("RGB")
        
        full_buffer = bytearray()
        pixels = list(img.getdata())
        
        # Convert to RGB565
        for r, g, b in pixels:
            # --- SWAPPED R AND B FOR BGR DISPLAY ---
            rgb = ((b & 0xF8) << 8) | ((g & 0xFC) << 3) | (r >> 3)
            
            # Revert to Big Endian (>H) to fix the "Noise/Green" issue
            full_buffer.extend(struct.pack(">H", rgb))
            
        total_size = len(full_buffer)
        print(f"[TX]: Total Image Size: {total_size} bytes")
        
        # --- CHUNKED SENDING ---
        sent_bytes = 0
        while sent_bytes < total_size:
            end_index = min(sent_bytes + CHUNK_SIZE, total_size)
            chunk = full_buffer[sent_bytes:end_index]
            
            ser.write(chunk)
            sent_bytes += len(chunk)
            
            time.sleep(0.05) 
            
            progress = int((sent_bytes / total_size) * 10)
            sys.stdout.write(f"\r[TX]: Sending [{'#' * progress}{'.' * (10-progress)}] {sent_bytes}/{total_size}")
            sys.stdout.flush()

        print("\n[TX]: Image Sent Successfully.")
        
    except Exception as e:
        print(f"\n[Image Error]: {e}")
        send_text(ser, "Img Error")

def send_text(ser, text):
    print(f"[TX]: Sending Text: {text}")
    clean_text = text.replace('\n', ' ').replace('\r', '')
    ser.write(f"{clean_text}\n".encode('utf-8'))

def check_inbox(ser):
    print("[System]: Checking n8n...")
    try:
        response = requests.get(POLL_URL, timeout=10)
        if response.status_code == 200:
            data = response.json()
            b64 = data.get('image_data')
            
            if b64 and len(b64) > 100:
                process_and_send_image(ser, b64)
            elif data.get('content'):
                send_text(ser, data.get('content'))
            else:
                print(f"[System]: Unknown Response")
        else:
            print(f"[System]: Server Error {response.status_code}")
    except Exception as e:
        print(f"[System]: Connection Error: {e}")

def main():
    try:
        ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=0.5)
        print(f"--- Chunked Image Bridge Active on {COM_PORT} ---")

        while True:
            if ser.in_waiting > 0:
                try:
                    line = ser.readline().decode('utf-8', errors='ignore').strip()
                    if "WEBHOOK:ai" in line:
                        print("\n[Button]: User requested update...")
                        check_inbox(ser)
                except Exception:
                    pass
            time.sleep(0.01)

    except KeyboardInterrupt:
        if 'ser' in locals() and ser.is_open: ser.close()
        sys.exit()

if __name__ == "__main__":
    main()