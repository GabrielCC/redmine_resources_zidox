'use strict';
var ResourceWindow = (function (me, $) {
  var self = me || function (selector) {
    this.root = $(selector);
    this.initialize();
  };

  var def = self.prototype;

  def.createEstimationElement = function (editableClass, element) {
    return '<tr>\
        <td class="estimation-cell ' + editableClass + '">\
        <div class="hours ' + editableClass + '"\
          data-id="' + element.id + '">' + element.estimation + '</div> h\
        </td>\
        <td>' + element.code + '</td>\
        <td>\
          <a class="icon icon-del remove" rel="nofollow" data-id="' +
            element.id + '" href="#">Delete</a>\
         </td>\
      </tr>';
  };

  def.createDivisionElement = function (editable, division) {
    var partial =  '<table><tbody><tr>\
        <td colspan="3" class="division-name">\
          <strong>' + division.name + '</strong>\
        </td>\
      </tr>';
    var editableClass = editable ? 'editable' : '';
    $.each(division.elements, function (index, element) {
      partial += this.createEstimationElement(editableClass, element);
    }.bind(this));
    partial += '</tbody></table>';
    return partial;
  };

  def.loadIssueResources = function (divisions) {
    var list = this.root.find('.resources-list');
    list.empty();
    var newElements = '';
    var isEditable = this.root.find('.estimation').length === 1
    $.each(divisions, function (key, value) {
      newElements += this.createDivisionElement(isEditable, value);
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
    this.initializeSelect2();
  };

  def.reloadIssueResources = function (response) {
    this.loadIssueResources(response.divisions);
    this.loadAvailableResources(response.resources);
    this.makeEstimationsEditable();
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

  def.updateInitialEstimationField = function (response) {
    var id = this.root.find('.custom_field_id').val();
    var total = response.total;
    var textField = $('td.cf_' + id);
    var input = $('input#issue_custom_field_values_' + id);
    textField.text(total);
    input.val(total);
    if (!response.editable) {
      input.attr('readonly', 'readonly');
    }
  };

  def.addDeleteEvents = function () {
    var buttons = this.root.find('a.remove');
    buttons.on('click', function (event) {
      event.preventDefault();
      var target = $(event.target);
      var id = target.data('id');
       $.ajax({
        data: { key: this.root.find('.api-key').val() },
        dataType: 'json',
        type: 'DELETE',
        url: '/issue_resources/' + id
      }).done(function (response) {
        this.removeIssueResourceElement(target);
        this.loadAvailableResources(response.resources);
        this.updateInitialEstimationField(response);
      }.bind(this)).fail(function (response) {
        console.log('Failed to delete issue resource!');
      }.bind(this));
    }.bind(this));
  };

  def.createIssueResource = function() {
    var data = { key: this.root.find('.api-key').val(),
      issue_resource: {
        issue_id: this.root.find('.issue-id').val(),
        estimation: this.root.find('.estimation').val(),
        resource_id: this.root.find('.resource-id').select2('val')
    }};
    $.ajax({
      data: data,
      dataType: 'json',
      type: 'POST',
      url: '/issue_resources'
    }).done(function (response) {
      this.reloadIssueResources(response);
      this.updateInitialEstimationField(response);
    }.bind(this)).fail(function (response) {
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

  def.initializeSelect2 = function () {
    this.root.find('select#resource_id').select2({ width: '90px',
      placeholder_text_single: 'Select' });
  };

  def.hoursAreValid = function (hours) {
    if (isNaN(hours)) {
      alert('Resource estimation is not a number!');
      return false;
    }
    if (hours <= 0) {
      alert('Resource estimation must be greater than 0!');
      return false;
    }
    if (!(parseFloat(hours) === parseInt(hours))) {
      alert('Resource estimation must be an integer!');
      return false;
    }
    return true;
  };

  def.editIssueResourceElement = function (field, value) {
    var oldValue = parseInt(field.data('value'));
    var hours = parseInt(value);
    if (oldValue === hours) { return oldValue };
    if (this.hoursAreValid(hours)) {
      var id = field.data('id');
      var data = { key: this.root.find('.api-key').val(),
        issue_resource: {
          issue_id: this.root.find('.issue_id').val(),
          estimation: value
      } }
      $.ajax({
        data: data,
        type: 'PUT',
        url: '/issue_resources/' + id
      }).done(function (response) {
        this.updateInitialEstimationField(response);
      }.bind(this)).fail(function (reason) {
        alert('Could not update issue resource!');
      });
      field.data('value', hours);
      return hours;
    } else {
      return oldValue;
    }
  };

  def.makeEstimationsEditable = function () {
    var elements = this.root.find('.hours.editable');
    var settings = { onblur: 'submit', tooltip: 'Click to edit.',
      'event': 'editable' }
    var self = this;
    elements.editable(function (value) {
      return self.editIssueResourceElement($(this), value);
    }, settings);
    this.root.find('.estimation-cell').on('click', function (event) {
      var target = $(event.target);
      var editable = target.find('.hours.editable');
      if (editable.length === 0 && target.hasClass('editable')) {
        editable = target;
      }
      editable.trigger('editable');
      var input = target.find('input');
      input.focus().select();
    }.bind(this));
  };

  def.initialize = function () {
    this.addButtonEvents();
    this.makeEstimationsEditable();
    this.initializeSelect2();
  };

  return self;
}(ResourceWindow, $));

$(function () {
  var resourceWindow = new ResourceWindow('#resources');
  var manuallEstimated = $('#manually_estimated').val();
  if (manuallEstimated === 'true') {
    var id = $('.custom_field_id').val();
    var input = $('input#issue_custom_field_values_' + id);
    input.attr('readonly', 'readonly');
  }
});
