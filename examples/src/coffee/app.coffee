angular.module 'app', ['smart-fullscreenscroll']
  .controller 'AppCtrl', ['$scope', '$timeout', ($scope, $timeout) ->
    $timeout () ->
      $scope.enterFullscreenscroll()
    , 50
    
    # $timeout () ->
    #   $scope.existFullscreenscroll()
    # , 40000
  ]
