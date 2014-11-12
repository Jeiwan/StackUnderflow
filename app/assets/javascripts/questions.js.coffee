$ ->
  $("#question_tag_list").tagsinput({
    confirmKeys: [32, 13, 188],
    tagClass: "label label-default"
  })

class @Question
  constructor: () ->
    this.$el = $(".question")
    this.$body = this.$el.find(".question-body")
    this.$title = $("#question-title h1")
    this.$tags = this.$el.find(".question-tags")
    this.$author = this.$el.find(".question-author")
    this.tagList = this.$tags.data("tags")
    this.$files = this.$el.find(".question-attachments")
    this.$voting = this.$el.find(".question-voting .voting")
    this.$votes = this.$voting.find(".votes")
    this.$commentBtn = this.$el.find(".show-comment-form")
    this.$commentForm = this.$el.find(".comment-form")
    this.$cancelComment = this.$commentForm.find(".cancel-comment")
    this.$commentsWrapper = this.$el.find(".comments-wrapper")
    this.$comments = this.$commentsWrapper.find(".comments")
    this.$answers = $(".answers")
    this.$answerForm = $("#new-answer-form")
    this.$answersCounter = $("#answers-counter")
    this.answersCounter = this.$answersCounter.data("counter")
    this.answers = []
    this.comments = []

    this.id = this.$el.data("question-id")

    this.bind()
    this.setAjaxHooks()
    this.subscribeToChannels()

  bind: () ->
    that = this

    this.$commentBtn.click (e) ->
      e.preventDefault()
      that.toggleCommentForm()

    this.$cancelComment.click (e) ->
      e.preventDefault()
      that.$commentForm.slideUp()

    this.$el.on "click", ".edit-question", (e) ->
      e.preventDefault()
      $(".comment-form").slideUp()
      $(".edit-form").prev().show().end().remove()
      that.$body.hide()
      that.$body.after(HandlebarsTemplates["edit_question"]({id: that.id, body: that.$body.text(), title: that.$title.text(), tag_list: that.tagList}))
      $("#question_tag_list").tagsinput({ confirmKeys: [32, 13, 188], tagClass: "label label-default" })

    this.$el.on "click", ".cancel-editing", (e) ->
      e.preventDefault()
      that.$body.siblings(".edit-form").remove()
      that.$body.show()

  setAjaxHooks: () ->
    that = this
    this.$el.on "ajax:success", "form.edit_question", (e, data, status, xhr) ->
      that.$body.siblings(".edit-form").remove()
      that.$body.text(xhr.responseJSON.body)
      that.$body.show()
      that.$tags.replaceWith(HandlebarsTemplates["question_tags"](xhr.responseJSON))
      if that.$files.length == 0
        that.$files = $("<ul class='question-attachments'></ul>")
        that.$author.after(that.$files)
      that.$files.html($(HandlebarsTemplates["attachments_list"]($.extend(xhr.responseJSON, {rel: "shadowbox[question-attachments]"}))))
      Shadowbox.clearCache()
      Shadowbox.setup()
      that.$tags = that.$el.find(".question-tags")
      that.$title.text(xhr.responseJSON.title)
      that.tagList = that.$tags.data("tags")

    this.$el.on "ajax:error", "form.edit_question", (e, xhr, status) ->
      that.renderFormErrors(this, xhr.responseJSON)

    this.$answerForm.on "ajax:success", (e, data, status, xhr) ->
      that.addAnswer(xhr.responseJSON)

    this.$answerForm.on "ajax:error", (e, xhr, status) ->
      that.renderFormErrors(this, xhr.responseJSON)

    this.$commentForm.on "ajax:success", (e, data, status, xhr) ->
      that.addComment(xhr.responseJSON)

    this.$commentForm.on "ajax:error", (e, xhr, status) ->
      that.renderFormErrors(this, xhr.responseJSON)

    this.$el.on "ajax:success", "form.edit_comment", (e, data, status, xhr) ->
      $(this).parents(".comment").replaceWith(HandlebarsTemplates["comment"](xhr.responseJSON))

    this.$el.on "ajax:error", "form.edit_comment", (e, xhr, status) ->
      that.renderFormErrors(this, xhr.responseJSON)

    this.$el.on "ajax:success", "a.delete-comment", (e, data, status, xhr) ->
      that.removeComment($(this).data("id"))

    this.$answers.on "ajax:success", "a.delete-answer", (e, xhr, status) ->
      that.removeAnswer($(this).data("id"))

    this.$voting.on "ajax:success", "a.vote-up", (e, data, status, xhr) ->
      that.$votes.text(xhr.responseJSON.votes)
      $(this).replaceWith($("<span class='voted-up'></span>"))
      that.$voting.find("a.vote-down").remove()

    this.$voting.on "ajax:success", "a.vote-down", (e, data, status, xhr) ->
      that.$votes.text(xhr.responseJSON.votes)
      $(this).replaceWith($("<span class='voted-down'></span>"))
      that.$voting.find("a.vote-up").remove()

    this.$el.on "ajax:success", "a.delete-attachment", (e, data, status, xhr) ->
      $(this).parents("li").remove()
      if that.$files.find("li").length == 0
        that.$files.remove()
        that.$files = []

  subscribeToChannels: () ->
    that = this

    PrivatePub.subscribe "/questions/#{this.id}", (data, channel) ->
      if (typeof data.answer_create != 'undefined')
        that.addAnswer($.parseJSON(data.answer_create))
      if (typeof data.answer_destroy != 'undefined')
        that.removeAnswer($.parseJSON(data.answer_destroy))
      if (typeof data.parent != 'undefined' && data.parent == 'Question' && typeof data.vote != 'undefined')
        that.$votes.text(data.vote)
      if (typeof data.parent != 'undefined' && data.parent == 'Answer' && typeof data.vote != 'undefined')
        that.answerById(data.parent_id).$votes.text(data.vote)
      if (typeof data.parent != 'undefined' && data.parent == 'Comment' && typeof data.vote != 'undefined')
        $("#comment_#{data.parent_id} .votes").text(data.vote)
      if (typeof data.parent != 'undefined' && data.parent == 'Question' && typeof data.comment_create != 'undefined')
        that.addComment($.parseJSON(data.comment_create))
      if (typeof data.parent != 'undefined' && data.parent == 'Answer' && typeof data.comment_create != 'undefined')
        that.answerById(data.parent_id).addComment($.parseJSON(data.comment_create))
      if (typeof data.parent != 'undefined' && data.parent == 'Question' && typeof data.comment_destroy != 'undefined')
        that.removeComment($.parseJSON(data.comment_destroy))
      if (typeof data.parent != 'undefined' && data.parent == 'Answer' && typeof data.comment_destroy != 'undefined')
        that.answerById(data.parent_id).removeComment($.parseJSON(data.comment_destroy))

  edit: (form) ->
    this.$body.html(form)

  setTitle: (title) ->
    this.$title.text(title)

  toggleCommentForm: () ->
    $(".edit-form").prev().show().end().remove()
    $(".comment-form").slideUp()
    this.$commentForm.slideToggle()


  addComment: (comment) ->
    current_user = $("#current_user").data("current-user")
    unless this.commentById(comment.id)
      if (this.$comments.length == 0 || this.$comments.find(".comment").length == 0)
        this.$comments = $("<ul class='comments'></ul>").appendTo(this.$commentsWrapper)
      this.$comments.append(HandlebarsTemplates["comment"](comment))
      this.comments.push(new Comment("comment_#{comment.id}", "questions", this.id))
      if comment.author != current_user
        this.commentById(comment.id).$el.find(".edit-comment, .delete-comment").remove()
      else
        this.commentById(comment.id).$el.find(".vote-up, .vote-down").remove()
      this.$commentForm.slideUp()
      this.clearCommentForm()

  removeComment: (commentId) ->
    if this.commentById(commentId)
      this.$comments.find("#comment_#{commentId}").remove()
      if (this.$comments.is(":empty"))
        this.$comments.remove()
      for comment in this.comments
        if comment.id == parseInt(commentId, 10)
          this.comments.splice(this.comments.indexOf(comment), 1)
          break

  editComment: (comment) ->

  renderCommentForm: (form) ->
    this.$commentForm.html(form)

  clearCommentForm: () ->
    this.$commentForm.find("textarea").val("")
    this.$commentForm.find(".alert-danger").remove()
    this.$commentForm.find(".has-error").removeClass("has-error").find(".help-block").remove()

  addAnswer: (answer) ->
    current_user = $("#current_user").data("current-user")
    question_author = this.$el.data("author")
    unless this.answerById(answer.id)
      this.$answers.append(HandlebarsTemplates["answer"]($.extend(answer, {rel: "shadowbox[answer#{answer.id}-attachments]"})))
      this.increaseAnswersCounter()
      this.answers.push(new Answer("answer_#{answer.id}"))
      this.answers[this.answers.length-1].comments = []
      this.clearAnswerForm()
      if answer.user.username == current_user
        this.answerById(answer.id).$el.find(".mark-best-answer").parent().remove() if answer.user.username != question_author
        this.answerById(answer.id).$el.find(".vote-up, .vote-down").remove()
      else
        this.answerById(answer.id).$el.find(".delete-answer, .edit-answer").parent().remove()
        this.$files.find(".delete-attachment").remove()
      if answer.question.has_best_answer
        this.answerById(answer.id).$el.find(".mark-best-answer").parent().remove()
    Shadowbox.clearCache()
    Shadowbox.setup()

  renderFormErrors: (form, response) ->
    response = response.errors
    this.clearFormErrors(form)
    $form = $(form)
    $form.prepend("<div class='alert alert-danger'>Please review the problems below:</div>")
    for field, error of response
      if field == 'attachments.file'
        $form.prepend("<div class='alert alert-danger'>#{error}</div>")
      field = $form.find("*[id$=#{field}]")
      formGroup = field.parents(".form-group").addClass("has-error")
      formGroup.append("<span class='help-block error'>#{error[0]}</a>")

  clearFormErrors: (form) ->
    $form = $(form)
    $form.find(".alert.alert-danger").remove()
    formGroup = $form.find(".has-error")
    formGroup.find(".help-block.error").remove()
    formGroup.removeClass("has-error")

  clearAnswerForm: () ->
    this.$answerForm.find("textarea").val("")
    this.$answerForm.find(".alert-danger").remove()
    this.$answerForm.find(".has-error").removeClass("has-error").find(".help-block").remove()

  removeAnswer: (answerId) ->
    if this.answerById(answerId)
      this.$answers.find("#answer_#{answerId}").remove()
      for answer in this.answers
        if answer.id == parseInt(answerId, 10)
          this.answers.splice(this.answers.indexOf(answer), 1)
          break
      this.decreaseAnswersCounter()

  renderAnswerForm: (form) ->
    this.$answerForm.html(form)

  increaseAnswersCounter: () ->
    this.answersCounter++
    this.renderAnswersCounter()

  decreaseAnswersCounter: () ->
    this.answersCounter--
    this.renderAnswersCounter()

  renderAnswersCounter: () ->
    answerText = if (this.answersCounter > 1 || this.answersCounter == 0) then "Answers" else "Answer"
    this.$answersCounter.text(this.answersCounter + " " + answerText)

  answerById: (id) ->
    for answer in this.answers
      return answer if answer.id == id
    return null

  commentById: (id) ->
    for comment in this.comments
      return comment if comment.id == id
    return null
