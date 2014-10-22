# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $(".user-profile-tabs li:first").addClass("active")
  $(".pane:first").show()

  $(".user-profile-tabs li").click (e) ->
    e.preventDefault()
    $this = $(this)
    $this.siblings().removeClass("active")
    $this.addClass("active")
    $(".pane").hide().eq($this.index()).show()
