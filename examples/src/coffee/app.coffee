angular.module 'app', ['smart-fullscreanscroll']
  .controller 'AppCtrl', ['$scope', '$timeout', ($scope, $timeout) ->
    $timeout () ->
      $scope.enterFullscreanscroll()
    , 50
    
    # $timeout () ->
    #   $scope.existFullscreanscroll()
    # , 40000
  ]
