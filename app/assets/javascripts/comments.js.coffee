class @Comment
  constructor: (@commentId, @commentable_type, @commentable_id) ->
    this.$el= $("##{commentId}")
    this.$body = this.$el.find(".comment-body")
    this.$voting = this.$el.find(".voting")
    this.$votes = this.$voting.find(".votes")
    this.id = parseInt(commentId.split("_")[1], 10)

    this.binds()
    this.setAjaxHooks()

  binds: () ->
    that = this
    this.$el.on "click", ".edit-comment", (e) ->
      e.preventDefault()
      that.edit(HandlebarsTemplates["edit_comment"]({id: that.id, commentable: that.commentable_type, commentable_id: that.commentable_id, body: that.$body.text()}))

  setAjaxHooks: () ->
    that = this
    this.$el.on "ajax:success", "form.edit_comment", (e, data, status, xhr) ->
      that.$el.html($(HandlebarsTemplates["comment"](xhr.responseJSON)).contents())
      that.$el= $("##{that.commentId}")
      that.$body = that.$el.find(".comment-body")
      that.binds()

    this.$el.on "ajax:error", "form.edit_comment", (e, xhr, status) ->
      that.renderFormErrors(this, xhr.responseJSON)

    this.$voting.on "ajax:success", "a.vote-up", (e, data, status, xhr) ->
      that.$votes.text(xhr.responseJSON.votes)
      $(this).replaceWith($("<span class='voted-up'><span class='glyphicon glyphicon-plus'></span></span>"))
      that.$voting.find("a.vote-down").remove()

    this.$voting.on "ajax:success", "a.vote-down", (e, data, status, xhr) ->
      that.$votes.text(xhr.responseJSON.votes)
      $(this).replaceWith($("<span class='voted-down'><span class='glyphicon glyphicon-minus'></span></span>"))
      that.$voting.find("a.vote-up").remove()

  edit: (comment) ->
    this.$el.html(comment)

  renderFormErrors: (form, response) ->
    this.clearFormErrors(form)
    $form = $(form)
    $form.prepend("<div class='alert alert-danger'>Please review the problems below:</div>")
    for field, error of response
      field = $form.find(".form-control[id$=#{field}]")
      formGroup = field.parents(".form-group").addClass("has-error")
      formGroup.append("<span class='help-block error'>#{error[0]}</a>")

  clearFormErrors: (form) ->
    $form = $(form)
    $form.find(".alert.alert-danger").remove()
    formGroup = $form.find(".has-error")
    formGroup.find(".help-block.error").remove()
    formGroup.removeClass("has-error")
