/*TODO: Uncomment each function when needed, to have some control over what code is used and how... */

/*** Attached image preview on forms ***/

  function initializeImageAttachmentFormElement(containerSelector) {
    var fileInput = $(containerSelector + ' input[type="file"]');
    fileInput.on('change', function() {
      var files = this.files;
      var file = files[0];
      var previewContainer = $(containerSelector + ' .image-preview-container');
      var imgElem = $(containerSelector + ' .image-preview-container img');

      // Only process image files.
      if (file.type.match('image.*')) {
        var reader = new FileReader();
        reader.onload = (function(theFile) {
          return function(e) {
            imgElem[0].src=e.target.result;
            previewContainer.removeClass('no-image');
            previewContainer.addClass('with-image');
          };
        })(file);

      // Read in the image file as a data URL.
      reader.readAsDataURL(file);
      }  
    
    });
  }

/*** Default configuration for jQuery datepicker ***/

$.datepicker.setDefaults($.datepicker.regional["es"]);
$.datepicker.setDefaults({
      dateFormat: 'dd-mm-yy',
      changeMonth: true,
      changeYear: true,
      yearRange: "-100:+1"
});


/*** CVS export for search results ***/

        function performCSVSearch(link) {
          csvParams    = $('input.search_csv_param');
          activeParams = [];
          csvParams.each(function() {
            if(this.checked) {
              activeParams.push(this.value);
            }
          });
          activeParamsString = activeParams.join(',')
          searchUrl = link.href + '&csv_params=' + activeParamsString;

          $('#csv_export_button').addClass('loading'); 
          var elemIF = document.createElement("iframe");
          elemIF.onload = function(){$('#csv_export_button').removeClass('loading')};
          elemIF.src = searchUrl;
          elemIF.style.display = "none";
          document.body.appendChild(elemIF); 
       }

        function performCSVSearch_old(link) {
          searchUrl    = link.href;
          csvParams    = $('input.search_csv_param');
          activeParams = [];
         csvParams.each(function(checkBox) {
            if(checkBox.checked) {
              activeParams.push(checkBox.value);
            }
          });
          activeParamsString = activeParams.join(',')
          document.location = searchUrl + '&csv_params=' + activeParamsString;
        }

        function csvParamToggleAll(to) {
          csvParams    = $('input.search_csv_param');
          csvParams.each(function() {
            if(to == 'active') {
              this.checked = true;
            } else {
              this.checked = false;
            }
          });
        }

/*** Fits the size of a list to suit its components ***/

  function fitListSizeToContents(boxId,maxSize) {
    box = document.getElementById(boxId);
    numElems = box.options.length;
    if (numElems > maxSize)
      box.size = maxSize;
    else
      box.size = numElems;
  }

/*** Collapsible sections: Showing/hiding elements associated to clicks on a DOM element ***/
  
  $(document).on("click", ".collapsable_section_control", function() {
    $(this).closest('.collapsable_section').toggleClass('collapsed');
  });

/*** Hideable groups: Showing/hiding elements associated to a form input ***/

function registerHideableGroup(chkBoxId, hideableGroupSelector, showValue, displayAttribute){

  $('#'+chkBoxId).on("change", function(e) {
      e.preventDefault();
      checkHideableGroupById(chkBoxId, hideableGroupSelector, showValue, displayAttribute);
    });
  
  $(document).ready(function(){
    checkHideableGroupById(chkBoxId, hideableGroupSelector, showValue, displayAttribute);
  });

}

function checkHideableGroupById(chkBoxId, hideableGroupSelector, showValue, displayAttribute){
  
  chkBox = document.getElementById(chkBoxId);
  if (chkBox)
    checkHideableGroup(chkBox, hideableGroupSelector, showValue, displayAttribute);
}

function checkHideableGroup(formInput, hideableGroupSelector, showValue, displayAttribute){

  var curValue;
  if (formInput.type=='checkbox')
    curValue = formInput.checked;
  else 
    curValue = formInput.value;

  if (curValue == showValue)
    $(hideableGroupSelector).show();
  else
    $(hideableGroupSelector).hide();
}

///*** Floating nested menus ***/

