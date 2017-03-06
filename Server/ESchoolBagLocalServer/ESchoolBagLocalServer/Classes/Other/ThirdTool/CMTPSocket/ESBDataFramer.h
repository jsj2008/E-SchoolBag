//
//  ESBDataFramer.h
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/3.
//  Copyright © 2017年 23. All rights reserved.
//

#ifndef ESBDataFramer_h
#define ESBDataFramer_h

#include <stdio.h>

#endif /* ESBDataFramer_h */


/**将buf里面的数据，成帧发送出去 ----- 定长成帧，前两个字节指定了消息的长度*/
size_t FrameLengthSend(void *buf, size_t msgSize, FILE *out);

/**从指定流中读取数据，并成帧*/
size_t FrameLengthRecv(FILE *in, void *buf, size_t bufSize);


