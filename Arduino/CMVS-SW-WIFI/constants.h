#define RD_WIDTH 32
#define DLY 500
#define DATA_CH 1
#define STATUS_CH 2

#define N_SENSORS 9
#define BUFLEN 2
#define CMVS_INTEGRATION TSL2591_INTEGRATIONTIME_100MS
#define CMVS_GAIN TSL2591_GAIN_LOW
#define LUX_MODE 0b1000
#define LUM_MODE 0b0100
#define IR_MODE 0b0010
#define VIS_MODE 0b0001
#define FULL_MODE 0b0000

#define T_SCANNING_ON 50
#define T_SCANNING_OFF 100
#define T_STUCK_ON 4000
#define T_STUCK_OFF 4000
#define T_PROCESSING_ON 10
#define T_PROCESSING_OFF 1000
#define LED_PIN 19
// #define LED_PIN LED_BUILTIN

#define SDA_E  17
#define SDA_SE 14
#define SDA_S  12
#define SDA_SW 11
#define SDA_W   8
#define SDA_C   7
#define SDA_NW  4
#define SDA_N   2
#define SDA_NE 21

#define SCL_E  16
#define SCL_SE 15
#define SCL_S  13
#define SCL_SW 10
#define SCL_W   9
#define SCL_C   6
#define SCL_NW  5
#define SCL_N   3
#define SCL_NE 20
