class Wap::ApplicationController < ApplicationController
  layout 'wap/layouts/application'
  helper_method :load_wx_js_api,:hide_option,:share

  def wx_oauth
    if session[:user_id].blank?

      init_wexin_client

      if params[:code].present?

        sns_info = $client.get_oauth_access_token(params[:code])
        openid = sns_info.result['openid']

        user_info = $client.user(openid).result

        if user_info['errcode'].present?
          return render 'wap/errors/500'
        end

       @user = User.find_or_create_by_user_info user_info

       session[:user_id] = @user.id
      else
        redirect_to  $client.authorize_url(request.url)
      end
    else
      @user = User.find session[:user_id]
    end

  end

  def load_wx_js_api(debug = false,account_id=nil)

    init_wexin_client(account_id)

    js_package = $client.get_jssign_package(request.url)

    html = '<script src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>'
    html << "<script>
              wx.config({
                 debug: #{debug},
                 appId: '#{js_package['appId']}',
                 timestamp: #{js_package['timestamp']},
                 nonceStr: '#{js_package['nonceStr']}',
                 signature: '#{js_package['signature']}',
                 jsApiList: [
                     'checkJsApi', 'onMenuShareTimeline', 'onMenuShareAppMessage', 'onMenuShareQQ',
                     'onMenuShareWeibo', 'hideMenuItems', 'showMenuItems', 'hideAllNonBaseMenuItem',
                     'showAllNonBaseMenuItem', 'translateVoice', 'startRecord', 'stopRecord',
                     'onRecordEnd', 'playVoice', 'pauseVoice', 'stopVoice', 'uploadVoice',
                     'downloadVoice', 'chooseImage', 'previewImage', 'uploadImage',
                     'downloadImage', 'getNetworkType', 'openLocation', 'getLocation',
                     'hideOptionMenu', 'showOptionMenu', 'closeWindow', 'scanQRCode',
                     'chooseWXPay', 'openProductSpecificView', 'addCard', 'chooseCard', 'openCard'
                 ]
             });
            </script>"

    # render must use raw
    html
  end

  def upload_wx_file(file)
    put_policy = Qiniu::Auth::PutPolicy.new(
        'zwwz22'     # 存储空间
    )

    uptoken = Qiniu::Auth.generate_uptoken(put_policy)

    code, result, response_headers = Qiniu::Storage.upload_with_put_policy(
        put_policy,     # 上传策略
        file          # 本地文件名
    )
    return "http://7xjshs.com1.z0.glb.clouddn.com/#{result["key"]}",code
  end

  def hide_option(state = false)
    @hide_option ||= state
  end

  def share(state = false)
    @share ||= state
  end



end