/**
 * Created by masonwoo on 15-6-22.
 */

//微信上传图片
function chooseImage(upload){
  wx.chooseImage({
    success: function (res) {
      var localIds = res.localIds; // 返回选定照片的本地ID列表，localId可以作为img标签的src属性显示图片
      showImage(localIds[0]);
      setCookie('localId',localIds[0]);
      if(upload){
        uploadImage(localIds[0])
      }
    }
  });
}

//显示图片
function showImage(localId){
  $('#local_image').attr('src',localId);
  $('.content-img').show();
  $('.content').hide();
}

//上传图片,返回media_id
function uploadImage(localId){
  var serverId;
  wx.uploadImage({
    localId: localId, // 需要上传的图片的本地ID，由chooseImage接口获得
    isShowProgressTips: 1, // 默认为1，显示进度提示
    success: function (res) {
      serverId = res.serverId; // 返回图片的服务器端ID
      setCookie('mediaId',serverId)
    }
  });

}

function setCookie(type,localId){
  $.cookie(type,localId,{expires:1})
}

var recordState = 'stop';
var recordLocalId;
var recordServerId;
var recordTime = 0;
var recordTimer;


// 微信jsapi开始录音
function startRecord(){
  wx.startRecord({
    fail:function(res){
      alert('无法提供录音功能，请更新微信版本');
      $('.begin_ly').remove();
    }
  });

  recordState = 'start';

  $('#begin').text('停止播放');

  // 开启秒数计时器
  recordTime = 60;
  recordTimer = setInterval(function(){
    recordTime = recordTime - 1;
    recordTime = recordTime  >0 ? recordTime:0;
    $('#time').text("0:"+recordTime);
  }, 1000);

  // 录音时间超过一分钟没有停止的时候会执行 complete 回调
  wx.onVoiceRecordEnd({
    complete: function (res) {
      voiceComplete(res.localId);
      $('#begin').text('重新录音');
      $('#time').text("1:00");
      $('#begin').removeClass('green');
    }
  });
}

// 手动停止录音
function stopRecord(){
  if(recordState == 'start'){
    wx.stopRecord({
      success: function (res) {
        voiceComplete(res.localId);
        $('#begin').text('重新录音');
        $('#time').text("1:00");
      },
      fail: function(res){
        alert("无法提供录音功能"+JSON.stringify(res))
      }
    });
  }
}

// 录音结束
function voiceComplete(localId){
  clearInterval(recordTimer);
  recordLocalId = localId;
}

// 试听录音
var playState = 'stop';
function playRecord(){
  if(recordLocalId != undefined){
    if(playState == 'stop'){
      playState = 'playing';
      $('#end').addClass('green');
      $('#end').text('停止试听');
      wx.playVoice({
        localId: recordLocalId
      });

      wx.onVoicePlayEnd({
        success: function (res) {
          playState = 'stop';
          $('#end').removeClass('green');
          $('#end').text('试听录音');
        }
      });

    }else{
      playState = 'stop';
      $('#end').removeClass('green');
      $('#end').text('试听录音');
      wx.stopVoice({
        localId: recordLocalId
      });
    }
  }
}

//上传录音
function uploadVoice(recordLocalId){
  wx.uploadVoice({
    localId: recordLocalId, // 需要上传的音频的本地ID，由stopRecord接口获得
    isShowProgressTips: 1, // 默认为1，显示进度提示
    success: function (res) {
      recordServerId = res.serverId; // 返回音频的服务器端ID
    },
    fail:function(){
      alert('上传录音失败')
    }
  });
}


function checkJsApi(){
  wx.checkJsApi({
    jsApiList: ['chooseImage','startRecord','stopRecord','playVoice'], // 需要检测的JS接口列表，所有JS接口列表见附录2,
    success: function(res) {
      // 以键值对的形式返回，可用的api值true，不可用为false
      // 如：{"checkResult":{"chooseImage":true},"errMsg":"checkJsApi:ok"}
    }
  });
}





