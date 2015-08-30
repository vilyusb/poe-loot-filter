$ = angular.element

app = angular.module('plf', ['ui.bootstrap', 'ngRangeSlider'])
app.config(['$compileProvider', ($compileProvider) ->
  $compileProvider.aHrefSanitizationWhitelist(/^\s*blob:/)
]);
app.controller 'CreatorController', ['$scope', '$modal', ($scope, $modal) ->
  $scope.operators = {
    '>': 'More than'
    '>=': 'At least'
    '=': 'Equals'
    '<=': 'Up to'
    '<': 'Less than'
  }
  $scope.rarities = [
    'Normal', 'Magic', 'Rare', 'Unique'
  ]
  empty_rule = {
    hide: no
    hideshow: 'show'
    anyclass: yes
    classes: []
    basetype: ''
    socketgroup: []
    rarity: null
    anyquality: yes
    quality: {from: 0, to: 20}
    anydroplvl: yes
    droplvl: {from: 0, to: 100}
    anyitemlvl: yes
    itemlvl: {from: 0, to: 100}
    anysockets: yes
    sockets: {from: 0, to: 6}
    anylinkedsockets: yes
    linkedsockets: {from: 0, to: 6}
    anyheight: yes
    height: {from: 1, to: 4}
    anywidth: yes
    width: {from: 1, to: 2}
    anylabel: yes
    label: {
      border: {r: 0, g: 0, b: 0, a: 0}
      size: 32
      textcolor: {r: 255, g: 255, b: 255, a: 255}
      bg: {r: 0, g: 0, b: 0, a: 240}
    }
    showborder: no
    showsize: no
    showtextcolor: no
    showbg: no
    nosound: yes
    sound: '1'
    setvolume: no
    volume: 150
  }
  $scope.add = ->
    $scope.rules.push angular.copy(empty_rule)
  $scope.rules = []
  $scope.classes = [
    'Active Skill Gems',
    'Amulets',
    'Arrowcuda',
    'Basaltic Stinger',
    'Belts',
    'Body Armours',
    'Boots',
    'Bows',
    'Burrowmundi',
    'Chromatic Squirter',
    'Claws',
    'Coffinjaw',
    'Currency',
    'Daggers',
    'Deathgrinner',
    'Equalussuaquatch',
    'Fangtooth',
    'Fishing Rods',
    'Flameray',
    'Gloves',
    'Heliobenth',
    'Helmets',
    'Hideout Doodads',
    'Hulkeri',
    'Hybrid Flasks',
    'Kilimorae',
    'Knifeback',
    'Life Flasks',
    'Mana Flasks',
    'Map Fragments',
    'Maps',
    'Microtransactions',
    'One Hand Axes',
    'One Hand Maces',
    'One Hand Swords',
    'Planc Grai',
    'Plink Snapper',
    'Quest Items',
    'Quivers',
    'Rings',
    'Sceptres',
    'Shields',
    'Socketclops',
    'Stackable Currency',
    'Staves',
    'Support Skill Gems',
    'Teslateuth',
    'Thrusting One Hand Swords',
    'Two Hand Axes',
    'Two Hand Maces',
    'Two Hand Swords',
    'Utility Flasks',
    'Wands'
  ]
  $scope.has_class = (rule, cls) -> cls in rule.classes
  $scope.toggle_class = (rule, cls) ->
    if cls in rule.classes
      rule.classes.splice rule.classes.indexOf(cls), 1
    else
      rule.classes.push cls
  $scope.edit_socket_group = (rule) ->
    $modal.open({
      template: '
      <div class="modal-header">
        Edit linked sockets group
      </div>
      <div class="modal-body">
        <div ng-hide="sockets.length > 5">
          <button type="button" class="btn-xs btn-danger" ng-click="sockets.push(\'red\')">
            <span class="glyphicon glyphicon-plus"></span> red
          </button>
          <button type="button" class="btn-xs btn-success" ng-click="sockets.push(\'green\')">
            <span class="glyphicon glyphicon-plus"></span> green
          </button>
          <button type="button" class="btn-xs btn-primary" ng-click="sockets.push(\'blue\')">
            <span class="glyphicon glyphicon-plus"></span> blue
          </button>
          <button type="button" class="btn-xs btn-default" ng-click="sockets.push(\'white\')">
            <span class="glyphicon glyphicon-plus"></span> white
          </button>
        </div>
        <div class="well well-sm" ng-show="sockets.length">
          <button type="button" ng-repeat="socket in sockets track by $index"
                  class="btn btn-xs" ng-click="sockets.splice($index, 1)"
                  ng-class="\'btn-\' + ({red: \'danger\', blue: \'primary\', green: \'success\', white: \'default\'})[socket]"
                  ng-bind="socket" title="remove &laquo;{{ socket }}&raquo; from socket group"></button>
          <button type="button" class="btn btn-xs btn-default"
                  ng-show="sockets.length" ng-click="sockets.splice(0, sockets.length)">
            <span class="glyphicon glyphicon-remove"></span> clear
          </button>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn-success" ng-click="done()">Done</button>
        <button type="button" class="btn-default" ng-click="$dismiss()">Cancel</button>
      </div>'
      controller: ['$scope', ($modal_scope) ->
        $modal_scope.sockets = angular.copy rule.socketgroup
        $modal_scope.done = ->
          rule.socketgroup = $modal_scope.sockets
          $modal_scope.$close()
      ]
    })
  $scope.fmt_range = (range) ->
    if range.to == range.from then return String range.to
    return "From #{range.from} to #{range.to}"
  $scope.get_color = (c) -> "RGBA(#{c.r}, #{c.g}, #{c.b}, #{c.a / 255})"
  $scope.get_size = (size) -> parseInt(Math.round(size / 2)) + 'px'
  render_range = (param, range) ->
    if range.to == range.from
      return "\n    #{param} = #{range.to}"
    return "\n    #{param} >= #{range.from}\n    #{param} <= #{range.to}"

  render = (blocks) ->
    res = ''
    range_params = ['Quality', 'DropLevel', 'ItemLevel', 'Width', 'Height',
                    'Sockets', 'LinkedSockets']
    for block in blocks
      res += block[0]
      for own key, value of block[1]
        unless key in range_params
          res += "\n    #{key} #{value}"
        else
          res += render_range(key, value)
      res += '\n'
    return res

  render_properties = (rule) ->
    obj = {}
    unless rule.anyclass
      if rule.classes.length
        obj.Class = ('"' + cls + '"' for cls in rule.classes).join(' ')
    if rule.basetype and rule.basetype.length
      obj.BaseType = '"' + rule.basetype + '"'
    if rule.rarity
      obj.Rarity = rule.rarity
    if rule.socketgroup.length
      obj.SocketGroup = ({
        red: 'R'
        green: 'G'
        blue: 'B'
        white: 'W'
      }[color] for color in rule.socketgroup).join('')
    unless rule.anyquality
      obj.Quality = rule.quality
    unless rule.anydroplvl
      obj.DropLevel = rule.droplvl
    unless rule.anyitemlvl
      obj.ItemLevel = rule.itemlvl
    unless rule.anysockets
      obj.Sockets = rule.sockets
    unless rule.anylinkedsockets
      obj.LinkedSockets = rule.linkedsockets
    unless rule.anyheight
      obj.Height = rule.height
    unless rule.anywidth
      obj.Width = rule.width
    unless rule.anylabel
      obj.SetBorderColor = [
        rule.label.border.r,
        rule.label.border.g,
        rule.label.border.b,
        rule.label.border.a,
      ].join(' ')
      obj.SetTextColor = [
        rule.label.textcolor.r,
        rule.label.textcolor.g,
        rule.label.textcolor.b,
        rule.label.textcolor.a,
      ].join(' ')
      obj.SetBackgroundColor = [
        rule.label.bg.r,
        rule.label.bg.g,
        rule.label.bg.b,
        rule.label.bg.a,
      ].join(' ')
      obj.SetFontSize = rule.label.size
    unless rule.nosound
      sound = rule.sound
      if rule.setvolume
        sound += ' ' + rule.volume
      obj.PlayAlertSound = sound
    return obj

  $scope.generate = ->
    blocks = []
    for rule in $scope.rules
      if rule.hideshow == 'hideall'
        blocks.push ['Hide', {}]
        return render(blocks)
      else if rule.hideshow == 'show'
        block = ['Show', {}]
      else if rule.hideshow == 'hide'
        block = ['Hide', {}]
      else
        throw 'WTF! ' + rule.hideshow
      blocks.push block
      block[1] = render_properties(rule)
    return render(blocks)

  move_in_arr = (arr, element, offset) ->
    index = arr.indexOf(element)
    newIndex = index + offset

    if newIndex > -1 && newIndex < arr.length
      # Remove the element from the array
      removedElement = arr.splice(index, 1)[0]

      # At "newIndex", remove 0 elements, insert the removed element
      arr.splice(newIndex, 0, removedElement)

  $scope.move_up_rule = (rule) -> move_in_arr($scope.rules, rule, -1)
  $scope.move_down_rule = (rule) -> move_in_arr($scope.rules, rule, 1)
  $scope.result = ''
  $scope.$watch('rules', ->
    $scope.result = $scope.generate()
  , true)
  $scope.download = () ->
    a = document.createElement "a"
    document.body.appendChild a
    a.style = "display: none"
    a.target = '_blank'
    blob = new Blob([$scope.result], {type: 'text/plain'})
    url = window.URL.createObjectURL(blob)
    a.href = url
    a.download = 'loot-filter.filter'
    a.click()
    window.URL.revokeObjectURL url
    document.body.removeChild a
    return true
]

$(document).ready ->
  angular.bootstrap document, ['plf']

