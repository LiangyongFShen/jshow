﻿#ifndef CRASH_REPORT_H_
#define CRASH_REPORT_H_

#include "av_common.h"

namespace tencent {

/**
@brief CrashReport：crash上报模块。

@details crash上报模块。可以借助该模块进行crash上报。这边主要上报SDK内部出现的crash，
并由腾讯侧来查看和解决这些crash，以提高SDK的稳定性等。客户可以不用关心这些上报的细节。

*/
class AV_EXPORT CrashReport {
 public:
  virtual ~CrashReport() {}

  /**
  @brief 打开/关闭crash上报。

  @details 打开/关闭crash上报。

  @param [in] is_enable 是否打开。

  @return 无。

  @remark 可以在任意时刻调用该接口。但SDK1.1版本只有在AVContext::CreateContext()调用成功后SDK才开始启用crash上报功能。
  */
  static void EnableCrashReport(bool is_enable);

};

} // namespace tencent

#endif // #define CRASH_REPORT_H_