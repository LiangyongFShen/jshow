package com.tencent.avsdk.activity;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.app.TabActivity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TabHost;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.av.opengl.utils.Utils;
import com.tencent.av.sdk.AVConstants;
import com.tencent.avsdk.CircularImageButton;
import com.tencent.avsdk.DemoConstants;
import com.tencent.avsdk.HttpUtil;
import com.tencent.avsdk.ImageConstant;
import com.tencent.avsdk.ImageUtil;
import com.tencent.avsdk.LiveVideoInfo;
import com.tencent.avsdk.LiveVideoInfoAdapter;
import com.tencent.avsdk.ParadeVideoInfo;
import com.tencent.avsdk.ParadeVideoInfoAdapter;
import com.tencent.avsdk.QavsdkApplication;
import com.tencent.avsdk.R;
import com.tencent.avsdk.UserInfo;
import com.tencent.avsdk.Util;
import com.tencent.avsdk.control.QavsdkControl;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by kowalskixu on 2015/8/21.
 */
public class ProgramListActivity extends TabActivity implements View.OnClickListener {
    private static final String TAG = "ProgramListActivity";
    private int mLoginErrorCode = AVConstants.AV_ERROR_OK;
    private static final int DIALOG_LOGIN = 0;
    private static final int DIALOG_LOGOUT = DIALOG_LOGIN + 1;
    private static final int DIALOG_LOGIN_ERROR = DIALOG_LOGOUT + 1;
    private ProgressDialog mDialogLogin = null;
    private ProgressDialog mDialogLogout = null;

    private Context ctx = null;
    private TabHost tabHost;
    private QavsdkControl mQavsdkControl;
    private UserInfo mSelfUserInfo;

    private TextView mTextViewLiveTab;
    private TextView mTextViewParadeTab;
    private View mViewLine0;
    private View mViewLine1;
    private int selectedColor;
    private int unselectedColor;

    private long firstTime = 0;

