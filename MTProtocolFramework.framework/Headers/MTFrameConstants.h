//
//  MTFrameConstants.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/23/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

// sizes of protocol datatypes in bytes
#define SIZE_UINT8      1
#define SIZE_UINT16     2
#define SIZE_UINT32     4
#define SIZE_FLOAT      4

//Specifies if frame is a request or a response
#define EN_FRAME_TYPE_REQUEST       0x03
#define EN_FRAME_TYPE_RESPONSE      0x00

//Specifies the format of the frame (SHORT, LONG or EXTENDED)
#define EN_FRAME_FORMAT_LONG        0 //0b00
#define EN_FRAME_FORMAT_SHORT       1 //0b01
#define EN_FRAME_FORMAT_EXT         2 //0b10
#define EN_FRAME_FORMAT_RESERVED    3 //0b11 //Also implemented to avoid invalid array access when 2Bit-Field has wrong value

#define EN_RCV_STATE_INIT           0
#define EN_RCV_STATE_MODE           1
#define EN_RCV_STATE_STATUS         2
#define EN_RCV_STATE_CMD            3
#define EN_RCV_STATE_SIZE_LSB       4
#define EN_RCV_STATE_SIZE_MSB       5
#define EN_RCV_STATE_DATA           6
#define EN_RCV_STATE_CRC_LSB        7
#define EN_RCV_STATE_CRC_MSB        8
#define EN_RCV_STATE_ERROR          9


// Enumeration for ui3ComStatus field of status word
#define EN_COMM_STATUS_SUCCESS 0
#define EN_COMM_STATUS_TIMEOUT 1
#define EN_COMM_STATUS_MODE_NOT_SUPPORTED_OR_INVALID 2
#define EN_COMM_STATUS_CHECKSUM_ERROR 3
#define EN_COMM_STATUS_CMD_UNKONWN 4
#define EN_COMM_STATUS_ACCESS_DENIED 5
#define EN_COMM_STATUS_PARAM_OR_DATA_ERROR 6

//Specifies the format of the request and response frame for one message exchange.
//Used for assignments to unionFrameMode; which abstracts the Mode-Byte of the frame.
//Bit 1..0	Response frame format
//Bit 3..2	Request frame format
//Bit 5..4	reserved
//Bit 7..6	Frame type: 00=response; 11=request; others=invalid. For master always TYPE_REQUEST
//Field partitions:                               REQUEST FORMAT          |    RESPONSE FORMAT    |     FRAME_TYPE_REQUEST
#define EN_FRAME_MODE_SHORT_REQ_SHORT_RESP      (EN_FRAME_FORMAT_SHORT << 2) | EN_FRAME_FORMAT_SHORT | (EN_FRAME_TYPE_REQUEST << 6)
#define EN_FRAME_MODE_SHORT_REQ_LONG_RESP       (EN_FRAME_FORMAT_SHORT << 2) | EN_FRAME_FORMAT_LONG  | (EN_FRAME_TYPE_REQUEST << 6)
#define EN_FRAME_MODE_SHORT_REQ_EXT_RESP        (EN_FRAME_FORMAT_SHORT << 2) | EN_FRAME_FORMAT_EXT   | (EN_FRAME_TYPE_REQUEST << 6)
#define EN_FRAME_MODE_LONG_REQ_SHORT_RESP       (EN_FRAME_FORMAT_LONG  << 2) | EN_FRAME_FORMAT_SHORT | (EN_FRAME_TYPE_REQUEST << 6)
#define EN_FRAME_MODE_LONG_REQ_LONG_RESP        (EN_FRAME_FORMAT_LONG  << 2) | EN_FRAME_FORMAT_LONG  | (EN_FRAME_TYPE_REQUEST << 6)
#define EN_FRAME_MODE_LONG_REQ_EXT_RESP         (EN_FRAME_FORMAT_LONG  << 2) | EN_FRAME_FORMAT_EXT   | (EN_FRAME_TYPE_REQUEST << 6)
#define EN_FRAME_MODE_EXT_REQ_SHORT_RESP        (EN_FRAME_FORMAT_EXT   << 2) | EN_FRAME_FORMAT_SHORT | (EN_FRAME_TYPE_REQUEST << 6)
#define EN_FRAME_MODE_EXT_REQ_LONG_RESP         (EN_FRAME_FORMAT_EXT   << 2) | EN_FRAME_FORMAT_LONG  | (EN_FRAME_TYPE_REQUEST << 6)
#define EN_FRAME_MODE_EXT_REQ_EXT_RESP          (EN_FRAME_FORMAT_EXT   << 2) | EN_FRAME_FORMAT_EXT   | (EN_FRAME_TYPE_REQUEST << 6)

//=== Request  ===
#define EN_TX_FIFO_OFFSET_REQ_MODE      0
#define EN_TX_FIFO_OFFSET_REQ_CMD       1
#define EN_TX_FIFO_OFFSET_REQ_SIZE_LSB  2
#define EN_TX_FIFO_OFFSET_REQ_SIZE_MSB  3

//=== Response ===
#define EN_TX_FIFO_OFFSET_RESP_STATUS       0
#define EN_TX_FIFO_OFFSET_RESP_SIZE_LONG    1
#define EN_TX_FIFO_OFFSET_RESP_CMD_EXT      1
#define EN_TX_FIFO_OFFSET_RESP_SIZE_LSB_EXT 2
#define EN_TX_FIFO_OFFSET_RESP_SIZE_MSB_EXT 3