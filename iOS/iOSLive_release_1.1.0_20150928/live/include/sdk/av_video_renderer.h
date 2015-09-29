/* 
** Copyright (c) 2014 The AVSdk project. All rights reserved.
** Created by ryandeng
*/
#ifndef AV_VIDEO_RENDERER_H_
#define AV_VIDEO_RENDERER_H_
#include "av_common.h"

namespace tencent
{
    
namespace av
{

class AV_EXPORT AVVideoRenderer {
public:

#ifdef OS_WIN
  static void RenderFrame(HWND hwnd, LPRECT rect_out, const AVVideoFrame* frame_data);
#endif

};

} // namespace av

} // namespace tencent

#endif