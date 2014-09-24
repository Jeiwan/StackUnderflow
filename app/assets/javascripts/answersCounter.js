$(function(){
  window.answersCounter = new AnswersCounter("#answers-counter");
});

function AnswersCounter(counterId) {
  this.$el = $(counterId);
  this.counter = this.$el.data("counter")
}

AnswersCounter.prototype.increase = function() {
  this.counter++;
  this.render();
};

AnswersCounter.prototype.decrease = function() {
  this.counter--;
  this.render();
};

AnswersCounter.prototype.render = function() {
  var answerText = this.counter > 1 ? "Answers" : "Answer";
  this.$el.text(this.counter + " " + answerText);
};
