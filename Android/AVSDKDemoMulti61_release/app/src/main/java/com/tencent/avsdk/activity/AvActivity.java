package com.tencent.avsdk.activity;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.ClipboardManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.hardware.SensorManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.PowerManager;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.OrientationEventListener;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsListView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.TIMCallBack;
import com.tencent.TIMConversation;
import com.tencent.TIMConversationType;
import com.tencent.TIMCustomElem;
import com.tencent.TIMElem;
import com.tencent.TIMElemType;
import com.tencent.TIMGroupManager;
import com.tencent.TIMGroupSystemElem;
import com.tencent.TIMGroupSystemElemType;
import com.tencent.TIMManager;
import com.tencent.TIMMessage;
import com.tencent.TIMMessageListener;
import com.tencent.TIMTextElem;
import com.tencent.TIMValueCallBack;
import com.tencent.av.TIMAvManager;
import com.tencent.av.sdk.AVAudioCtrl;
import com.tencent.av.sdk.AVConstants;
import com.tencent.av.sdk.AVEndpoint;
import com.tencent.av.sdk.AVRoomMulti;
import com.tencent.av.utils.PhoneStatusTools;
import com.tencent.avsdk.ChatEntity;
import com.tencent.avsdk.ChatMsgListAdapter;
import com.tencent.avsdk.CircularImageButton;
import com.tencent.avsdk.HttpUtil;
import com.tencent.avsdk.ImageUtil;
import com.tencent.avsdk.MemberInfo;
import com.tencent.avsdk.QavsdkApplication;
import com.tencent.avsdk.R;
import com.tencent.avsdk.UserInfo;
import com.tencent.avsdk.Util;

import com.tencent.avsdk.VideoConst;
import com.tencent.avsdk.control.QavsdkControl;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

/**
 * 直播界面
 */
public class AvActivity extends Activity implements OnClickListener {
    private static final String TAG = "AvActivity";
    private static final String UNREAD = "0";
    private static final int PRIASE_MSG = 1;
    private static final int MEMBER_ENTER_MSG = 2;
    private static final int MEMBER_EXIT_MSG = 3;

    private static final int DIALOG_INIT = 0;
    private static final int DIALOG_AT_ON_CAMERA = DIALOG_INIT + 1;
    private static final int DIALOG_ON_CAMERA_FAILED = DIALOG_AT_ON_CAMERA + 1;
    private static final int DIALOG_AT_OFF_CAMERA = DIALOG_ON_CAMERA_FAILED + 1;
    private static final int DIALOG_OFF_CAMERA_FAILED = DIALOG_AT_OFF_CAMERA + 1;
    private static final int DIALOG_AT_SWITCH_FRONT_CAMERA = DIALOG_OFF_CAMERA_FAILED + 1;
    private static final int DIALOG_SWITCH_FRONT_CAMERA_FAILED = DIALOG_AT_SWITCH_FRONT_CAMERA + 1;
    private static final int DIALOG_AT_SWITCH_BACK_CAMERA = DIALOG_SWITCH_FRONT_CAMERA_FAILED + 1;
    private static final int DIALOG_SWITCH_BACK_CAMERA_FAILED = DIALOG_AT_SWITCH_BACK_CAMERA + 1;
    private static final int DIALOG_DESTROY = DIALOG_SWITCH_BACK_CAMERA_FAILED + 1;

    private static final int ERROR_MESSAGE_TOO_LONG = 0x1;
    private static final int ERROR_ACCOUNT_NOT_EXIT = ERROR_MESSAGE_TOO_LONG + 1;

    private static final int REFRESH_CHAT = 0x100;
    private static final int UPDAT_WALL_TIME_TIMER_TASK = REFRESH_CHAT + 1;
    private static final int REMOVE_CHAT_ITEM_TIMER_TASK = UPDAT_WALL_TIME_TIMER_TASK + 1;
    private static final int UPDAT_MEMBER = REMOVE_CHAT_ITEM_TIMER_TASK + 1;
    private static final int MEMBER_EXIT_COMPLETE = UPDAT_MEMBER + 1;
    private static final int CLOSE_VIDEO = MEMBER_EXIT_COMPLETE + 1;
    private static final int START_RECORD = CLOSE_VIDEO + 1;
    private static final int IM_HOST_LEAVE = START_RECORD + 1;

    private boolean mIsPaused = false;
    private boolean mIsClicked = false;
    private boolean mIsSuccess = false;
    private boolean mpush = false;
    private boolean mRecord = false;
    private int mOnOffCameraErrorCode = AVConstants.AV_ERROR_OK;
    private int mSwitchCameraErrorCode = AVConstants.AV_ERROR_OK;

    private ProgressDialog mDialogInit = null;
    private ProgressDialog mDialogAtOnCamera = null;
    private ProgressDialog mDialogAtOffCamera = null;
    private ProgressDialog mDialogAtSwitchFrontCamera = null;
    private ProgressDialog mDialogAtSwitchBackCamera = null;
    private ProgressDialog mDialogAtDestroy = null;

    private ListView mListViewMsgItems;
    private EditText mEditTextInputMsg;
    private Button mButtonSendMsg;
    private InputMethodManager mInputKeyBoard;
    private TIMConversation mConversation;
    private TIMConversation mSystemConversation;
    private List<ChatEntity> mArrayListChatEntity;
    private ChatMsgListAdapter mChatMsgListAdapter;
    private final int MAX_PAGE_NUM = 10;
    private int mLoadMsgNum = MAX_PAGE_NUM;
    private boolean bNeverLoadMore = true;
    private boolean bMore = true;
    private boolean mIsLoading = false;
    private boolean FormalEnv = true;
    private QavsdkControl mQavsdkControl;
    private String mRecvIdentifier = "";
    private String mHostIdentifier = "";
    OrientationEventListener mOrientationEventListener = null;
    int mRotationAngle = 0;
    private PowerManager.WakeLock wakeLock;

    private Context ctx;
    private UserInfo mSelfUserInfo;
    private int roomNum;
    private String groupId;
    private boolean mChecked = false;

    ArrayList<MemberInfo> mMemberList;
    private GridView mGridView;
    private static final int slength = 40;
    private float density;

    private int groupForPush;
    private int praiseNum;
    private TextView mPraiseNum;
    private ImageButton mButtonPraise;
    private TextView mClockTextView;
    private long second = 0;
    private long time;
    private int StreamType = 1;
    private Timer mVideoTimer;
    private Timer mChatTimer;
    private Timer mHeartClickTimer;
    private TimerTask mVideoTimerTask = new TimerTask() {
        @Override
        public void run() {
            ++second;
            mHandler.sendEmptyMessage(UPDAT_WALL_TIME_TIMER_TASK);
        }
    };

    private TimerTask mHeartClickTask = new TimerTask() {
        @Override
        public void run() {
            heartClick();
        }
    };

    private TimerTask mChatTimerTask = new TimerTask() {
        @Override
        public void run() {
            mHandler.sendEmptyMessage(REMOVE_CHAT_ITEM_TIMER_TASK);
            Log.e(TAG, "timer");
        }
    };

    private TIMMessageListener msgListener = new TIMMessageListener() {
        @Override
        public boolean onNewMessages(List<TIMMessage> list) {
            if (isTopActivity()) {
                if (groupId != null) {
                    for (TIMMessage msg : list) {

                        if (groupId.equals(msg.getConversation().getPeer())) {
                            getMessage();
                            return false;
                        } else {
                            getSysMessage();
                        }

                    }
                }

            }
            return false;
        }
    };

    private Handler mHandler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case REFRESH_CHAT:
                    refreshChat(msg);
                    break;
                case IM_HOST_LEAVE:
                    onMemberExit();
                    onCloseVideo();
                    break;

                case ERROR_MESSAGE_TOO_LONG:
                    Toast.makeText(getBaseContext(), "消息太长，发送失败", Toast.LENGTH_SHORT).show();
                    break;
                case ERROR_ACCOUNT_NOT_EXIT:
                    Toast.makeText(getBaseContext(), "对方账号不存在或未登陆过！", Toast.LENGTH_SHORT).show();
                    break;

                case UPDAT_WALL_TIME_TIMER_TASK:
                    updateWallTime();
                    break;
                case REMOVE_CHAT_ITEM_TIMER_TASK:
                    removeChatItem();
                    break;
                case UPDAT_MEMBER:
                    Log.d(TAG, "handleMessage update_member");
                    setGridView();
                    break;
                case MEMBER_EXIT_COMPLETE:
                    sendCloseMsg();
                    break;
                case CLOSE_VIDEO:
                    onCloseVideo();
                    break;
                case START_RECORD:
                    startRecord();
                    break;

