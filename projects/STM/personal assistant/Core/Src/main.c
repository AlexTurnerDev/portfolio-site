/* USER CODE BEGIN Header */
/**
  * @file           : main.c
  * @brief          : Chunk Mode with Offset Correction (Fixes Noisy Edges)
  */
/* USER CODE END Header */

/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "font.h"
#include <string.h>
#include <stdbool.h>
#include <stdio.h>

/* Private define ------------------------------------------------------------*/
#define NUMROWS 160
#define NUMCOLS 128
#define BLACK 0x0000
#define WHITE 0xFFFF
#define BLUE  0xF800
#define GREEN 0x07E0
#define RED   0xF800

// --- ALIGNMENT FIX ---
// Change these if you still see noise or if the image is cut off.
// Common values: (0,0), (2,1), (2,3), or (1,2)
#define X_OFFSET 2
#define Y_OFFSET 1

// Exact size of 128x160 RGB565 image
#define IMAGE_SIZE 40960
#define MAX_BUFFER_SIZE 50000

/* Private variables ---------------------------------------------------------*/
SPI_HandleTypeDef hspi1;
UART_HandleTypeDef huart2;
DMA_HandleTypeDef hdma_usart2_rx;

uint16_t cursor_x = 0;
uint16_t cursor_y = 0;

// Main Buffer
uint8_t message[MAX_BUFFER_SIZE];

// Accumulator Variables
volatile uint32_t total_bytes_received = 0;
volatile bool full_image_ready = false;
volatile bool new_text_ready = false;
volatile bool update_screen_progress = false;

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_DMA_Init(void);
static void MX_USART2_UART_Init(void);
static void MX_SPI1_Init(void);

void ST7735_Init(void);
void ST7735_FillScreen(uint16_t color);
void ST7735_PrintString(char* string);
void ST7735_UpdateCharCursor(uint16_t x, uint16_t y);
void ST7735_DrawImage(uint8_t* imageData, uint32_t size);
void ST7735_DrawPixel(uint8_t x, uint8_t y, uint16_t color);
void ST7735_WriteData(uint8_t data[], uint16_t size);
void ST7735_WriteCommand(uint8_t cmd);
void ST7735_SetAddressWindow(uint16_t xStart, uint16_t yStart, uint16_t xEnd, uint16_t yEnd);

void Send_Webhook_Trigger(char* action);
void Listen_For_Next_Chunk(void);

int main(void)
{
  HAL_Init();
  SystemClock_Config();
  MX_GPIO_Init();
  MX_DMA_Init();
  MX_USART2_UART_Init();
  MX_SPI1_Init();

  ST7735_Init();
  ST7735_FillScreen(BLUE);
  ST7735_UpdateCharCursor(0,0);
  ST7735_PrintString("Program Ready.");

  // Start Listening
  total_bytes_received = 0;
  Listen_For_Next_Chunk();

  int heartbeat = 0;
  char statusBuf[30];

  while (1)
  {
      Send_Webhook_Trigger("poll");

      for(int i=0; i<20; i++) {
          HAL_Delay(100);

          heartbeat = !heartbeat;
          ST7735_DrawPixel(127, 0, heartbeat ? GREEN : BLACK);

          // Progress Update
          if (update_screen_progress) {
              update_screen_progress = false;
              ST7735_UpdateCharCursor(0, 20);
              sprintf(statusBuf, "RX: %lu / %d", total_bytes_received, IMAGE_SIZE);
              ST7735_PrintString(statusBuf);
          }

          // Case A: Full Image
          if (full_image_ready) {
              full_image_ready = false;

              ST7735_UpdateCharCursor(0, 30);
              ST7735_PrintString("Drawing...");

              ST7735_DrawImage(message, IMAGE_SIZE);

              // Reset
              total_bytes_received = 0;
              Listen_For_Next_Chunk();
              break;
          }

          // Case B: Text
          if (new_text_ready) {
              new_text_ready = false;

              if (total_bytes_received < 2000) {
                  message[total_bytes_received] = '\0';

                  if (strstr((char*)message, "LivingRoomLightOn")) {
                      HAL_GPIO_WritePin(GPIOB, LivingRoomLight_Pin, GPIO_PIN_SET);
                      ST7735_FillScreen(BLUE);
                      ST7735_UpdateCharCursor(0,0);
                      ST7735_PrintString("Light ON");
                  }
                  else if (strstr((char*)message, "LivingRoomLightOff")) {
                      HAL_GPIO_WritePin(GPIOB, LivingRoomLight_Pin, GPIO_PIN_RESET);
                      ST7735_FillScreen(BLUE);
                      ST7735_UpdateCharCursor(0,0);
                      ST7735_PrintString("Light OFF");
                  }
                  else {
                      ST7735_FillScreen(BLUE);
                      ST7735_UpdateCharCursor(0,0);
                      ST7735_PrintString("RX: ");
                      ST7735_PrintString((char*)message);
                  }

                  // Reset
                  total_bytes_received = 0;
                  Listen_For_Next_Chunk();
              }
          }

          // Button Check
          if (HAL_GPIO_ReadPin(GPIOC, GPIO_PIN_13) == GPIO_PIN_RESET) {
              ST7735_FillScreen(BLUE);
              ST7735_UpdateCharCursor(0,0);
              ST7735_PrintString("Requesting AI...");

              total_bytes_received = 0;
              Listen_For_Next_Chunk();

              Send_Webhook_Trigger("ai");
              HAL_Delay(500);
          }
      }
  }
}

