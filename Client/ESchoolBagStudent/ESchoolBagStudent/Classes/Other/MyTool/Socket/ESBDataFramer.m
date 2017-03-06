//
//  ESBDataFramer.c
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/3.
//  Copyright © 2017年 23. All rights reserved.
//

#include "ESBDataFramer.h"

/**将buf里面的数据，成帧发送出去 ----- 定长成帧，前两个字节指定了消息的长度*/
size_t FrameLengthSend(void *buf, size_t msgSize, FILE *out)
{
    
    if (msgSize > INT16_MAX) {
        //因为是定长成帧，所以用两个字节来表示消息的最大长度，所以每次发送消息的最大长度不能超过两个字节所能表示的最大值
        return -1;
    }
    
    //1 根据消息长度计算帧头(一个消息由帧头和数据两个部分组成，帧头两个字节表示数据的长度)
    uint16_t payloadSize = htons(msgSize);
    
    //2 使用fwrite函数，将帧头和负载写入内存缓存区
    if((fwrite(&payloadSize, sizeof(uint16_t), 1, out) != 1) || (fwrite(buf, sizeof(uint8_t), msgSize, out) != msgSize)){
        //写入数据失败，写入的数据和要发送的数据不匹配
        return -1;
    }
    
    //3 将内存缓存区中的数据立即发送出去
    fflush(out);
    
    //4 返回发送的数据的字节数
    return msgSize;
    
}

/**从指定流中读取数据，并成帧*/
size_t FrameLengthRecv(FILE *in, void *buf, size_t bufSize)
{
    uint16_t payloadSize = 0;
    uint16_t extra = 0;
    
    
    //首先读取前两个字节---也就是数据的长度
    if (fread(&payloadSize, sizeof(uint16_t), 1, in) < 1) {
        //没有读取到2个字节的数据
        printf("成帧--获取数据负载的长度出错");
        return -1;
    }
    
    //字节序列转换
    payloadSize = ntohs(payloadSize);
    
    //如果数据的长度比缓存区空间还大，说明一次性接收不完全，先接受一部分
    if (payloadSize > bufSize) {
        extra = payloadSize - bufSize;  //比缓存区大多少
        payloadSize = bufSize;          //按缓存区的大小接收
    }
    
    //接收
    if(fread(buf, sizeof(uint8_t), payloadSize, in) != payloadSize){
        //实际接收的字节数和拟接收的字节数不匹配
        printf("成帧-实际接收的字节数和拟接收的字节数不匹配");
        return -1;
    }
    
    if (extra > 0) {
        //继续接收
        uint8_t waste[extra];
        fread(waste, sizeof(uint8_t), extra, in);
        return -(payloadSize + extra);  //返回总共有多少字节
    }else{
        //返回实际接收的正确的字节数
        return payloadSize;
    }
}
















