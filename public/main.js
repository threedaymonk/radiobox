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
      setTimeout(periodic, interval);
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

  CommentSet.prototype.each = function(callback){
    _.each(_.values(this._comments), callback);
  };

  var Resolver = function(){
    this._cache = {};
  };

  Resolver.prototype.fetch = function(comment, callback){
    if (['wikipedia', 'dbpedia', 'flickr'].indexOf(comment.type) > -1) {
      $.ajax({
        url: '/' + comment.type + '/' + comment.body,
        success: callback
      });
    } else {
      callback(comment.body);
    }
  };

  Resolver.prototype.resolve = function(comment, callback){
    var cached = this._cache[comment.id];
    if (cached) {
      callback(cached);
    } else {
      this.fetch(comment, function(data){
        this._cache[comment.id] = data;
        callback(data);
      }.bind(this));
    }
  };

  var flickrSet = new CommentSet(_.select(window.RadioBox.comments, function(a){
    return a.type === "flickr";
  }));

  var commentSet = new CommentSet(_.select(window.RadioBox.comments, function(a){
    return a.type !== "flickr";
  }));

  var resolver = new Resolver();

  flickrSet.each(function(comments){
    resolver.resolve(comments[0], function(data){
      var im = new Image();
      $(im).attr('src', data);
    });
  });

  commentSet.each(function(comments){
    resolver.resolve(comments[0], function(){});
  });

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
    var comment = cs[0];
    resolver.resolve(comment, function(data){
      var im = new Image();
      $(im).load(function(){
        $('#background').attr('src', data);
        setTimeout(setBackgroundScale, 1);
      }).attr('src', data);
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
    var comment = cs[0];
    resolver.resolve(comment, function(data){
      $('#content').text(data).attr('class', comment.type);
      centerContent();
    });
  }, 500);

  $(window).resize(centerContent);
  $(window).resize(setBackgroundScale);
});
