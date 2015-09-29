#ifndef AV_INVITATION_BASE_H_
#define AV_INVITATION_BASE_H_

#include <string>
#include "basictypes.h"

//注意，邀请相关的实现都是demo用来展示的，外部使用的话不负责bug或开发功能！！
class AVInvitationBase {
 public:
  virtual ~AVInvitationBase() {};
  struct Delegate {
    virtual void OnInvitationReceived(std::string& open_id,  uint64 room_id, int av_mode) {}
    virtual void OnInvitationAccepted() {}
    virtual void OnInvitationRefused() {}
    virtual void OnInvitationCanceled(std::string& open_id) {}
  };

  virtual void SetDelegate(Delegate* delegate) = 0;

  typedef void (*CompleteCallback)(int, void*);
  virtual void Invite(const std::string& open_id, uint64 room_id, CompleteCallback callback, void* custom_data) = 0;
  virtual void Accept(const std::string& open_id, CompleteCallback callback, void* custom_data) = 0;
  virtual void Refuse(const std::string& open_id, CompleteCallback callback, void* custom_data) = 0;

  static AVInvitationBase* CreateInvitation();
};

#endif // #ifndef AV_INVITATION_BASE_H_
