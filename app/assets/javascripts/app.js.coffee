this.Underflow = {}
$ ->
  Underflow.question = new Question

  $(".answers .answer").each((i, e) ->
    answer = new Answer(e.id)
    answer.$el.find(".comment").each((i, e) ->
      answer.comments.push(new Comment(e.id, "answers", answer.id))
    )
    Underflow.question.answers.push(answer)
  )

  $(".question .comment").each((i, e) ->
    Underflow.question.comments.push(new Comment(e.id, "questions", Underflow.question.id))
  )

  Shadowbox.init()