    private BroadcastReceiver mBroadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals(Util.ACTION_START_CONTEXT_COMPLETE)) {
                mLoginErrorCode = intent.getIntExtra(
                        Util.EXTRA_AV_ERROR_RESULT, AVConstants.AV_ERROR_OK);
                refreshWaitingDialog();
                if (mLoginErrorCode != AVConstants.AV_ERROR_OK) {
                    Log.e(TAG, "登录失败");
                    showDialog(DIALOG_LOGIN_ERROR);
                }
                Log.d(TAG, "start context complete");
            } else if (action.equals(Util.ACTION_CLOSE_CONTEXT_COMPLETE)) {
                mQavsdkControl.setIsInStopContext(false);
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.program_list_activity);
        ctx = this;

        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(Util.ACTION_START_CONTEXT_COMPLETE);
        intentFilter.addAction(Util.ACTION_CLOSE_CONTEXT_COMPLETE);
        registerReceiver(mBroadcastReceiver, intentFilter);

        QavsdkApplication mQavsdkApplication = (QavsdkApplication) getApplication();
        mQavsdkControl = mQavsdkApplication.getQavsdkControl();
        mSelfUserInfo = mQavsdkApplication.getMyselfUserInfo();
        startContext();

        mTextViewLiveTab = (TextView) findViewById(R.id.live_list);
        mTextViewParadeTab = (TextView) findViewById(R.id.parade_list);
        mViewLine0 = findViewById(R.id.line0);
        mViewLine1 = findViewById(R.id.line1);
        mTextViewLiveTab.setOnClickListener(this);
        mTextViewParadeTab.setOnClickListener(this);
        selectedColor = getResources().getColor(R.color.indicators_color);
        unselectedColor = getResources().getColor(R.color.main_gray);
        initTabHost();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        unregisterReceiver(mBroadcastReceiver);
        mQavsdkControl.stopContext();
        mQavsdkControl.setIsInStopContext(false);
    }


    private void initTabHost() {
        tabHost = getTabHost();
        Intent liveIntent = new Intent(this, LiveActivity.class);
        Intent paradeIntent = new Intent(this, ParadeActivity.class);

        TabHost.TabSpec spec1 = tabHost.newTabSpec("livelist");
        spec1.setIndicator("最新直播");
        spec1.setContent(liveIntent);

        TabHost.TabSpec spec2 = tabHost.newTabSpec("paradelist");
        spec2.setIndicator("直播预告");
        spec2.setContent(paradeIntent);

        tabHost.addTab(spec1);
        tabHost.addTab(spec2);
        tabHost.setCurrentTabByTag("livelist");
        updateTab();
        tabHost.setOnTabChangedListener(new OnTabChangedListener()); // 选择监听器
    }

    class OnTabChangedListener implements TabHost.OnTabChangeListener {
        @Override
        public void onTabChanged(String tabId) {
            updateTab();
        }
    }

    private void updateTab() {
        if (tabHost.getCurrentTab() == 0) {
            mTextViewLiveTab.setTextColor(selectedColor);
            mTextViewParadeTab.setTextColor(unselectedColor);
            mViewLine0.setVisibility(View.VISIBLE);
            mViewLine1.setVisibility(View.INVISIBLE);
        } else {
            mTextViewLiveTab.setTextColor(unselectedColor);
            mTextViewParadeTab.setTextColor(selectedColor);
            mViewLine0.setVisibility(View.INVISIBLE);
            mViewLine1.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.live_list:
                tabHost.setCurrentTabByTag("livelist");
                break;
            case R.id.parade_list:
                tabHost.setCurrentTabByTag("paradelist");
                break;
            default:
                break;
        }
    }

    private void startContext() {
        if (!mQavsdkControl.hasAVContext()) {

            String phone = mSelfUserInfo.getUserPhone();
            //if (mSelfUserInfo.getLoginType() == Util.TRUSTEESHIP)
            phone = "86-" + phone;
            Log.e(TAG, "import phone: " + phone+ "Usersig "+ mSelfUserInfo.getUsersig());


            mLoginErrorCode = mQavsdkControl.startContext(
                    phone, mSelfUserInfo.getUsersig());
            Log.e(TAG, "startContext mLoginErrorCode   " +mLoginErrorCode);
            if (mLoginErrorCode != AVConstants.AV_ERROR_OK) {
                Log.e(TAG, "startContext mLoginErrorCode   " +mLoginErrorCode);
                showDialog(DIALOG_LOGIN_ERROR);
            }
            refreshWaitingDialog();
        }
    }

    @Override
    protected Dialog onCreateDialog(int id) {
        Dialog dialog = null;
        switch (id) {
            case DIALOG_LOGIN:
                dialog = mDialogLogin = Util.newProgressDialog(this,
                        R.string.at_login);
                break;

            case DIALOG_LOGOUT:
                dialog = mDialogLogout = Util.newProgressDialog(this,
                        R.string.at_logout);
                break;

            case DIALOG_LOGIN_ERROR:
                dialog = Util.newErrorDialog(this, R.string.login_failed);
                break;

            default:
                break;
        }
        return dialog;
    }

    @Override
    protected void onPrepareDialog(int id, Dialog dialog) {
        switch (id) {
            case DIALOG_LOGIN_ERROR:
                ((AlertDialog) dialog)
                        .setMessage(getString(R.string.error_code_prefix)
                                + mLoginErrorCode);
                break;
            default:
                break;
        }
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        switch (keyCode) {
            case KeyEvent.KEYCODE_BACK:
                long secondTime = System.currentTimeMillis();

                if (secondTime - firstTime > 2000) {
                    firstTime = secondTime;
                    Toast.makeText(this, "再点击一次退出程序", Toast.LENGTH_SHORT).show();
                    return true;
                } else
                    finish();
                break;
        }
        return super.onKeyUp(keyCode, event);
    }

    private void refreshWaitingDialog() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Util.switchWaitingDialog(ctx, mDialogLogin, DIALOG_LOGIN,
                        mQavsdkControl.getIsInStartContext());
                Util.switchWaitingDialog(ctx, mDialogLogout, DIALOG_LOGOUT,
                        mQavsdkControl.getIsInStopContext());
            }
        });
    }
}
