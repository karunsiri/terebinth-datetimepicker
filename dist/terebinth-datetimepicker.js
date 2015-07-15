(function() {
  var directive;

  angular.module('terebinth.datetimepicker', []);

  directive = function($parse, $filter) {
    var enableDatepicker, getTarget, init, linkFn, showDatePicker, turnOffEventListeners;
    getTarget = function(element) {
      return element.find('.datepicker-wrapper');
    };
    enableDatepicker = function(scope, element, attrs, ngModelCtrl) {
      var format, target;
      format = scope.format;
      target = getTarget(element);
      scope.datePicker = target.datetimepicker({
        widgetPositioning: {
          vertical: scope.position
        },
        showTodayButton: scope.showTodayButton,
        format: format,
        defaultDate: scope.date,
        icons: {
          date: 'fa fa-calendar'
        }
      });
      target.on('click', '.datepicker-input', function(e) {
        return showDatePicker(scope);
      });
      if (!scope.editable) {
        return target.on('keydown input paste mousedown', '.datepicker-input', function(e) {
          return e.preventDefault();
        });
      }
    };
    showDatePicker = function(scope) {
      return scope.datePicker.data('DateTimePicker').show();
    };
    turnOffEventListeners = function(element) {
      var target;
      target = getTarget(element);
      target.off('click', '.datepicker-input');
      return target.off('keydown input paste mousedown', '.datepicker-input');
    };
    init = function(scope, element, attrs, ngModelCtrl) {
      if (!angular.isDefined(attrs.format)) {
        scope.format = 'YYYY-MM-DD';
      }
      if (angular.isDefined(attrs.defaultDate)) {
        scope.date = attrs.defaultDate;
      }
      if (angular.isDefined(attrs.showTodayButton)) {
        scope.showTodayButton = $parse(attrs.showTodayButton)(scope);
      } else {
        scope.showTodayButton = true;
      }
      if (!angular.isDefined(attrs.position)) {
        return scope.position = 'bottom';
      }
    };
    linkFn = function(scope, element, attrs, ngModelCtrl) {
      var textWatcher;
      init(scope, element, attrs, ngModelCtrl);
      enableDatepicker(scope, element, attrs.ngModelCtrl);
      ngModelCtrl.$render = function() {
        return scope.date = ngModelCtrl.$viewValue;
      };
      textWatcher = scope.$watch('date', function(newVal) {
        var current;
        if (!newVal || (newVal == null) || !newVal.length) {
          if (scope.defaultToCurrent) {
            current = moment().format(scope.format);
            return getTarget(element).find('.datepicker-input').val(current);
          }
        }
      });
      return element.on('$destroy', function() {
        turnOffEventListeners(element);
        return textWatcher();
      });
    };
    return {
      restrict: 'E',
      require: 'ngModel',
      templateUrl: '/terebinth-datetimepicker/datepicker.html',
      scope: {
        format: '@',
        date: '=ngModel',
        required: '=',
        disabled: '=',
        showClearButton: '=',
        defaultToCurrent: '=',
        defaultDate: '@',
        position: '@',
        editable: '='
      },
      link: linkFn,
      controller: [
        '$scope', function($scope) {
          return $scope.clearValue = function() {
            return $scope.date = '';
          };
        }
      ]
    };
  };

  directive.$inject = ['$parse', '$filter'];

  angular.module('terebinth.datetimepicker').directive('terebinthDatepicker', directive);

}).call(this);

angular.module("terebinth.datetimepicker").run(["$templateCache", function($templateCache) {$templateCache.put("/terebinth-datetimepicker/datepicker.html","<div class=\'input-group datepicker-wrapper\'>\n  <span class=\"input-group-addon datepickerbutton\">\n    <span class=\"glyphicon glyphicon-calendar\"></span>\n  </span>\n\n  <input type=\"text\"\n    class=\"form-control datepicker-input\"\n    ng-model=\"date\"\n    ng-value=\"date\"\n    ng-required=\"required\"\n    ng-disabled=\"disabled\"\n    live-model\n    >\n\n  <span class=\"input-group-btn\" ng-show=\"showClearButton\">\n    <button class=\"btn btn-default\" type=\"button\" ng-click=\"clearValue()\" ng-disabled=\"disabled\">\n      <span class=\"glyphicon glyphicon-remove\"></span>\n    </button>\n  </span>\n </div>\n");}]);