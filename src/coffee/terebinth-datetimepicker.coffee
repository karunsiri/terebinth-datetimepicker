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

  init = (scope, element, attrs, ngModelCtrl) ->
    scope.format = 'YYYY-MM-DD' unless angular.isDefined(attrs.format)
    scope.date = attrs.defaultDate if angular.isDefined(attrs.defaultDate)

    if angular.isDefined(attrs.showTodayButton)
      scope.showTodayButton = $parse(attrs.showTodayButton)(scope)
    else
      scope.showTodayButton = true

    scope.position = 'bottom' unless angular.isDefined(attrs.position)

  linkFn = (scope, element, attrs, ngModelCtrl) ->
    init(scope, element, attrs, ngModelCtrl)
    enableDatepicker(scope, element, attrs. ngModelCtrl)

    ngModelCtrl.$render = ->
      scope.date = ngModelCtrl.$viewValue

    textWatcher = scope.$watch 'date', (newVal) ->
      if not newVal or not newVal? or not newVal.length
        if scope.defaultToCurrent
          current = moment().format(scope.format)
          getTarget(element).find('.datepicker-input').val(current)

    element.on '$destroy', ->
      turnOffEventListeners(element)
      textWatcher()

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

# Make datetime picker input live reload
liveModel = ($parse, $interval) ->
  linkFn = (scope, element, attrs) ->
    if angular.isDefined(attrs.updateInterval)
      scope.updateInterval = $parse(attrs.updateInterval)(scope)
    else
      scope.updateInterval = 500

    attribute = attrs.ngModel || element.attr('name')

    if angular.isDefined(attrs.ngValue)
      value = $parse(attrs.ngValue)(scope)
    else
      value = $(element).val()

    $parse(attribute).assign(scope, value)

    watcher = $interval(
      ->
        value = $(element).val() || ''
        $parse(attribute).assign(scope, value)
      ,
      scope.updateInterval
    )

    element.on '$destroy', ->
      $interval.cancel(watcher)

  return {
    restrict: 'A',
    link: linkFn
  }
liveModel.$inject = ['$parse', '$interval']
angular.module('terebinth.datetimepicker').directive 'terebinthDatetimepickerLiveModel', liveModel
