angular.module('app', ['smart-fullscreenscroll']).controller('AppCtrl', [
  '$scope', '$timeout', function($scope, $timeout) {
    return $timeout(function() {
      return $scope.enterFullscreenscroll();
    }, 50);
  }
]);
