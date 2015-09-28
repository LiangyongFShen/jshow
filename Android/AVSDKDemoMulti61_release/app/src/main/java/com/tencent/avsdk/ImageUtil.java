package com.tencent.avsdk;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.HttpVersion;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.ContentBody;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.CoreProtocolPNames;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;

public class ImageUtil {
    private final String TAG = "ImageUtil";

    public void saveImage(Bitmap bitmap, String path) {
        File f = new File(path);
        if (f.exists()) {
            f.delete();
        }

        try {
            f.createNewFile();
        } catch (IOException e) {
            Log.e(TAG, e.toString());
            e.printStackTrace();
        }
        FileOutputStream fout = null;
        try {
            fout = new FileOutputStream(f);
        } catch (FileNotFoundException e) {
            Log.e(TAG, e.toString());
            e.printStackTrace();
        }
        if (fout != null)
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fout);
        try {
            fout.flush();
        } catch (IOException e) {
            Log.e(TAG, e.toString());
            e.printStackTrace();
        }
        try {
            fout.close();
        } catch (IOException e) {
            Log.e(TAG, e.toString());
            e.printStackTrace();
        }
    }

    public int sendCoverToServer(String f, JSONObject object, String url, String json)
            throws UnsupportedEncodingException, JSONException {
        File file = new File(f);
        if (!file.exists())
            try {
                file.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
            }
        MultipartEntity mpEntity = new MultipartEntity();
        ContentBody info = new StringBody(object.toString(), Charset.forName("UTF-8"));
        ContentBody cbFile = new FileBody(file, "image/jpg");
        mpEntity.addPart("image", cbFile);
        mpEntity.addPart(json, info);
        String response = Send(mpEntity, url);
        JSONTokener jsonTokener = new JSONTokener(response);
        JSONObject OB = (JSONObject) jsonTokener.nextValue();
        int ret = OB.getInt("code");
        Log.e(TAG, "ret = " + ret);
        return ret;
    }

    public int sendHeadToServer(String s, UserInfo mSelfUserInfo)
            throws UnsupportedEncodingException, JSONException {

        File file = new File(s);
        System.out.println(s);
        MultipartEntity mpEntity = new MultipartEntity();
        String userphone = mSelfUserInfo.getUserPhone();
        int imagetype = 1;

        JSONObject object = new JSONObject();
        try {
            object.put("userphone", userphone);
            object.put("imagetype", imagetype);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        ContentBody info = new StringBody(object.toString(), Charset.forName("UTF-8"));
        ContentBody cbFile = new FileBody(file, "image/jpg");

        mpEntity.addPart("image", cbFile);
        mpEntity.addPart("imagepostdata", info);
        String response = Send(mpEntity, HttpUtil.requestUrl);
        JSONTokener jsonTokener = new JSONTokener(response);
        JSONObject OB = (JSONObject) jsonTokener.nextValue();
        int ret = OB.getInt("code");
        Log.e(TAG, ret + "");
        return ret;
    }

    public String Send(HttpEntity entity, String RequestUrl) {
        HttpClient httpClient = new DefaultHttpClient();
        httpClient.getParams().setParameter(CoreProtocolPNames.PROTOCOL_VERSION, HttpVersion.HTTP_1_1);
        HttpPost httpPost = new HttpPost(RequestUrl);
        httpPost.setEntity(entity);
        System.out.println("executing request: " + httpPost.getRequestLine());
        HttpResponse response = null;
        try {
            response = httpClient.execute(httpPost);
        } catch (IOException e) {
            e.printStackTrace();
        }
        if (response == null)
            return "";
        HttpEntity resEntity = response.getEntity();
        int ret = response.getStatusLine().getStatusCode();
        String res = null;
        httpClient.getConnectionManager().shutdown();
        if (ret == 200)
            try {
                res = EntityUtils.toString(resEntity, "utf-8");
                return res;
            } catch (IOException e) {
                e.printStackTrace();
            }

        return "";
    }

    public Bitmap getImageFromServer(String param) {
        String url = HttpUtil.rootUrl + param;
        Log.e(TAG, url);
        Bitmap bitmap = null;
        HttpClient httpClient = new DefaultHttpClient();
        HttpGet httpGet = new HttpGet(url);
        try {
            HttpResponse response = httpClient.execute(httpGet);
            if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
                InputStream is = response.getEntity().getContent();
                bitmap = BitmapFactory.decodeStream(is);
                is.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return bitmap;
    }
}
