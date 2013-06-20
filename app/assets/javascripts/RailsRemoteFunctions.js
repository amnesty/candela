/*
 * Examples: 
 *  addAutocompleteInputCallback('interested_cp', '/city_for_cp', 'cp', 'interested_city');
 *  addAutocompleteInputCallback('interested_cp', '/provinces_for_cps', 'cp', 'interested_province_id');
 *  addAutocompleteInputCallback('interested_province_id', '/cities_for_province', 'province_id', 'interested_city');
 *  addAutocompleteInputCallback('interested_city', '/cp_for_city', 'city_id', 'interested_cp');
 *  addAutocompleteInputCallback('interested_local_organization_id', '/auto_complete/talks_as_options_for_interesteds', 'local_organization_id', 'interested_talk_ids');
 *
 */

function addAutocompleteInputCallback(triggerElementId, ajaxUrl, requestParamName, updatedElementId, afterSuccess) {
  $(document).ready(function() {
    $('#'+triggerElementId).on("change", function(e) {
      e.preventDefault();
      performInputAutocomplete(ajaxUrl, requestParamName+'='+e.target.value, updatedElementId, afterSuccess)
    });
  });
}

function performInputAutocomplete(ajaxUrl, requestParams, updatedElementId, afterSuccess) {

  updatedElement = $('#'+updatedElementId);
  updatedElement.addClass('loading');

  $.ajax({
    url: ajaxUrl,
    async: false,
    method: 'get',
    dataType: 'html',
    data: requestParams, 
    success: function(data) {
      updatedElement.removeClass('loading');
      if (updatedElement.attr('type') == 'text')
        updatedElement.val(data);
      else // Discarded all other options, select input is assumed
        updatedElement.empty().append(data);
      if (afterSuccess){
        afterSuccess();
      }
    },
    error: function(xhr,exception,status) {
      //TODO: catch any errors here
      updatedElement.removeClass('loading');
    }
  });
}

/*
 * Performs an ajax call to fill data for specified performance
 *
 */
function updateFollowingPerformance(linkElementId,updatedElementId,ajaxUrl){
  linkElement = $('#'+linkElementId);
  updatedElement = $('#'+updatedElementId);
  linkElement.removeClass('action_view');
  linkElement.addClass('loading'),

  $.ajax({
    url: ajaxUrl,
    async: false,
    method: 'get',
    dataType: 'html',
//        data: requestParamName+'='+e.target.value, 
    success: function(data) {
      linkElement.removeClass('loading');
      linkElement.addClass('action_view');
      updatedElement.html(data);
    },
    error: function(xhr,exception,status) {
      //TODO: catch any errors here
alert('Error in updateFollowingPerformance()!!');
      linkElement.removeClass('loading');
      linkElement.addClass('action_view');
    }
  });
}

