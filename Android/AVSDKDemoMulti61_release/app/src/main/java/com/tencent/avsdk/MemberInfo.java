package com.tencent.avsdk;

import android.graphics.Bitmap;

public class MemberInfo {
    private String userPhone;
    private String userName;
    private String headImagePath = null;
    private Bitmap headImage = null;

    public MemberInfo(String phone) {
        userPhone = phone;
    }

    public MemberInfo(String phone, String name, String path) {
        userPhone = phone;
        userName = name;
        headImagePath = path;
    }

    public void setUserPhone(String phone) {
        userPhone = phone;
    }
    public String getUserPhone() {
        return userPhone;
    }

    public void setUserName(String name) {
        userName = name;
    }
    public String getUserName() {
        return userName;
    }

    public void setHeadImagePath(String path) {
        headImagePath = path;
    }
    public String getHeadImagePath() {
        return headImagePath;
    }

    public void setHeadImage(Bitmap bitmage) {
        headImage = bitmage;
    }
    public Bitmap getHeadImage(){
        return headImage;
    }
}