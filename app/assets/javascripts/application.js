// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require vendor

function showSuccess(msg){
  $('.flash-success').addClass('in').find('p').text(msg);
  $('.flash-success').animate({
    right:'20px',
    opacity:'1'
  },2000);

  setTimeout(function(){
    $('.flash-success').animate({
      right:'-200px',
      opacity:'0'
    },3000)
  },4000)

}
function showError(msg){
  $('.flash-error').addClass('in').find('p').text(msg);
  $('.flash-error').animate({
    right:'20px',
    opacity:'1'
  },2000);

  setTimeout(function(){
    $('.flash-error').animate({
      right:'-200px',
      opacity:'0'
    },3000)
  },4000)
}
