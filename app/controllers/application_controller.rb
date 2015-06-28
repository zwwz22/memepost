class ApplicationController < ActionController::Base
  protect_from_forgery

  def upload_file(file)
    put_policy = Qiniu::Auth::PutPolicy.new(
        'zwwz22'     # 存储空间
    )

    uptoken = Qiniu::Auth.generate_uptoken(put_policy)

    code, result, response_headers = Qiniu::Storage.upload_with_put_policy(
        put_policy,     # 上传策略
        file.tempfile.path     # 本地文件名
    )
    return "http://7xjshs.com1.z0.glb.clouddn.com/#{result["key"]}",code
  end

  def init_wexin_client(account_id = nil)
    account = Account.first
    $client ||= WeixinAuthorize::Client.new(account.app_id, account.app_secret)
  end

  def get_access_token(account_id = nil)
    init_wexin_client(account_id)
  end


end
