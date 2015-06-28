# encoding: utf-8
# Use this hook to configure WeixinRailsMiddleware bahaviors.
WeixinRailsMiddleware.configure do |config|

  ## NOTE:
  ## If you config all them, it will use `weixin_token_string` default

  ## Config public_account_class if you SAVE public_account into database ##
  # Th first configure is fit for your weixin public_account is saved in database.
  # +public_account_class+ The class name that to save your public_account
  config.public_account_class = "Account"

  ## Here configure is for you DON'T WANT TO SAVE your public account into database ##
  # Or the other configure is fit for only one weixin public_account
  # If you config `weixin_token_string`, so it will directly use it
  # config.weixin_token_string = 'cc12ca8c73ba6008366f1a3b'
  # using to weixin server url to validate the token can be trusted.
  # config.weixin_secret_string = 'jn8zV5Nq4yF5DxvjeyzFurrcre-8j8U7'
  # 加密配置，如果需要加密，配置以下参数
  # config.encoding_aes_key = '52d983535c489bd24ab998d6de70c3c8ad42c07d47d'
  # config.app_id = "your app id"

  ## You can custom your adapter to validate your weixin account ##
  # Wiki https://github.com/lanrion/weixin_rails_middleware/wiki/Custom-Adapter
  # config.custom_adapter = "MyCustomAdapter"

end
