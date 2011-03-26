$('document').ready(function(){
  var comments = _.reduce(window.comments, function(a, e){
    if (!a[e.timestamp]) { a[e.timestamp] = []; }
    a[e.timestamp].push(e);
    return a;
    }, {});

  var timestamps = _.map(_.keys(comments), function(a){ return parseInt(a, 10); });

  var currentComment = null;

  var loadComment = function(comment) {
    console.log(comment);
  };

  var updateComments = function(){
    var offset = $('#player')[0].currentTime * 1000;
    var before = _.select(timestamps, function(a){
      return a <= offset;
    });
    var latest = (before.length > 0) ? _.max(before) : _.min(timestamps);
    if (latest !== currentComment) {
      currentComment = latest;
      loadComment(comments[latest]);
    }
    setTimeout(updateComments, 500);
  };
  updateComments();
});
