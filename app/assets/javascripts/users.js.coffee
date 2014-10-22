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

  $(".user-info form.edit_user").on "ajax:success", (e, data, status, xhr)->
    $(".user-avatar").attr("src", xhr.responseJSON.avatar_url)

  $("#change-avatar").click (e) ->
    e.preventDefault()
    $("#user_avatar").val("").click()

  $("form.edit_user").on "change", "#user_avatar", () ->
    $(this).parents("form.edit_user").submit()