//function toggleSubmenu(topElement, subMenuId, pos){
//  subMenu = $(subMenuId);
//  if (pos == null)
//    pos = 'down';

//  if (pos=='down'){
//    subMenu.clonePosition(topElement, { offsetTop:topElement.getHeight(), setHeight:false, setWidth:false });
//  } else if (pos=='right') {
//    subMenu.clonePosition(topElement, { offsetLeft:topElement.getWidth(), setHeight:false, setWidth:false });
//  } else if (pos=='none'){
//    subMenu.clonePosition(topElement, { setHeight:false, setWidth:false });
//  }
//  subMenu.toggle();

//}

//function getOffset( el ) {
//    var _x = 0;
//    var _y = 0;
//    while( el && !isNaN( el.offsetLeft ) && !isNaN( el.offsetTop ) ) {
//        _x += el.offsetLeft - el.scrollLeft;
//        _y += el.offsetTop - el.scrollTop;
//        el = el.offsetParent;
//    }
//    return { top: _y, left: _x };
//}

/*** ACTIVISTS FILTERING (complement to helper SummaryHelper::summary_collaborations_for_section_for)***/

var activistFilterHash = {};

function initActivistFilters(activeFilters){
  if (activistFilterHash == null)
    activistFiltersHash = {};

  for (var i = 0; i < activeFilters.length; i++) {
    modifyActivistFilter(activeFilters[i],$('#activist_filter_'+activeFilters[i]));
  }
}

function modifyActivistFilter(filterName,input){

  if (input.val()==""){
    delete activistFilterHash[filterName];
  }
  else{
    activistFilterHash[filterName] = input.val();
  }

  input.removeClass();
  input.addClass(input.find(":selected").attr("class"));
  updateActivistsList();
}

function checkActivistFilter(elem){
  ret = true;
  for (var key in activistFilterHash) {
    if (!elem.hasClass(activistFilterHash[key])) {
      ret = false;
      return;
    }
  };
  return ret;
}

function updateActivistsList() {
  $('#organization_activists_list').children().each(function() {
    elem = $(this)
    if (checkActivistFilter(elem)) {
      elem.show();
    }
    else {
      elem.hide();
    }
  });

  var filteredItemsCount = $('#organization_activists_list li:visible').length;
  $('#organization_activists_list_counter').text( $('#organization_activists_list_counter').data('base-text').replace("{count}", filteredItemsCount) );
}

/*** POSTAL STUFF ***/

function copy_to_postal(organization_type) {
  var address              = document.getElementById(organization_type + '_address');
  var cp                   = document.getElementById(organization_type + '_cp');
  var province_id          = document.getElementById(organization_type + '_province_id');
  var city                 = document.getElementById(organization_type + '_city');
  var postal_address       = document.getElementById(organization_type + '_postal_address');
  var postal_cp            = document.getElementById(organization_type + '_postal_cp');
  var postal_province_id   = document.getElementById(organization_type + '_postal_province_id');
  var postal_city          = document.getElementById(organization_type + '_postal_city');
  
  postal_address.value     = address.value;
  postal_cp.value          = cp.value;
  postal_province_id.value = province_id.value;
  
  for( opt = postal_city.length-1; opt >=0;  opt-- ) {
    postal_city.remove(opt);
  }
  for( opt = 0; opt < city.length; opt++ ) {
    postal_city.options.add( new Option(city.options[opt].text, city.options[opt].value, city.options[opt].defaultSelected, city.options[opt].selected ) );
  }
  postal_city.selectedIndex = city.selectedIndex;
}

function clear_postal(organization_type) {
  var postal_address       = document.getElementById(organization_type + '_postal_address');
  var postal_cp            = document.getElementById(organization_type + '_postal_cp');
  var postal_province_id   = document.getElementById(organization_type + '_postal_province_id');
  var postal_city          = document.getElementById(organization_type + '_postal_city');
  
  postal_address.value     = '';
  postal_cp.value          = '';
  postal_province_id.value = '';
  
  for( opt = postal_city.length-1; opt >=0;  opt-- ) {
    postal_city.remove(opt);
  }
}

