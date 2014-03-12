$(document).ready(function() {
  add_inline_editing();          
});

function add_inline_editing() {
  $('.resource_estimation').each(function(element) {
    var $editable_element = $(this);
    var id = $editable_element.data('resource-id');
    $editable_element.editable('/issue_resources/' + id, {
        method : 'PUT',
        ajaxoptions : {type : 'PUT'},
        name : 'issue_resource[estimation]',
        tooltip   : "Click to edit...",
        'event' : 'editable'
    });
    $('#cell-' + id).live('click', function() {
      $editable_element.trigger('editable');
      $('input', $editable_element).trigger('focus').trigger('select');

    })
  });
}