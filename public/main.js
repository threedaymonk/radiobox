$('document').ready(function(){
  var CommentSet = function(comments){
    this._comments = _.reduce(window.comments, function(a, e){
      if (!a[e.timestamp]) { a[e.timestamp] = []; }
      a[e.timestamp].push(e);
      return a;
    }, {});

    this._timestamps = _.map(_.keys(this._comments), function(a){ return parseInt(a, 10); });
    this._currentComment = null;
    this._updateComments();
  };

  CommentSet.prototype.poll = function(selector, callback, interval){
    var periodic = function(){
      setTimeout(periodic, interval)
      this._updateComments(selector, callback);
    }.bind(this);
    periodic();
  };

  CommentSet.prototype._updateComments = function(selector, callback){
    var element = $(selector)[0];
    if (!element) { return; }
    var offset = element.currentTime * 1000;
    var before = _.select(this._timestamps, function(a){ return a <= offset; });
    var latest = (before.length > 0) ? _.max(before) : _.min(this._timestamps);
    if (latest !== this._currentComment) {
      this._currentComment = latest;
      callback(this._comments[latest]);
    }
  };

  var commentSet = new CommentSet(window.comments);
  commentSet.poll('#player', function(cs) {
    console.log(cs);
  }, 500);
});