                default:
                    break;
            }
            return false;
        }
    });

    private BroadcastReceiver connectionReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            ConnectivityManager connectMgr = (ConnectivityManager) getSystemService(CONNECTIVITY_SERVICE);
            NetworkInfo mobileInfo = connectMgr.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
            NetworkInfo wifiInfo = connectMgr.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
            Log.e(TAG, "WL_DEBUG netinfo mobile = " + mobileInfo.isConnected() + ", wifi = " + wifiInfo.isConnected());

            int netType = Util.getNetWorkType(ctx);
            Log.e(TAG, "WL_DEBUG connectionReceiver getNetWorkType = " + netType);
            mQavsdkControl.setNetType(netType);

            if (!mobileInfo.isConnected() && !wifiInfo.isConnected()) {
                Log.e(TAG, "WL_DEBUG connectionReceiver no network = ");
                // unconnect network
                // 暂时不关闭
//				if (ctx instanceof Activity) {
//					Toast.makeText(getApplicationContext(), ctx.getString(R.string.notify_no_network), Toast.LENGTH_SHORT).show();
//					((Activity)ctx).finish();
//				}
            } else {
                // connect network
            }
        }
    };

    private BroadcastReceiver mBroadcastReceiver = new BroadcastReceiver() {

        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            Log.d(TAG, "WL_DEBUG onReceive action = " + action);
            if (action.equals(Util.ACTION_SURFACE_CREATED)) {
                locateCameraPreview();
                wakeLock.acquire();
                if (mSelfUserInfo.isCreater() == true) {
                    initTIM();
                    mEditTextInputMsg.setClickable(true);
                    mIsSuccess = true;
                    mVideoTimer.schedule(mVideoTimerTask, 1000, 1000);
                    mQavsdkControl.toggleEnableCamera();
                    boolean isEnable = mQavsdkControl.getIsEnableCamera();
                    refreshCameraUI();
                    if (mOnOffCameraErrorCode != AVConstants.AV_ERROR_OK) {
                        showDialog(isEnable ? DIALOG_OFF_CAMERA_FAILED : DIALOG_ON_CAMERA_FAILED);
                        mQavsdkControl.setIsInOnOffCamera(false);
                        refreshCameraUI();
                    }
                    getMemberInfo();
                    mHeartClickTimer.schedule(mHeartClickTask,1000,10000);
                } else {
                    requestView(mHostIdentifier);
                }
            } else if (action.equals(Util.ACTION_VIDEO_CLOSE)) {
                String identifier = intent.getStringExtra(Util.EXTRA_IDENTIFIER);
                if (!TextUtils.isEmpty(mRecvIdentifier)) {
                    mQavsdkControl.setRemoteHasVideo(false, mRecvIdentifier);
                }

                mRecvIdentifier = identifier;
            } else if (action.equals(Util.ACTION_VIDEO_SHOW)) {
                Log.d(TAG, "onReceive ACTION_VIDEO_SHOW ");
                String identifier = intent.getStringExtra(Util.EXTRA_IDENTIFIER);
                mRecvIdentifier = identifier;
                mQavsdkControl.setRemoteHasVideo(true, mRecvIdentifier);
                joinGroup();
                initTIM();
                mIsSuccess = true;
                mEditTextInputMsg.setClickable(true);
                getMemberInfo();
                onMemberEnter();
                Util.switchWaitingDialog(ctx, mDialogInit, DIALOG_INIT, false);
            } else if (action.equals(Util.ACTION_ENABLE_CAMERA_COMPLETE)) {
                refreshCameraUI();

                mOnOffCameraErrorCode = intent.getIntExtra(Util.EXTRA_AV_ERROR_RESULT, AVConstants.AV_ERROR_OK);
                boolean isEnable = intent.getBooleanExtra(Util.EXTRA_IS_ENABLE, false);

                if (mOnOffCameraErrorCode == AVConstants.AV_ERROR_OK) {
                    if (!mIsPaused) {
                        mQavsdkControl.setSelfId(mHostIdentifier);
                        mQavsdkControl.setLocalHasVideo(isEnable, mHostIdentifier);
                    }
                } else {
                    showDialog(isEnable ? DIALOG_ON_CAMERA_FAILED : DIALOG_OFF_CAMERA_FAILED);
                }
            } else if (action.equals(Util.ACTION_SWITCH_CAMERA_COMPLETE)) {
                refreshCameraUI();

                mSwitchCameraErrorCode = intent.getIntExtra(Util.EXTRA_AV_ERROR_RESULT, AVConstants.AV_ERROR_OK);
                boolean isFront = intent.getBooleanExtra(Util.EXTRA_IS_FRONT, false);
                if (mSwitchCameraErrorCode != AVConstants.AV_ERROR_OK) {
                    showDialog(isFront ? DIALOG_SWITCH_FRONT_CAMERA_FAILED : DIALOG_SWITCH_BACK_CAMERA_FAILED);
                }
            } else if (action.equals(Util.ACTION_MEMBER_CHANGE)) {

            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d(TAG, "WL_DEBUG onCreate start");
        super.onCreate(savedInstanceState);
        ctx = this;
        setContentView(R.layout.av_activity);
        registerBroadcastReceiver();

        showDialog(DIALOG_INIT);
        Util.switchWaitingDialog(ctx, mDialogInit, DIALOG_INIT, true);
        QavsdkApplication mQavsdkApplication = (QavsdkApplication) getApplication();
        mQavsdkControl = mQavsdkApplication.getQavsdkControl();
        int netType = Util.getNetWorkType(ctx);
        Log.e(TAG, "WL_DEBUG connectionReceiver onCreate = " + netType);
        if (netType != AVConstants.NETTYPE_NONE) {
            mQavsdkControl.setNetType(Util.getNetWorkType(ctx));
        }

        if (mQavsdkControl.getAVContext() != null) {
            mQavsdkControl.onCreate((QavsdkApplication) getApplication(), findViewById(android.R.id.content));
        } else {
            finish();
        }

        mSelfUserInfo = mQavsdkApplication.getMyselfUserInfo();
        mMemberList = mQavsdkControl.getMemberList();
        roomNum = getIntent().getExtras().getInt(Util.EXTRA_ROOM_NUM);
        groupForPush = roomNum;
        if (mSelfUserInfo.getEnv() == Util.ENV_TEST) {
//			groupForPush = Integer.parseInt(mSelfUserInfo.getUserPhone().substring(0, 5));
            groupForPush = 14010;
        }
        mRecvIdentifier = "" + roomNum;
        Log.d(TAG, "xujinguang " + mRecvIdentifier);
        mHostIdentifier = getIntent().getExtras().getString(Util.EXTRA_SELF_IDENTIFIER);
        Log.d(TAG, "onCreate mHostIdentifier" + mHostIdentifier);

        groupId = getIntent().getExtras().getString(Util.EXTRA_GROUP_ID);
        if (!mSelfUserInfo.isCreater()) {
            praiseNum = getIntent().getExtras().getInt(Util.EXTRA_PRAISE_NUM);
        }
        mIsSuccess = false;
        initView();
        initGridView();
        initShowTips();
        registerOrientationListener();

    }

    @Override
    public void onResume() {
        super.onResume();
        mIsPaused = false;
        mQavsdkControl.onResume();
        refreshCameraUI();
        if (mOnOffCameraErrorCode != AVConstants.AV_ERROR_OK) {
            showDialog(DIALOG_ON_CAMERA_FAILED);
        }
        startOrientationListener();
    }

    @Override
    protected void onPause() {
        super.onPause();
        mIsPaused = true;
        mQavsdkControl.onPause();
        refreshCameraUI();
        if (mOnOffCameraErrorCode != AVConstants.AV_ERROR_OK) {
            showDialog(DIALOG_OFF_CAMERA_FAILED);
        }
        stopOrientationListener();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.e("memoryLeak", "memoryLeak avactivity onDestroy");
        mQavsdkControl.onDestroy();
        // 注销广播
        if (mBroadcastReceiver != null) {
            unregisterReceiver(mBroadcastReceiver);
        }
        if (connectionReceiver != null) {
            unregisterReceiver(connectionReceiver);
        }

        Log.e("memoryLeak", "memoryLeak avactivity onDestroy end");
        Log.d(TAG, "WL_DEBUG onDestroy");
        Util.switchWaitingDialog(ctx, mDialogAtDestroy, DIALOG_DESTROY, false);
    }

    private void registerBroadcastReceiver() {
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(Util.ACTION_SURFACE_CREATED);
        intentFilter.addAction(Util.ACTION_VIDEO_SHOW);
        intentFilter.addAction(Util.ACTION_VIDEO_CLOSE);
        intentFilter.addAction(Util.ACTION_ENABLE_CAMERA_COMPLETE);
        intentFilter.addAction(Util.ACTION_SWITCH_CAMERA_COMPLETE);
        intentFilter.addAction(Util.ACTION_MEMBER_CHANGE);
        registerReceiver(mBroadcastReceiver, intentFilter);

        IntentFilter netIntentFilter = new IntentFilter();
        netIntentFilter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
        registerReceiver(connectionReceiver, netIntentFilter);
    }

    private LinearLayout praiseLayout;

    private void initView() {
        ImageButton mButtonMute;
        ImageButton mButtonSwitchCamera;

        mButtonMute = (ImageButton) findViewById(R.id.qav_topbar_mute);
        mButtonSwitchCamera = (ImageButton) findViewById(R.id.qav_topbar_switchcamera);
        mListViewMsgItems = (ListView) findViewById(R.id.im_msg_items);
        mEditTextInputMsg = (EditText) findViewById(R.id.qav_bottombar_msg_input);
        mEditTextInputMsg.setOnClickListener(this);

        findViewById(R.id.qav_topbar_hangup).setOnClickListener(this);
        findViewById(R.id.qav_topbar_push).setOnClickListener(this);
        findViewById(R.id.qav_topbar_record).setOnClickListener(this);
        findViewById(R.id.qav_topbar_streamtype).setOnClickListener(this);

        if (!mSelfUserInfo.isCreater()) {
            findViewById(R.id.qav_topbar_push).setVisibility(View.GONE);
            findViewById(R.id.qav_topbar_streamtype).setVisibility(View.GONE);
            findViewById(R.id.qav_topbar_record).setVisibility(View.GONE);
        }
        praiseLayout = (LinearLayout) findViewById(R.id.praise_layout);
        mButtonSendMsg = (Button) findViewById(R.id.qav_bottombar_send_msg);
        mButtonSendMsg.setOnClickListener(this);
        mClockTextView = (TextView) findViewById(R.id.qav_timer);
        mPraiseNum = (TextView) findViewById(R.id.text_view_live_praise);
        mButtonPraise = (ImageButton) findViewById(R.id.image_btn_praise);
        mButtonPraise.setOnClickListener(this);

        if (mSelfUserInfo.isCreater()) {
            mButtonMute.setOnClickListener(this);
            mButtonSwitchCamera.setOnClickListener(this);
            AVAudioCtrl avAudioCtrl = mQavsdkControl.getAVContext().getAudioCtrl();
            avAudioCtrl.enableMic(false);
            avAudioCtrl.enableMic(true);
            mButtonPraise.setEnabled(false);
        } else {
            mQavsdkControl.getAVContext().getAudioCtrl().enableMic(false);
            mPraiseNum.setText("" + praiseNum);
            mButtonMute.setVisibility(View.GONE);
            mButtonSwitchCamera.setVisibility(View.GONE);
        }

        //不熄屏
        PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
        wakeLock = pm.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK, "TAG");

        //默认不显示键盘
        mInputKeyBoard = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);

        findViewById(R.id.av_screen_layout).setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                hideMsgIputKeyboard();
                mEditTextInputMsg.setVisibility(View.VISIBLE);
                return false;
            }
        });

        mVideoTimer = new Timer(true);
        mHeartClickTimer = new Timer(true);
    }

    private void initTIM() {
        if (groupId != null)
            mConversation = TIMManager.getInstance().getConversation(TIMConversationType.Group, groupId);
        mSystemConversation = TIMManager.getInstance().getConversation(TIMConversationType.System, "");

        mArrayListChatEntity = new ArrayList<ChatEntity>();
        mChatMsgListAdapter = new ChatMsgListAdapter(this, mArrayListChatEntity, mMemberList);
        mListViewMsgItems.setAdapter(mChatMsgListAdapter);
        if (mListViewMsgItems.getCount() > 1)
            mListViewMsgItems.setSelection(mListViewMsgItems.getCount() - 1);
        mListViewMsgItems.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                hideMsgIputKeyboard();
                mEditTextInputMsg.setVisibility(View.VISIBLE);
                return false;
            }
        });

        mListViewMsgItems.setOnScrollListener(new AbsListView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {
                switch (scrollState) {
                    case AbsListView.OnScrollListener.SCROLL_STATE_IDLE:
                        if (view.getFirstVisiblePosition() == 0 && !mIsLoading && bMore) {
                            bNeverLoadMore = false;
                            mIsLoading = true;
                            mLoadMsgNum += MAX_PAGE_NUM;
//							getMessage();
                        }
                        break;
                }
            }

            @Override
            public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
            }
        });
        getMessage();
        TIMManager.getInstance().addMessageListener(msgListener);

        mChatTimer = new Timer(true);
        time = System.currentTimeMillis() / 1000;
        mChatTimer.schedule(mChatTimerTask, 8000, 2000);
    }

    private void destroyTIM() {
        TIMManager.getInstance().removeMessageListener(msgListener);
        Log.d(TAG, "WL_DEBUG onDestroy");
        if (groupId != null && mIsSuccess) {
            if (mSelfUserInfo.isCreater()) {
                TIMGroupManager.getInstance().deleteGroup(groupId, new TIMCallBack() {
                    @Override
                    public void onError(int i, String s) {
                        Log.e(TAG, "quit group error " + i + " " + s);
                    }

                    @Override
                    public void onSuccess() {
                        Log.e(TAG, "delete group success");
                        Log.d(TAG, "WL_DEBUG onDestroy");
                    }
                });
            } else {
                TIMGroupManager.getInstance().quitGroup(groupId, new TIMCallBack() {
                    @Override
                    public void onError(int i, String s) {
                        Log.e(TAG, "quit group error " + i + " " + s);
                    }

                    @Override
                    public void onSuccess() {
                        Log.i(TAG, "delete group success");
                        Log.i(TAG, "WL_DEBUG onDestroy");
                    }
                });
            }
            TIMManager.getInstance().deleteConversation(TIMConversationType.Group, groupId);
        }
    }

    private void joinGroup() {
        TIMGroupManager.getInstance().applyJoinGroup(groupId, "申请加入" + groupId, new TIMCallBack() {
            @Override
            public void onError(int i, String s) {
                TIMManager.getInstance().logout();
                Toast.makeText(ctx, "加群失败,失败原因：" + i + ":" + s, Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onSuccess() {
                Log.i(TAG, "applyJpoinGroup success");
            }
        });
    }

    private void getMessage() {
        if (mConversation == null)
            return;
        int unread = (int) mConversation.getUnreadMessageNum();

        Log.e(TAG, "unread: " + unread);
        mConversation.getMessage(1, null, new TIMValueCallBack<List<TIMMessage>>() {
            @Override
            public void onError(int i, String s) {
                Log.e(TAG, "get msgs failed:" + i + ":" + s);
            }

            @Override
            public void onSuccess(List<TIMMessage> timMessages) {
                Log.e(TAG, "get msgs success");
                Message Msg = new Message();
                final List<TIMMessage> tmpMsgs = timMessages;

                Msg.what = REFRESH_CHAT;
                Msg.obj = tmpMsgs;
                mHandler.sendMessage(Msg);
            }
        });
    }

    private void getSysMessage() {
        if (mSystemConversation == null)
            return;
        int unread = (int) mSystemConversation.getUnreadMessageNum();

        Log.i(TAG, "getSysMessage unread: " + unread);
        mSystemConversation.getMessage(1, null, new TIMValueCallBack<List<TIMMessage>>() {
            @Override
            public void onError(int i, String s) {
                Log.e(TAG, "getSysMessage failed:" + i + ":" + s);
            }

            @Override
            public void onSuccess(List<TIMMessage> timMessages) {
                Log.i(TAG, "getSysMessage success");
                Message Msg = new Message();
                final List<TIMMessage> tmpMsgs = timMessages;

                for (int i = tmpMsgs.size() - 1; i >= 0; i--) {
                    TIMMessage currMsg = tmpMsgs.get(i);
                    if (currMsg.getElement(i) != null) {
                        TIMElem elem = currMsg.getElement(i);
                        TIMElemType type = elem.getType();
                        Log.d(TAG, "getSysMessage !!!! curMsg    " + ((TIMGroupSystemElem) elem).getSubtype());
                        if (TIMGroupSystemElemType.TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE == ((TIMGroupSystemElem) elem).getSubtype()) {
                            mHandler.sendEmptyMessage(IM_HOST_LEAVE);
                        }
                    }
                }
            }
        });


    }


    private void refreshChat(Message msg) {
        Log.d(TAG, "refreshChat 0000 " + msg);
        List<TIMMessage> tlist = (List<TIMMessage>) msg.obj;


        if (tlist.size() > 0) {
            mConversation.setReadMessage(tlist.get(0));
        }
        if (!bNeverLoadMore && (tlist.size() < mLoadMsgNum))
            bMore = false;

        for (int i = tlist.size() - 1; i >= 0; i--) {
            Log.d(TAG, "refreshChat 2222curMsg");
            TIMMessage currMsg = tlist.get(i);
            if (currMsg.getElement(i) != null) {
                TIMElem elem = currMsg.getElement(i);
                TIMElemType type = elem.getType();
                Log.d(TAG, "refreshChat !!!! curMsg    " + type);
//                if (type == TIMElemType.GroupTips) {
//                    Log.d(TAG, "refreshChat yes yes  " + ((TIMTextElem) elem).getText());
////                    String customText = new String(((TIMCustomElem) elem).getData(), "UTF-8");
////                    if(TIMGroupSystemElemType.TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE == ((TIMGroupSystemElem) elem).getSubtype()) {
////                        Log.d(TAG, "refreshChat yes yes  " + ((TIMGroupSystemElem) elem).getSubtype());
////                    }
//
//                }

            }

            long msgTime = currMsg.timestamp();
            if (msgTime < time)
                continue;
            for (int j = 0; j < currMsg.getElementCount(); j++) {


                if (currMsg.getElement(j) == null)
                    continue;
                TIMElem elem = currMsg.getElement(j);
                TIMElemType type = elem.getType();

                Log.d(TAG, "refreshChat 3333curMsg" + type);
                if (type == TIMElemType.Custom) {
                    handleCustomMsg(elem);
                    continue;
                }
                ChatEntity entity = new ChatEntity();
                entity.setElem(elem);
                entity.setIsSelf(currMsg.isSelf());
                entity.setTime(currMsg.timestamp());
                Log.e(TAG, "" + currMsg.timestamp());
                entity.setType(currMsg.getConversation().getType());
                entity.setSenderName(currMsg.getSender());
                entity.setStatus(currMsg.status());
                mArrayListChatEntity.add(entity);
            }
        }

        mChatMsgListAdapter.notifyDataSetChanged();
        mListViewMsgItems.setVisibility(View.VISIBLE);
        if (mListViewMsgItems.getCount() > 1) {
            if (mIsLoading)
                mListViewMsgItems.setSelection(0);
            else
                mListViewMsgItems.setSelection(mListViewMsgItems.getCount() - 1);
        }
        mIsLoading = false;
    }

    public boolean hideMsgIputKeyboard() {
        if (getWindow().getAttributes().softInputMode != WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN) {
            if (getCurrentFocus() != null) {
                mInputKeyBoard.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
                this.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
                return true;
            }
        }

        return false;
    }


    private void locateCameraPreview() {
        if (mDialogInit != null && mDialogInit.isShowing()) {
            mDialogInit.dismiss();
        }
    }

    private AVEndpoint.RequestViewCompleteCallback mRequestViewCompleteCallback = new AVEndpoint.RequestViewCompleteCallback() {
        protected void OnComplete(String identifier, int result) {
            // TODO
            Log.d(TAG, "RequestViewCompleteCallback.OnComplete");
        }
    };

    private AVEndpoint.CancelViewCompleteCallback mCancelViewCompleteCallback = new AVEndpoint.CancelViewCompleteCallback() {
        protected void OnComplete(String identifier, int result) {
            // TODO
            Log.d(TAG, "CancelViewCompleteCallback.OnComplete");
        }
    };

    public void requestView(String identifier) {
        Log.d(TAG, "request " + identifier);
        identifier = "86-" + identifier;
        AVEndpoint endpoint = ((AVRoomMulti) mQavsdkControl.getAVContext().getRoom()).getEndpointById(identifier);
        Log.d(TAG, "requestView identifier " + identifier + " endpoint " + endpoint);
        if (endpoint != null) {
            mVideoTimer.schedule(mVideoTimerTask, 1000, 1000);
            AVEndpoint.View view = new AVEndpoint.View();
            view.videoSrcType = AVEndpoint.View.VIDEO_SRC_TYPE_CAMERA;//SDK1.2版本只支持摄像头视频源，所以当前只能设置为VIDEO_SRC_TYPE_CAMERA。
            view.viewSizeType = AVEndpoint.View.VIEW_SIZE_TYPE_BIG;

            endpoint.requestView(view, mRequestViewCompleteCallback);
            ctx.sendBroadcast(new Intent(Util.ACTION_VIDEO_SHOW)
                    .putExtra(Util.EXTRA_IDENTIFIER, identifier)
                    .putExtra(Util.EXTRA_VIDEO_SRC_TYPE, view.videoSrcType));

        } else {
            mEditTextInputMsg.setVisibility(View.GONE);
            mButtonSendMsg.setVisibility(View.GONE);
            mPraiseNum.setVisibility(View.GONE);
            mButtonPraise.setVisibility(View.GONE);

            dialog = new Dialog(this, R.style.dialog);
            dialog.setContentView(R.layout.alert_dialog);
            ((TextView) dialog.findViewById(R.id.dialog_title)).setText("温馨提示");
            ((TextView) dialog.findViewById(R.id.dialog_message)).setText("此直播已结束，请观看其他直播！");
            ((Button) dialog.findViewById(R.id.close_dialog)).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    onCloseVideo();
                    dialog.dismiss();
                }
            });
            dialog.setCanceledOnTouchOutside(false);
            dialog.show();
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.qav_topbar_mute:
                onCheckedChanged(mChecked);
                mChecked = !mChecked;
                break;
            case R.id.qav_topbar_hangup:
                if (mIsSuccess && mSelfUserInfo.isCreater() == false) {
                    onMemberExit();
                    onCloseVideo();
                } else
                    closeAlertDialog();
                break;
            case R.id.qav_topbar_switchcamera:
                onSwitchCamera();
                break;
            case R.id.qav_bottombar_send_msg:
                onSendMsg();
                break;
            case R.id.qav_bottombar_msg_input:
                mIsClicked = true;
                break;
            case R.id.image_btn_praise:
                onSendPraise();
                break;
            case R.id.qav_show_tips:
                showTips = !showTips;
                if (showTips) {
                    tvShowTips.setText("CloseTips");
                    tvShowTips.setTextColor(Color.RED);
                } else {
                    tvShowTips.setText("OpenTips");
                    tvShowTips.setTextColor(Color.GREEN);
                }
                break;
            case R.id.qav_topbar_push:
                Push();
                break;
            case R.id.qav_topbar_streamtype:
                switch (StreamType) {
                    case 1:
                        ((Button) findViewById(R.id.qav_topbar_streamtype)).setText("FLV");
                        StreamType = 2;
                        break;
                    case 2:
                        ((Button) findViewById(R.id.qav_topbar_streamtype)).setText("RTMP");
                        StreamType = 5;
                        break;
                    case 5:
                        ((Button) findViewById(R.id.qav_topbar_streamtype)).setText("HLS");
                        StreamType = 1;
                        break;
                }
                break;
            case R.id.qav_topbar_record:
                //Record();
                if (!mRecord) {
                    setRecordParam();
                } else {
                    stopRecord();
                }
                break;
            default:
                break;
        }
    }

    public void Push() {
        int roomid = (int) mQavsdkControl.getAVContext().getRoom().getRoomId();
        Log.e(TAG, "roomid: " + roomid);
        Log.e(TAG, "groupid: " + groupForPush);
        Log.e(TAG, "mpush: " + mpush);
        TIMAvManager.StreamEncode st;
        if (StreamType == 1)
            st = TIMAvManager.StreamEncode.FLV;
        else
            st = TIMAvManager.StreamEncode.HLS;

        if (!mpush) {
            TIMAvManager.getInstance().requestMultiVideoStreamerStart(groupForPush, roomid, "hello", st, new TIMValueCallBack<List<TIMAvManager.LiveUrl>>() {
                @Override
                public void onError(int i, String s) {
                    Log.e(TAG, "url error " + i + " : " + s);
                    Toast.makeText(getApplicationContext(), "start stream error,try again " + i + " : " + s, Toast.LENGTH_SHORT).show();
                }

                @Override
                public void onSuccess(List<TIMAvManager.LiveUrl> liveUrls) {
                    mpush = true;
                    Log.e(TAG, liveUrls.toString());
                    ((Button) findViewById(R.id.qav_topbar_push)).setTextColor(getResources().getColor(R.color.red));
                    ((Button) findViewById(R.id.qav_topbar_push)).setText("停推");
                    int length = liveUrls.size();
                    String url = null;
                    for (int i = 0; i < length; i++) {
                        TIMAvManager.LiveUrl avUrl = liveUrls.get(i);
                        url = avUrl.getUrl();
                        Log.e(TAG, "url success " + " : " + url);
                    }

                    final String finalUrl = url;
                    dialog = new Dialog(AvActivity.this, R.style.dialog);
                    dialog.setContentView(R.layout.alert_dialog);
                    ((TextView) dialog.findViewById(R.id.dialog_title)).setText("复制到粘贴板");
                    ((TextView) dialog.findViewById(R.id.dialog_message)).setText(url);
                    ((Button) dialog.findViewById(R.id.close_dialog)).setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            ClipboardManager clip = (ClipboardManager) getApplicationContext().getSystemService(getApplicationContext().CLIPBOARD_SERVICE);
                            clip.setText(finalUrl);
                            dialog.dismiss();
                            //Toast.makeText(getApplicationContext(), "copy success", Toast.LENGTH_SHORT).show();
                        }
                    });
                    dialog.setCanceledOnTouchOutside(false);
                    dialog.show();
/*
                    final AlertDialog.Builder builder = new AlertDialog.Builder(AvActivity.this);

					builder.setTitle("已复制到粘贴板")
							.setCancelable(false)
							.setMessage(url)
							.setPositiveButton("确定", new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog, int which) {
									ClipboardManager clip = (ClipboardManager) getApplicationContext().getSystemService(getApplicationContext().CLIPBOARD_SERVICE);
									clip.setText(finalUrl);

									dialog.dismiss();
									Toast.makeText(getApplicationContext(), clip.getText(), Toast.LENGTH_SHORT).show();
								}
							}).show();*/

                }
            });
        } else {

            TIMAvManager.getInstance().requestMultiVideoStreamerStop(groupForPush, roomid, "hello", st, new TIMValueCallBack<List<TIMAvManager.LiveUrl>>() {
                @Override
                public void onError(int i, String s) {
                    Log.e(TAG, "url stop error " + i + " : " + s);
                    Toast.makeText(getApplicationContext(), "stop stream error,try again " + i + " : " + s, Toast.LENGTH_SHORT).show();
                }

                @Override
                public void onSuccess(List<TIMAvManager.LiveUrl> liveUrls) {
                    mpush = false;
                    ((Button) findViewById(R.id.qav_topbar_push)).setTextColor(getResources().getColor(R.color.white));
                    ((Button) findViewById(R.id.qav_topbar_push)).setText("推流");
                    int length = liveUrls.size();
                    for (int i = 0; i < length; i++) {
                        TIMAvManager.LiveUrl avUrl = liveUrls.get(i);
                        String url = avUrl.getUrl();
                        Log.e(TAG, "url stop success " + " : " + url);
                    }
                    Toast.makeText(getApplicationContext(), "stop stream success", Toast.LENGTH_SHORT).show();
                }
            });
        }
    }

    private EditText filenameEditText;
    private EditText tagEditText;
    private EditText classEditText;
    private CheckBox trancodeCheckBox;
    private CheckBox screenshotCheckBox;
    private CheckBox watermarkCheckBox;
    private String filename = "";
    private String tags = "";
    private String classId = "";
    TIMAvManager.RecordParam mRecordParam;

    private void setRecordParam() {
        dialog = new Dialog(this, R.style.dialog);
        dialog.setContentView(R.layout.record_param);
        mRecordParam = TIMAvManager.getInstance().new RecordParam();
        filenameEditText = (EditText) dialog.findViewById(R.id.record_filename);
        tagEditText = (EditText) dialog.findViewById(R.id.record_tag);
        classEditText = (EditText) dialog.findViewById(R.id.record_class);
        trancodeCheckBox = (CheckBox) dialog.findViewById(R.id.record_tran_code);
        screenshotCheckBox = (CheckBox) dialog.findViewById(R.id.record_screen_shot);
        watermarkCheckBox = (CheckBox) dialog.findViewById(R.id.record_water_mark);

        if (filename.length() > 0) {
            filenameEditText.setText(filename);
        }

        if (tags.length() > 0) {
            tagEditText.setText(tags);
        }

        if (classId.length() > 0) {
            classEditText.setText(classId);
        }
        Button recordOk = (Button) dialog.findViewById(R.id.btn_record_ok);
        recordOk.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                filename = filenameEditText.getText().toString();
                mRecordParam.setFilename(filename);
                tags = tagEditText.getText().toString();
                classId = classEditText.getText().toString();
                Log.d(TAG, "onClick classId " + classId);
                if (classId.equals("")) {
                    Toast.makeText(getApplicationContext(), "classID can not be empty", Toast.LENGTH_LONG).show();
                    return;
                }
                mRecordParam.setClassId(Integer.parseInt(classId));
                mRecordParam.setTransCode(trancodeCheckBox.isChecked());
                mRecordParam.setSreenShot(screenshotCheckBox.isChecked());
                mRecordParam.setWaterMark(watermarkCheckBox.isChecked());
                mHandler.sendEmptyMessage(START_RECORD);
                startOrientationListener();
                dialog.dismiss();
            }
        });
        Button recordCancel = (Button) dialog.findViewById(R.id.btn_record_cancel);
        recordCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startOrientationListener();
                dialog.dismiss();
            }
        });
        stopOrientationListener();
        dialog.setCanceledOnTouchOutside(false);
        dialog.show();
    }


    public void startRecord() {
        int roomid = (int) mQavsdkControl.getAVContext().getRoom().getRoomId();
        Log.e(TAG, "roomid: " + roomid);
        Log.e(TAG, "groupid: " + groupForPush);
        TIMAvManager.getInstance().requestMultiVideoRecorderStart(groupForPush, roomid, "hello", mRecordParam, new TIMCallBack() {
            @Override
            public void onError(int i, String s) {
                Log.e(TAG, "Record error" + i + " : " + s);
                Toast.makeText(getApplicationContext(), "start record error,try again", Toast.LENGTH_LONG).show();
            }

            @Override
            public void onSuccess() {
                mRecord = true;
                ((Button) findViewById(R.id.qav_topbar_record)).setTextColor(getResources().getColor(R.color.red));
                ((Button) findViewById(R.id.qav_topbar_record)).setText("停录");
                Log.e(TAG, "begin to record");
                Toast.makeText(getApplicationContext(), "start record now ", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void stopRecord() {
        int roomid = (int) mQavsdkControl.getAVContext().getRoom().getRoomId();
        TIMAvManager.getInstance().requestMultiVideoRecorderStop(groupForPush, roomid, "hello", new TIMValueCallBack<List<String>>() {
            @Override
            public void onError(int i, String s) {
                Log.e(TAG, "stop record error " + i + " : " + s);
                Toast.makeText(getApplicationContext(), "stop record error,try again", Toast.LENGTH_LONG).show();
            }

            @Override
            public void onSuccess(List<String> file) {
                mRecord = false;
                ((Button) findViewById(R.id.qav_topbar_record)).setTextColor(getResources().getColor(R.color.white));
                ((Button) findViewById(R.id.qav_topbar_record)).setText("录制");
                Log.e(TAG, "stop record success");
                Toast.makeText(getApplicationContext(), "stop record success", Toast.LENGTH_SHORT).show();
            }
        });
        Log.d(TAG, "success");
    }

    protected void onCheckedChanged(boolean checked) {
        AVAudioCtrl avAudioCtrl = mQavsdkControl.getAVContext().getAudioCtrl();
        if (checked) {
            avAudioCtrl.enableMic(true);
        } else {
            avAudioCtrl.enableMic(false);
        }
    }

    private void onSwitchCamera() {
        boolean isFront = mQavsdkControl.getIsFrontCamera();
        mSwitchCameraErrorCode = mQavsdkControl.toggleSwitchCamera();
        refreshCameraUI();
        if (mSwitchCameraErrorCode != AVConstants.AV_ERROR_OK) {
            showDialog(isFront ? DIALOG_SWITCH_BACK_CAMERA_FAILED : DIALOG_SWITCH_FRONT_CAMERA_FAILED);
            mQavsdkControl.setIsInSwitchCamera(false);
            refreshCameraUI();
        }
    }

    private void onCloseVideo() {
        stopOrientationListener();
//		showDialog(DIALOG_DESTROY);
        if (mSelfUserInfo.isCreater() != true) {
            Util.switchWaitingDialog(ctx, mDialogAtDestroy, DIALOG_DESTROY, true);
        }
        if (mIsSuccess) {
            mChatTimer.cancel();
            mVideoTimer.cancel();
            timer.cancel();
            mHeartClickTimer.cancel();
        }
        destroyTIM();
        mQavsdkControl.exitRoom();
        if (wakeLock.isHeld())
            wakeLock.release();
        if (mSelfUserInfo.isCreater() == true) {
            closeLive();
            setResult(Util.SHOW_RESULT_CODE);
            Util.switchWaitingDialog(ctx, mDialogAtDestroy, DIALOG_DESTROY, true);
            startActivity(new Intent(AvActivity.this, GameOverActivity.class)
                    .putExtra(Util.EXTRA_ROOM_NUM, roomNum));
        } else {
            leaveLive();
            setResult(Util.VIEW_RESULT_CODE);
        }
        finish();
    }

    private void closeLive() {
        new Thread() {
            @Override
            public void run() {
                super.run();
                JSONObject object = new JSONObject();
                try {
                    Log.d(TAG, "DEBUG " + mRecvIdentifier);
                    object.put(Util.EXTRA_ROOM_NUM, roomNum);
                    System.out.println(object.toString());
                    List<NameValuePair> list = new ArrayList<NameValuePair>();
                    list.add(new BasicNameValuePair("closedata", object.toString()));
                    String ret = HttpUtil.PostUrl(HttpUtil.liveCloseUrl, list);
                    Log.d(TAG, "close room" + ret);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }.start();
    }

    private void leaveLive() {
        new Thread() {
            @Override
            public void run() {
                super.run();
                JSONObject object = new JSONObject();
                try {
                    object.put(Util.EXTRA_ROOM_NUM, roomNum);
                    object.put(Util.EXTRA_USER_PHONE, mSelfUserInfo.getUserPhone());
                    System.out.println(object.toString());
                    List<NameValuePair> list = new ArrayList<NameValuePair>();
                    list.add(new BasicNameValuePair("viewerout", object.toString()));
                    String ret = HttpUtil.PostUrl(HttpUtil.closeLiveUrl, list);
                    Log.d(TAG, "leave room" + ret);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }.start();
    }

    private void onSendMsg() {
        final String msg = mEditTextInputMsg.getText().toString();
        mEditTextInputMsg.setText("");
        if (msg.length() > 0) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    sendText(msg);
                }
            }).start();
        }
    }

    private void sendText(String msg) {
        if (msg.length() == 0)
            return;
        try {
            byte[] byte_num = msg.getBytes("utf8");
            if (byte_num.length > 160) {
                mHandler.sendEmptyMessage(ERROR_MESSAGE_TOO_LONG);
                return;
            }

        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return;
        }
        TIMMessage Nmsg = new TIMMessage();
        TIMTextElem elem = new TIMTextElem();
        elem.setText(msg);
        if (Nmsg.addElement(elem) != 0) {
            return;
        }
        mConversation.sendMessage(Nmsg, new TIMValueCallBack<TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                if (i == 85) {
                    mHandler.sendEmptyMessage(ERROR_MESSAGE_TOO_LONG);
                } else if (i == 6011) {
                    mHandler.sendEmptyMessage(ERROR_ACCOUNT_NOT_EXIT);
                }
                Log.e(TAG, "send message failed. code: " + i + " errmsg: " + s);
                getMessage();
            }

            @Override
            public void onSuccess(TIMMessage timMessage) {
                Log.e(TAG, "Send text Msg ok");
                getMessage();
            }
        });
    }

    private void handleCustomMsg(TIMElem elem) {
        try {
            String customText = new String(((TIMCustomElem) elem).getData(), "UTF-8");
            String splitItems[] = customText.split("&");
            int cmd = Integer.parseInt(splitItems[1]);
            for (int i = 0; i < splitItems.length; ++i) {
                Log.d(TAG, "xujinguangmsg:" + splitItems[i] + "loop" + i);
            }
            switch (cmd) {
                case PRIASE_MSG:
                    int num = Integer.parseInt(splitItems[2]);
                    praiseNum += num;
                    mPraiseNum.setText("" + praiseNum);
                    break;
                case MEMBER_ENTER_MSG:
                    boolean isExist = false;
                    for (int i = 0; i < mMemberList.size(); ++i) {
                        String userPhone = mMemberList.get(i).getUserPhone();
                        if (userPhone.equals(splitItems[0])) {
                            isExist = true;
                            break;
                        }
                    }
                    if (!isExist) {
                        MemberInfo member;
                        Log.d(TAG, "handleCustomMsg splitItems.length " + splitItems.length);
                        if (2 < splitItems.length) {
                            member = new MemberInfo(splitItems[0], splitItems[2], splitItems[1]);
                        } else {
                            member = new MemberInfo(splitItems[0], "", splitItems[1]);
                        }
                        mMemberList.add(member);

                        setMemberHeadImage();
                    }
                    break;
                case MEMBER_EXIT_MSG:
                    for (int i = 0; i < mMemberList.size(); ++i) {
                        String userPhone = mMemberList.get(i).getUserPhone();
                        if (userPhone.equals(splitItems[0])) {

                            mMemberList.remove(i);

                        }
                    }
                    setGridView();
                    break;
                default:
                    break;
            }
        } catch (UnsupportedEncodingException e) {
        }
    }

    public void setMemberHeadImage() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                ImageUtil tool = new ImageUtil();
                for (int i = 0; i < mMemberList.size(); ++i) {
                    if (mMemberList.get(i).getHeadImage() == null) {
                        //Log.d(TAG, "xujinguang" + mMemberList.get(i).getHeadImagePath());
                        String param = "?imagepath=" + mMemberList.get(i).getHeadImagePath() + "&width=0&height=0";
                        Bitmap headBitmap = tool.getImageFromServer(param);
                        if (i < mMemberList.size())
                            mMemberList.get(i).setHeadImage(headBitmap);
                    }
                }
                mHandler.sendEmptyMessage(UPDAT_MEMBER);
            }
        }).start();
    }

    private void initGridView() {
        mGridView = (GridView) findViewById(R.id.grid);
        DisplayMetrics dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(dm);
        density = dm.density;
        int itemWidth = (int) (slength * density);
        mGridView.setColumnWidth(itemWidth);
        mGridView.setHorizontalSpacing(0);
        mGridView.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);
    }

    private void setGridView() {
        int size = mMemberList.size();
        int gridviewWidth = 0;
        if (size == 1) {
            gridviewWidth = (int) (size * (slength + 5) * density);
        } else {
            gridviewWidth = (int) (size * (slength) * density);
        }
        Log.d(TAG, "setGridView gridvieWidth" + gridviewWidth);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
                gridviewWidth, LinearLayout.LayoutParams.WRAP_CONTENT);
        mGridView.setLayoutParams(params);
        mGridView.setNumColumns(size);
        GridViewAdapter adapter = (GridViewAdapter) mGridView.getAdapter();
        if (adapter != null) {
            mGridView.postInvalidate();
        } else {
            adapter = new GridViewAdapter(getApplicationContext(), mMemberList);
            mGridView.setAdapter(adapter);
        }
    }

    public class GridViewAdapter extends BaseAdapter {
        Context context;
        List<MemberInfo> list;

        public GridViewAdapter(Context context, List<MemberInfo> list) {
            this.list = list;
            this.context = context;
        }

        @Override
        public int getCount() {
            return list.size();
        }

        @Override
        public Object getItem(int position) {
            return list.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            LayoutInflater layoutInflater = LayoutInflater.from(context);
            convertView = layoutInflater.inflate(R.layout.member_head_image, null);
            CircularImageButton headImage = (CircularImageButton) convertView.findViewById(R.id.head_image);
            headImage.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
            MemberInfo item = list.get(position);
            headImage.setImageBitmap(item.getHeadImage());
            return convertView;
        }
    }

    private void onSendPraise() {
        String message = mSelfUserInfo.getUserPhone() + "&" + PRIASE_MSG + "&" + 1;
        TIMMessage Tim = new TIMMessage();
        TIMCustomElem elem = new TIMCustomElem();
        elem.setData(message.getBytes());
        elem.setDesc(UNREAD);
        if (1 == Tim.addElement(elem))
            Toast.makeText(getApplicationContext(), "priase error", Toast.LENGTH_SHORT).show();
        else {
            mConversation.sendMessage(Tim, new TIMValueCallBack<TIMMessage>() {
                @Override
                public void onError(int i, String s) {
                    Log.e(TAG, "send praise error " + i + ": " + s);
                }

                @Override
                public void onSuccess(TIMMessage timMessage) {
                    Log.i(TAG, "send priase success");
                }
            });
        }
        getMessage();
        sendPraiseToServer();
    }

    private void sendPraiseToServer() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                JSONObject object = new JSONObject();
                try {
                    object.put(Util.EXTRA_ROOM_NUM, roomNum);
                    object.put("addnum", 1);
                    System.out.println(object.toString());
                    List<NameValuePair> list = new ArrayList<NameValuePair>();
                    list.add(new BasicNameValuePair("praisedata", object.toString()));
                    String ret = HttpUtil.PostUrl(HttpUtil.liveAddPraiseUrl, list);
                    Log.e(TAG, "send praise to server return: " + ret);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    private void onMemberEnter() {
        String message = mSelfUserInfo.getUserPhone() + "&"
                + MEMBER_ENTER_MSG + "&"
                + mSelfUserInfo.getUserName() + "&"
                + mSelfUserInfo.getHeadImagePath();
        TIMMessage Tim = new TIMMessage();
        TIMCustomElem elem = new TIMCustomElem();
        elem.setData(message.getBytes());
        elem.setDesc(UNREAD);
        if (1 == Tim.addElement(elem))
            Toast.makeText(getApplicationContext(), "enter error", Toast.LENGTH_SHORT).show();
        else {
            mConversation.sendMessage(Tim, new TIMValueCallBack<TIMMessage>() {
                @Override
                public void onError(int i, String s) {
                    Log.e(TAG, "enter error" + i + ": " + s);
                }

                @Override
                public void onSuccess(TIMMessage timMessage) {
                    Log.i(TAG, "enter  success");
                }
            });
        }

        final String msg = "轻轻地“" + mSelfUserInfo.getUserName() + "”来了";
        if (msg.length() > 0) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    sendText(msg);
                }
            }).start();
        }
    }

    private void onMemberExit() {
        String message = mSelfUserInfo.getUserPhone() + "&"
                + MEMBER_EXIT_MSG;
        TIMMessage Tim = new TIMMessage();
        TIMCustomElem elem = new TIMCustomElem();
        elem.setData(message.getBytes());
        elem.setDesc(UNREAD);
        if (1 == Tim.addElement(elem))
            Toast.makeText(getApplicationContext(), "exit error", Toast.LENGTH_SHORT).show();
        else {
            mConversation.sendMessage(Tim, new TIMValueCallBack<TIMMessage>() {
                @Override
                public void onError(int i, String s) {
                    Log.e(TAG, "exit error" + i + ": " + s);
                    mHandler.sendEmptyMessage(MEMBER_EXIT_COMPLETE);
                }

                @Override
                public void onSuccess(TIMMessage timMessage) {
                    Log.i(TAG, "exit  success");
                    mHandler.sendEmptyMessage(MEMBER_EXIT_COMPLETE);
                }
            });
        }
        mMemberList.clear();
    }

    private void sendCloseMsg() {
        final String msg = "轻轻地“" + mSelfUserInfo.getUserName() + "”离开了";
        new Thread(new Runnable() {
            @Override
            public void run() {
                if (msg.length() == 0)
                    return;
                try {
                    byte[] byte_num = msg.getBytes("utf8");
                    if (byte_num.length > 160) {
                        mHandler.sendEmptyMessage(ERROR_MESSAGE_TOO_LONG);
                        return;
                    }

                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                    return;
                }
                TIMMessage Nmsg = new TIMMessage();
                TIMTextElem elem = new TIMTextElem();
                elem.setText(msg);
                if (Nmsg.addElement(elem) != 0) {
                    return;
                }
                mConversation.sendMessage(Nmsg, new TIMValueCallBack<TIMMessage>() {
                    @Override
                    public void onError(int i, String s) {
                        if (i == 85) {
                            mHandler.sendEmptyMessage(ERROR_MESSAGE_TOO_LONG);
                        } else if (i == 6011) {
                            mHandler.sendEmptyMessage(ERROR_ACCOUNT_NOT_EXIT);
                        }
                        Log.e(TAG, "send message failed. code: " + i + " errmsg: " + s);
                        mHandler.sendEmptyMessage(CLOSE_VIDEO);
                    }

                    @Override
                    public void onSuccess(TIMMessage timMessage) {
                        Log.e(TAG, "Send text Msg ok");
                        mHandler.sendEmptyMessage(CLOSE_VIDEO);
                    }
                });
            }
        }).start();

    }

    private void getMemberInfo() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                List<NameValuePair> params = new ArrayList<NameValuePair>();
                JSONObject object = new JSONObject();
                String url = "http://203.195.167.34/user_getinfobatch.php";
                String response = "";
                try {
                    object.put(Util.EXTRA_ROOM_NUM, roomNum);
                    Log.d(TAG, object.toString());
                    params.add(new BasicNameValuePair("data", object.toString()));
                    response = HttpUtil.PostUrl(url, params);
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                Log.d(TAG, TAG + response);
                if (0 == response.length()) {
                    return;
                }
                Log.d(TAG, "memberlist" + response);
                JSONTokener jsonTokener = new JSONTokener(response);
                try {
                    object = (JSONObject) jsonTokener.nextValue();
                    int ret = object.getInt("code");
                    if (ret != 200) {
                        return;
                    }

                    JSONArray array = object.getJSONArray("data");
                    for (int i = 0; i < array.length(); i++) {
                        JSONObject jobject = array.getJSONObject(i);
                        Log.d(TAG, "member size" + mMemberList.size());
                        MemberInfo member = new MemberInfo(jobject.getString(Util.EXTRA_USER_PHONE),
                                jobject.getString(Util.EXTRA_USER_NAME),
                                jobject.getString(Util.EXTRA_HEAD_IMAGE_PATH));
                        Log.d(TAG, "member" + member.getUserPhone() + member.getUserName() + member.getHeadImagePath());
                        mMemberList.add(member);
                    }
                    setMemberHeadImage();
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    @Override
    protected Dialog onCreateDialog(int id) {
        Dialog dialog = null;

        switch (id) {
            case DIALOG_INIT:
                dialog = mDialogInit = Util.newProgressDialog(this, R.string.interface_initialization);
                break;
            case DIALOG_AT_ON_CAMERA:
                dialog = mDialogAtOnCamera = Util.newProgressDialog(this, R.string.at_on_camera);
                break;
            case DIALOG_ON_CAMERA_FAILED:
                dialog = Util.newErrorDialog(this, R.string.on_camera_failed);
                break;
            case DIALOG_AT_OFF_CAMERA:
                dialog = mDialogAtOffCamera = Util.newProgressDialog(this, R.string.at_off_camera);
                break;
            case DIALOG_OFF_CAMERA_FAILED:
                dialog = Util.newErrorDialog(this, R.string.off_camera_failed);
                break;

            case DIALOG_AT_SWITCH_FRONT_CAMERA:
                dialog = mDialogAtSwitchFrontCamera = Util.newProgressDialog(this, R.string.at_switch_front_camera);
                break;
            case DIALOG_SWITCH_FRONT_CAMERA_FAILED:
                dialog = Util.newErrorDialog(this, R.string.switch_front_camera_failed);
                break;
            case DIALOG_AT_SWITCH_BACK_CAMERA:
                dialog = mDialogAtSwitchBackCamera = Util.newProgressDialog(this, R.string.at_switch_back_camera);
                break;
            case DIALOG_SWITCH_BACK_CAMERA_FAILED:
                dialog = Util.newErrorDialog(this, R.string.switch_back_camera_failed);
                break;
            case DIALOG_DESTROY:
                dialog = mDialogAtDestroy = Util.newProgressDialog(this, R.string.at_close_room);
                break;
            default:
                break;
        }
        return dialog;
    }

    @Override
    protected void onPrepareDialog(int id, Dialog dialog) {
        switch (id) {
            case DIALOG_ON_CAMERA_FAILED:
            case DIALOG_OFF_CAMERA_FAILED:
                ((AlertDialog) dialog).setMessage(getString(R.string.error_code_prefix) + mOnOffCameraErrorCode);
                break;
            case DIALOG_SWITCH_FRONT_CAMERA_FAILED:
            case DIALOG_SWITCH_BACK_CAMERA_FAILED:
                ((AlertDialog) dialog).setMessage(getString(R.string.error_code_prefix) + mSwitchCameraErrorCode);
                break;
            default:
                break;
        }
    }

    private void refreshCameraUI() {
        boolean isEnable = mQavsdkControl.getIsEnableCamera();
        boolean isFront = mQavsdkControl.getIsFrontCamera();
        boolean isInOnOffCamera = mQavsdkControl.getIsInOnOffCamera();
        boolean isInSwitchCamera = mQavsdkControl.getIsInSwitchCamera();


        if (isInOnOffCamera) {
            if (isEnable) {
                Util.switchWaitingDialog(this, mDialogAtOffCamera, DIALOG_AT_OFF_CAMERA, true);
                Util.switchWaitingDialog(this, mDialogAtOnCamera, DIALOG_AT_ON_CAMERA, false);
            } else {
                Util.switchWaitingDialog(this, mDialogAtOffCamera, DIALOG_AT_OFF_CAMERA, false);
                Util.switchWaitingDialog(this, mDialogAtOnCamera, DIALOG_AT_ON_CAMERA, true);
            }
        } else {
            Util.switchWaitingDialog(this, mDialogAtOffCamera, DIALOG_AT_OFF_CAMERA, false);
            Util.switchWaitingDialog(this, mDialogAtOnCamera, DIALOG_AT_ON_CAMERA, false);
        }

        if (isInSwitchCamera) {
            if (isFront) {
                Util.switchWaitingDialog(this, mDialogAtSwitchBackCamera, DIALOG_AT_SWITCH_BACK_CAMERA, true);
                Util.switchWaitingDialog(this, mDialogAtSwitchFrontCamera, DIALOG_AT_SWITCH_FRONT_CAMERA, false);
            } else {
                Util.switchWaitingDialog(this, mDialogAtSwitchBackCamera, DIALOG_AT_SWITCH_BACK_CAMERA, false);
                Util.switchWaitingDialog(this, mDialogAtSwitchFrontCamera, DIALOG_AT_SWITCH_FRONT_CAMERA, true);
            }
        } else {
            Util.switchWaitingDialog(this, mDialogAtSwitchBackCamera, DIALOG_AT_SWITCH_BACK_CAMERA, false);
            Util.switchWaitingDialog(this, mDialogAtSwitchFrontCamera, DIALOG_AT_SWITCH_FRONT_CAMERA, false);
        }
    }

    class VideoOrientationEventListener extends OrientationEventListener {
        boolean mbIsTablet = false;

        public VideoOrientationEventListener(Context context, int rate) {
            super(context, rate);
            mbIsTablet = PhoneStatusTools.isTablet(context);
        }

        int mLastOrientation = -25;

        @Override
        public void onOrientationChanged(int orientation) {
            if (orientation == OrientationEventListener.ORIENTATION_UNKNOWN) {
                mLastOrientation = orientation;
                return;
            }

            if (mLastOrientation < 0) {
                mLastOrientation = 0;
            }

            if (((orientation - mLastOrientation) < 20)
                    && ((orientation - mLastOrientation) > -20)) {
                return;
            }

            if (mbIsTablet) {
                orientation -= 90;
                if (orientation < 0) {
                    orientation += 360;
                }
            }
            mLastOrientation = orientation;

            if (orientation > 314 || orientation < 45) {
                if (mQavsdkControl != null) {
                    mQavsdkControl.setRotation(0);
                }
                mRotationAngle = 0;
            } else if (orientation > 44 && orientation < 135) {
                if (mQavsdkControl != null) {
                    mQavsdkControl.setRotation(90);
                }
                mRotationAngle = 90;
            } else if (orientation > 134 && orientation < 225) {
                if (mQavsdkControl != null) {
                    mQavsdkControl.setRotation(180);
                }
                mRotationAngle = 180;
            } else {
                if (mQavsdkControl != null) {
                    mQavsdkControl.setRotation(270);
                }
                mRotationAngle = 270;
            }
        }
    }

    void registerOrientationListener() {
        if (mOrientationEventListener == null) {
            mOrientationEventListener = new VideoOrientationEventListener(super.getApplicationContext(), SensorManager.SENSOR_DELAY_UI);
        }
    }

    void startOrientationListener() {
        if (mOrientationEventListener != null) {
            mOrientationEventListener.enable();
        }
    }

    void stopOrientationListener() {
        if (mOrientationEventListener != null) {
            mOrientationEventListener.disable();
        }
    }

    private void updateWallTime() {
        String formatTime;
        String hs, ms, ss;

        long h, m, s;
        h = second / 3600;
        m = (second % 3600) / 60;
        s = (second % 3600) % 60;
        if (h < 10) {
            hs = "0" + h;
        } else {
            hs = "" + h;
        }

        if (m < 10) {
            ms = "0" + m;
        } else {
            ms = "" + m;
        }

        if (s < 10) {
            ss = "0" + s;
        } else {
            ss = "" + s;
        }

        formatTime = hs + ":" + ms + ":" + ss;
        mClockTextView.setText(formatTime);
    }

    private void removeChatItem() {
        time += 2;
        int num = mListViewMsgItems.getCount();
        Log.e(TAG, "lvCount:" + num);
        if (num > 0) {
            for (int i = num - 1; i >= 0; i--) {
                if (mArrayListChatEntity.size() == 0) return;
                if (time - mArrayListChatEntity.get(i).getTime() > 10) {
                    Log.e(TAG, "remove");
                    mArrayListChatEntity.remove(i);
                }
            }
            mChatMsgListAdapter.notifyDataSetChanged();
            mListViewMsgItems.setVisibility(View.VISIBLE);
        }
    }

    private Dialog dialog;

    private void closeAlertDialog() {
        dialog = new Dialog(this, R.style.dialog);
        dialog.setContentView(R.layout.exit_dialog);
        TextView messageTextView = (TextView) dialog.findViewById(R.id.message);
        Button exitOk = (Button) dialog.findViewById(R.id.btn_exit_ok);
        Button exitCancel = (Button) dialog.findViewById(R.id.btn_exit_cancel);
        messageTextView.setText("有" + mMemberList.size() + "人正在看您的直播\n确定结束直播吗？");
        exitOk.setText("结束直播");
        exitCancel.setText("继续直播");
        exitOk.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onCloseVideo();
                dialog.dismiss();
            }
        });

        exitCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startOrientationListener();
                dialog.dismiss();
            }
        });
        stopOrientationListener();
        dialog.show();
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        switch (keyCode) {
            case KeyEvent.KEYCODE_BACK:
                if (mIsClicked) {
                    mIsClicked = false;
                    break;
                }
                if (mSelfUserInfo.isCreater())
                    closeAlertDialog();
                else
                    onCloseVideo();
                break;
        }

        return false; //这一句很关键
    }

    private boolean isTopActivity() {
        boolean isTop = false;
        ActivityManager am = (ActivityManager) getSystemService(ACTIVITY_SERVICE);
        ComponentName cn = am.getRunningTasks(1).get(0).topActivity;
        if (cn.getClassName().contains(TAG)) {
            isTop = true;
        }
        return isTop;
    }


    private static final int TIMER_INTERVAL = 1000;
    private TextView tvTipsMsg;
    private boolean showTips = false;
    private TextView tvShowTips;
    Timer timer = new Timer();
    TimerTask task = new TimerTask() {
        public void run() {
            runOnUiThread(new Runnable() {
                public void run() {
                    if (showTips) {
                        if (tvTipsMsg != null) {
                            String strTips = mQavsdkControl.getQualityTips();
                            strTips = praseString(strTips);
                            if (!TextUtils.isEmpty(strTips)) {
                                tvTipsMsg.setText(strTips);
                            }
                        }
                    } else {
                        tvTipsMsg.setText("");
                    }
                }
            });
        }
    };

    private String praseString(String video) {
        if (video.length() == 0) {
            return "";
        }
        String result = "";
        String splitItems[];
        String tokens[];
        splitItems = video.split("\\n");
        for (int i = 0; i < splitItems.length; ++i) {
            if (splitItems[i].length() < 2)
                continue;

            tokens = splitItems[i].split(":");
            if (tokens[0].length() == "mainVideoSendSmallViewQua".length()) {
                continue;
            }
            if (tokens[0].endsWith("BigViewQua")) {
                tokens[0] = "mainVideoSendViewQua";
            }
            if (tokens[0].endsWith("BigViewQos")) {
                tokens[0] = "mainVideoSendViewQos";
            }
            result += tokens[0] + ":\n" + "\t\t";
            for (int j = 1; j < tokens.length; ++j)
                result += tokens[j];
            result += "\n\n";
            //Log.d(TAG, "test:" + result);
        }
        //Log.d(TAG, "test:" + result);
        return result;
    }

    private void initShowTips() {
        tvTipsMsg = (TextView) findViewById(R.id.qav_tips_msg);
        tvTipsMsg.setTextColor(Color.GREEN);
        tvShowTips = (TextView) findViewById(R.id.qav_show_tips);
        tvShowTips.setTextColor(Color.GREEN);
        tvShowTips.setText("Tips");
        tvShowTips.setOnClickListener(this);
        timer.schedule(task, TIMER_INTERVAL, TIMER_INTERVAL);
    }

    private void heartClick(){
        Log.d(TAG, "heartClick click ");
        JSONObject object = new JSONObject();
        try {
            object.put(Util.EXTRA_LIVEPHONE, mSelfUserInfo.getUserPhone());
            List<NameValuePair> list = new ArrayList<NameValuePair>();
            list.add(new BasicNameValuePair("heartTime", object.toString()));
            String ret = HttpUtil.PostUrl(HttpUtil.heartClickUrl, list);
            Log.d(TAG, "hear click" + ret);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    };
}