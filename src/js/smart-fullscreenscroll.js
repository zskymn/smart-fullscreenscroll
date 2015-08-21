(function($, angular) {
  return angular.module('smart-fullscreenscroll', []).directive('smartFullscreenscroll', [
    '$timeout', function($timeout) {
      return {
        restict: 'A',
        scope: true,
        link: function(scope, elem) {
          var SmartFullScreanscroll, sf;
          SmartFullScreanscroll = (function() {
            var beginAnimation, continueScroll, getItems, getTotalHeight, pauseScroll, registerObservers, unregisterObservers;

            getItems = function(mainObj) {
              var child, item, items, _i, _len, _ref;
              items = [];
              _ref = mainObj.children();
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                child = _ref[_i];
                item = {};
                item.obj = $(child);
                item.rawTop = item.obj.css('top');
                if (item.obj.css('display') !== 'none') {
                  items.push(item);
                }
              }
              return items;
            };

            getTotalHeight = function(items) {
              var item, totalHeight, _i, _len;
              totalHeight = 0;
              for (_i = 0, _len = items.length; _i < _len; _i++) {
                item = items[_i];
                totalHeight += item.obj.height();
              }
              return totalHeight;
            };

            beginAnimation = function(items, item, animateFactor, initTop) {
              var itemHeight, pos;
              itemHeight = item.obj.height();
              pos = initTop != null ? initTop : getTotalHeight(items) - itemHeight;
              item.obj.css('top', pos + 'px').animate({
                top: (-itemHeight) + 'px'
              }, (pos + itemHeight) * animateFactor, 'linear', (function(items, item, animateFactor) {
                return function() {
                  beginAnimation(items, item, animateFactor);
                };
              })(items, item, animateFactor));
            };

            pauseScroll = function(items) {
              var item, _i, _len;
              for (_i = 0, _len = items.length; _i < _len; _i++) {
                item = items[_i];
                item.obj.stop(true, false);
              }
            };

            continueScroll = function(items, animateFactor) {
              var initTop, item, _i, _len;
              for (_i = 0, _len = items.length; _i < _len; _i++) {
                item = items[_i];
                initTop = item.obj.offset().top;
                beginAnimation(items, item, animateFactor, initTop);
              }
            };

            registerObservers = function(mainObj, items, animateFactor) {
              mainObj.on('mouseenter.smartFullscreenscroll', function() {
                pauseScroll(items);
              }).on('mouseleave.smartFullscreenscroll', function() {
                continueScroll(items, animateFactor);
              });
            };

            unregisterObservers = function(mainObj) {
              mainObj.off('mouseenter.smartFullscreenscroll');
              mainObj.off('mouseleave.smartFullscreenscroll');
            };

            function SmartFullScreanscroll(element) {
              this.mainObj = element;
              this.parentExtendCss = 'never-transform';
              this.fullscreenscrollCss = 'smart-fullscreenscroll';
              this.fullscreenscrollItemCss = 'smart-fullscreenscroll-item';
              this.animateFactor = 20;
              this.items = [];
              this.scrollIsOn = false;
              this.enterFullscreenscrollPromise = null;
            }

            SmartFullScreanscroll.prototype.enterFullscreenscroll = function() {
              if (this.scrollIsOn) {
                return;
              }
              this.scrollIsOn = true;
              this.mainObj.parents().addClass(this.parentExtendCss);
              this.mainObj.addClass(this.fullscreenscrollCss);
              this.items = getItems(this.mainObj);
              $(window).trigger('resize');
              return this.enterFullscreenscrollPromise = $timeout((function(_this) {
                return function() {
                  var initTop, item, itemsTotalHeightIsOverWindow, obj, _i, _len, _ref;
                  itemsTotalHeightIsOverWindow = getTotalHeight(_this.items) > $(window).height();
                  initTop = 0;
                  _ref = _this.items;
                  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                    item = _ref[_i];
                    obj = item.obj;
                    obj.addClass(_this.fullscreenscrollItemCss);
                    if (itemsTotalHeightIsOverWindow) {
                      beginAnimation(_this.items, item, _this.animateFactor, initTop);
                    } else {
                      obj.css('top', initTop + 'px');
                    }
                    initTop += obj.height();
                  }
                  if (itemsTotalHeightIsOverWindow) {
                    registerObservers(_this.mainObj, _this.items, _this.animateFactor);
                  }
                };
              })(this), 1500);
            };

            SmartFullScreanscroll.prototype.exitFullscreenscroll = function() {
              var item, _i, _len, _ref;
              if (!this.scrollIsOn) {
                return;
              }
              $timeout.cancel(this.enterFullscreenscrollPromise);
              this.scrollIsOn = false;
              this.mainObj.parents().removeClass(this.parentExtendCss);
              this.mainObj.removeClass(this.fullscreenscrollCss);
              _ref = this.items;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                item = _ref[_i];
                item.obj.stop(true, false).removeClass(this.fullscreenscrollItemCss).css('top', item.rawTop);
              }
              unregisterObservers(this.mainObj);
              $(window).trigger('resize');
            };

            return SmartFullScreanscroll;

          })();
          sf = new SmartFullScreanscroll(elem);
          scope.enterFullscreenscroll = function() {
            sf.enterFullscreenscroll();
          };
          scope.exitFullscreenscroll = function() {
            sf.exitFullscreenscroll();
          };
        }
      };
    }
  ]);
})(jQuery, angular);
