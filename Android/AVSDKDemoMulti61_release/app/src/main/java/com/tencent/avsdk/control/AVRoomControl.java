package com.tencent.avsdk.control;

import java.util.ArrayList;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.tencent.av.sdk.AVContext;
import com.tencent.av.sdk.AVEndpoint;
import com.tencent.av.sdk.AVRoom;
import com.tencent.av.sdk.AVRoomMulti;
import com.tencent.avsdk.MemberInfo;
import com.tencent.avsdk.QavsdkApplication;
import com.tencent.avsdk.Util;

class AVRoomControl {
	private static final int TYPE_MEMBER_CHANGE_IN = 0;
	private static final int TYPE_MEMBER_CHANGE_OUT = TYPE_MEMBER_CHANGE_IN + 1;
	private static final int TYPE_MEMBER_CHANGE_UPDATE = TYPE_MEMBER_CHANGE_OUT + 1;
	private static final String TAG = "AVRoomControl";
	private boolean mIsInCreateRoom = false;
	private boolean mIsInCloseRoom = false;
	private Context mContext;
	private ArrayList<MemberInfo> mMemberList = new ArrayList<MemberInfo>();
	private int audioCat = Util.AUDIO_VOICE_CHAT_MODE;

	public void setAudioCat(int audioCat) {
		this.audioCat = audioCat;
	}

	private AVRoomMulti.Delegate mRoomDelegate = new AVRoomMulti.Delegate() {
		// 创建房间成功回调
		protected void onEnterRoomComplete(int result) {
			Log.d(TAG, "WL_DEBUG mRoomDelegate.onEnterRoomComplete result = " + result);
			mIsInCreateRoom = false;
			mContext.sendBroadcast(new Intent(Util.ACTION_ROOM_CREATE_COMPLETE).putExtra(Util.EXTRA_AV_ERROR_RESULT, result));
		}
		
		// 离开房间成功回调
		protected void onExitRoomComplete(int result) {
			Log.d(TAG, "WL_DEBUG mRoomDelegate.onExitRoomComplete result = " + result);
			mIsInCloseRoom = false;
			mMemberList.clear();
			mContext.sendBroadcast(new Intent(Util.ACTION_CLOSE_ROOM_COMPLETE));			
		}

		protected void onEndpointsEnterRoom(int endpointCount, AVEndpoint endpointList[]) {
			Log.d(TAG, "WL_DEBUG onEndpointsEnterRoom. endpointCount = " + endpointCount);
			onMemberChange(TYPE_MEMBER_CHANGE_IN, endpointList, endpointCount);
		}

		protected void onEndpointsExitRoom(int endpointCount, AVEndpoint endpointList[]) {
			Log.d(TAG, "WL_DEBUG onEndpointsExitRoom. endpointCount = " + endpointCount);
			onMemberChange(TYPE_MEMBER_CHANGE_OUT, endpointList, endpointCount);
		}

		protected void onEndpointsUpdateInfo(int endpointCount, AVEndpoint endpointList[]) {
			Log.d(TAG, "WL_DEBUG onEndpointsUpdateInfo. endpointCount = " + endpointCount);
			onMemberChange(TYPE_MEMBER_CHANGE_UPDATE, endpointList, endpointCount);
		}
				
		protected void OnPrivilegeDiffNotify(int privilege) {
			Log.d(TAG, "OnPrivilegeDiffNotify. privilege = " + privilege);
		}
	};


	AVRoomControl(Context context) {
		mContext = context;
	}

	/**
	 * 成员列表变化
	 * 
	 * @param type
	 *            类型
	 * @param endpointList
	 *            成员列表
	 * @param endpointCount
	 *            成员总数
	 */
	private void onMemberChange(int type, AVEndpoint endpointList[], int endpointCount) {

		mContext.sendBroadcast(new Intent(Util.ACTION_MEMBER_CHANGE));
	}

	/**
	 * 创建房间
	 * 
	 * @param relationId
	 *            讨论组号
	 */
	void enterRoom(int relationId) {
		Log.d(TAG, "WL_DEBUG enterRoom relationId = " + relationId);
		int roomType = AVRoom.AV_ROOM_MULTI;
		int roomId = 0;

		QavsdkControl qavsdk = ((QavsdkApplication) mContext).getQavsdkControl();
		AVContext avContext = qavsdk.getAVContext();
		long authBits = AVRoom.AUTH_BITS_DEFUALT;//权限位；默认值是拥有所有权限。TODO：请业务侧填根据自己的情况填上权限位。
		byte[] authBuffer = null;//权限位加密串；TODO：请业务侧填上自己的加密串。
		int authBufferSize = 0;//权限位加密串长度；TODO：请业务侧填上自己的加密串长度。
		String controlRole = "";//角色名；多人房间专用。该角色名就是web端音视频参数配置工具所设置的角色名。TODO：请业务侧填根据自己的情况填上自己的角色名。
		int audioCategory = audioCat;
		AVRoom.Info roomInfo = new AVRoom.Info(roomType, roomId, relationId, AVRoom.AV_MODE_AUDIO, "", authBits, authBuffer, authBufferSize, audioCategory, controlRole);
		// create room
		avContext.enterRoom(mRoomDelegate, roomInfo);
		mIsInCreateRoom = true;
	}

	/** 关闭房间 */
	int exitRoom() {
		Log.d(TAG, "WL_DEBUG exitRoom");
		QavsdkControl qavsdk = ((QavsdkApplication) mContext).getQavsdkControl();
		AVContext avContext = qavsdk.getAVContext();
		int result = avContext.exitRoom();
		mIsInCloseRoom = true;

		return result;
	}

	/**
	 * 获取成员列表
	 * 
	 * @return 成员列表
	 */
	ArrayList<MemberInfo> getMemberList() {
		return mMemberList;
	}

	boolean getIsInEnterRoom() {
		return mIsInCreateRoom;
	}

	boolean getIsInCloseRoom() {
		return mIsInCloseRoom;
	}
	
	public void setCreateRoomStatus(boolean status) {
		mIsInCreateRoom = status;
	}
	public void setCloseRoomStatus(boolean status) {
		mIsInCloseRoom = status;
	}
	
	public void setNetType(int netType) {
		QavsdkControl qavsdk = ((QavsdkApplication) mContext).getQavsdkControl();
		AVContext avContext = qavsdk.getAVContext();
		AVRoomMulti room = (AVRoomMulti)avContext.getRoom();
	}
}