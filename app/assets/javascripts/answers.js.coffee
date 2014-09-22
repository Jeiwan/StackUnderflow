# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $("#show-answer-comment-textarea").click((e)->
    e.preventDefault()
    $(this).parents('.answer').find(".new_comment").slideToggle()
  )
