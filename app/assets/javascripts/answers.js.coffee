# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $(".answers").on("click", ".comment-answer", (e)->
    e.preventDefault()
    $(this).parents(".answer").find(".comment-answer-form").slideToggle()
  )
