# Define a main module
angular.module('terebinth.datetimepicker', [])

directive = ($parse, $filter) ->
  getTarget = (element) ->
    element.find('.datepicker-wrapper')

  enableDatepicker = (scope, element, attrs, ngModelCtrl) ->
    format = scope.format
    target = getTarget(element)
    scope.datePicker = target.datetimepicker {
      widgetPositioning: {
        vertical: scope.position
      },
      showTodayButton: scope.showTodayButton,
      format: format,
      defaultDate: scope.date,
      icons: {
        date: 'fa fa-calendar'
      },
    }

    # Update model everytime the input changed
    target.on 'dp.change', (e) ->
      scope.date = target.find('.datepicker-input').val()

    target.on 'click', '.datepicker-input', (e) ->
      showDatePicker(scope)

    unless scope.editable
      target.on 'keydown input paste mousedown', '.datepicker-input', (e) ->
        e.preventDefault()

  showDatePicker = (scope) ->
    scope.datePicker.data('DateTimePicker').show()

  turnOffEventListeners = (element) ->
    target = getTarget(element)
    target.off 'click', '.datepicker-input'
    target.off 'keydown input paste mousedown', '.datepicker-input'
    target.off 'dp.change'

  init = (scope, element, attrs, ngModelCtrl) ->
    scope.format = 'YYYY-MM-DD' unless angular.isDefined(attrs.format)
    scope.date = attrs.defaultDate if angular.isDefined(attrs.defaultDate)

    if angular.isDefined(attrs.showTodayButton)
      scope.showTodayButton = $parse(attrs.showTodayButton)(scope)
    else
      scope.showTodayButton = true

    scope.position = 'auto' unless angular.isDefined(attrs.position)

  linkFn = (scope, element, attrs, ngModelCtrl) ->
    init(scope, element, attrs, ngModelCtrl)
    enableDatepicker(scope, element, attrs, ngModelCtrl)

    if scope.defaultToCurrent
      if not scope.date or not scope.date? or not scope.date.length
        current = moment().format(scope.format)
        scope.date = current

    textWatcher = scope.$watch 'date', (newVal) ->
      ngModelCtrl.$setViewValue(newVal)

    element.on '$destroy', ->
      textWatcher()
      turnOffEventListeners(element)

  return {
    restrict: 'E',
    require: 'ngModel'
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
      '$scope',
      ($scope) ->
        $scope.clearValue = ->
          $scope.date = ''
    ]
  }

directive.$inject = ['$parse', '$filter']
angular.module('terebinth.datetimepicker').directive 'terebinthDatetimepicker', directive
