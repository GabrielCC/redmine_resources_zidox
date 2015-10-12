'use strict';
var ResourceWindow = (function (me, $) {
  var self = me || function (selector) {
    this.root = $(selector);
    this.initialize();
  };

  var def = self.prototype;

  def.createEstimationElement = function (element) {
    return '<tr>\
        <td class="estimation-cell">\
        <div class="resource-estimation editable"\
          data-id="' + element.id + '">' + element.estimation +
        '</div> h\
        </td>\
        <td>' + element.code + '</td>\
        <td>\
          <a class="icon icon-del remove" rel="nofollow" data-id="' +
            element.id + '" href="#">Delete</a>\
         </td>\
      </tr>';
  }

  def.createDivisionElement = function (division) {
    var partial =  '<table><tbody><tr>\
        <td colspan="3" class="division-name">\
          <strong>' + division.name + '</strong>\
        </td>\
      </tr>';
    $.each(division.elements, function (index, element) {
      partial += this.createEstimationElement(element);
    }.bind(this));
    partial += '</tbody></table>';
    return partial;
  };

  def.loadIssueResources = function (divisions) {
    var list = this.root.find('.resources-list');
    list.empty();
    var newElements = '';
    $.each(divisions, function (key, value) {
      newElements += this.createDivisionElement(value);
    }.bind(this));
    list.append(newElements);
  };

  def.loadAvailableResources = function (resources) {
    var select = this.root.find('.resource-id');
    select.empty();
    select.append('<option value="">&nbsp;</option>');
    $.each(resources, function (index, value) {
      select.append('<option value="' + value.id + '">' + value.code +
        '</option>');
    });
  };

  def.reloadIssueResources = function (response) {
    this.loadIssueResources(response.divisions);
    this.loadAvailableResources(response.resources);
    this.addDeleteEvents();
    this.root.find('input.estimation').val('');
  };

  def.removeIssueResourceElement = function (target) {
    var row = target.closest('tr');
    var siblings = row.siblings();
    target.off('click');
    if (siblings.length > 1) {
      row.remove();
    } else {
      row.closest('table').remove();
    }
  };

  def.addDeleteEvents = function () {
    var buttons = this.root.find('a.remove');
    buttons.on('click', function (event) {
      event.preventDefault();
      var target = $(event.target);
      var id = target.data('id');
       $.ajax({
        dataType: 'json',
        type: 'DELETE',
        url: '/issue_resources/' + id
      }).done(function (response) {
        this.removeIssueResourceElement(target);
        this.loadAvailableResources(response);
      }.bind(this)).fail(function (response) {
        console.log('Failed to delete issue resource!');
      }.bind(this));
    }.bind(this));
  };

  def.createIssueResource = function() {
    var data = { issue_resource: {
      issue_id: this.root.find('.issue-id').val(),
      estimation: this.root.find('.estimation').val(),
      resource_id: this.root.find('.resource-id').val()
    }};
    $.ajax({
      data: data,
      dataType: 'json',
      type: 'POST',
      url: '/issue_resources'
    }).done(this.reloadIssueResources.bind(this))
    .fail(function (response) {
      console.log('Failed to create issue resource!');
    }.bind(this));
  };

  def.addButtonEvents =function () {
    this.root.find('.actions .save').on('click', function (event) {
      event.preventDefault();
      this.createIssueResource();
    }.bind(this));
    this.addDeleteEvents();
  };

  def.initialize = function () {
    this.addButtonEvents();
  };

  return self;
}(ResourceWindow, $));

$(function () {
  var resourceWindow = new ResourceWindow('#resources');
});
