var pic_w, pic_h, size, scale = 0;
var load = false ,show = true;
var sub = false;
var body;
var design;
var $select_tpl;
var origin_client_width = document.body.clientWidth;
function objURL(url){
  var ourl=url||window.location.href;
  var href="";//?前面部分
  var params={};//url参数对象
  var jing="";//#及后面部分
  var init=function(){
    var str=ourl;
    var index=str.indexOf("#");
    if(index>0){
      jing=str.substr(index);
      str=str.substring(0,index);
    }
    index=str.indexOf("?");
    if(index>0){
      href=str.substring(0,index);
      str=str.substr(index+1);
      var parts=str.split("&");
      for(var i=0;i<parts.length;i++){
        var kv=parts[i].split("=");
        params[kv[0]]=kv[1];
      }
    }else{
      href=ourl;
      params={};
    }
  };
  this.set=function(key,val){
    params[key]=encodeURIComponent(val);
  };
  this.remove=function(key){
    if(key in params) params[key]=undefined;
  };
  this.get=function(key){
    return params[key];
  };
  this.url=function(key){
    var strurl=href;
    var objps=[];
    for(var k in params){
      if(params[k]){
        objps.push(k+"="+params[k]);
      }
    }
    if(objps.length>0){
      strurl+="?"+objps.join("&");
    }
    if(jing.length>0){
      strurl+=jing;
    }
    return strurl;
  };
  this.debug=function(){
    var objps=[];
    for(var k in params){
      objps.push(k+"="+params[k]);
    }
    alert(objps);//输出params的所有值
  };
  init();
}

$(function () {
  $select_tpl = $('.templates_pic').find('img').first();
  $('.templates_pic').first().addClass('border');
  $('.templates_pic').first().parent().addClass('padd');

  main_design();

  $(document).on('click','.templates_pic',function(){
    var _this = $(this);
      $('.templates_pic').removeClass('border');
      $('.templates').removeClass('padd');
      _this.addClass('border');
      _this.parent().addClass('padd');
      $('#upc').hide();

      $select_tpl = $(_this).find('img').first();


      $('#tpl').hide();

      $('#template_id').val($select_tpl.attr('tid'));

      $('#bg').attr('src', $select_tpl.attr('src'));


      var rotation;
      if($select_tpl.attr('rotation') == 'true'){
        rotation = true;
      }else{
        rotation = false;
      }
      initialize_img(
        $select_tpl.attr('area_width'),
        $select_tpl.attr('area_height'),
        $select_tpl.attr('area_x'),
        $select_tpl.attr('area_y'),
        rotation);  //图片缩放

      $('#tpl').fadeIn();

    $(window).resize(function(){
      if(origin_client_width != document.body.clientWidth){
        origin_client_width = document.body.clientWidth;
        main_design();
      }
    });
    })
  })

//介绍
function introduce_show(show){
  if (show){
    $('.img3').show();
    $('.img4').addClass('img4_bg');
  }else{
    $('.img3').hide();
  }
}

function main_design() {
  body = document.body.clientWidth * 0.9*0.7;
//  body = $('#tpl').width();

  scale = body / 1000;  //模板的缩放比例

  if (isNaN(scale)){
    alert('参数异常,由于网络过慢或系统版本过低,请返回重试');
    sub = false;
  }

  var img_w = $select_tpl.attr('area_width') * scale;
  var img_h = $select_tpl.attr('area_height') * scale;
  var x = $select_tpl.attr('area_x') * scale;
  var y = $select_tpl.attr('area_y') * scale;

  var rotation;
  if ( $select_tpl.attr('rotation') == 'true'){
    rotation = true;
  }else{
    rotation = false;
  }

  $('#image_uploader').css({
    'top': y + 'px',
    'left': x + 'px',
    width: img_w + 'px',
    height: img_h + 'px'
  });

  $('#tpl').css({
    width: body + 'px',
    height: 1500 * scale + 'px'
  });


  //图片效果
  init_rotation = ($select_tpl.attr('rotation') == 'true');
  design = new Design($('.img'), {
    width: body,
    height: 1500*scale,
    imageUrl: image_url,
    imageContainerLeft: x,
    imageContainerTop: y,
    imageContainerWidth: img_w,
    imageContainerHeight: img_h,
    rotation:init_rotation
  });

  $('#submit').click(function () {
//    var media_id = 's94eGh8sv_0_9p4f9F-EEH-m7BhGoJ-UqcqveDJNkId1T2-cBdMi7vjYOi3fll9n'; //获取media_id
    var media_id = $.cookie('mediaId'); //获取media_id
    if (sub == true && media_id) {
      sub = false;

      setTimeout(function(){
        //获取图片各项属性

        if(design.attrs.scale>0){


          alert(design.attrs.posX+'||| y='+ design.attrs.posX)

          $.ajax({
            type: 'POST',
            url: '/wap/designs/create_order',
            data: {
              x:parseFloat(design.attrs.x),
              y:parseFloat(design.attrs.y),
              scale:scale,
              scale_card:parseFloat(design.attrs.scale),
              rotation:parseFloat(design.attrs.rotation),
              pos_x:parseFloat(design.attrs.posX),
              pos_y:parseFloat(design.attrs.posY),
              template_id:$('#template_id').val(),
              account_id:$('#account_id').val(),
              media_id:media_id,
              auto_orient:auto_orient,  //自动旋转
              local_id: $.cookie('localId'),
              osn:$('#osn').val()
            },
            success: function(data){
              if(data.status == true){
                window.location = data.redirect_url;
              }else{
                alert(data.message);
                sub = true;
              }
            },
            error: function(data){
              alert('提交失败请返回重试');
              wrong_cc = true;
              sub = true;
            },
            dataType: 'json'
          });
        }
      },600)
    }
  });
}

//更换模板对图片重新进行缩放
function initialize_img(w,h,x,y,rotation){
  var img_w = w * scale;
  var img_h = h * scale;
  var x = x * scale;
  var y = y * scale;

  var w = img_w / pic_w;  //重新计算比值确保图片宽高比一致
  var h = img_h / pic_h;
  size = w > h ? w : h;

  $('#loading').css('position', 'absolute');
  $('#loading').css('margin-top',(img_h /2 - 64)+'px');
  $('#loading').css('margin-left',(img_w /2 - 64)+'px');

  $('#bg').attr('src', $select_tpl.attr('src'));

  design = new Design($('.img'), {
    width: body,
    height: 1500*scale,
    imageUrl: image_url,
    imageContainerLeft: x,
    imageContainerTop: y,
    imageContainerWidth: img_w,
    imageContainerHeight: img_h,
    rotation:rotation
  });

}

