package com.tencent.avsdk.control;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.util.Log;
import android.view.GestureDetector;
import android.view.Gravity;
import android.view.ScaleGestureDetector;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.WindowManager;

import com.tencent.av.opengl.GraphicRendererMgr;
import com.tencent.av.opengl.gesturedetectors.MoveGestureDetector;
import com.tencent.av.opengl.ui.GLRootView;
import com.tencent.av.opengl.ui.GLView;
import com.tencent.av.opengl.ui.GLViewGroup;
import com.tencent.av.opengl.utils.Utils;
import com.tencent.av.sdk.AVConstants;
import com.tencent.av.utils.QLog;
import com.tencent.avsdk.MemberInfo;
import com.tencent.avsdk.QavsdkApplication;
import com.tencent.avsdk.R;
import com.tencent.avsdk.Util;

public class AVUIControl extends GLViewGroup {
	static final String TAG = "VideoLayerUI";

	boolean mIsLocalHasVideo = false;// 自己是否有视频画面
	Context mContext = null;
	GraphicRendererMgr mGraphicRenderMgr = null;

	View mRootView = null;
	int mTopOffset = 0;
	int mBottomOffset = 0;

	GLRootView mGlRootView = null;
	GLVideoView mGlVideoView = null;

	int mClickTimes = 0;
	int mTargetIndex = -1;
	OnTouchListener mTouchListener = null;
	GestureDetector mGestureDetector = null;
	MoveGestureDetector mMoveDetector = null;
	ScaleGestureDetector mScaleGestureDetector = null;
	private String mRemoteIdentifier;
	private int remoteViewIndex = -1;

	private SurfaceView mSurfaceView = null;
	private SurfaceHolder.Callback mSurfaceHolderListener = new SurfaceHolder.Callback() {
		@Override
		public void surfaceCreated(SurfaceHolder holder) {
			mContext.sendBroadcast(new Intent(Util.ACTION_SURFACE_CREATED));
			mCameraSurfaceCreated = true;

			QavsdkControl qavsdk = ((QavsdkApplication) mContext).getQavsdkControl();
			qavsdk.getAVContext().setRenderMgrAndHolder(mGraphicRenderMgr, holder);
			Log.e("memoryLeak", "memoryLeak surfaceCreated");
		}

		@Override
		public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
			if (holder.getSurface() == null) {
				return;
			}
			holder.setFixedSize(width, height);
			Log.e("memoryLeak", "memoryLeak surfaceChanged");				
		}

