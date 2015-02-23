$(document).ready(function() {
  add_inline_editing();
  $('#issue-form').bind('submit', function(e){
    var next_status_id = $('#issue_status_id').val();
    if ((next_status_id != current_status_id) &&
        ($.inArray(parseInt(next_status_id), window.issue_workflow_list) != -1) &&
        $('#has_resources').val() == '0') {
      alert('You need to add estimation before moving to this status.');
      $('#estimation').focus();
      e.preventDefault();
      $(e.target).removeAttr('data-submitted');
      return false;
    }
  });

  $('#new_issue_resource').bind('submit', function() {
    $('input.button', $(this)).attr('disabled', true);
    return true;
  });

  window.current_status_id = $('#issue_status_id').val();
});

function add_inline_editing() {
  $('.resource_estimation_editable').each(function(element) {
    var $editable_element = $(this);
    var id = $editable_element.data('resource-id');
    $editable_element.editable('/issue_resources/' + id, {
        onblur: 'submit',
        method: 'PUT',
        ajaxoptions: {type : 'PUT'},
        name: 'issue_resource[estimation]',
        tooltip: "Click to edit...",
        'event': 'editable',
        callback: function(values, setting){
          var estimation = 0
          $('.estimation_cell .resource_estimation').each(function(index) {
            estimation += parseInt($(this)[0].innerHTML);
          });
          $('.issue-attributes td.estimated-hours')[0].innerHTML=estimation+'.00 hours';
          $('#issue-form #issue_estimated_hours').val(estimation+'.0');
        }
    });
    $('#cell-' + id).on('click', function() {
      $editable_element.trigger('editable');
      $('input', $editable_element).trigger('focus').trigger('select');
    })
  });
}
