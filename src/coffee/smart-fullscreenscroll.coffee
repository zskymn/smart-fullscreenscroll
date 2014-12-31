(($, angular) ->
  angular.module 'smart-fullscreenscroll', []
  .directive 'smartFullscreenscroll', ['$timeout', ($timeout) ->
    restict: 'A',
    scope: true,
    link: (scope, elem) ->
      class SmartFullScreanscroll
        getItems = (mainObj) ->
          items = []
          for child in mainObj.children()
            item = {}
            item.obj = $(child)
            item.rawTop = item.obj.css('top')
            items.push(item) if item.obj.css('display') isnt 'none'
          return items

        getTotalHeight = (items) ->
          totalHeight = 0
          for item in items
            totalHeight += item.obj.height()
          return totalHeight
        
        beginAnimation = (items, item, animateFactor, initTop) ->
          itemHeight = item.obj.height()
          pos = initTop ? (getTotalHeight(items) - itemHeight)
          item.obj.css('top', pos + 'px')
          .animate(
            {top:  (-itemHeight) + 'px'},
            (pos + itemHeight) * animateFactor,
            'linear',
            ((items, item, animateFactor) ->
              () ->
                beginAnimation(items, item, animateFactor)
                return
            )(items, item, animateFactor)
          )
          return
        
        pauseScroll = (items) ->
          for item in items
            item.obj.stop(true, false)
          return
        
        continueScroll = (items, animateFactor) ->
          for item in items
            initTop = item.obj.offset().top
            beginAnimation items, item, animateFactor, initTop
          return
        
        registerObservers = (mainObj, items, animateFactor) ->
          mainObj.on 'mouseenter.smartFullscreenscroll',
            () ->
              pauseScroll(items)
              return
          .on 'mouseleave.smartFullscreenscroll',
            () ->
              continueScroll(items, animateFactor)
              return
          return
        
        unregisterObservers = (mainObj) ->
          mainObj.off 'mouseenter.smartFullscreenscroll'
          mainObj.off 'mouseleave.smartFullscreenscroll'
          return
        
        constructor: (element) ->
          @mainObj = element
          @parentExtendCss = 'never-transform'
          @fullscreenscrollCss = 'smart-fullscreenscroll'
          @fullscreenscrollItemCss = 'smart-fullscreenscroll-item'
          @animateFactor = 20
          @children = []
          @scrollIsOn = false
          @enterFullscreenscrollPromise = null

        enterFullscreenscroll: () ->
          if @scrollIsOn
            return
          @scrollIsOn = true
          @mainObj.parents().addClass @parentExtendCss
          @mainObj.addClass @fullscreenscrollCss
          @items = getItems(@mainObj)
          $(window).trigger('resize')
          @enterFullscreenscrollPromise = $timeout () =>
            itemsTotalHeightIsOverWindow = getTotalHeight(@items) > $(window).height()
            initTop = 0
            for item in @items
              obj = item.obj
              obj.addClass @fullscreenscrollItemCss
              if itemsTotalHeightIsOverWindow
                beginAnimation @items, item, @animateFactor, initTop
              else
                obj.css 'top', initTop + 'px'
              initTop += obj.height()
            registerObservers(@mainObj, @items, @animateFactor) if itemsTotalHeightIsOverWindow
            return
          , 1500
        
        exitFullscreenscroll: () ->
          if not @scrollIsOn
            return
          $timeout.cancel @enterFullscreenscrollPromise
          @scrollIsOn = false
          @mainObj.parents().removeClass @parentExtendCss
          @mainObj.removeClass @fullscreenscrollCss
          for item in @items
            item.obj.stop true, false
            .removeClass @fullscreenscrollItemCss
            .css 'top', item.rawTop
          unregisterObservers(@mainObj)
          $(window).trigger('resize')
          return
        
      sf = new SmartFullScreanscroll elem
      scope.enterFullscreenscroll = () ->
        sf.enterFullscreenscroll()
        return
      scope.exitFullscreenscroll = () ->
        sf.exitFullscreenscroll()
        return
      return
  ]
)(jQuery, angular)