		@Override
		public void surfaceDestroyed(SurfaceHolder holder) {
			Log.e("memoryLeak", "memoryLeak surfaceDestroyed");			
		}
	};

	public AVUIControl(Context context, View rootView) {
		mContext = context;
		mRootView = rootView;
		mGraphicRenderMgr = new GraphicRendererMgr();
		initQQGlView();
		initCameraPreview();
	}

	@Override
	protected void onLayout(boolean flag, int left, int top, int right, int bottom) {
		if (QLog.isColorLevel()) {
			QLog.d(TAG, QLog.CLR, "onLayout|left: " + left + ", top: " + top + ", right: " + right + ", bottom: " + bottom);
		}
		layoutVideoView();
	}

	public void showGlView() {
		if (mGlRootView != null) {
			mGlRootView.setVisibility(View.VISIBLE);
		}
	}

	public void hideGlView() {
		if (mGlRootView != null) {
			mGlRootView.setVisibility(View.GONE);
		}
	}

	public void onResume() {
		if (mGlRootView != null) {
			mGlRootView.onResume();
		}

		setRotation(mCacheRotation);
	}

	public void onPause() {
		if (mGlRootView != null) {
			mGlRootView.onPause();
		}
	}

	public void onDestroy() {
		Log.e("memoryLeak", "memoryLeak AVUIControl onDestroy");		
		unInitCameraaPreview();
		mContext = null;
		mRootView = null;

		removeAllView();
		
			mGlVideoView.flush();
			mGlVideoView.clearRender();
		
		mGlRootView.setOnTouchListener(null);
		mGlRootView.setContentPane(null);

		mTouchListener = null;
		mGestureDetector = null;
		mMoveDetector = null;
		mScaleGestureDetector = null;

		mGraphicRenderMgr = null;

		mGlRootView = null;
		mGlVideoView = null;
	}

	public boolean setLocalHasVideo(boolean isLocalHasVideo, boolean forceToBigView, String identifier) {
		if (mContext == null)
			return false;

		if (Utils.getGLVersion(mContext) == 1) {
			return false;
		}
		
				
		if (isLocalHasVideo) {// 打开摄像头
			GLVideoView view = null;
			view = mGlVideoView;
			view.setRender(identifier, AVConstants.VIDEO_SRC_CAMERA);
			view.setIsPC(false);
			view.enableLoading(false);
			view.setVisibility(GLView.VISIBLE);
		} else if (!isLocalHasVideo) {// 关闭摄像头
			closeVideoView(0);
		}
		mIsLocalHasVideo = isLocalHasVideo;

		return true;
	}

	public void setRemoteHasVideo(String identifier, int videoSrcType, boolean isRemoteHasVideo, boolean forceToBigView, boolean isPC) {
		boolean needForceBig = forceToBigView;
		if (mContext == null)
			return;
		if (Utils.getGLVersion(mContext) == 1) {
			isRemoteHasVideo = false;
			return;
		}
		if (!forceToBigView && !isLocalFront()) {
			forceToBigView = true;
		}
				
		if (isRemoteHasVideo) {// 打开对方画面
			GLVideoView view = null;
		
					view = mGlVideoView;
					view.setRender(identifier, videoSrcType);
					remoteViewIndex = 0;
					mRemoteIdentifier = identifier;
			
			
			
				view.setIsPC(isPC);
				view.setMirror(false);
				if (needForceBig && (videoSrcType == AVConstants.VIDEO_SRC_PPT || videoSrcType == AVConstants.VIDEO_SRC_SHARESCREEN)) {
					view.enableLoading(false);
				} else {
					view.enableLoading(true);
				}
				view.setVisibility(GLView.VISIBLE);
		
		
		} else {// 关闭对方画面
		
				closeVideoView(0);
				remoteViewIndex = -1;
			
		}
	}

	int mRotation = 0;
	int mCacheRotation = 0;

	public void setRotation(int rotation) {
		
		if (mContext == null) {
			return;
		}

		if ((rotation % 90) != (mRotation % 90)) {
			mClickTimes = 0;
		}

		mRotation = rotation;
		mCacheRotation = rotation;
		
		QavsdkControl qavsdk = ((QavsdkApplication) mContext).getQavsdkControl();
		if ((qavsdk != null) && (qavsdk.getAVVideoControl() != null)) {		
			qavsdk.getAVVideoControl().setRotation(rotation);			
		}
		switch (rotation) {
		case 0:
			for (int i = 0; i < getChildCount(); i++) {
				GLView view = getChild(i);
				if(view != null)
					view.setRotation(0);
			}
			break;
		case 90:
			for (int i = 0; i < getChildCount(); i++) {
				GLView view = getChild(i);
				if(view != null)				
					view.setRotation(90);
			}
			break;
		case 180:
			for (int i = 0; i < getChildCount(); i++) {
				GLView view = getChild(i);
				if(view != null)				
					view.setRotation(180);
			}
			break;
		case 270:
			for (int i = 0; i < getChildCount(); i++) {
				GLView view = getChild(i);
				if(view != null)				
					view.setRotation(270);
			}
			break;
		default:
			break;
		}
	}
	
	public String getQualityTips() {
		QavsdkControl qavsdk = ((QavsdkApplication) mContext).getQavsdkControl();
		String audioQos = "";
		String videoQos = "";
		String roomQos = "";
		
		if (qavsdk != null) {
			if (qavsdk.getAVAudioControl() != null) {
				audioQos = qavsdk.getAVAudioControl().getQualityTips();
				//Log.d(TAG, "xujinguang:" + audioQos);
			}
			if (qavsdk.getAVVideoControl() != null) {
				videoQos = qavsdk.getAVVideoControl().getQualityTips();
				//Log.d(TAG, "xujinguang:" + videoQos);
			}
			
			if (qavsdk.getAVVideoControl() != null) {
				roomQos = qavsdk.getRoom().getQualityTips();
				//Log.d(TAG, "xujinguang:" + roomQos);
			}
		}

		return audioQos + videoQos + roomQos;
	}

	public void setOffset(int topOffset, int bottomOffset) {
		if (QLog.isColorLevel()) {
			QLog.d(TAG, QLog.CLR, "setOffset topOffset: " + topOffset + ", bottomOffset: " + bottomOffset);
		}
		mTopOffset = topOffset;
		mBottomOffset = bottomOffset;
		// refreshUI();
		layoutVideoView();
	}

	
	
	public void onVideoSrcTypeChanged(String identifier, int oldVideoSrcType, int newVideoSrcType) {
	
			GLVideoView view = mGlVideoView;
			view.clearRender();
			view.setRender(identifier, newVideoSrcType);
			if ((newVideoSrcType == AVConstants.VIDEO_SRC_PPT || newVideoSrcType == AVConstants.VIDEO_SRC_SHARESCREEN)) {
				view.enableLoading(false);
			} else {
				view.enableLoading(true);
			}

	}

	boolean isLocalFront() {
		boolean isLocalFront = true;
		String selfIdentifier = "";
		GLVideoView view = mGlVideoView;
		if (view.getVisibility() == GLView.VISIBLE && selfIdentifier.equals(view.getIdentifier())) {
			isLocalFront = false;
		}
		return isLocalFront;
	}

	

	boolean isRemoteHasVideo() {
		boolean isRemoteHasVideo = false;
		String selfIdentifier = "";
		
			GLVideoView view = mGlVideoView;
			if (view.getVisibility() == GLView.VISIBLE && !selfIdentifier.equals(view.getIdentifier())) {
				isRemoteHasVideo = true;
			}
	
		return isRemoteHasVideo;
	}

	void layoutVideoView() {
		
		if (mContext == null)
			return;
		
		int width = getWidth();
		int height = getHeight();
		mGlVideoView.layout(0, 0, width, height);
		mGlVideoView.setBackgroundColor(Color.BLACK);
		invalidate();
	}

	void closeVideoView(int index) {
		GLVideoView view = mGlVideoView;
		view.setVisibility(GLView.INVISIBLE);
		view.setNeedRenderVideo(true);
		view.enableLoading(false);
		view.setIsPC(false);
		view.clearRender();
		layoutVideoView();
	}

	void initQQGlView() {
		mGlRootView = (GLRootView) mRootView.findViewById(R.id.av_video_glview);
		mGlVideoView = new GLVideoView(mContext.getApplicationContext(), mGraphicRenderMgr);
		mGlVideoView.setVisibility(GLView.INVISIBLE);
		addView(mGlVideoView);
		mGlRootView.setContentPane(this);
	}

	boolean mCameraSurfaceCreated = false;

	void initCameraPreview() {
        WindowManager windowManager = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);
        WindowManager.LayoutParams layoutParams = new WindowManager.LayoutParams();
        layoutParams.width = 1;
        layoutParams.height = 1;
        layoutParams.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                | WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
                | WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN;
        layoutParams.format = PixelFormat.TRANSLUCENT;
        layoutParams.windowAnimations = 0;// android.R.style.Animation_Toast;
        layoutParams.type = WindowManager.LayoutParams.TYPE_TOAST;
        layoutParams.gravity = Gravity.LEFT | Gravity.TOP;
        try {
        	mSurfaceView = new SurfaceView(mContext);
            SurfaceHolder holder = mSurfaceView.getHolder();
            holder.addCallback(mSurfaceHolderListener);
            holder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);// 3.0以下必须在初始化时调用，否则不能启动预览
            mSurfaceView.setZOrderMediaOverlay(true);
            windowManager.addView(mSurfaceView, layoutParams);
        } catch (IllegalStateException e) {
            windowManager.updateViewLayout(mSurfaceView, layoutParams);
        } catch (Exception e) {
            Log.e(TAG,  "add camera surface view fail." + e);
        }		
	}
	
	void unInitCameraaPreview() {
        WindowManager windowManager = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);
        try {
            windowManager.removeView(mSurfaceView);
            mSurfaceView = null;
        } catch(Exception e) {
            Log.e(TAG, "remove camera view fail."+ e);
        }
	}

	public void setSmallVideoViewLayout(boolean isRemoteHasVideo, String remoteIdentifier) {
		if (isRemoteHasVideo) {// 打开摄像头
			GLVideoView view = null;
			mRemoteIdentifier = remoteIdentifier;
			
			if (remoteViewIndex != -1) {
				closeVideoView(remoteViewIndex);
			}
			view = mGlVideoView;
			view.setRender(remoteIdentifier, AVConstants.VIDEO_SRC_CAMERA);
			remoteViewIndex = 0;
			view.setIsPC(false);
			view.enableLoading(false);
			view.setVisibility(GLView.VISIBLE);
		} else {// 关闭摄像头
			closeVideoView(0);
			remoteViewIndex = -1;
		}		
	}

	public void setSelfId(String key) {
		if (mGraphicRenderMgr != null) {
			mGraphicRenderMgr.setSelfId(key + "_" + AVConstants.VIDEO_SRC_CAMERA);
		}
	}
}
