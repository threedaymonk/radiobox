$('document').ready(function(){
  var CommentSet = function(comments){
    this._comments = _.reduce(comments, function(a, e){
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

  var flickrSet = new CommentSet(_.select(window.comments, function(a){
    return a.type === "flickr";
  }));

  var commentSet = new CommentSet(_.select(window.comments, function(a){
    return a.type !== "flickr";
  }));

  var setBackgroundScale = function(){
    var w = $(window),
        e = $('#background'),
        wa = w.width() / w.height(),
        ea = e.width() / e.height();
    if (ea > wa) {
      e.css('height', '100%').
        css('width',  'auto').
        css('top',    '0').
        css('left',   (w.width() - e.width()) / 2 + 'px');
    } else {
      e.css('height', 'auto').
        css('width',  '100%').
        css('top',    (w.height() - e.height()) / 2 + 'px').
        css('left',   '0');
    }
  };

  flickrSet.poll('#player', function(cs) {
    console.log(["flickr", cs]);
    $.ajax({
      url: '/flickr/' + cs[0].body,
      success: function(data){
        console.log(data);
        var im = new Image();
        $(im).load(function(){
          $('#background').attr('src', data);
          setTimeout(setBackgroundScale, 1);
        }).attr('src', data);
      }
    });
  }, 500);

  var centerContent = function() {
    $('body').css('font-size', $(window).height() / 16 + 'px');
    var el = $('#content');
    el.css('position', 'absolute').
       css('left', (($(window).width()  / 2) - (el.width()  / 2)) + 'px').
       css('top',  (($(window).height() / 2) - (el.height() / 2)) + "px");
  };

  commentSet.poll('#player', function(cs) {
    console.log(["comment", cs]);
    switch (cs[0].type) {
      case "wikipedia":
        $.ajax({
          url: '/wikipedia/' + cs[0].body,
          success: function(data){
            console.log(data);
            $('#content').text(data).attr('class', cs[0].type);
          }
        });
        break;
      case "dbpedia":
        $.ajax({
          url: '/dbpedia/' + cs[0].body,
          success: function(data){
            console.log(data);
            $('#content').text(data).attr('class', cs[0].type);
          }
        });
        break;
      default:
        var elements = $('#content');
        elements.attr('class', cs[0].type);
        elements.text(cs[0].body);
        centerContent();
    }
  }, 500);

  $(window).resize(centerContent);
  $(window).resize(setBackgroundScale);
});
