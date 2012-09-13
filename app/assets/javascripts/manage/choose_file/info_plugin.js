// Добавление loader и блокировка ссылки
$.fn.add_loader_and_lock = function(){
  $(this).append($('<span/>', { class: 'ajax_loading' }));
  $(this).addClass('clicked');
};

// Создание диалога
$.fn.create_or_return_dialog = function(class_name){
  var clicked_link = $(this);
  var container = $('#'+class_name);

  if (container.length == 0) {
    $('<div/>', { id: class_name }).appendTo('body').dialog({
      autoOpen: false,
      draggable: false,
      height: '468',
      modal: true,
      position: 'center',
      resizable: false,
      title: 'Выбор файла',
      width: '855',
      beforeClose: function(event, ui){
        $('body').css({ overflow: 'inherit' });
        remove_ajax_and_unblock_link();
      }
    });
  };

  return $('#'+class_name);
};

// Загрузка iframe в диалог
$.fn.load_iframe = function(params){
  var dialog = $(this);
  dialog.dialog({height: '468'});
  dialog.html(
      $('<iframe/>',
        {
          height: '402',
          scrolling: 'no',
          src: '/el_finder?'+params,
          width: '821'
        }
      ).load(function(){
        dialog.open_dialog();
      })
  )
};

// Показать диалог
$.fn.open_dialog = function(){
  remove_ajax_and_unblock_link();
  $('body').css({ overflow: 'hidden' });
  $(this).dialog('open');
};

$.fn.create_or_return_ckeditor = function(){
  var dialog = $(this);
  var dialog_id = dialog.attr('id');
  var ckeditor_instance = CKEDITOR.instances['editor1'];

  if (!ckeditor_instance){
    ckeditor_instance = CKEDITOR.appendTo(
                          dialog_id,
                          {
                            height: '320',
                            width: '830',
                            resize_enabled: false
                          }
                        );
  };

  return ckeditor_instance;
};

$.fn.save_file_content = function(common_path, info_path){
  var dialog  = $(this);
  var content = CKEDITOR.instances['editor1'].getData();
  var path_object = get_file_name_and_hash(info_path);

  $('.error_messages').remove();
  $('.ui-dialog-buttonset').append($('<span/>', { class: 'ajax_loading', style: 'float: left; margin: 10px 5px 0 0;' }));

  $.post(common_path+'&root_path='+path_object.info_path+'&cmd=put&target=r1_'+path_object.file_name_hash, { content: content })
    .success(function(){
      dialog.dialog('close');
      show_content(content);
    })
    .error(function(){
      $('.ui-dialog-buttonset')
        .append('<span style="color:red; float: left; margin: 10px 5px 0 0;" class="error_messages">Ошибка при сохранении! Обратитесь в службу поддержки.</span>');
    })
    .complete(function(){remove_ajax_and_unblock_link()});
};

$.fn.get_file_content = function(common_path, info_path, ckeditor){
  var dialog = $(this);
  // Получить путь к папке, имя файла и base64 хеш файла
  var path_object = get_file_name_and_hash(info_path);
  var file_name = path_object.file_name;
  var file_name_hash = path_object.file_name_hash;
  info_path = path_object.info_path;

  // Открыть папку
  $.get(common_path+'&root_path='+info_path+'&cmd=open&init=1', function(folder_data){
    var files  = folder_data.files;
    var folder = folder_data.cwd;
    var file_content = '';
    var need_create_index_html = true;

    // Посмотреть есть ли файл
    $(files).each(function(index, file){
      if (file.hash.match(file_name_hash)){
        need_create_index_html = false;
        // Загрузить файл в CKEditor
        $.get(common_path+'&root_path='+info_path+'&cmd=get&target='+file.hash, function(file_data){
          file_content = file_data.content;
          ckeditor.setData(file_content);
          dialog.open_dialog();
        });
        return false;
      }
    });

    // Создать файл если его нет
    if (need_create_index_html){
      $.get(common_path+'&root_path='+info_path+'&cmd=mkfile&name='+file_name+'&target='+folder.hash, function(file_data){
        dialog.open_dialog();
      });
    };
  });
};

function get_file_name_and_hash(info_path){
  var file_name = info_path.match(/[^\/]*?$/)[0];
  var file_name_hash = service({ encode: true, path_to_hash: file_name });
  info_path = info_path.replace(file_name, '');

  return {
           file_name: file_name,
           file_name_hash: file_name_hash,
           info_path: info_path
         };
};

function remove_ajax_and_unblock_link(){
  $('.ajax_loading').remove();
  $('.clicked').removeClass('clicked');
};

// Работа с service_controller
function service(params){
  var result = '';
  $.ajax({
    url: '/build_info_path',
    async: false,
    type: 'GET',
    data: params,
    success: function(data){
      result = data;
    }
  });

  return result;
};

function show_content(content) {
  $('.show_info_path').html(content);
};

// Вешаем обработку изменения поля info_path после callback из elFinder
$.fn.watch_for_callback_from_elFinder = function(){
  var dialog = $(this);
  $('#info_path').change(function(){
    var info_path_input = $(this);
    var info_path_hash  = info_path_input.val();

    // Декодировать hash из callback elFinder
    var info_path = service({ decode: true, path_hash: info_path_hash});

    // Записать в input
    info_path_input.val(info_path);
    info_path_input.unbind('change');

    dialog.dialog('close');
  });
};

//*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
$(function(){
  var create_edit_link = $('.info_link');
  var choose_link      = $('.choose_link');
  var info_path_input  = $('#info_path');
  var info_path        = info_path_input.val(); // Путь к файлу контента
  var common_path      = '/api/el_finder/v2?format=json';

  create_edit_link.click(function(){
    var parent_id = create_edit_link.attr('parent_data');
    var additional     = $('.for_info_path').val();

    $('.error_messages').remove();

    if (additional.length == 0){
      $('.info_wrapper').append('<span class="error_messages" style="float: right; color: red;">Заполните обязательные поля!!!</span>');
      remove_ajax_and_unblock_link();
      return false;
    };

    if ($(this).hasClass('clicked')) {
      return false;
    };
    // Добавить loader и заблокировать ссылку
    create_edit_link.add_loader_and_lock();

    // Создать диалог для CKEditor
    var dialog = create_edit_link.create_or_return_dialog('ckeditor_dialog');
    dialog.dialog({
      buttons: {
        'Сохранить': function(){
          dialog.save_file_content(common_path, info_path);
        },

        'Отмена': function(){
          dialog.dialog('close');
        }
      }
    });

    // Если нет info_path сгенерить
    if (info_path.length == 0){
      info_path = service({ parent_id: parent_id, additional: additional });
      info_path_input.val(info_path);
    };

    // Создать CKEditor
    var ckeditor = dialog.create_or_return_ckeditor();

    dialog.get_file_content(common_path, info_path, ckeditor);

    return false;
  });

  choose_link.click(function(){
    if ($(this).hasClass('clicked')) {
      return false;
    };
    // Добавить loader и заблокировать ссылку
    choose_link.add_loader_and_lock();

    // Создать диалог для elFinder
    var dialog = choose_link.create_or_return_dialog('elfinder_dialog');

    // Загрузить iframe elFinder в диалог и показать его
    dialog.load_iframe();

    // Повесить обработчик на callback elFinder
    dialog.watch_for_callback_from_elFinder();

    return false;
  });

});


