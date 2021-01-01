var colorpicker = {
  init: function(){
    $("input[type='text'].colorpicker").colorpicker()
      .on('changeColor.colorpicker', function(event){
        var bgColor = event.color.toHex();
        if ($(event.target).val() == '') { bgColor = 'white'; }

        $(event.target)
          .css('background-color', bgColor)
          .css('color', colorpicker.colorOnRGB(event.color.toRGB()));
      });
  },

  colorOnRGB: function(rgb) {
    var
      red   = rgb.r,
      green = rgb.g,
      blue  = rgb.b;

    var color = 'black';
    if ((red * 0.299 + green * 0.587 + blue * 0.114) < 186) {
      color = 'white';
    }
    return color;
  }
}

$(function(){ colorpicker.init() });
