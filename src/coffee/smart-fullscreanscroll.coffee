(($, angular) ->
  angular.module 'smart-fullscreanscroll', []
  .directive 'smartFullscreanscroll', ['$timeout', ($timeout) ->
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
          mainObj.on 'mouseenter.smartFullscreanscroll',
            () ->
              pauseScroll(items)
              return
          .on 'mouseleave.smartFullscreanscroll',
            () ->
              continueScroll(items, animateFactor)
              return
          return
        
        unregisterObservers = (mainObj) ->
          mainObj.off 'mouseenter.smartFullscreanscroll'
          mainObj.off 'mouseleave.smartFullscreanscroll'
          return
        
        constructor: (element) ->
          @mainObj = element
          @parentExtendCss = 'never-transform'
          @fullscreanscrollCss = 'smart-fullscreanscroll'
          @fullscreanscrollItemCss = 'smart-fullscreanscroll-item'
          @animateFactor = 20
          @children = []
          @scrollIsOn = false
          @enterFullscreanscrollPromise = null

        enterFullscreanscroll: () ->
          if @scrollIsOn
            return
          @scrollIsOn = true
          @mainObj.parents().addClass @parentExtendCss
          @mainObj.addClass @fullscreanscrollCss
          @items = getItems(@mainObj)
          $(window).trigger('resize')
          @enterFullscreanscrollPromise = $timeout () =>
            itemsTotalHeightIsOverWindow = getTotalHeight(@items) > $(window).height()
            initTop = 0
            for item in @items
              obj = item.obj
              obj.addClass @fullscreanscrollItemCss
              if itemsTotalHeightIsOverWindow
                beginAnimation @items, item, @animateFactor, initTop
              else
                obj.css 'top', initTop + 'px'
              initTop += obj.height()
            registerObservers(@mainObj, @items, @animateFactor) if itemsTotalHeightIsOverWindow
            return
          , 1500
        
        exitFullscreanscroll: () ->
          if not @scrollIsOn
            return
          $timeout.cancel @enterFullscreanscrollPromise
          @scrollIsOn = false
          @mainObj.parents().removeClass @parentExtendCss
          @mainObj.removeClass @fullscreanscrollCss
          for item in @items
            item.obj.stop true, false
            .removeClass @fullscreanscrollItemCss
            .css 'top', item.rawTop
          unregisterObservers(@mainObj)
          $(window).trigger('resize')
          return
        
      sf = new SmartFullScreanscroll elem
      scope.enterFullscreanscroll = () ->
        sf.enterFullscreanscroll()
        return
      scope.exitFullscreanscroll = () ->
        sf.exitFullscreanscroll()
        return
      return
  ]
)(jQuery, angular)
