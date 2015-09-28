package com.tencent.avsdk;


import android.content.Context;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.TIMElemType;
import com.tencent.TIMTextElem;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;


public class ChatMsgListAdapter extends BaseAdapter {

	private static String TAG = ChatMsgListAdapter.class.getSimpleName();
	private static final int ITEMCOUNT = 9;
	private List<ChatEntity> listMessage = null;
	private LayoutInflater inflater;
	private LinearLayout layout;
	public static final int TYPE_TEXT_SEND = 0;
	public static final int TYPE_TEXT_RECV = 1;
	private Context context;
	private Timer mTimer;
	private TimerTask mTimerTask;
	private ArrayList<MemberInfo> mMemberList;
	public ChatMsgListAdapter(Context context, List<ChatEntity> objects, ArrayList<MemberInfo> memberList) {
		this.context = context;
		inflater = LayoutInflater.from(context);
		this.listMessage = objects;
		mMemberList = memberList;
	}


	@Override
	public int getCount() {
		return listMessage.size();
	}

	@Override
	public Object getItem(int position) {
		return listMessage.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public int getItemViewType(int position) {
		ChatEntity entity = listMessage.get(position);
		if(entity.getElem().getType()== TIMElemType.Text){
			return entity.getIsSelf() ? TYPE_TEXT_SEND : TYPE_TEXT_RECV;
		}
		return -1;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent){
		layout = (LinearLayout) inflater.inflate(R.layout.chat_item_left,null);
		ChatEntity entity = listMessage.get(position);
		TIMTextElem elem = (TIMTextElem) entity.getElem();
		CircularImageButton sendheadimage = (CircularImageButton)layout.findViewById(R.id.tv_chat_head_image);
		TextView sendcontent = (TextView) layout.findViewById(R.id.tv_chatcontent);
		for(int i = 0; i < mMemberList.size(); ++i) {
			if(mMemberList.get(i).getUserPhone().equals(entity.getSenderName())) {
				Bitmap bm = mMemberList.get(i).getHeadImage();
				if(bm !=  null) {
					sendheadimage.setImageBitmap(bm);
				}
			}
		}
		sendcontent.setText(elem.getText().toString());
		return layout;
	}

	static class ViewHolder {
		public TextView tvSendTime;
		public TextView tvUserName;
		public TextView tvContent;
		public ImageView avatar;
	}
}