// --- CALLBACKS ---
void HAL_UARTEx_RxEventCallback(UART_HandleTypeDef *huart, uint16_t Size) {
  if (huart->Instance == USART2) {
      total_bytes_received += Size;
      update_screen_progress = true;

      if (total_bytes_received >= IMAGE_SIZE) {
          full_image_ready = true;
      }
      else {
          if (total_bytes_received < 2000) {
              new_text_ready = true;
          }
          Listen_For_Next_Chunk();
      }
  }
}

void HAL_UART_ErrorCallback(UART_HandleTypeDef *huart) {
    Listen_For_Next_Chunk();
}

void Listen_For_Next_Chunk(void) {
    HAL_UART_AbortReceive(&huart2);
    if (total_bytes_received >= MAX_BUFFER_SIZE) total_bytes_received = 0;
    HAL_UARTEx_ReceiveToIdle_DMA(&huart2, &message[total_bytes_received], MAX_BUFFER_SIZE - total_bytes_received);
}

void Send_Webhook_Trigger(char* action) {
    char cmdBuffer[50];
    sprintf(cmdBuffer, "WEBHOOK:%s\n", action);
    HAL_UART_Transmit(&huart2, (uint8_t*)cmdBuffer, strlen(cmdBuffer), 100);
}

// --- DRIVERS (With Offset Fix) ---

void ST7735_SetAddressWindow(uint16_t xStart, uint16_t yStart, uint16_t xEnd, uint16_t yEnd) {
    // --- APPLY OFFSETS HERE ---
    xStart += X_OFFSET;
    xEnd   += X_OFFSET;
    yStart += Y_OFFSET;
    yEnd   += Y_OFFSET;

    uint8_t address[4];
    ST7735_WriteCommand(0x2A);
    address[0] = xStart >> 8; address[1] = xStart & 0xFF; address[2] = xEnd >> 8; address[3] = xEnd & 0xFF;
    ST7735_WriteData(address, 4);
    ST7735_WriteCommand(0x2B);
    address[0] = yStart >> 8; address[1] = yStart & 0xFF; address[2] = yEnd >> 8; address[3] = yEnd & 0xFF;
    ST7735_WriteData(address, 4);
    ST7735_WriteCommand(0x2C);
}

