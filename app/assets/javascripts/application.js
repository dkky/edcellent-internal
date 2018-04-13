// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.

//= require jquery
//= require jquery_ujs
//= require moment
//= require fullcalendar
//= require fullcalendar/gcal
//= require turbolinks
//= require bootstrap-sprockets
//= require filterrific/filterrific-jquery
//= require daterangepicker
//= require bootstrap-material-datetimepicker
//= require bootstrap-wysihtml5
//= require bootstrap-datepicker
//= require select2
//= require select2-full


// $modal.on('hidden', function () {
//   $('.modal-backdrop').remove();
// });
  
// $(document).ready(function() {
//   console.log( "ready!" );
//   $(".modal").on("hidden.bs.modal", function () {
//     debugger
//   });
//   $('.modal').on('shown.bs.modal', function () {
//     alert('hehe')
//   });
// });

var initialize_calendar;
initialize_calendar = function() {
  $('#f-calendar').each(function(){
    var calendar = $(this);
    calendar.fullCalendar({
      minTime: "07:00:00",
      maxTime: "22:30:00",
      buttonText: {
        listWeek: 'list - week',
        listDay: 'list - day',
      },
      header: {
          center: 'agendaWeek,month,listWeek,listDay, listView' // buttons for switching between views
      },
      views: {
          agenda7Day: {
              type: 'agenda',
              duration: { days: 7 },
              buttonText: '7 days'
          }
      },
      events: '/periods.json',
      editable: true, 
      droppable: true,
      selectable: true,
      selectHelper: true,
      defaultView: 'agendaWeek',
      firstDay: 1,
      select: function(start, end) {
        $.getScript('/newmodal', function() {
          $('.modal_start_time').val(moment(start).format('YYYY-MM-DD HH:mm'));
          $('.modal_end_time').val(moment(end).format('YYYY-MM-DD HH:mm'));
        });
        calendar.fullCalendar('unselect');
      },
      eventRender: function(event, element) { 
        element.find(".fc-time").remove();
        element.find('.fc-title').append("<br/>" + moment(event.start).format("HH:mm")  + '-' + moment(event.end).format("HH:mm") + "<br/>"); 
        element.find('.fc-list-item-title').append(event.tutor + 
          "<br/>" + 
          event.student
        ); 
        element.find('.fc-content').append(
          '<a href="' + event.destroy_url + 
          '" data-remote=true data-method=delete>' + 
          '  ' + 
          event.icon +  
          '</a>' + 
          '  TUTOR: ' + 
          event.tutor + 
          "<br/>" + 
          event.student +
          "<br/>" + event.session_number
        ); 
      },
      eventDrop: function(event, delta, revertFunc) {

        alert("You're changing your lesson: " + event.description + " to " + event.start.format('YYYY-MM-DD HH:mm'));

        if (!confirm("Are you sure about this change?")) {
            revertFunc();
        }
        $.ajax({
          type: 'GET',
          url: '/periods/calendar/drop/' + event.id,
          dataType: 'json',
          data: { 
            period: { 
              start_time: event.start.format(), 
              end_time: event.end.format()
            } 
          }
        });
      },
      eventClick: function(event, jsEvent, view) {
        // $('.fc-content').on('click', function(e) {
        //   console.log('asa')
        //   if (e.target != this)
        //     return;
          $.getScript(event.edit_url, function() {
            // $('#event_date_range').val(moment(event.start).format("MM/DD/YYYY HH:mm") + ' - ' + moment(event.end).format("MM/DD/YYYY HH:mm"))
            // date_range_picker();
            // $('.start_hidden').val(moment(event.start).format('YYYY-MM-DD HH:mm'));
            // $('.end_hidden').val(moment(event.end).format('YYYY-MM-DD HH:mm'));
          });
        // });
      }
    });
  })
};


function clearCalendar() {
  $('#f-calendar').fullCalendar('delete'); // In case delete doesn't work.
  $('#f-calendar').html('');
};

$(document).on('turbolinks:load', initialize_calendar);
$(document).on('turbolinks:before-cache', clearCalendar);