function copy_to_delivery(organization_type) {
  
  var postal_address         = document.getElementById(organization_type + '_postal_address');
  var postal_cp              = document.getElementById(organization_type + '_postal_cp');
  var postal_province_id     = document.getElementById(organization_type + '_postal_province_id');
  var postal_city            = document.getElementById(organization_type + '_postal_city');
  var delivery_address       = document.getElementById(organization_type + '_delivery_address');
  var delivery_cp            = document.getElementById(organization_type + '_delivery_cp');
  var delivery_province_id   = document.getElementById(organization_type + '_delivery_province_id');
  var delivery_city          = document.getElementById(organization_type + '_delivery_city');
  
  delivery_address.value     = postal_address.value;
  delivery_cp.value          = postal_cp.value;
  delivery_province_id.value = postal_province_id.value;
  
  for( opt = delivery_city.length-1; opt >=0;  opt-- ) {
    delivery_city.remove(opt);
  }
  
  for( opt = 0; opt < postal_city.length; opt++ ) {
    delivery_city.options.add( new Option(postal_city.options[opt].text, postal_city.options[opt].value, postal_city.options[opt].defaultSelected, postal_city.options[opt].selected ) );
  }
  delivery_city.selectedIndex = postal_city.selectedIndex;
}

function clear_delivery(organization_type) {
  var delivery_address     = document.getElementById(organization_type + '_delivery_address');
  var delivery_cp          = document.getElementById(organization_type + '_delivery_cp');
  var delivery_province_id = document.getElementById(organization_type + '_delivery_province_id');
  var delivery_city        = document.getElementById(organization_type + '_delivery_city');
  
  delivery_address.value = '';
  delivery_cp.value = '';
  delivery_province_id.value = '';
  
  for( opt = delivery_city.length-1; opt >=0;  opt-- ) {
    delivery_city.remove(opt);
  }
}

function unCheckAllBut( number, fldName ) {
  if (!fldName) {
     fldName = 'cb';
  }
  var f = document.indexForm;
  for (i=0; i < 20; i++) {
    if( i == number )
      continue;
    cb = eval( 'f.' + fldName + '' + i );
    if (cb) {
      cb.checked = false;
    } else {
      break;
    }
  }
}

function submitform(pressbutton, fldName ){
  var f = document.indexForm;
  if (!fldName) {
      fldName = pressbutton + '_';
  }
  cb = eval( 'f.' + fldName + '' + document.indexForm.boxchecked.value );
  if( cb ) {
    this.location.href = cb.value;
  }
}


function setChecked(object, number, fldname){
  unCheckAllBut(number, fldname)
  if (object.checked == true){
    document.indexForm.boxchecked.value = number;
  }
  else {
    document.indexForm.boxchecked.value = -1;
  }
}



//function setCurrentTab() {
//  toggleable_elements = $$('.toggleable_div_content');
//  location_split = location.href.split('#')
//  // default first tab
//  active_tab = toggleable_elements[0].id.replace(/toggleable_div_/,'');


//  // #parameter come, check if tab exist
//  if(location_split != location.href) {
//    for (var i = 0; i < toggleable_elements.length; i++) {
//      if(toggleable_elements[i].id.replace(/toggleable_div_/,'') == location_split[1]) {
//        active_tab = location_split[1];
//      }
//    }
//  }

//  // active and return it
//  showTab(active_tab);
//  return active_tab;
//}

//function showTab(which_one) {
//  if(last_tab) {
//    //remove active style and div display
//    $('toggleable_link_' + last_tab).removeClassName('active');
//    $('toggleable_div_' + last_tab).hide();
//  }
//  $('toggleable_link_' + which_one).addClassName('active');
//  $('toggleable_div_' + which_one).show();
//  last_tab = which_one;
//}


//function optionsUpdater(update_url, update_select_id) {
//  $(update_select_id).addClassName('loading');
//  new Ajax.Updater(update_select_id, update_url, {
//      method: 'get',
//      asynchronous:true,
//      on404: function () { alert('Ocurrió un error inesperado en la llamada a ' + update_url) },
//      onSuccess: function(transport) { $(update_select_id).removeClassName('loading');   }
//      });
//}