void ST7735_DrawImage(uint8_t* imageData, uint32_t size) {
    ST7735_SetAddressWindow(0, 0, NUMCOLS - 1, NUMROWS - 1);
    HAL_GPIO_WritePin(DC_GPIO_Port, DC_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(CS_GPIO_Port, CS_Pin, GPIO_PIN_RESET);
    HAL_SPI_Transmit(&hspi1, imageData, size, HAL_MAX_DELAY);
    HAL_GPIO_WritePin(CS_GPIO_Port, CS_Pin, GPIO_PIN_SET);
}

void ST7735_WriteData(uint8_t data[], uint16_t size) {
 HAL_GPIO_WritePin(DC_GPIO_Port, DC_Pin, GPIO_PIN_SET);
 HAL_GPIO_WritePin(CS_GPIO_Port, CS_Pin, GPIO_PIN_RESET);
 HAL_SPI_Transmit(&hspi1, data, size, HAL_MAX_DELAY);
 HAL_GPIO_WritePin(CS_GPIO_Port, CS_Pin, GPIO_PIN_SET);
}
void ST7735_WriteCommand(uint8_t cmd) {
 HAL_GPIO_WritePin(DC_GPIO_Port, DC_Pin, GPIO_PIN_RESET);
 HAL_GPIO_WritePin(CS_GPIO_Port, CS_Pin, GPIO_PIN_RESET);
 HAL_SPI_Transmit (&hspi1, &cmd, 1, HAL_MAX_DELAY);
 HAL_GPIO_WritePin(CS_GPIO_Port, CS_Pin, GPIO_PIN_SET);
}
void ST7735_Init(void) {
 HAL_GPIO_WritePin(RST_GPIO_Port, RST_Pin, GPIO_PIN_RESET);
 HAL_Delay(5);
 HAL_GPIO_WritePin(RST_GPIO_Port, RST_Pin, GPIO_PIN_SET);
 HAL_Delay(5);
 ST7735_WriteCommand(0x01);
 HAL_Delay(150);
 ST7735_WriteCommand(0x11);
 HAL_Delay(150);
 ST7735_WriteCommand(0x3A);
 uint8_t colorMode = 0x05;
 ST7735_WriteData(&colorMode, 1);
 ST7735_WriteCommand(0x36);
 uint8_t accessMode = 0xC8;
 ST7735_WriteData(&accessMode, 1);
 ST7735_WriteCommand(0x29);
 HAL_Delay(10);
}
void ST7735_FillScreen(uint16_t color) {
    ST7735_SetAddressWindow(0, 0, NUMCOLS - 1, NUMROWS - 1);
    for (uint8_t y = 0; y < NUMROWS; y++) {
        for (uint8_t x = 0; x < NUMCOLS; x++) {
             uint8_t pixelData[2] = { color >> 8, color & 0xFF };
             ST7735_WriteData(pixelData, 2);
        }
    }
}
void ST7735_DrawPixel(uint8_t x, uint8_t y, uint16_t color) {
    if ((x >= NUMCOLS) || (y >= NUMROWS)) return;
    ST7735_SetAddressWindow(x, y, x, y);
    uint8_t pixelData[2] = { color >> 8, color & 0xFF };
    ST7735_WriteData(pixelData, 2);
}
void ST7735_UpdateCharCursor(uint16_t x, uint16_t y){
 cursor_x = x; cursor_y = y;
}
void ST7735_PrintChar(char character) {
 if ((character < ' ') || (character > '~')) return;
 int fontIndex = character - 0x20;
 const uint8_t* characterData = fontTable[fontIndex];
 ST7735_SetAddressWindow(cursor_x, cursor_y, cursor_x + 7, cursor_y + 7);
 for (int row = 0; row < 8; row++) {
   uint8_t rowData = characterData[row];
   for (int col = 7; col >= 0; col--) {
     uint16_t color = (rowData & (1 << col)) ? BLACK : WHITE;
     uint8_t pixelData[2] = { color >> 8, color & 0xFF };
     ST7735_WriteData(pixelData, 2);
   }
 }
 cursor_x += 8;
 if(cursor_x > NUMCOLS-8) { cursor_x = 0; cursor_y += 8; }
}
void ST7735_PrintString(char* string) {
 for (int i = 0; string[i] != '\0'; i++) ST7735_PrintChar(string[i]);
}

// BOILERPLATE (Ensure match)
void SystemClock_Config(void) {
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};
  HAL_PWREx_ControlVoltageScaling(PWR_REGULATOR_VOLTAGE_SCALE1);
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
  RCC_OscInitStruct.PLL.PLLM = 1;
  RCC_OscInitStruct.PLL.PLLN = 10;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV7;
  RCC_OscInitStruct.PLL.PLLQ = RCC_PLLQ_DIV2;
  RCC_OscInitStruct.PLL.PLLR = RCC_PLLR_DIV2;
  HAL_RCC_OscConfig(&RCC_OscInitStruct);
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK|RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;
  HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_4);
}
static void MX_SPI1_Init(void) {
  hspi1.Instance = SPI1;
  hspi1.Init.Mode = SPI_MODE_MASTER;
  hspi1.Init.Direction = SPI_DIRECTION_2LINES;
  hspi1.Init.DataSize = SPI_DATASIZE_8BIT;
  hspi1.Init.CLKPolarity = SPI_POLARITY_LOW;
  hspi1.Init.CLKPhase = SPI_PHASE_1EDGE;
  hspi1.Init.NSS = SPI_NSS_SOFT;
  hspi1.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_4;
  hspi1.Init.FirstBit = SPI_FIRSTBIT_MSB;
  hspi1.Init.TIMode = SPI_TIMODE_DISABLE;
  hspi1.Init.CRCCalculation = SPI_CRCCALCULATION_DISABLE;
  hspi1.Init.NSSPMode = SPI_NSS_PULSE_ENABLE;
  HAL_SPI_Init(&hspi1);
}
static void MX_USART2_UART_Init(void) {
  huart2.Instance = USART2;
  huart2.Init.BaudRate = 115200;
  huart2.Init.WordLength = UART_WORDLENGTH_8B;
  huart2.Init.StopBits = UART_STOPBITS_1;
  huart2.Init.Parity = UART_PARITY_NONE;
  huart2.Init.Mode = UART_MODE_TX_RX;
  huart2.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart2.Init.OverSampling = UART_OVERSAMPLING_16;
  huart2.Init.OneBitSampling = UART_ONE_BIT_SAMPLE_DISABLE;
  HAL_UART_Init(&huart2);
}
static void MX_DMA_Init(void) {
  __HAL_RCC_DMA1_CLK_ENABLE();
  HAL_NVIC_SetPriority(DMA1_Channel6_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA1_Channel6_IRQn);
}
static void MX_GPIO_Init(void) {
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();
  HAL_GPIO_WritePin(GPIOA, RST_Pin|DC_Pin, GPIO_PIN_RESET);
  HAL_GPIO_WritePin(GPIOB, LivingRoomLight_Pin|CS_Pin, GPIO_PIN_RESET);
  GPIO_InitStruct.Pin = GPIO_PIN_13;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);
  GPIO_InitStruct.Pin = RST_Pin|DC_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
  GPIO_InitStruct.Pin = LivingRoomLight_Pin|CS_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);
}
void Error_Handler(void) { __disable_irq(); while (1) {} }
