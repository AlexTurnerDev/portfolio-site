\# 🤖 STM32 IoT Personal Assistant ("Jarvis")



!\[Platform](https://img.shields.io/badge/Hardware-STM32\_Nucleo--L476RG-blue)

!\[Stack](https://img.shields.io/badge/Tech-Embedded\_C\_\&\_Python-yellow)

!\[Cloud](https://img.shields.io/badge/Cloud-n8n\_\&\_Telegram\_API-orange)

!\[Protocol](https://img.shields.io/badge/Comms-UART\_\&\_SPI-green)



\*\*Full Documentation:\*\* \[View Final Project Report (PDF)](./Final\_Project\_v2.pdf)



\## 🌐 Project Overview

This project implements a complete \*\*Internet of Things (IoT)\*\* pipeline that enables a users to control embedded hardware via a smartphone. Inspired by "JARVIS," the system allows a user to send text, audio, or image commands via the \*\*Telegram App\*\*, which are processed in the cloud and executed on an \*\*STM32 Microcontroller\*\*.



\*\*Key Capabilities:\*\*

\* \*\*Remote Control:\*\* Turn "Living Room Lights" (LEDs) on/off via chat commands.

\* \*\*Image Streaming:\*\* Receive images sent from Telegram and render them on an ST7735 LCD screen.

\* \*\*Audio Processing:\*\* Converts voice notes into hardware commands via cloud transcription.



---



\## 🛠️ System Architecture

The system utilizes a "Full Stack" engineering approach, connecting a high-level API to low-level hardware registers.



\### \*\*1. The Frontend (User Interface)\*\*

\* \*\*Telegram App:\*\* Acts as the command terminal. Users send messages or files to a custom bot.



\### \*\*2. The Middleware (Cloud \& Logic)\*\*

\* \*\*n8n Automation:\*\* A workflow engine that listens to Telegram Webhooks. It parses text for keywords (e.g., "Light On") and uploads binary image data to \*\*Google Drive\*\*.

\* \*\*Google Sheets:\*\* Acts as a volatile memory buffer to queue commands for the hardware.



\### \*\*3. The Bridge (PC Interface)\*\*

\* \*\*Python Script:\*\* Polls the cloud APIs for new data. When a command is found, it establishes a serial connection (USB-UART) to the microcontroller.



\### \*\*4. The Hardware (Embedded C)\*\*

\* \*\*STM32 Nucleo-L476RG:\*\* The brain of the operation.

&nbsp;   \* \*\*UART (Interrupt-Driven):\*\* Receives command packets and image chunks.

&nbsp;   \* \*\*DMA (Direct Memory Access):\*\* Critical for image rendering. It offloads the massive data transfer (pixel arrays) from the CPU to the SPI bus, allowing the processor to handle logic while the screen draws.

&nbsp;   \* \*\*SPI:\*\* Drives the 1.8" ST7735 GLCD.



---



\## 💻 Technical Highlights



\### \*\*Direct Memory Access (DMA) for Graphics\*\*

Rendering a full-color image via SPI requires sending thousands of bytes. A standard CPU polling method would freeze the system. I implemented \*\*Circular DMA buffers\*\* to stream image data in the background.



```c

// Interrupt Callback: Triggered when a chunk of image data is fully received

void HAL\_UART\_RxCpltCallback(UART\_HandleTypeDef \*huart) {

&nbsp;   if (huart->Instance == USART1) {

&nbsp;       // 1. Process the chunk (Send to Display via SPI)

&nbsp;       DrawImageChunk(rx\_buffer);

&nbsp;       

&nbsp;       // 2. Restart DMA to catch the next packet immediately

&nbsp;       HAL\_UART\_Receive\_DMA(\&huart1, rx\_buffer, CHUNK\_SIZE);

&nbsp;   }

}

