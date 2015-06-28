// 在el的父元素上面增加触摸事件
var Card = function(el, config) {

  if(/(iPhone|iPad|iPod|iOS)/i.test(navigator.userAgent)) {
    this.ios = true;
  } else {
    this.ios = false;
  }

  this.config = config;

  // 目标元素改动
  this.$el = $(el);
  this.$el.addClass("card");
  this.$el.css({width: config.width, height: config.height});
  // 生成html
  this.buildHtml(config.imageUrl);
  this.$image = this.$el.find('.image-container > .image');

  if(config.rotation){
    this.attrs = {
      posX: 0, posY: 0, lastPosX: 0, lastPosY: 0,
      scale: 1, last_scale: 1, initScale: 1,
      rotation: 90, last_rotation: 90
    };
  }else{
    this.attrs = {
      posX: 0, posY: 0, lastPosX: 0, lastPosY: 0,
      scale: 1, last_scale: 1, initScale: 1,
      rotation: 0, last_rotation: 0
    };
  }

  // 做图片自适应
  this.fit(config.rotation);


  this.addTouchEvent();

};


//cb(imageBase64Url)
Card.prototype.toImage = function(cb) {
  var _this = this;
  console.log((this.attrs.posX)+','+(this.attrs.posY)+','+this.attrs.scale+','+this.attrs.rotation);
  // 准备好canvas，往里头放图片，然后根据参数调整，最后输出图片
  var canvas = new fabric.StaticCanvas(fabric.util.createCanvasElement());
  canvas.setDimensions({width: this.config.width, height: this.config.height});

  // 以下是图片参数
  var scale = this.attrs.scale;
  var angle = this.attrs.rotation;
  var width = this.oriImageSize.width*scale;
  var height = this.oriImageSize.height*scale;
  var left = this.attrs.posX+(this.oriImageSize.width-width)/2;
  var top = this.attrs.posY+(this.oriImageSize.height-height)/2;

  // 因为csstransform是根据中心点旋转的，而fabricjs是左上角旋转，所以要fix一下
  var newPoint = fabric.util.rotatePoint(new fabric.Point(left, top), new fabric.Point(left+width/2, top+height/2), fabric.util.degreesToRadians(angle));

  fabric.Image.fromURL(this.config.imageUrl, function(img) {
    img.scale(scale).set({
      // _this.config.imageContainerLeft：相对于frame的位置
      left: newPoint.x+_this.config.imageContainerLeft,
      top: newPoint.y+_this.config.imageContainerTop,
      angle: angle
    });
    background = $(".frame").css("background-image").replace(/^url\(["']?/, '').replace(/["']?\)$/, '');
    fabric.Image.fromURL(background, function(frameImg) {
      frameImg.set({
        width: _this.config.width,
        height: _this.config.height
      });
      canvas.add(img);
      canvas.add(frameImg);
      cb(canvas.toDataURL({'format': 'jpg', 'quality': 0.7}));
    });


  }, {crossOrigin : 'anonymous'});

};

Card.prototype.toObject = function() {
  var bounds = getBounds(this.$image);
  return {x: bounds[0], y: bounds[1], scale: this.attrs.scale, rotation: this.attrs.rotation}
}

Card.prototype.buildHtml = function(imageUrl) {
  var htmlText =
      '<div class="image-container">'+
          ' <div id="loading" style="text-align: center">'+
          '<img src="/assets/wap/loading.gif" style="width: 30%" ></div>'+
          '<img class="image" id="pic" rotation="0" scale="1" posX="0" posY="0" left="0" top="0" w="0" h="0" src="'+imageUrl+'"/>'+
          '<!-- <div class="bbox"></div> -->'+
          '</div>'+
          '<div class="frame">' +
        '</div>';

  this.$el.html(htmlText);
  var imageContainer = this.$el.find(".image-container");
  imageContainer.css({
    left: this.config.imageContainerLeft,
    top: this.config.imageContainerTop,
    width: this.config.imageContainerWidth,
    height: this.config.imageContainerHeight
  });
  $('#loading').css('margin-top',(this.config.imageContainerHeight /2 - 64));
};

Card.prototype.addTouchEvent = function() {
  var hammer = Hammer(this.$el.parent().get(0), {
    transform_always_block: true,
    transform_min_scale: 1,
    drag_block_horizontal: true,
    drag_block_vertical: true,
    drag_min_distance: 0
  });

  var _this = this;
//
//  hammer.on('tap',function(){
//    $('.img4').removeClass('img4_bg');
//    $('.img3').hide();
//  })

  hammer.on('touch', function(ev) {
    //log('touch');
    _this.attrs.lastPosX = _this.attrs.posX;
    _this.attrs.lastPosY = _this.attrs.posY;
    _this.attrs.last_scale = _this.attrs.scale;
    _this.attrs.last_rotation = _this.attrs.rotation;
    $('.img4').css({opacity:0});
    $('.img3').hide();

  });


  hammer.on('drag', function(ev) {
    //log('drag');
    _this.attrs.posX = ev.gesture.deltaX + _this.attrs.lastPosX;
    _this.attrs.posY = ev.gesture.deltaY + _this.attrs.lastPosY;
    _this.applyTransform();
    //showBounds($('#image'));
  });

  hammer.on('dragend', function(ev) {
    //log('dragend');
    _this.attrs.lastPosX = _this.attrs.posX;
    _this.attrs.lastPosY = _this.attrs.posY;
    //
    _this.kickback();


    //showBounds($('#image'));
  });

  hammer.on('transform', function(ev) {
    //log('transform');
    _this.attrs.rotation = _this.attrs.last_rotation + ev.gesture.rotation;
    _this.attrs.rotation = snapToAngle(_this.attrs.rotation, 90, 20);
    //
    _this.attrs.scale = Math.max(_this.attrs.initScale, Math.min(_this.attrs.last_scale * ev.gesture.scale, _this.attrs.initScale * 2));
    _this.applyTransform();

    //showBounds($('#image'));
  });

  hammer.on('transformend', function(ev) {
    //log('transformend');
    _this.kickback();

    //showBounds($('#image'));
  });
};

Card.prototype.applyTransform = function() {
  if (this.ios===true) {
    var transform =
        "translate("+this.attrs.posX+"px,"+this.attrs.posY+"px) " +
            "scale("+this.attrs.scale+","+this.attrs.scale+") " +
            "rotate("+this.attrs.rotation+"deg) ";
  } else {
    var transform =
        "translate3d("+this.attrs.posX+"px,"+this.attrs.posY+"px, 0) " +
            "scale3d("+this.attrs.scale+","+this.attrs.scale+", 0) " +
            "rotate("+this.attrs.rotation+"deg) ";
  }
//  log(transform);
  var el = this.$image.get(0);
  el.style.transform = transform;
  el.style.oTransform = transform;
  el.style.msTransform = transform;
  el.style.mozTransform = transform;
  el.style.webkitTransform = transform;
};

Card.prototype.kickback = function() {
  var bounds = getBounds(this.$image);

  var left = bounds[0];
  var top = bounds[1];
  var width = bounds[2];
  var height = bounds[3];

  var $imageContainer = this.$image.parent();
  var img_window_width = $imageContainer.width();
  var img_window_height = $imageContainer.height();

  //log(left+','+top+','+width+','+ height+','+img_window_width+','+img_window_height);
  var dx, dy;

  // 大的情况
  if (width >= img_window_width) {
    if (left > 0) {
      this.attrs.posX = this.attrs.lastPosX = this.attrs.posX-left;
    }
    dx = width - img_window_width;
    if (left < -dx) {
      this.attrs.posX = this.attrs.lastPosX = this.attrs.posX+((-left)-dx);
    }
  }
  if (height >= img_window_height) {
    if (top > 0) {
      this.attrs.posY = this.attrs.lastPosY = this.attrs.posY-top;
    }
    dy = height - img_window_height;
    if (top < -dy) {
      this.attrs.posY = this.attrs.lastPosY = this.attrs.posY+((-top)-dy);
    }
  }

  // 小的情况
  if (width < img_window_width) {
    if (left < 0) {
      this.attrs.posX = this.attrs.lastPosX = this.attrs.posX-left;
    }
    dx = img_window_width - width;
    if (left > dx) {
      this.attrs.posX = this.attrs.lastPosX = this.attrs.posX-(left-dx);
    }
  }
  if (height < img_window_height) {
    if (top < 0) {
      this.attrs.posY = this.attrs.lastPosY = this.attrs.posY-top;
    }
    dy = img_window_height - height;
    if (top > dy) {
      this.attrs.posY = this.attrs.lastPosY = this.attrs.posY-(top-dy);
    }
  }

  this.applyTransform();
};



Card.prototype.fit = function(rotation) {
  var _this = this;
  var transform;
  if (rotation){
    transform =  "rotate(90deg) ";
    //log(transform);
  }else{
    transform =  "rotate(0deg) ";
  }
  var el = _this.$image.get(0);
  el.style.transform = transform;
  el.style.oTransform = transform;
  el.style.msTransform = transform;
  el.style.mozTransform = transform;
  el.style.webkitTransform = transform;
  getImgSize(_this.config.imageUrl, function(imageWidth, imageHeight){
    _this.oriImageSize = {width: imageWidth, height: imageHeight};
    if(rotation){
      var sv = getSuiteValues({width: imageHeight, height: imageWidth}, {width: _this.config.imageContainerWidth, height: _this.config.imageContainerHeight});
    }else{
      var sv = getSuiteValues({width: imageWidth, height: imageHeight}, {width: _this.config.imageContainerWidth, height: _this.config.imageContainerHeight});
    }

    _this.attrs.scale = _this.attrs.initScale = sv.scale;
    // 因为缩放是根据中心点进行的，所以要考虑挪回去点：(imageWidth-sv.width)/2
    _this.attrs.posX = sv.left-(imageWidth-sv.width)/2;
    _this.attrs.posY = sv.top-(imageHeight-sv.height)/2;
    _this.applyTransform();

    sub = true
  });
};

function log(content) {
  console.log(content);
}

function showBounds($el) {
  var bounds = getBounds($el);
  $('.bbox').css({
    'left': bounds[0],
    'top': bounds[1],
    'width': bounds[2],
    'height': bounds[3]
  });
}

function snapToAngle(rotation, angle, distance_angle) {
  // 先将度数归于 0 ~ 360
  rotation = rotation%360;
  if(rotation<0) {
    rotation = 360 + rotation;
  }

  //
  var yu = rotation % angle;
  if( yu > 0 && yu < distance_angle ) {
    rotation = rotation - yu;
  }
  var tmp = angle-yu;
  if( tmp > 0 && tmp < distance_angle ) {
    rotation = rotation + tmp;
  }

  return rotation;
}

function getBounds($el) {
  var rect = $el.get(0).getBoundingClientRect();
  // 因为getBoundingClientRect方法获取的是相对于document左上角的坐标，所以要减去其父元素
  // 的位置
  var parentOffset = $el.parent().offset();
  return [rect.left-parentOffset.left, rect.top+$(window).scrollTop()-parentOffset.top, rect.width, rect.height];

}

function getSuiteValues(imageSize, imageContainerSize) {
  var w1 = imageSize.width;
  var h1 = imageSize.height;
  var w0 = imageContainerSize.width;
  var h0 = imageContainerSize.height;
  // 0 是相框
  if( w1/h1 <= w0/h0 ) { // 图片的宽长比小于像框的，就是竖着的
    var scale = w0/w1;
    return { width: w0, height: scale*h1, scale: scale, orientation: 1, top: -(scale*h1-h0)/2, left: 0 };
  } else if( w1/h1 > w0/h0 ) { // 横着的
    var scale = h0/h1;
    return { width: scale*w1, height: h0, scale: scale, orientation: 0, left: -(w1*scale-w0)/2, top: 0 };
  }
//  }

}

function check_orientation(width, height, url){

  if(url.indexOf("wechat-cdn.qiniudn.com") >= 0){
    return true;
  }else if(url.indexOf("mmbiz.qpic.cn") >= 0){
    if(width > 1000 || height > 1000){
      $('#wait_text').text('正在自动调整图片方向...');
      ShowProgressBar();
      mref = $('#mref').val();
      account_id = $('#account_id').val();
      var nurl = new objURL();
      ucc = nurl.get("cc");
      printer_id = nurl.get("printer_id");
      mt = nurl.get("mt");

      if(/(iPhone|iPad|iPod|iOS)/i.test(navigator.userAgent)){
        setTimeout(function(){
          HideProgressBar();
          var url = 'http://fp.memeing.cn/fp/designs/orientation?mref=' + mref + '&account_id=' + account_id;
          if(ucc != undefined){
            url = url + '&cc='+ucc;
          }

          if(printer_id != undefined){
            url = url + '&printer_id='+printer_id;
          }

          if(mt != undefined){
            url = url + '&mt='+mt;
          }

          url = url + '#wechat_redirect' ;

          return window.location = url;
        }, 1500);
      }else{
        var url = 'http://fp.memeing.cn/fp/designs/orientation?mref=' + mref + '&account_id=' + account_id;
        if(ucc != undefined){
          url = url + '&cc='+ucc;
        }

        if(printer_id != undefined){
          url = url + '&printer_id='+printer_id;
        }

        if(mt != undefined){
          url = url + '&mt='+mt;
        }

        url = url + '#wechat_redirect' ;

        return window.location = url;
      }
    }else{
      return true;
    }
  }else{
    return true;
  }
}

function getImgSize(imgSrc, cb) {
  var newImg = new Image();
  newImg.onload = function() {
    var height = newImg.height;
    var width = newImg.width;

//    check_orientation(width, height, imgSrc);

    if (/(iPhone|iPad|iPod|iOS)/i.test(navigator.userAgent)) {
      var $pic = $('#pic');


      if(width != $pic.width() && height != $pic.height()){
        $('#pic').css({
           width:height+'px',
           height:width+'px'
        })

        // ios自动旋转长宽修正
        cb(height, width);
      }else{
        cb(width, height);
      }
    }else{
      cb(width, height);
    }

    cb(width, height);
    $('#loading').remove();
  }
  newImg.src = imgSrc;

}