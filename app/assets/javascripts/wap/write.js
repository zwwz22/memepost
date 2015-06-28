var sub = true;
$(function(){
  zipcode("receiver_province", "receiver_city", "receiver_county", "receiver_post_no");
  if(remote_ip_info != undefined){

    var province = remote_ip_info.province;
    var city     = remote_ip_info.city;

    if(province in zipcodes){
      si = 0;
      $("#receiver_province option").each(function(){
        var s_province = $(this);
        if(province == s_province.text()){
          $("#receiver_province")[0].selectedIndex = si;
          $('#receiver_province').change();
          return false;
        }
        si ++;
      });

      if (city in zipcodes[province]){
        si = 0;
        $("#receiver_city option").each(function(){
          var s_city = $(this);
          if(city == s_city.text()){
            s_city.selected = true;
            $("#receiver_city")[0].selectedIndex = si;
            $('#receiver_city').change();
            return false;
          }
        });
        si ++;
      }
    }

  }

  if(receiver.receiver_province != undefined){
    var province = receiver.receiver_province;
    var city     = receiver.receiver_city;
    var county   = receiver.receiver_county;

    if(province in zipcodes){
      si = 0;
      $("#receiver_province option").each(function(){
        var s_province = $(this);
        if(province == s_province.text()){
          $("#receiver_province")[0].selectedIndex = si;
          $('#receiver_province').change();
          return false;
        }
        si ++;
      });
      if (city in zipcodes[province]){
        si = 0;
        $("#receiver_city option").each(function(){
          var s_city = $(this);
          if(city == s_city.text()){
            s_city.selected = true;
            $("#receiver_city")[0].selectedIndex = si;
            $('#receiver_city').change();
            return false;
          }
          si ++;
        });
      }
      if(county != '' && county != undefined){
        if (county in zipcodes[province][city]){
        si = 0;
        $("#receiver_city option").each(function(){
          var s_county = $(this);
          if(county == s_county.text()){
            s_county.selected = true;
            $("#receiver_county")[0].selectedIndex = si;
            $('#receiver_county').change();
            return false;
          }
          si ++;
        });
      }
      }
    }

  }

});

$(document).ready(function(){


  $('#sub').click(function(){
    var receiver  = $('#receiver').val().trim();

    var receiver_province = $('#receiver_province').find("option:selected").val();

    var receiver_city = $('#receiver_city').find("option:selected").val();

    var receiver_county = $('#receiver_county').find("option:selected").val();

    var receiver_address = $('#receiver_address').val().trim();

    var receiver_post_no = $('#receiver_post_no').val().trim();

    var osn = $('#osn').val().trim();

    var pattern =  /^[0-9]{6}$/;

    if (receiver == '' || receiver == null){
      alert('敢问尊姓大名');
    }else if(receiver_post_no == ''){
      alert('邮编不能为空')
    }else if(!(pattern.exec(receiver_post_no))){
      alert('邮编是6位数字哦')
    }else if (receiver_province == '' || receiver_province == null || receiver_address == '' || receiver_address == null){
      alert('没有详细地址我们是无法寄出的哟');
    }
    else{
      if (sub == true){
        sub = false
        // ajax 提交
        $.ajax({
          url:'/wap/designs/update_address',
          method:'post',
          data:{receiver:receiver,receiver_province:receiver_province,receiver_city:receiver_city,receiver_county:receiver_county,
receiver_address:receiver_address,receiver_post_no:receiver_post_no,osn:osn},
          dataType:'JSON',
          success:function(data){
            if(data.status){
              window.location.href = data.redirect_url
            }else{
              alert('提交失败')
            }
          },
          error:function(){
            alert('提交失败')
          }
        })
      }
    }
  });


});