function toggleCheckedOf(checked, klass) {
  
  checkboxs = Array();
  
  if(klass == 'ALL') {
    checkboxs = $('input.check_box_permission')
  } else {
    checkboxs = $('input.check_box_permission_' + klass)
  }
  for (var i = 0; i < checkboxs.length; i++) {
    checkboxs[i].checked = checked;
  }
  
}

//var loaded_page_time = new Date();


//function time_expire() {
//  time_now = new Date();

//  if((time_now - loaded_page_time) > 1740000) { //inactivity after 30 minutes, send message 1 minute before
//    alert('Esta página lleva 29 minutos de inactividad. La aplicación cerrará su sesión en un minuto salvo que realize alguna consulta.');
//  } else {
//    window.setTimeout('time_expire()', 20000);
//  }
//}

//current_location = String(document.location);
//if(!current_location.include('create_interested') && !current_location.include('form_voluntariado')) {
//  time_expire();
//}





//function inspect(obj, maxLevels, level)
//{
//  var str = '', type, msg;

//    // Start Input Validations
//    // Don't touch, we start iterating at level zero
//    if(level == null)  level = 0;

//    // At least you want to show the first level
//    if(maxLevels == null) maxLevels = 1;
//    if(maxLevels < 1)     
//        return '<font color="red">Error: Levels number must be > 0</font>';

//    // We start with a non null object
//    if(obj == null)
//    return '<font color="red">Error: Object <b>NULL</b></font>';
//    // End Input Validations

//    // Each Iteration must be indented
//    str += '<ul>';

//    // Start iterations for all objects in obj
//    for(property in obj)
//    {
//      try
//      {
//          // Show "property" and "type property"
//          type =  typeof(obj[property]);
//          str += '<li>(' + type + ') ' + property + 
//                 ( (obj[property]==null)?(': <b>null</b>'):('')) + '</li>';

//          // We keep iterating if this property is an Object, non null
//          // and we are inside the required number of levels
//          if((type == 'object') && (obj[property] != null) && (level+1 < maxLevels))
//          str += inspect(obj[property], maxLevels, level+1);
//      }
//      catch(err)
//      {
//        // Is there some properties in obj we can't access? Print it red.
//        if(typeof(err) == 'string') msg = err;
//        else if(err.message)        msg = err.message;
//        else if(err.description)    msg = err.description;
//        else                        msg = 'Unknown';

//        str += '<li><font color="red">(Error) ' + property + ': ' + msg +'</font></li>';
//      }
//    }

//      // Close indent
//      str += '</ul>';

//    return str;
//}

/*** SEARCH FORM STUFF ***/

function onActivistSearchCollaborationOrganizationTypeChange(ctrl,ev)
{
  var organizationTypeInput = $('#activist_activists_collaborations_organization_type_eq');
  var groupTypeInput = $('#activist_with_collaborations_on_group_type');
  var organizationIdInput = $('#activist_activists_collaborations_organization_id_eq');
  var groupTypeRow = groupTypeInput.closest('tr');
  var organizationProvinceIdInput = $('#activist_activists_collaborations_organization_of_LocalOrganization_type_province_id_in');  
  var organizationProvinceIdRow = organizationProvinceIdInput.closest('tr');

  if (!organizationTypeInput.val())
  {
    organizationIdInput.find('option').remove().end().append('<option value=""></option>');
  }  
    
  if (organizationTypeInput.val() == 'LocalOrganization')
  {
    groupTypeRow.show();
    organizationProvinceIdRow.show();
  }
  else
  {
    groupTypeInput.val('');
    groupTypeRow.hide('');
    organizationProvinceIdInput.val('');
    organizationProvinceIdRow.hide('');    
  }
  
  var autonomicTeamsInput = $('#activist_activists_collaborations_autonomic_teams_id_eq'); 
  var autonomicTeamsRow = autonomicTeamsInput.closest('tr');
  if (organizationTypeInput.val() == 'Autonomy')
  {
    autonomicTeamsRow.show();
  }
  else
  {
    autonomicTeamsInput.val('');
    autonomicTeamsRow.hide('');
  }  
}
