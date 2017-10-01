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
//= require bootstrap-sprockets
//= require filterrific/filterrific-jquery
//= require bootstrap-material-datetimepicker
//= require select2

// AIzaSyB1iR2eo3a_Ewc_kH6Yns1u0bPqKvpaEGI

// $(document).ready(function() {
//   debugger
//   $('#f-calendar').fullCalendar({
//       googleCalendarApiKey: 'AIzaSyB1iR2eo3a_Ewc_kH6Yns1u0bPqKvpaEGI',
//       events: {
//         googleCalendarId: 'noone.knowu@gmail.com',
//         className: 'gcal-event' // an option!
//       },
//       eventRender: function(event, element) { 
//       element.find(".fc-time").remove();
//       element.find('.fc-title').append("<br/>" + moment(event.start).format("HH:mm")  + '-' + moment(event.end).format("HH:mm") + "<br/>"); 
//       element.find('.fc-list-item-title').append(event.tutor + "<br/>" + event.student); 
//       element.find('.fc-content').append('TUTOR: ' + event.tutor + "<br/>" + event.student); 
//     },
//   });
// });

$(document).ready(function() {
  $('#f-calendar').fullCalendar({
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
    eventColor: '#669999',
    events: '/periods.json',
    editable: true, 
    droppable: true,
    defaultView: 'month',
    eventRender: function(event, element) { 
      element.find(".fc-time").remove();
      element.find('.fc-title').append("<br/>" + moment(event.start).format("HH:mm")  + '-' + moment(event.end).format("HH:mm") + "<br/>"); 
      element.find('.fc-list-item-title').append(event.tutor + "<br/>" + event.student); 
      element.find('.fc-content').append('TUTOR: ' + event.tutor + "<br/>" + event.student); 
    },
    eventDrop: function(event, delta, revertFunc) {

        alert("You're changing your lesson: " + event.description + " to " + event.start.format());

        if (!confirm("Are you sure about this change?")) {
            revertFunc();
        }
        $.ajax({
          type: 'PUT',
          url: '/periods/' + event.id,
          dataType: 'json',
          data: { lesson: { start_time: new Date(event.start).toUTCString(), end_time: new Date(event.end).toUTCString()  } }
        });
    }
  });
});

